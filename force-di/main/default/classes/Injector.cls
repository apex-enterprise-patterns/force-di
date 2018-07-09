public class Injector {

    /**
     * Binding resolver for the Injector
     **/
    public static final Binding.Query Bindings = new Binding.Query();

    /**
     * Resolves the given binding
     **/
    public static Object getInstance(String qualifiedBindingName) {
        return getInstance(qualifiedBindingName, null);
    }

    /**
     * Resolves the given binding explicitly assuming a Provider binding (if params is not null)
     **/
    public static Object getInstance(String qualifiedBindingName, Object params) {        
        List<Binding> bindings = Bindings.byName(qualifiedBindingName).get();
        if(bindings==null || bindings.size()==0) {
            throw new InjectorException('Binding for ' + qualifiedBindingName + ' not found');
        }
        return bindings[0].getInstance(params);
    }

    public class InjectorException extends Exception {}
}
