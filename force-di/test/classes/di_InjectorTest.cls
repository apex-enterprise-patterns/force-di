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

    @isTest
    static void whenDeveloperNameIsEmptyThenGetInstanceShouldThrowException(){

        //given
        di_Module module = new di_Module();
        di_Injector injector = new di_Injector(module);

        //when
        try {
            injector.getInstance('', Account.getSObjectType(), null);
            System.assert(false, 'Expecting that exception was thrown');
        } catch (di_Injector.InjectorException excp) {
            //then
            System.assertEquals('Request for Binding cannot take "developerName" parameter of null', excp.getMessage(), 'Expecting specific exception message');
        } catch (Exception e) {
            System.assert(false, 'Was expecting a di_Injector.InjectorException but instead received ' + e);
        }
    }

    @isTest
    static void givenInjectorWithBindingsThenBindingIsReturned(){

        //given
        di_Injector injector = di_Injector.Org;
        di_Injector.mock_BindingConfigurationWrappersOuter = new List<di_BindingConfigWrapper> { 
            new di_BindingConfigWrapper(
                'testQualifiedApiName',
                di_InjectorTest.InterfaceForTest.class.getName(), 
                'testNamespacePrefix', 
                'Apex',
                di_InjectorTest.ClassForTest.class.getName(),
                'Account',
                'Account',
                null,
                1
            )
        };
        //when
        di_InjectorTest.InterfaceForTest returnedInstance = 
            (di_InjectorTest.InterfaceForTest)injector.getInstance( di_InjectorTest.InterfaceForTest.class.getName(), Account.SObjectType, null);

        //then
        System.assert(returnedInstance instanceof di_InjectorTest.ClassForTest, 'Expecting that instance of class was returned');
    }

    @isTest
    static void givenBindingsWithAlternateObjectNameThenBindingIsReturned(){

        //given
        di_Injector injector = di_Injector.Org;
        di_Injector.mock_BindingConfigurationWrappersOuter = new List<di_BindingConfigWrapper> { 
            new di_BindingConfigWrapper(
                'testQualifiedApiName',
                di_InjectorTest.InterfaceForTest.class.getName(), 
                'testNamespacePrefix', 
                'Apex',
                di_InjectorTest.ClassForTest.class.getName(),
                null,
                null,
                'Account',
                1
            )
        };

        //when
        di_InjectorTest.InterfaceForTest returnedInstance = 
            (di_InjectorTest.InterfaceForTest)injector.getInstance( di_InjectorTest.InterfaceForTest.class.getName(), Account.SObjectType, null);

        //then
        System.assert(returnedInstance instanceof di_InjectorTest.ClassForTest, 'Expecting that instance of class was returned');
    }

    @isTest
    static void givenNoBindingsGetInstanceShouldThrowException(){

        //given
        String dummyBindingName = 'UnknownBinding';
        di_Module module=new di_Module();
        di_Injector injector = new di_Injector(module);

        //when
        try {
            injector.getInstance(dummyBindingName, null);
            System.assert(false, 'Expecting that exception was thrown');
        } catch (di_Injector.InjectorException excp) {
            //then
            System.assertEquals('Binding for "' + dummyBindingName + '" not found', excp.getMessage(), 'Expecting specific exception message');
        }

    }

    public interface InterfaceForTest {
        void implementMe();
    }

    public class ClassForTest implements InterfaceForTest {
        public ClassForTest() { }
        public void implementMe(){}
    }

}