public with sharing class di_PlatformCache
{
    //////////////////////////////////////////////////////////////////////////////////////////////
    // Data Members
    //////////////////////////////////////////////////////////////////////////////////////////////
    // number of seconds for a 24 hour period
    public static final Integer NUM_OF_SECS_IN24HR =  86400;

    @TestVisible
    private static final String BINDING_KEY = 'bindingKeyIndex';
    private static di_PlatformCache instance;
    @TestVisible
    private Map<String, Map<Schema.SObjectType, Set<String> > > cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String> > >();
    @TestVisible
    private static Map<String, String> generatedKeyNames = new Map<String, String>();
    // Used for turning on logging (if needed)
    @TestVisible
    private static Boolean DEBUGGING = true;

    //////////////////////////////////////////////////////////////////////////////////////////////
    //  Constructors
    //////////////////////////////////////////////////////////////////////////////////////////////
    // singleton
    private di_PlatformCache() 
    {
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    //////////////////////////////////////////////////////////////////////////////////////////////
    public static di_PlatformCache getInstance()
    {
        if ( instance == null )
        {
            instance = new di_PlatformCache();
        }

        return instance;
    }

    public static Boolean isStoringBindingInPlatformCache()
    {
        return getConfig().UsePlatformCacheToStoreBindings__c == null ? false : ( getConfig().UsePlatformCacheToStoreBindings__c && getPartition() != null );
    }

    public Map<String, Map<Schema.SObjectType, Set<String>>> getCacheKeyIndexMap()
    {
        if ( cacheKeyIndexMap.isEmpty() )
        {
            try 
            {
                // if there IS NO Partition created; let's not FAIL
                Cache.OrgPartition orgPartition = getPartition();
                if ( orgPartition != null ) 
                {
                    cacheKeyIndexMap = (Map<String, Map<Schema.SObjectType, Set<String> > >) orgPartition.get( getKeyIndexName() );
                }
            }
            catch (Cache.Org.OrgCacheException ex) 
            {
                // this indicates a potentially corrupt cache, so clear the map and let it rebuild
                cacheKeyIndexMap = null;
            }

            if ( cacheKeyIndexMap == null )
            {
                cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String> > >();
            }
        }

        return cacheKeyIndexMap;
    }

    public Boolean addBindingToPlatformCache( di_Binding binding )
    {
        Boolean result = false;
        if ( isStoringBindingInPlatformCache() )
        {
            // if there IS NO Partition created; let's not FAIL
            Cache.OrgPartition orgPartition = getPartition();
            if ( orgPartition != null ) 
            {
                String theKeyName = getKeyName(binding);
                
                // add the binding to the platform cache directly
                List<di_Binding> workingBindings = new List<di_Binding>();

                // the binding may be a group of bindings.  
                //  if there are bindings already cached on this key... 
                if ( orgPartition.contains(theKeyName) )
                {
                    // ... then retrieve those bindings first 
                    workingBindings.addAll((List<di_Binding>) orgPartition.get(theKeyName));
                }
                // ... add the new binding to the working group.
                workingBindings.add( binding );
                log('Adding binding for hash => ' + theKeyName + ' && developerName => ' + binding.DeveloperName + ' && object => ' + binding.BindingObject);
                // ... then put the working list back in cache on this key
                try 
                {
                    orgPartition.put(theKeyName, workingBindings, getPartitionTTL(), Cache.Visibility.ALL, false);    
                }
                catch (Cache.Org.OrgCacheException oce)
                {
                    // there are some objects that cannot be serialized and thus cannot be stored in cache.  
                    //  in those situations, we simply bypass storing that object. 
                    log( oce );
                }

                // add the binding's cache key name to the bindingKeyIndex
                addBindingToKeyIndex(binding);
                // log('Adding binding for hash => ' + theKeyName + ' && developerName => ' + binding.developerName + ' && object => ' + binding.bindingObject);
                result = true;
            }
        }
        return result;
    }

    public List<di_Binding> retrieveBindings(String developerName, Schema.SObjectType bindingSObjectType)
    {
        List<di_Binding> bindings = new List<di_Binding>();

        if ( isStoringBindingInPlatformCache()
             && String.isNotBlank(developerName)
             && bindingSObjectType != null)
        {
            log('Retrieving from Cache Key => ' + developerName + ' && Cache Key Index => ' + bindingSObjectType);
            // if there IS NO Partition created; let's not FAIL
            Cache.OrgPartition orgPartition = getPartition();
            log('OrgPartition = ' + orgPartition);
            log('cacheKeyIndexMap = ' + getCacheKeyIndexMap());
            Map<Schema.SObjectType, Set<String> > keyIndexBySObjectTypeMap = getCacheKeyIndexMap().get(developerName.toLowerCase().trim());
            log('keyIndexBySObjectTypeMap = ' + keyIndexBySObjectTypeMap);
            if ( keyIndexBySObjectTypeMap != null && orgPartition != null )
            {
                Set<String> cacheKeys = keyIndexBySObjectTypeMap.get(bindingSObjectType);
                if ( cacheKeys != null )
                {
                    log('Found ' + cacheKeys.size() + ' cache key(s) for object type ' + bindingSObjectType);
                    Object cachedObject = null;
                    for ( String cacheKey : cacheKeys )
                    {
                        log('Retrieving entries with cache key "' + cacheKey + '" from platform cache partition "' + orgPartition + '"');
                        cachedObject = orgPartition.get( cacheKey );
                        if ( cachedObject != null )
                        {
                            bindings.addAll( (List<di_Binding>) cachedObject);
                        }
                    }
                } else {
                    log('Found no cache key(s) for object type ' + bindingSObjectType);
                }
            }
        }

        return bindings;
    }

    public static void clearCachedBindings() {

        Set<String> keys = getPartitionKeys();

        if ( keys != null ) 
        {
            String partitionKey = getPartitionName();
            Cache.OrgPartition partition = getPartition();
            // clear current bindings
            for (String key : partition.getKeys() ) 
            {
                try 
                {
                    partition.remove(key);
                } 
                catch (Exception ex) 
                {
                    log('XX]> Unable to remove Platform Cache partition [' + partitionKey + '] key [' + key + ']');
                }
            }
        }
    }

    /**
     * getPartitionKeys get partition keys
     * @return   return Set<String> partition keys
     */
    public static Set<String> getPartitionKeys() 
    {
        Set<String> keys = null;
        Cache.OrgPartition partition = getPartition();
        if ( partition != null ) 
        {
            // get partition keys
            keys = partition.getKeys();
        }
        return keys;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    // Private Methods
    //////////////////////////////////////////////////////////////////////////////////////////////

    @TestVisible
    private static di_Configurations__c getConfig()
    {
        di_Configurations__c config = di_Configurations__c.getInstance();

        if ( config == null )
        {
            config = new di_Configurations__c();
            config.SetupOwnerId = ConnectApi.Organization.getSettings().orgId;
            // make CheckMarx happy
            if (di_Configurations__c.SObjectType.getDescribe().isCreateable() )
            {
                insert config;
            }
        }

        return config;
    }

    @TestVisible
    private static String getPartitionName()
    {
        return getConfig().OrgCachePartitionName__c;
    }

    @TestVisible
    private Integer getPartitionTTL()
    {
        return NUM_OF_SECS_IN24HR; // number of seconds for a 24 hour period
    }

    @TestVisible
    private static Cache.OrgPartition getPartition()
    {
        Cache.OrgPartition result = null;
        try 
        {
            result = Cache.Org.getPartition( getPartitionName() );
        }
        catch (Exception excp) 
        {
            log('ERROR: Is there Cache? Is the Cache Partition enabled : Exception:' + excp);
        }
        return result;
    }

    @TestVisible
    private Boolean pushCacheKeyIndexMapToCache()
    {
        // if there IS NO Partition created; let's not FAIL
        Cache.OrgPartition orgPartition = getPartition();
        if ( orgPartition != null ) 
        {
            orgPartition.put( getKeyIndexName(), this.cacheKeyIndexMap, getPartitionTTL(), Cache.Visibility.ALL, false);

        }
        return orgPartition != null;
    }

    @TestVisible
    private void addBindingToKeyIndex(di_Binding binding)
    {
        String workingDeveloperName = binding.DeveloperName.toLowerCase().trim();

        if ( !getCacheKeyIndexMap().containsKey( workingDeveloperName ) )
        {
            getCacheKeyIndexMap().put(workingDeveloperName, new Map<Schema.SObjectType, Set<String> >() );
        }

        if ( !getCacheKeyIndexMap().get(workingDeveloperName).containsKey( binding.BindingObject) )
        {
            getCacheKeyIndexMap().get(workingDeveloperName).put( binding.BindingObject, new Set<String>() );
        }

        getCacheKeyIndexMap().get(workingDeveloperName).get(binding.BindingObject).add(getKeyName(binding));

        pushCacheKeyIndexMapToCache();
    }

    @TestVisible
    private String constructKeyName( Schema.SObjectType bindingSObjectType, String developerName )
    {
        String key = ( ( bindingSObjectType != null ) ? bindingSObjectType.getDescribe().getName().toLowerCase().replaceAll('__','') : '' )
                     + ( String.isBlank(developerName) ? '' : developerName.toLowerCase().trim() );

        // put generated hash into a map on first pass, so that we do not perform hashcode() operation more than once per "key"
        // hashcode() is a more expensive operation than map.get()
        if (generatedKeyNames.containsKey(key)) 
        { 
            return generatedKeyNames.get(key); 
        }

        String hash = String.valueOf( Math.abs( ( key ).hashCode() ) );
        log('Creating Hash For => ' + developerName + ' && ' + bindingSObjectType + ' := ' + hash);
        generatedKeyNames.put(key, hash);
        return hash;
    }

    @TestVisible
    private String getKeyName( String developerName, Schema.SObjectType bindingSObjectType)
    {
        return constructKeyName( bindingSObjectType, developerName);
    }
    
    @TestVisible
    private String getKeyName( di_Binding binding )
    {
        return constructKeyName( binding.BindingObject, binding.DeveloperName);
    }

    @TestVisible
    private String getKeyIndexName()
    {
        return di_PlatformCache.BINDING_KEY;
    }

    /**
     * log centralize to encapsulate and refactor later
     * @param  excp to display in sink
     */
    @TestVisible
    private static Boolean log(Exception excp)
    {
        Boolean before = DEBUGGING, result;
        // always show exceptions
        DEBUGGING = true;
        result = log('Exception: ' + excp.getMessage());
        DEBUGGING = before;
        return result;

    }

    /**
     * log centralize to encapsulate and refactor later
     * @param  message message to display in sink
     */
    @TestVisible
    private static Boolean log(String message)
    {
        Boolean doLog = DEBUGGING && String.isNotBlank(message);
        if ( doLog ) 
        {
            System.debug('+++ di_PlatformCache.message: ' + message);
        }
        return doLog;
    }
}
