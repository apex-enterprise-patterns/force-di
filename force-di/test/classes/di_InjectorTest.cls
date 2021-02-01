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
 * Modifications:
 * =============
 *  B Anderson : Gettting the overall code-coverage > 75%
 */
@IsTest
private class di_InjectorTest {

    //TODO
    @IsTest
    private static void test(){
        di_module module = new di_module();
        di_Injector injector = new di_Injector(module);

        di_Injector.Org.Bindings.byName( Contact.class.getName() )
        .bySObject( Account.sObjectType )
        .replaceBindingWith( null );

    }
    @IsTest
    private static void givenListOfModulesBindThenGetCount(){
        // Given
        List<di_module> modules =  new List<di_module > {
        };
        final Integer expected = 0;
        // When
        di_Injector injector = new di_Injector(modules);
        // Then
        system.assertEquals(expected, injector.Bindings.get().size());

    }

    @isTest
    static void givenInstanceThenGetThatInstance(){
        // Given
        di_module module=new di_module();
        di_Binding bobBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            di_BindingTest.Bob.class.getName(), null, null,
            di_BindingTest.Bob.class.getName(), null);

        module.getBindings().add(bobBinding);

        di_Injector injector = new di_Injector(module);
        // When
        Object result=injector.getInstance(di_BindingTest.Bob.class);
        Object resultNoParams=injector.getInstance(di_BindingTest.Bob.class,(Object)null);
        Object resultByName=injector.getInstance(di_BindingTest.Bob.class.getName());
        // Then
        system.assertEquals(true, result instanceof di_BindingTest.Bob);
        system.assertEquals(true, resultByName instanceof di_BindingTest.Bob);
        system.assertEquals(true, resultNoParams instanceof di_BindingTest.Bob);
    }

    @isTest
    static void givenInstanceNameThenGetException(){
        // Given
        di_module module=new di_module();
        di_Injector injector = new di_Injector(module);
        Boolean hasException = false;
        // When
        try {
            injector.getInstance((String)null);
        } catch (di_Injector.InjectorException excp) {
            hasException=true;
        }
        // Then
        system.assertEquals(true, hasException);
        // When
        hasException=false;
        try {
            injector.getInstance('');
        } catch (di_Injector.InjectorException excp) {
            hasException=true;
        }
        // Then
        system.assertEquals(true, hasException);

    }

    @isTest
    static void givenNullSTypeParamterInGetInstanceThenThrowException()
    {
        //
        // Given
        di_Module module= new di_Module();
        di_Injector injector = new di_Injector(module);
        Schema.SObjectType sType = null;
        Boolean hasException=false;
        // Then

        try {
            injector.getInstance(di_Module.class,sType);
        } catch (di_Injector.InjectorException excp) {
            hasException=true;
        }
        // Then
        system.assertEquals(true, hasException);
    }
    @isTest
    static void givenNullParamterInGetInstanceThenThrowException()
    {
        //
        // Given
        di_Module module= new di_Module();
        di_Injector injector = new di_Injector(module);
        Schema.SObjectType sType = Account.getSObjectType();
        Boolean hasException=false;
        // Then

        try {
            injector.getInstance(Account.class,sType,null);
        } catch (di_Injector.InjectorException excp) {
            hasException=true;
        }
        // Then
        system.assertEquals(true, hasException);
    }

    @IsTest 
    private static void givenDefaultConditionsWhenInjectorOrgBindingsCalled() {
        // Given
        di_Binding__mdt testBindingRecord1 = new di_Binding__mdt();
        testBindingRecord1.Type__c = di_Binding.BindingType.Apex.name();
        testBindingRecord1.To__c = Bob.class.getName();
        testBindingRecord1.QualifiedAPIName = 'apex_Bob';
        testBindingRecord1.DeveloperName = 'TestApexClassBob';
        testBindingRecord1.BindingObject__c = Account.sObjectType.getDescribe().getName();
        
        di_BindingConfigWrapper wrapper1 = new di_BindingConfigWrapper(testBindingRecord1);
        wrapper1.BindingObjectQualifiedApiName = 'Account';

        di_Binding__mdt testBindingRecord2 = new di_Binding__mdt();
        testBindingRecord2.Type__c = di_Binding.BindingType.Apex.name();
        testBindingRecord2.To__c = Charlie.class.getName();
        testBindingRecord2.QualifiedAPIName = 'apex_Charlie';
        testBindingRecord2.DeveloperName = 'TestApexClassCharlie';
        testBindingRecord2.BindingObjectAlternate__c = Contact.sObjectType.getDescribe().getName();
        testBindingRecord2.BindingSequence__c = 20;
        
        di_BindingConfigWrapper wrapper2 = new di_BindingConfigWrapper(testBindingRecord2);
        wrapper2.BindingObjectQualifiedApiName = 'Contact';

        List<di_BindingConfigWrapper> wrappers = new List<di_BindingConfigWrapper>();
        wrappers.add(wrapper1);
        wrappers.add(wrapper2);

        di_Injector.mock_BindingConfigurationWrappersOuter = wrappers;

        // When
        di_Injector.CustomMetadataModule defaultModule = new di_Injector.CustomMetadataModule();

        defaultModule.configure();
    }

    @IsTest
    private static void givenApexBindingWhenReplaceBindingWithNewInstanceThenNewInstance() {
        // Given
        di_Binding bindingBob = di_Binding.newInstance( di_Binding.BindingType.Apex, Bob.class.getName(), Account.sObjectType, null, Bob.class.getName(), null);

        di_Binding bindingCharlie = di_Binding.newInstance( di_Binding.BindingType.Apex, Charlie.class.getName(), Account.sObjectType, null, Charlie.class.getName(), null);

//         di_Binding bindingModule = di_Binding.newInstance( di_Binding.BindingType.Module, null, null, null, TestDIModule.class.getName(), null);

        di_module module = new di_module();

        // run through options
        module.apex();
        module.flow();
        module.lightningComponent();
        module.visualforceComponent();
        module.module();
        module.sequence(1);
        module.type('Module');

        // now set the values appropriately
        module.type(di_Binding.BindingType.Module);
        module.to(TestDIModule.class);

        di_Injector injector = new di_Injector(module);
        
        // When
        Object boundInstanceBob = bindingBob.getInstance();

        List<di_Binding> bindings = injector.Bindings.byName( Bob.class.getName() ).bySObject( Account.sObjectType ).get();
        System.debug(bindings);

        Object boundInstanceCharlie = bindingCharlie.getInstance();

        injector.Bindings.byName( Bob.class.getName() )
                                .bySObject( Account.sObjectType )
                                .replaceBindingWith( bindingCharlie );

        // Then
        System.assert(boundInstanceBob instanceof Bob);
        System.assert(boundInstanceCharlie instanceof Charlie);
        System.assert(boundInstanceBob !== boundInstanceCharlie);
    }

    public class Bob {
        public String Name {get;private set;}
        public Bob() { }
        public Bob(String name) { this.Name = name; }
    }
    
    public class Charlie {
        public String Name {get;private set;}
        public Charlie() { }
        public Charlie(String name) { this.Name = name; }
    }

    public class TestDIModule
        extends di_Module
    {
        public override void configure()
        {
            apex();
            bind( Account.sObjectType );
            bind( di_InjectorTest.Bob.class );
            data('binding of Bob');
            to(di_InjectorTest.Bob.class.getName());
        }
    }
}