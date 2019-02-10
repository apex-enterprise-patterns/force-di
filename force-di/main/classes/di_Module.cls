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
public virtual class di_Module {

    private List<di_Binding> bindings = new List<di_Binding>();
    private di_Binding.BindingType bindingType;
    private String developerName;
    private SObjectType bindingObject;
    private Integer bindingSequence;
    private Object to;
    private Object bindingData;

    /**
     * Module class can be extended and/or used directly
     **/
    public di_Module() {
        init();
    }

    /**
     * Called by the framework when its ready to receive the binding config
     **/
    public virtual void configure() { }

    /**
     * Type of binding, see also alias methods apex(), lightningComponent(), visualforceComponent()
     **/
    public di_Module type(String value) {
        List<di_Binding.BindingType> bindEnumValues = di_Binding.BindingType.values();
        for(di_Binding.BindingType bindEnumValue : bindEnumValues) {
            if(bindEnumValue.name().equals(value)) {
                bindingType = bindEnumValue;
                return this;
            }
        }
        throw new ModuleException('Binding type ' + value + ' is not valid.');
    }

    /**
     * Type of binding
     **/
    public di_Module type(di_Binding.BindingType value) {
        bindingType = value;
        return this;
    }

    /**
     * Sets the binding type to Apex
     **/
    public di_Module apex() {
        bindingType = di_Binding.BindingType.Apex;
        return this;
    }

    /**
     * Sets the binding type to Lightning Component
     **/
    public di_Module lightningComponent() {
        bindingType = di_Binding.BindingType.LightningComponent;
        return this;
    }

    /**
     * Sets the binding type to Visualforce Component
     **/
    public di_Module visualforceComponent() {
        bindingType = di_Binding.BindingType.VisualforceComponent;
        return this;
    }

    /**
     * Sets the binding type to Flow
     **/
    public di_Module flow() {
        bindingType = di_Binding.BindingType.Flow;
        return this;
    }

    /**
     * Sets the binding type to Module (Apex class binding must extend Module class)
     **/
    public di_Module module() {
        bindingType = di_Binding.BindingType.Module;
        return this;
    }

    /**
     * Binding is related to a given Apex class
     **/
    public di_Module bind(Type bindingType) {
        developerName = bindingType.getName();
        return this;
    }

    /**
     * Binding is related to a given SObject
     **/
    public di_Module bind(SObjectType sObjectType) {
        bindingObject = sObjectType;
        return this;
    }

    /**
     * Binding is related to a given developer name
     **/
    public di_Module bind(String bindingName) {
        developerName = bindingName;
        return this;
    }

    /**
     * When multiple bindings of the same SObjectType exist sequences them
     **/
    public di_Module sequence(Integer sequence) {
        bindingSequence = sequence;
        return this;
    }

    /**
     * Data associated with the binding by the binding configuration
     **/
    public di_Module data(Object data) {
        bindingData = data;
        return this;
    }

    /**
     * Binding implementation
     **/
    public di_Module to(String bindingTo) {
        return toObject(bindingTo);
    }

    /**
     * Binding implementation
     **/
    public di_Module to(Type bindingTo) {
        return toObject(bindingTo.getName());
    }

    /**
     * Binding to an actual instance of the implementation (as apposed to class name)
     **/
    public di_Module toObject(Object to) {
        // This can be a string (typically late binding) or an object (instance binding)
        this.to = to;
        // Attempt to auto infer type of binding
        if(to instanceof di_Flow) {
            return flow().addBinding();
        }
        return addBinding();
    }

    /**
     * Returns all the bindings this module has been configured with
     * Any module bindings will be expanded and removed
     **/
    public List<di_Binding> getBindings() {
        // Return this modules configured bindings
        return this.bindings;
    }

    private di_Module addBinding() {
        // Construct binding and configure it
        di_Binding newBinding = di_Binding.newInstance(
            bindingType,
            developerName,
            bindingObject,
            bindingSequence,
            to,
            bindingData);
        bindings.add(newBinding);

        di_PlatformCache.getInstance().addBindingToPlatformCache( newBinding );

        init();
        return this;
    }

    private void init() {
        // Reset state
        bindingType = di_Binding.BindingType.Apex;
        developerName = null;
        bindingObject = null;
        bindingSequence = null;
        to = null;
    }

    public class ModuleException extends Exception {}
}