global with sharing class DiInjector {
    private di_Injector localInjector;

    global interface Provider extends di_Binding.Provider {}

    /**
     * Default Injector instance configured via Custom Metadata bindings
     **/
    global static final DiInjector Org = new DiInjector(di_Injector.Org);

    /**
     * Constructor
     * 
     * For now we only support dependencies configured via custom metadata
     */
    private DiInjector(di_Injector injector) {
        this.localInjector = injector;
    }

    /**
     * Creates an instance of the object configured for the class name binding
     **/
    global Object getInstance(Type developerNameByType) {
        return getInstance(developerNameByType?.getName()?.toLowerCase(), null);
    }

    /**
     * Creates an instance of the object configured for the class name binding
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    global Object getInstance(Type developerNameByType, Object params) {
        return getInstance(developerNameByType?.getName()?.toLowerCase(), params);
    }

    /**
     * Creates an instance of the object configured for the named binding
     **/
    global Object getInstance(String developerName) {
        return getInstance(developerName, null);
    }

    /**
     * Creates an instance of the object configured for the named binding
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    global Object getInstance(String developerName, Object params) {
        return localInjector.getInstance(developerName, params);
    }

    /**
     * Creates an instance of the object configured for the named binding and the binding SObjectType
     **/
    global Object getInstance(Type developerNameByType, Schema.SObjectType bindingSObjectType) {
        return getInstance(developerNameByType, bindingSObjectType, null);
    }

    /**
     * Creates an instance of the object configured for the named binding and the binding SObjectType
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    global Object getInstance(Type developerNameByType, Schema.SObjectType bindingSObjectType, Object params) {
        return getInstance(developerNameByType == null ? null : developerNameByType.getName().toLowerCase(), bindingSObjectType, params);
    }

    /**
     * Creates an instance of the object configured for the named binding and the binding SObjectType
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    global Object getInstance(String developerName, Schema.SObjectType bindingSObjectType, Object params) {
        return localInjector.getInstance(developerName, bindingSObjectType, params);
    }
}