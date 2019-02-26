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

    private di_Configurations__c getConfig()
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

    private Boolean isStoringBindingInPlatformCache()
    {
        return getConfig().UsePlatformCacheToStoreBindings__c == null ? false : getConfig().UsePlatformCacheToStoreBindings__c;
    }

    private String getPartitionName()
    {
        return getConfig().OrgCachePartitionName__c;
    }

    private Integer getPartitionTTL()
    {
        return 86400; // number of seconds for a 24 hour period
    }

    private Cache.OrgPartition getPartition()
    {
        return Cache.Org.getPartition(getPartitionName());
    }

    private Map<String, Map<Schema.SObjectType, Set<String>>> cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String>>>();

    public Map<String, Map<Schema.SObjectType, Set<String>>> getCacheKeyIndexMap()
    {
        if ( cacheKeyIndexMap.isEmpty() )
        {
            cacheKeyIndexMap = (Map<String, Map<Schema.SObjectType, Set<String>>>) getPartition().get( getKeyIndexName() );

            if ( cacheKeyIndexMap == null )
            {
                cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String>>>();
            } 
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

    private String constructKeyName( Schema.SObjectType bindingSObjectType, String developerName )
    {
        return ( ( bindingSObjectType != null ) ? bindingSObjectType.getDescribe().getName().toLowerCase() : '' )
            + developerName.toLowerCase().trim().hashCode();
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
            // add the binding to the platform cache directly
            getPartition().put(getKeyName(binding), binding, getPartitionTTL(), Cache.Visibility.ALL, false);
            // add the binding's cache key name to the bindingKeyIndex
            addBindingToKeyIndex(binding);
        }
    }

    public list<di_Binding> retrieveBindings(String developerName, Schema.SObjectType bindingSObjectType)
    {
        list<di_Binding> bindings = new list<di_Binding>();

        if ( isStoringBindingInPlatformCache() )
        {
            System.debug('developerName == ' + developerName + ' -- bindingSObjectType == ' + bindingSObjectType);

            Map<Schema.SObjectType, Set<String>> keyIndexBySObjectTypeMap = getCacheKeyIndexMap().get(developerName.toLowerCase().trim());
            if ( keyIndexBySObjectTypeMap != null )
            {
                Set<String> cacheKeys = keyIndexBySObjectTypeMap.get(bindingSObjectType);
                if ( cacheKeys != null )
                {
                    for ( String cacheKey : cacheKeys )
                    {
                        bindings.add( (di_Binding) getPartition().get( cacheKey ) );
                    }
                }
            }
        }
           
        return bindings;
    }
}
