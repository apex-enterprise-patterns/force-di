@SuppressWarnings('PMD.ClassNamingConventions,PMD.CognitiveComplexity')
public with sharing class di_PlatformCache
{
    //////////////////////////////////////////////////////////////////////////////////////////////
    // Data Members
    //////////////////////////////////////////////////////////////////////////////////////////////
    // number of seconds for a 24 hour period
    public static final Integer NUM_OF_SECS_IN24HR =  86400;

    @TestVisible
    private static final String BINDING_KEY = 'bindingKeyIndex';
    @TestVisible
    private static di_PlatformCache instance;
    @TestVisible
    private Map<String, Map<Schema.SObjectType, Set<String> > > cacheKeyIndexMap = new Map<String, Map<Schema.SObjectType, Set<String> > >();
    @TestVisible
    private static Map<String, String> generatedKeyNames = new Map<String, String>();
    // Used for turning on logging (if needed)
    @TestVisible
    @SuppressWarnings('PMD.FieldNamingConventions')
    private static Boolean DEBUGGING = false;

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
                log('Adding binding for hash => ' + theKeyName + ' && developerName => ' + binding.developerName + ' && object => ' + binding.bindingObject);
                // ... then put the working list back in cache on this key
                try 
                {
                    orgPartition.put(theKeyName, workingBindings, getPartitionTTL(), Cache.Visibility.ALL, false);    
                }
                catch (cache.Org.OrgCacheException oce)
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

    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public list<di_Binding> retrieveBindings(String developerName, Schema.SObjectType bindingSObjectType)
    {
        list<di_Binding> bindings = new list<di_Binding>();

        if ( isStoringBindingInPlatformCache()
             && string.isNotBlank(developerName)
             && bindingSObjectType != null)
        {
            log('Retrieving from Cache Key => ' + developerName + ' && Cache Key Index => ' + bindingSObjectType);
            // if there IS NO Partition created; let's not FAIL
            Cache.OrgPartition orgPartition = getPartition();
            Map<Schema.SObjectType, Set<String> > keyIndexBySObjectTypeMap = getCacheKeyIndexMap().get(developerName.toLowerCase().trim());
            if ( keyIndexBySObjectTypeMap != null && orgPartition != null )
            {
                Set<String> cacheKeys = keyIndexBySObjectTypeMap.get(bindingSObjectType);
                if ( cacheKeys != null )
                {
                    Object cachedObject = null;
                    for ( String cacheKey : cacheKeys )
                    {
                        cachedObject = orgPartition.get( cacheKey );
                        
                        if ( cachedObject != null )
                        {
                            bindings.addAll( (List<di_Binding>) cachedObject);
                        }
                    }
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

    public static void enable()
    {
        initializeUpdateableConfig();
        
        enable(getConfig());
    }

    public static void enableForPartition(String partitionName)
    {
        initializeUpdateableConfig();
        
        di_Configurations__c config = getConfig();

        config.OrgCachePartitionName__c = partitionName;
        
        enable(config);
    }

    public static void disable()
    {
        initializeUpdateableConfig();
        
        di_Configurations__c config = getConfig();

        config.UsePlatformCacheToStoreBindings__c = false;

        persistChanges(config);
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

    public class DIPlatformCacheException extends Exception {}

    //////////////////////////////////////////////////////////////////////////////////////////////
    // Private Methods
    //////////////////////////////////////////////////////////////////////////////////////////////

    private static void enable(di_Configurations__c config)
    {
        if (String.isBlank(config.OrgCachePartitionName__c))
        {
            throw new DIPlatformCacheException('The di_Configurations__c.OrgCachePartitionName__c must bet set with the partition name before Platform Cache can be enabled for Force-DI bindings.');
        }

        // attempt to get the partition to ensure that it is present.  If it is not available, then an error will be thrown.
        try 
        {
            getPartitionByName(config.OrgCachePartitionName__c);
        }
        catch (DIPlatformCacheException pce)
        {
            throw new DIPlatformCacheException('The cache partition \'' + config.OrgCachePartitionName__c + '\' is not available.');
        }
        
        config.UsePlatformCacheToStoreBindings__c = true;

        persistChanges(config);
    }

    private static void persistChanges(di_Configurations__c config)
    {
        if ( config.isSet( di_Configurations__c.Id ) && di_Configurations__c.SObjectType.getDescribe().isUpdateable() )
        {
            update config;
        }
        else if (di_Configurations__c.SObjectType.getDescribe().isCreateable() )
        {
            insert config;
        }
        else 
        {
            throw new DIPlatformCacheException('Unable to persist changes for di_Configurations__c');
        }
    }

    private static di_Configurations__c DEFAULT_CONFIG = di_Configurations__c.getInstance();

    private static void initializeUpdateableConfig()
    {
        Id orgId = ConnectApi.Organization.getSettings().orgId;
        Id currentUsersProfileId = UserInfo.getProfileId();
        Id currentUsersId = UserInfo.getUserId();
        List<di_Configurations__c> allRelevantConfigs = [SELECT Id, Name, SetupOwnerId
                                                              , OrgCachePartitionName__c
                                                              , UsePlatformCacheToStoreBindings__c
                                                              , CreatedById, CreatedDate, LastModifiedById, LastModifiedDate
                                                           FROM di_Configurations__c
                                                          WHERE (SetupOwnerId = :currentUsersId AND Name = 'Force-DI Configurations (User)')
                                                             OR (SetupOwnerId = :currentUsersProfileId AND Name = 'Force-DI Configurations (Profile)')
                                                             OR (SetupOwnerId = :orgId)
                                                          ORDER BY Name DESC]; // the sort order is important to ensure that the 
                                                                                // user's default shows first in the list, then 
                                                                                // the user's profile version, and finally the org default.
        DEFAULT_CONFIG = allRelevantConfigs[0];                                                                      
    }

    @TestVisible
    private static di_Configurations__c getConfig()
    {
        di_Configurations__c config = DEFAULT_CONFIG;
        System.debug(LoggingLevel.ERROR, config);
        if ( config == null )
        {
            config = new di_Configurations__c();
            config.SetupOwnerId = ConnectApi.Organization.getSettings().orgId;
            persistChanges(config);
        }
        System.debug(LoggingLevel.ERROR, config);
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
        return getPartitionByName( getPartitionName() );
    }

    private static Cache.OrgPartition getPartitionByName(String partitionName)
    {
        Cache.OrgPartition result = null;
        try
        {
            result = Cache.Org.getPartition( partitionName );
        }
        catch (cache.Org.OrgCacheException oce)
        {
            throw new DIPlatformCacheException(oce);
        }
        // catch (Exception excp) // TODO::Determine if catching this exception is the right move
        // {
        //     // TODO: Determine if simply loging the error is sufficient
        //     log('ERROR: Is there Cache? Is the Cache Partition enabled : Exception:' + excp);
        // }
        return result;
    }

    @TestVisible
    private boolean pushCacheKeyIndexMapToCache()
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
        String workingDeveloperName = binding.developerName.toLowerCase().trim();

        if ( !getCacheKeyIndexMap().containsKey( workingDeveloperName ) )
        {
            getCacheKeyIndexMap().put(workingDeveloperName, new Map<Schema.SObjectType, Set<String> >() );
        }

        if ( !getCacheKeyIndexMap().get(workingDeveloperName).containsKey( binding.bindingObject) )
        {
            getCacheKeyIndexMap().get(workingDeveloperName).put( binding.bindingObject, new Set<String>() );
        }

        getCacheKeyIndexMap().get(workingDeveloperName).get(binding.bindingObject).add(getKeyName(binding));

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

        String hash = String.valueOf( Math.abs( ( key ).hashcode() ) );
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
        return constructKeyName( binding.bindingObject, binding.developerName);
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
        Boolean before = DEBUGGING;
        Boolean result;
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
        Boolean doLog = DEBUGGING && string.isNotBlank(message);
        if ( doLog ) 
        {
            system.debug('+++ di_PlatformCache.message: ' + message);
        }
        return doLog;
    }
}