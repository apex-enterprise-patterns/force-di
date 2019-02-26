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

public class di_Injector {

    /**
     * Default Injector instance configured via Custom Metadata bindings
     **/
    public static final di_Injector Org =
        new di_Injector(
            new List<di_Module> {
                new CustomMetadataModule()});

    /**
     * Bindings visible to this Injector
     **/
    public di_Binding.Resolver Bindings {get; private set;}

    /**
     * Configures the Injector with the bindings configured by the given Module
     **/
    public di_Injector(di_Module module) {
        this(new List<di_Module> { module });
    }

    /**
     * Configures the Injector with the bindings configured by the given Modules
     **/
    public di_Injector(List<di_Module> modules) {
        Bindings = new di_Binding.Resolver(modules);
    }

    /**
     * Creates an instance of the object configured for the class name binding
     **/
    public Object getInstance(Type developerNameByType) {
        return getInstance(developerNameByType == null ? null : developerNameByType.getName().toLowerCase(), null);
    }

    /**
     * Creates an instance of the object configured for the class name binding
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    public Object getInstance(Type developerNameByType, Object params) {
        return getInstance(developerNameByType == null ? null : developerNameByType.getName().toLowerCase(), params);
    }

    /**
     * Creates an instance of the object configured for the named binding
     **/
    public Object getInstance(String developerName) {
        return getInstance(developerName, null);
    }

    /**
     * Creates an instance of the object configured for the named binding
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    public Object getInstance(String developerName, Object params) {
        if ( String.isBlank(developerName) ) {
            throw new InjectorException('Request for Binding cannot take "developerName" parameter of null');
        }

        List<di_Binding> bindingsFound = this.Bindings.byName( developerName.toLowerCase().trim() ).get();
        if ( bindingsFound == null || bindingsFound.isEmpty() ) {
            throw new InjectorException('Binding for "' + developerName + '" not found');
        }
        return bindingsFound[0].getInstance(params);
    }

    /**
     * Creates an instance of the object configured for the named binding and the binding SObjectType
     **/
    public Object getInstance(Type developerNameByType, Schema.SObjectType bindingSObjectType) {
        return getInstance(developerNameByType, bindingSObjectType, null);
    }

    /**
     * Creates an instance of the object configured for the named binding and the binding SObjectType
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    public Object getInstance(Type developerNameByType, Schema.SObjectType bindingSObjectType, Object params) {
        return getInstance(developerNameByType == null ? null : developerNameByType.getName().toLowerCase(), bindingSObjectType, params);
    }

    /**
     * Creates an instance of the object configured for the named binding and the binding SObjectType
     *   (if params is specified, implicitly uses the Provider interface)
     **/
    public Object getInstance(String developerName, Schema.SObjectType bindingSObjectType, Object params) {
        if ( String.isBlank(developerName) ) {
            throw new InjectorException('Request for Binding cannot take "developerName" parameter of null');
        }

        if ( bindingSObjectType == null ) {
            throw new InjectorException('Request for Binding cannot take "bindingSObjectType" parameter of null');
        }

        List<di_Binding> bindingsFound = this.Bindings.bySObject( bindingSObjectType )
                                            .byName( developerName.toLowerCase().trim() )
                                            .get();

        if ( bindingsFound == null || bindingsFound.isEmpty() ) {
            throw new InjectorException('Binding for "' + developerName + '" and SObjectType "' + bindingSObjectType + '" not found');
        }
        return bindingsFound[0].getInstance(params);

    }

    /**
     * A Module that loads bindings configured via the Binding__mdt object
     **/
    private class CustomMetadataModule extends di_Module {

        public override void configure() {

            List<di_Binding__mdt> bindingConfigs = [select QualifiedAPIName, DeveloperName, NamespacePrefix, Type__c, To__c
                                                         , BindingObject__c, BindingObject__r.QualifiedApiName, BindingSequence__c
                                                      from di_Binding__mdt];

            // TODO: Support Namespace
            for(di_Binding__mdt bindingConfig : bindingConfigs) {
                // System.debug('bindingConfig.DeveloperName == ' + bindingConfig.DeveloperName);
                // System.debug('bindingConfig.To__c == ' + bindingConfig.To__c);
                // System.debug('bindingConfig.BindingObject__c == ' + bindingConfig.BindingObject__c);
                // if(String.isNotBlank(bindingConfig.BindingObject__c)) {
                //     System.debug('bindingConfig.BindingObject__r.QualifiedApiName == ' + bindingConfig.BindingObject__r.QualifiedApiName);
                // }
                bind(bindingConfig.DeveloperName);
                type(bindingConfig.Type__c);
                if(String.isNotBlank(bindingConfig.BindingObject__c)) {
                    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[] { bindingConfig.BindingObject__r.QualifiedApiName.toLowerCase().trim() });
                    if(results.size() != 1) {
                        throw new InjectorException('Failed to find SObject ' + bindingConfig.BindingObject__r.QualifiedApiName + ' referened by binding ' + bindingConfig.DeveloperName );
                    }
                    bind(results[0].getSObjectType());
                }
                if(bindingConfig.BindingSequence__c != null) {
                    sequence(Integer.valueOf(bindingConfig.BindingSequence__c));
                }
                data(bindingConfig);
                to(bindingConfig.To__c);
            }
        }
    }

    public class InjectorException extends Exception {}
}