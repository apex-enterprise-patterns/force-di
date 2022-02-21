/**
 * Copyright (c) 2018, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Wrap a binding config to subclass it and aid in resolving target binding
 *   (also leverages the Provider interface to allow for more advanced instantiation)
 **/
public abstract class di_Binding implements Comparable {

    public BindingType BindingType {get; private set;}

    @AuraEnabled
    public String BindingTypeAsString {get { return BindingType.name();} }

    @AuraEnabled
    public String NamespacePrefix {get;private set;}

    @AuraEnabled
    public String DeveloperName {get;private set;}

    @AuraEnabled
    public SObjectType BindingObject {get;private set;}

    @AuraEnabled
    public Integer BindingSequence {get;private set;}

    @AuraEnabled
    public Object To {get;private set;}

    @AuraEnabled
    public Object Data {get;private set;}

    private Boolean IsProvider = false;
    private Object Injected = null;

    /**
     * Gets the instance of the thing the binding points to
     **/
    public Object getInstance() {
        return getInstance(null, false);
    }

    /**
     * Gets the instance of the thing the binding points to
     **/
    public Object getInstance(Object params) {
        return getInstance(params, false);
    }

    /**
     * Gets the instance of the thing the binding points to
     **/
    public Object getInstance(Object params, Boolean newInstance) {
        if(IsProvider) {
            return newInstance(params);
        } else if(newInstance == true) {
            return newInstance(params);
        } else if(Injected == null) {
            Injected = newInstance(params);
        }
        return Injected;
    }

    /**
     * Gets the instance of the thing the binding points to
     **/
    public abstract Object newInstance(Object params);

    /**
     * Compare to impl to help sorted multiple matching bindings from the resolver
     *   See toString()
     **/
    public Integer compareTo(Object compareTo) {
        di_Binding binding = (di_Binding) compareTo;
        return this.toString().compareTo(binding.toString());
    }

    /**
     * Defaults to DeveloperName or binding object and sequence if specified
     **/
    public override String toString() {
        String hashValue = 
            (BindingObject != null) ? 
            BindingObject.getDescribe().getName() : 
            DeveloperName;
        if(BindingSequence != null) {
            hashValue += '#' + String.valueOf(BindingSequence).leftPad(4,'0');
        }
        return hashValue;
    }

    /**
    * Allows bindings to resolve dynamically (e.g. custom constructors) based passing in params if needed
    **/
    public interface Provider {
        Object newInstance(Object params);
    }

    /**
     * Simple fluent API to resolve Bindings, used by Injector methods or called directly
     **/
    public class Resolver {

        // Filter params for resolving bindings
        private String developerName;
        private SObjectType bindingObject;
        private boolean bindingsAreRequired = true;
        
        // Modules used by the Resolver to discover bindings
        private List<di_Module> modules = null;
        // Discovered bindings via the modules supplied to this resolver
// TODO: Consider changing this from a list<di_Binding> to a map<developerName, map<BindingObject, List<di_Binding>> 
        private List<di_Binding> bindings = null;

        /**
         * Resolver will call .configure() followed by getBindings() on each Modue
         **/
        public Resolver(List<di_Module> modules) {
            this.modules = modules;
        }

        /**
         * Clear any modules known to this resolver and add the one given
         **/
        public Resolver set(di_Module module) {
            modules.clear();
            modules.add(module);
// TODO: impact assessment on type change
            bindings = null; // Force reload of bindings
            return this;
        }

        /**
         * Add the module to those already known to this resolver
         **/
        public Resolver add(di_Module module) {
            modules.add(module);
// TODO: impact assessment on type change
            bindings = null; // Force reload of bindings
            return this;
        }

        /**
         * Resolve by name
         *
         *  @param the developerName of the Binding to be used as a filter in the resolving process.
         *  @return the current di_Binding.Resolver instance
         **/
        public Resolver byName(String developerName) {
            this.developerName = developerName;
            return this;
        }

        /**
         * Resolve by object type
         *
         *  @param the bindingObject to be used as a filter in the resolving process.
         *  @return the current di_Binding.Resolver instance
         **/
        public Resolver bySObject(SObjectType bindingObject) {
            this.bindingObject = bindingObject;
            return this;
        }

        /**
         * Alter the functionality, when bindings are not found in Platform Cache, a reload of the bindings to platform cache is not requred.
         *
         *  @return the current di_Binding.Resolver instance
         */
        public Resolver emptyBindingsAllowed() {
            bindingsAreRequired = false;
            return this;
        }

        /**
         * Replaces an existing binding for test mocking purposes.  This method is used in conjunction with the filtering
         * param methods of the di_Binding.Resolver class like "byName(String)" and "bySObject(SObjectType)". 
         *
         *  @param mockType - this is the Apex class that replaces the binding that is currently in default list of bindings
         *  @return the current di_Binding.Resolver instance
         */
        public Resolver replaceBindingWith( Object mockType )
        {
            // system.debug('replaceBindingWith method called');

            // Late resolve bindings to allow runtime module injection via set and add methods
            loadBindings();

            // find existing binding's position in the list.
            for (Integer currentBindingsIndex = 0; currentBindingsIndex < this.bindings.size(); currentBindingsIndex++) 
            {
                if ( isBindingMatchByFilteringCriteria( this.bindings[currentBindingsIndex] ) )
                {
                    this.bindings[currentBindingsIndex] = di_Binding.newInstance(di_Binding.BindingType.Apex, this.developerName, this.bindingObject, null, mockType, null);
                    break;
                }
            }

            this.developerName = null;
            this.bindingObject = null;

            // system.debug('replaceBindingWith method finished');

            return this;
        }

        /*
         *  Method used to determine if the di_Binding record supplied matches
         *  the available filtering parameters.
         *
         *  @param The current di_Binding from the Resolver's list of bindings to examine
         *  @return True if the current di_Binding is a match to the filtering critera.
         */
        private Boolean isBindingMatchByFilteringCriteria( di_Binding bind )
        {
            // System.debug('isBindingMatchByFilteringCriteria method called');
            Boolean isMatch = false;
            // system.debug('bind == ' + bind);
            // system.debug('this.developerName == ' + this.developerName);
            // system.debug('this.bindingObject == ' + this.bindingObject); 
            // System.debug('bind.BindingObject == ' + bind.BindingObject);
            // System.debug('bind.DeveloperName == ' + bind.DeveloperName);

            // if both filtering parameters were specified
            if ( String.isNotBlank(this.developerName) && this.bindingObject != null ) 
            {
                // then require both match for the binding to be included.
                if ( ( this.developerName.equalsIgnoreCase( bind.DeveloperName )
                        // or same check for the reference without a namespace prefix
                        || this.developerName.equalsIgnoreCase( di_NamespaceClass.CURRENTNAMESPACE + '.' + bind.DeveloperName )
                        )
                    && this.bindingObject == bind.BindingObject )
                {
                    isMatch = true;
                }
            }
            else {
                // else match on any of the available filtering parameters
                if ( String.isNotBlank(this.developerName)
                    && ( this.developerName.equalsIgnoreCase( bind.DeveloperName )
                        // or same check for the reference without a namespace prefix
                        || this.developerName.equalsIgnoreCase( di_NamespaceClass.CURRENTNAMESPACE + '.' + bind.DeveloperName )
                        )
                    ) 
                {
                    isMatch = true;
                } 
                else if (this.bindingObject != null && bind.BindingObject == this.bindingObject) 
                {
                    isMatch = true;
                }
            }
            
            // system.debug('isMatch == ' + isMatch); 

            return isMatch;
        }

        private void loadBindings()
        {
            if ( this.bindings == null ) 
            {
                // Ask each module to configure and aggregate the resulting bindings
                this.bindings = new List<di_Binding>();
                for (di_Module module : modules) 
                {
                    module.configure();
                    for(di_Binding bind : module.getBindings()) {
                        if(bind.BindingType == di_Binding.BindingType.Module) {
                            di_Module embeddedModule = (di_Module) bind.getInstance();
                            embeddedModule.configure();
                            this.bindings.addAll(embeddedModule.getBindings());
                        } else {
                            this.bindings.add(bind);
                        }
                    }
                }
            }
        }

        /**
         * Returns a filtered and sorted list of known bindings
         * Priority is given to filtering by DeveloperName if specified
         **/
        public List<di_Binding> get() 
        {
            list<di_Binding> matchedBindings = di_PlatformCache.getInstance().retrieveBindings(this.developerName, this.bindingObject);
            
            if ( ( di_PlatformCache.isStoringBindingInPlatformCache() && bindingsAreRequired && matchedBindings.isEmpty() ) 
                || ! di_PlatformCache.isStoringBindingInPlatformCache()
                )
            {
                // Late resolve bindings to allow runtime module injection via set and add methods
                loadBindings();

                // Filter bindings returned by preconfigured criteria
                // List<di_Binding> matchedBindings = new List<di_Binding>();
                for (di_Binding bind : bindings) 
                {
                    if ( isBindingMatchByFilteringCriteria(bind) )
                    {
                        matchedBindings.add(bind);
                    }
                }
            }

            this.developerName = null;
            this.bindingObject = null;
            matchedBindings.sort();
            
            // In case the default behavior was momentarily overridden, return the Resolver back to default behavior for next call.
            this.bindingsAreRequired = true;
            
            return matchedBindings;
        }
    }

    public class BindingException extends Exception {}

    /**
     * Types of Binding implementations supported by the framework
     **/
    public enum BindingType { Apex, VisualforceComponent, LightningComponent, Flow, Module }

    /**
     * Returns the applicable Binding impl to resolve the type of binding provided
     **/
    public static di_Binding newInstance(
            BindingType bindType,
            String developerName,
            SObjectType bindingObject,
            Integer bindingSequence,
            Object to,
            Object bindingData) 
    {
        // Return an applicable Binding subclass for the given binding type
        Type implType = BINDING_IMPLS_BY_TYPE.get(bindType);

        if ( implType != null ) {
            di_Binding binding = (di_Binding) implType.newInstance();
            binding.BindingType = bindType;
            binding.DeveloperName = developerName;
            binding.BindingObject = bindingObject;
            binding.BindingSequence = bindingSequence;
            binding.To = to;
            binding.Data = bindingData;
            return binding;
        }
        throw new BindingException('Binding type ' + bindType + ' has no implementation.');
    }

    // Maps binding type to the applicable impl
    private static final Map<BindingType, Type> BINDING_IMPLS_BY_TYPE =
        new Map<BindingType, Type> {
            BindingType.Apex => ApexBinding.class,
            BindingType.LightningComponent => LightningComponentBinding.class,
            BindingType.VisualforceComponent => VisualForceComponentBinding.class,
            BindingType.Flow => FlowBinding.class,
            BindingType.Module => ApexBinding.class
        };

    /**
     * Bindings to Apex classes (optionally via Provider interface)
     **/
    private class ApexBinding extends di_Binding 
    {
        public override Object newInstance(Object params) 
        {
            // Type binding?
            if ( To instanceof String ) 
            {
                // Leverage namespace if the Binding has one
                String className = (String) To;
                Type toType = NameSpacePrefix == null ? Type.forName(className) : Type.forName(NamespacePrefix, className);
                if ( toType == null ) 
                {
                    throw new BindingException('Apex binding ' + DeveloperName + ' implementation ' + To + ' does not exist');
                }
                Object toObject = toType.newInstance();
                // Is this Apex binding resolved via a Provider?
                IsProvider = toObject instanceof Provider;
                if ( IsProvider )
                {
                    return ((Provider) toObject).newInstance(params);
                } 
                else if ( params != null ) 
                {
                    // Params supplied but the binding does not reference a Provider?
                    throw new BindingException('Apex binding ' + DeveloperName + ' implementation ' + className + ' does not implement the Provider interface.');
                }
                return toObject;
            }
            // Instance binding
            return To;
        }
    }

    /**
     * Bindings to VF Components via Provider interface (required)
     **/
    private class VisualForceComponentBinding extends di_Binding 
    {
        public  override Object newInstance(Object params) 
        {
            // Type binding?
            if ( To instanceof String ) 
            {
                // Visualforce Components references must be made via an Apex class implementing the Provider interface
                String className = (String) To;
                Type toType = NamespacePrefix == null ? Type.forName(className) : Type.forName(NamespacePrefix, className);
                if ( toType == null )
                {
                    throw new BindingException('Visualforce Component binding ' + DeveloperName + ' implementation ' + className + ' does not exist.');
                }
                // Visualforce Components have to be resolved via a Provider
                Object toObject = toType.newInstance();
                IsProvider = toObject instanceof Provider;
                if ( IsProvider )
                {
                    return ((Provider) toObject).newInstance(params);
                }
                throw new BindingException('Visualforce Component binding ' + DeveloperName + ' must point to a class implementing the Provider interface.');
            }
            // Instance binding
            return To;
        }
    }

    /**
     * Bindings to Lightning Components (Provider interface not currently supported)
     **/
    private class LightningComponentBinding extends di_Binding 
    {
        public override Object newInstance(Object params) 
        {
            // Lightning Component bindings are resolve by the Lightning 'inject' Component included in this library
            return To;
        }
    }

    /**
     * Bindings to Flows (Provider interface not currently supported)
     **/
    private class FlowBinding extends di_Binding 
    {
        public  override Object newInstance(Object params) 
        {
            // Flow name binding?
            if ( To instanceof String ) 
            {
                String flowName = (String) To;
                if ( params instanceof Map<String, Object> )
                {
                    return new di_Flow(Flow.Interview.createInterview(flowName, (Map<String, Object>) params));
                }
                return new di_Flow(Flow.Interview.createInterview(flowName, new Map<String, Object>()));
            }
            // Instance binding
            return To;
        }
    }
}