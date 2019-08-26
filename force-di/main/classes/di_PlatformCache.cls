public with sharing class di_PlatformCache 
{
    private di_PlatformCache() { }

    private static di_PlatformCache instance;

    public static di_PlatformCache getInstance()
    {
        if ( instance == null )
        {
            instance = new di_PlatformCache();
        }

        return instance;
    }

    private static di_Configurations__c getConfig()
    {
        di_Configurations__c config = di_Configurations__c.getInstance();

        if ( config == null )
        {
            config = new di_Configurations__c();
            config.SetupOwnerId = ConnectApi.Organization.getSettings().orgId;
            insert config;
        }

        return config;
    }

    public static Boolean isStoringBindingInPlatformCache()
    {
        return getConfig().UsePlatformCacheToStoreBindings__c == null ? false : getConfig().UsePlatformCacheToStoreBindings__c;
    }

    private static String getPartitionName()
    {
        return getConfig().OrgCachePartitionName__c;
    }

    private Integer getPartitionTTL()
    {
        return 86400; // number of seconds for a 24 hour period
    }

    private static Cache.OrgPartition getPartition()
    {
        return Cache.Org.getPartition(getPartitionName());
    }

    private Map<String, Map<Schema.SObjectType, Set<String>>> cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String>>>();

    public Map<String, Map<Schema.SObjectType, Set<String>>> getCacheKeyIndexMap()
    {
        if ( cacheKeyIndexMap.isEmpty() )
        {
            try {
                cacheKeyIndexMap = (Map<String, Map<Schema.SObjectType, Set<String>>>) getPartition().get( getKeyIndexName() );
            }
            catch (Cache.Org.OrgCacheException ex) {
                // this indicates a potentially corrupt cache, so clear the map and let it rebuild
                cacheKeyIndexMap = null;
            }

            if ( cacheKeyIndexMap == null )
            {
                cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String>>>();
            }
            
            /*
            for(String key : cacheKeyIndexMap.keySet()) {
                System.debug('Cache Key => ' + key);
                for (SObjectType subkey : cacheKeyIndexMap.get(key).keySet()) {
                    System.debug('Cache Key Index => ' + subkey);
                    for(String item : cacheKeyIndexMap.get(key).get(subkey)) {
                        System.debug('Cache Key Index Item => ' + item);
                    }
                }
            }
            */
        }

        return cacheKeyIndexMap;
    }

    private void pushCacheKeyIndexMapToCache()
    {
        getPartition().put( getKeyIndexName(), this.cacheKeyIndexMap, getPartitionTTL(), Cache.Visibility.ALL, false);
    }

    private void addBindingToKeyIndex(di_Binding binding)
    {
        String workingDeveloperName = binding.developerName.toLowerCase().trim();

        if ( ! getCacheKeyIndexMap().containsKey( workingDeveloperName ) )
        {
            getCacheKeyIndexMap().put(workingDeveloperName, new Map<Schema.SObjectType, Set<String>>() );
        }

        if ( ! getCacheKeyIndexMap().get(workingDeveloperName).containsKey( binding.bindingObject) )
        {
            getCacheKeyIndexMap().get(workingDeveloperName).put( binding.bindingObject, new Set<String>() );
        }

        getCacheKeyIndexMap().get(workingDeveloperName).get(binding.bindingObject).add(getKeyName(binding));

        pushCacheKeyIndexMapToCache();
    }

    private static Map<String, String> generatedKeyNames = new Map<String, String>();

    private String constructKeyName( Schema.SObjectType bindingSObjectType, String developerName )
    {
        String key = ( ( bindingSObjectType != null ) ? bindingSObjectType.getDescribe().getName().toLowerCase().replaceAll('__','') : '' ) 
                            + ( String.isBlank(developerName) ? '' : developerName.toLowerCase().trim() );

        // put generated hash into a map on first pass, so that we do not perform hashcode() operation more than once per "key"
        // hashcode() is a more expensive operation than map.get()
        if (generatedKeyNames.containsKey(key)) { return generatedKeyNames.get(key); }

        String hash = String.valueOf( Math.abs( ( key ).hashcode() ) );
        //System.debug('Creating Hash For => ' + developerName + ' && ' + bindingSObjectType + ' := ' + hash);
        generatedKeyNames.put(key, hash);
        return hash;
    }

    private String getKeyName( String developerName, Schema.SObjectType bindingSObjectType)
    {
        return constructKeyName( bindingSObjectType, developerName);
    }

    private String getKeyName( di_Binding binding )
    {
        return constructKeyName( binding.bindingObject, binding.developerName);
    }

    private String getKeyIndexName()
    {
        return 'bindingKeyIndex';
    }

    public void addBindingToPlatformCache( di_Binding binding )
    {
        if ( isStoringBindingInPlatformCache() )
        {
            String theKeyName = getKeyName(binding);
            // add the binding to the platform cache directly
            getPartition().put(theKeyName, binding, getPartitionTTL(), Cache.Visibility.ALL, false);
            // add the binding's cache key name to the bindingKeyIndex
            addBindingToKeyIndex(binding);
            //System.debug('Adding binding for hash => ' + theKeyName + ' && developerName => ' + binding.developerName + ' && object => ' + binding.bindingObject);
        }
    }

    public list<di_Binding> retrieveBindings(String developerName, Schema.SObjectType bindingSObjectType)
    {   
        list<di_Binding> bindings = new list<di_Binding>();

        if ( isStoringBindingInPlatformCache() )
        {
            //System.debug('Retrieving from Cache Key => ' + developerName + ' && Cache Key Index => ' + bindingSObjectType);

            Map<Schema.SObjectType, Set<String>> keyIndexBySObjectTypeMap = getCacheKeyIndexMap().get(developerName.toLowerCase().trim());
            if ( keyIndexBySObjectTypeMap != null )
            {
                Set<String> cacheKeys = keyIndexBySObjectTypeMap.get(bindingSObjectType);
                if ( cacheKeys != null )
                {
                    Object cachedObject = null;
                    for ( String cacheKey : cacheKeys )
                    {
                        cachedObject = getPartition().get( cacheKey );
                        if ( cachedObject != null ) 
                        {
                            bindings.add( (di_Binding) getPartition().get( cacheKey ) );
                        }
                    }
                }
            }
        }
           
        return bindings;
    }

    public static void clearCachedBindings() {
        String partitionKey = getPartitionName();
        Cache.OrgPartition partition = getPartition();
        // clear current bindings
        for (String key : partition.getKeys() ) {
            try {
                partition.remove(key);
            } catch (Exception ex) {
                System.debug('XX]> Unable to remove Platform Cache partition [' + partitionKey + '] key [' + key + ']');
            }
        }
    }
}