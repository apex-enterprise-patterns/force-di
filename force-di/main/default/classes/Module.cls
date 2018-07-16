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
  *  Roughly based on the Java API. Instances of this class can be given to an Injector instance
  *    or registered via Binding__mdt and thus available to the global scope Injector
  *    See https://github.com/google/guice/wiki/GettingStarted
  *    See https://github.com/google/guice/wiki/ModulesShouldBeFastAndSideEffectFree
 **/
public virtual class Module {

    private List<Binding> bindings = new List<Binding>();
    private Binding.BindingType bindingType;
    private String developerName;
    private SObjectType bindingObject;
    private Integer bindingSequence;
    private String to;
    private Object bindingData;

    /**
     * Module class can be extended and/or used directly
     **/
    public Module() {
        init();
    }

    /** 
     * Called by the framework when its ready to receive the binding config
     **/
    public virtual void configure() { }

    /** 
     * Type of binding, see also alias methods apex(), lightningComponent(), visualforceComponent()
     **/
    public Module type(String value) {
        List<Binding.BindingType> bindEnumValues = Binding.BindingType.values();
        String valueToCompare = String.isBlank(value) ? null : value.toLowerCase().trim();
        for(Binding.BindingType bindEnumValue : bindEnumValues) {
            if(bindEnumValue.name().equalsIgnoreCase(valueToCompare)) {
                bindingType = bindEnumValue;
                return this;
            }
        }
        throw new ModuleException('Binding type ' + value + ' is not valid.');
    }

    /**
     * Type of binding
     **/
    public Module type(Binding.BindingType value) {
        bindingType = value;
        return this;
    }

    /**
     * Sets the binding type to Apex
     **/
    public Module apex() {
        bindingType = Binding.BindingType.Apex;
        return this;
    }

    /**
     * Sets the binding type to Lightning Component
     **/
    public Module lightningComponent() {
        bindingType = Binding.BindingType.LightningComponent;
        return this;
    }

    /**
     * Sets the binding type to Visualforce Component
     **/
    public Module visualforceComponent() {
        bindingType = Binding.BindingType.VisualforceComponent;
        return this;
    }

    /**
     * Sets the binding type to Module (Apex class binding must extend Module class)
     **/
    public Module module() {
        bindingType = Binding.BindingType.Module;
        return this;
    }

    /**
     * Binding is related to a given Apex class
     **/
    public Module bind(Type bindingType) {
        developerName = bindingType == null ? null : bindingType.getName().toLowerCase();
        return this;
    }

    /**
     * Binding is related to a given SObject
     **/
    public Module bind(SObjectType sObjectType) {
        bindingObject = sObjectType;
        return this;
    }

    /**
     * Binding is related to a given developer name
     **/
    public Module bind(String bindingName) {
        developerName = String.isBlank(bindingName) ? null : bindingName.toLowerCase().trim();
        return this;
    }

    /**
     * When multiple bindings of the same SObjectType exist sequences them
     **/
    public Module sequence(Integer sequence) {
        bindingSequence = sequence;
        return this;
    }

    /**
     * Data associated with the binding by the binding configuration
     **/
    public Module data(Object data) {
        bindingData = data;
        return this;
    }

    /**
     * Binding implementation
     **/
    public Module to(String bindingTo) {
        to = String.isBlank(bindingTo) ? null : bindingTo.toLowerCase().trim();
        return addBinding();
    }

    /**
     * Binding implementation
     **/
    public Module to(Type bindingTo) {
        to = bindingTo == null ? null : bindingTo.getName().toLowerCase(); 
        return addBinding();
    }

    /**
     * Returns all the bindings this module has been configured with
     * Any module bindings will be expanded and removed
     **/
    public List<Binding> getBindings() {
        // Return this modules configured bindings
        List<Binding> moduleBindings = new List<Binding>();
        for(Binding bind : bindings) {
            // Module bindings are expanded into the returned listed and removed
            if(bind.BindingType == Binding.BindingType.Module) {
                Module module = (Module) bind.getInstance();
                module.configure();
                moduleBindings.addAll(module.getBindings());
            } else {
                moduleBindings.add(bind);
            }
        }
        return moduleBindings;
    }

    private Module addBinding() {
        // Construct binding and configure it
        Binding newBinding = Binding.newInstance(bindingType);
        newBinding.DeveloperName = developerName;
        newBinding.BindingObject = bindingObject;
        newBinding.BindingSequence = bindingSequence;
        newBinding.To = to;
        newBinding.Data = bindingData;
        bindings.add(newBinding);
        init();
        return this;       
    }

    private void init() {
        // Reset state
        bindingType = Binding.BindingType.Apex;
        developerName = null;
        bindingObject = null;
        bindingSequence = null;
        to = null; 
    }

    public class ModuleException extends Exception {}
}
