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

public class Injector {

    /**
     * Default Injector instance configured via Custom Metadata bindings
     **/
    public static final Injector Org = 
        new Injector(
            new List<Module> { 
                new CustomMetadataModule()});

    /**
     * Bindings visible to this Injector
     **/
    public Binding.Resolver Bindings {get; private set;}

    /**
     * Configures the Injector with the bindings configured by the given Module
     **/
    public Injector(Module module) {
        this(new List<Module> { module });
    }   

    /**
     * Configures the Injector with the bindings configured by the given Modules
     **/
    public Injector(List<Module> modules) {
        Bindings = new Binding.Resolver(modules);
    }   

    /**
     * Creates an instance of the object configured for the class name binding
     **/
    public Object getInstance(Type developerNameByType) {
        return getInstance( developerNameByType == null ? null : developerNameByType.getName().toLowerCase(), null);
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
        if ( string.isBlank(developerName) ) {
            throw new InjectorException('Request for Binding cannot take "developerName" parameter of null');
        }

        List<Binding> bindings = Bindings.byName( developerName.toLowerCase().trim() ).get();
        if ( bindings == null || bindings.isEmpty() ) {
            throw new InjectorException('Binding for ' + developerName + ' not found');
        }
        return bindings[0].getInstance(params);
    }

    /** 
     * A Module that loads bindings configured via the Binding__mdt object
     **/
    private class CustomMetadataModule extends Module {

        public override void configure() {
            // TODO: Support Namespace
            for(Binding__mdt bindingConfig : 
                [select QualifiedAPIName, DeveloperName, NamespacePrefix, 
                        Type__c, To__c, BindingObject__c, BindingSequence__c 
                    from Binding__mdt]) {
                bind(bindingConfig.DeveloperName);
                type(bindingConfig.Type__c);
                if(String.isNotBlank(bindingConfig.BindingObject__c)) {                        
                    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[] { bindingConfig.BindingObject__c.toLowerCase().trim() });
                    if(results.size() != 1) {
                        throw new InjectorException('Failed to find SObject ' + bindingConfig.BindingObject__c + ' referened by binding ' + bindingConfig.DeveloperName );
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
