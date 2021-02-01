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

@IsTest
@TestVisible
private class di_BindingTest {

    @IsTest
    private static void givenApexBindingWhenGetInstanceThenInstance() {
        // Given
        di_Binding binding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Bob.class.getName(), null, null, Bob.class.getName(), null);
        // When
        Object boundInstance1 = binding.getInstance();
        Object boundInstance2 = binding.getInstance();
        // Then
        System.assert(boundInstance1 instanceof Bob);
        System.assert(boundInstance1 === boundInstance2);
    }

    @IsTest
    private static void givenApexBindingWhenGetInstanceWithParamThenInstanceWithParam() {
        // Given
        di_Binding binding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Bob.class.getName(), null, null, ProviderImpl.class.getName(), null);
        // When
        Object boundInstance1 = binding.getInstance('Some value 1');
        Object boundInstance2 = binding.getInstance('Some value 2');
        // Then
        System.assert(boundInstance1 instanceof Bob);
        System.assertEquals('Some value 1', ((Bob) boundInstance1).Name);
        System.assert(boundInstance2 instanceof Bob);
        System.assertEquals('Some value 2', ((Bob) boundInstance2).Name);
    }
    
    @IsTest
    private static void givenIncorrectApexBindingWhenGetInstanceThenThrowException() {
        try{
            //When
            di_Binding binding = di_Binding.newInstance(
            null, Bob.class.getName(), null, null, ProviderImpl.class.getName(), null);
            System.assert(false, 'No Exception was thrown.');
        } catch(Exception ex){
            //Then
            System.assert(ex instanceOf di_Binding.BindingException,'Exception thrown was not of type "di_Binding.BindingException"');
        }
    }
    
    @IsTest
    private static void givenApexBindingsWithDeveloperNamesWhenSortThenReturnSortedBindingsList() {
        
        List<di_Binding> bindings = new List<di_Binding>();
        List<di_Binding> sortedExpectedBindings = new List<di_Binding>();
        
        di_Binding zoroBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Zoro.class.getName(), null, null, ProviderImpl.class.getName(), null);
        bindings.add(zoroBinding);
        
        di_Binding charlieBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Charlie.class.getName(), null, null, ProviderImpl.class.getName(), null);
        bindings.add(charlieBinding);
        
        di_Binding bobBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Bob.class.getName(), null, null, ProviderImpl.class.getName(), null);
        bindings.add(bobBinding);
        
        bindings.sort();
        
        //Sorted based on developer names
        sortedExpectedBindings.add(bobBinding);
        sortedExpectedBindings.add(charlieBinding);
        sortedExpectedBindings.add(zoroBinding);
        
        
        System.assertEquals(sortedExpectedBindings, bindings, 'Binding sorted by default Developer Names');
    }
    
    @IsTest
    private static void givenApexBindingsWithSobjectTypesWhenSortThenReturnSortedBindingsList() {
        
        List<di_Binding> bindings = new List<di_Binding>();
        List<di_Binding> sortedExpectedBindings = new List<di_Binding>();
        
        di_Binding zoroBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Zoro.class.getName(), Contact.sObjectType, null, ProviderImpl.class.getName(), null);
        bindings.add(zoroBinding);
        
        di_Binding charlieBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Charlie.class.getName(), Account.sObjectType, null, ProviderImpl.class.getName(), null);
        bindings.add(charlieBinding);
        
        di_Binding bobBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Bob.class.getName(), Opportunity.sObjectType, null, ProviderImpl.class.getName(), null);
        bindings.add(bobBinding);
        
        bindings.sort();
        
        //Sorted based on binding sObject types
        sortedExpectedBindings.add(charlieBinding);
        sortedExpectedBindings.add(zoroBinding);
        sortedExpectedBindings.add(bobBinding);

        System.assertEquals(sortedExpectedBindings, bindings, 'Binding sorted by default Developer Names');
    }
    
    @IsTest
    private static void givenApexBindingsWithSequenceWhenSortThenReturnSortedBindingsList() {
        
        List<di_Binding> bindings = new List<di_Binding>();
        List<di_Binding> sortedExpectedBindings = new List<di_Binding>();
        
        di_Binding zoroBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Zoro.class.getName(), Contact.sObjectType, 2, ProviderImpl.class.getName(), null);
        bindings.add(zoroBinding);
        
        di_Binding charlieBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Charlie.class.getName(), Account.sObjectType, 3, ProviderImpl.class.getName(), null);
        bindings.add(charlieBinding);
        
        di_Binding bobBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            Bob.class.getName(), Account.sObjectType, 1, ProviderImpl.class.getName(), null);
        bindings.add(bobBinding);
        
        bindings.sort();
        
        //Sorted based on binding sequence
        sortedExpectedBindings.add(bobBinding);
        sortedExpectedBindings.add(charlieBinding);
        sortedExpectedBindings.add(zoroBinding);

        System.assertEquals(sortedExpectedBindings, bindings, 'Binding sorted by default Developer Names');
    }

    @IsTest
    private static void givenFlowBindingWhenGetInstanceThenInstance()
    {
        // Given
        di_Binding binding = di_Binding.newInstance(
            di_Binding.BindingType.Flow,
            Bob.class.getName(), null, null, Bob.class.getName(), null);
        
        // When
        try {
            Object boundInstance1 = binding.getInstance();
            System.assert(false, 'Based on current limitation of inability to setup a flow dynamically, we should not ever arive at this line.');
        }
        // Then
        catch (System.Exception e){
            System.assert(e instanceof System.TypeException, 'Since we cannot actually test with a live flow, we expect that the exception will be a System.TypeException.  Instead received ' + e);
            System.assert('Invalid type: di_BindingTest.Bob'.equalsIgnoreCase( e.getMessage() ), 'Since we cannot actually test with a live flow, we expect that the exception will be a System.TypeException with a message "Invalid type: di_BindingTest.Bob".  Instead received ' + e.getMessage());
        }
    }

    @IsTest
    private static void givenLightningComponentBindingWhenGetInstanceThenInstance()
    {
        // Given
        di_Binding binding = di_Binding.newInstance(
            di_Binding.BindingType.LightningComponent,
            null, null, null, Bob.class.getName(), null);
        
        // When
        Object boundInstance1 = binding.getInstance();
        
        // Then
        System.assert(boundInstance1 instanceOf String);
    }

    @IsTest
    private static void givenVisualForceComponentBindingWhenGetInstanceThenInstance()
    {
        // Given
        di_Binding bindingVF1 = di_Binding.newInstance(
            di_Binding.BindingType.VisualforceComponent,
            Bob.class.getName(), null, null, ProviderImpl.class.getName(), null);
        
        // When
        // try {
            Object boundInstance1 = bindingVF1.getInstance();
        //     System.assert(false, 'Based on current limitation of inability to setup a flow dynamically, we should not ever arive at this line.');
        // }
        // // Then
        // catch (System.Exception e){
        //     System.assert(e instanceof System.TypeException, 'Since we cannot actually test with a live flow, we expect that the exception will be a System.TypeException.  Instead received ' + e);
        //     System.assert('Invalid type: di_BindingTest.Bob'.equalsIgnoreCase( e.getMessage() ), 'Since we cannot actually test with a live flow, we expect that the exception will be a System.TypeException with a message "Invalid type: di_BindingTest.Bob".  Instead received ' + e.getMessage());
        // }
    }
    
    @IsTest
    private static void givenVisualForceComponentBindingDoesNotExistWhenGetInstanceThenBindingException()
    {
        // Given
        di_Binding bindingVF2 = di_Binding.newInstance(
            di_Binding.BindingType.VisualforceComponent,
            Bob.class.getName(), null, null, 'FakeProviderClassName', null);
        
        // When
        try {
            Object boundInstance1 = bindingVF2.getInstance();
        // Then
            System.assert(false, 'Unexpected behavior.  Expected that BinderException to be thrown.');
        }
        catch (System.Exception e){
            System.assert(e instanceof di_Binding.BindingException, 'Unexpected behavior.  Since the ProviderName was a fake, non-existent class, the di_Binding.BindingException should have been thrown.  Instead received ' + e);
            System.assert('Visualforce Component binding di_BindingTest.Bob implementation FakeProviderClassName does not exist.'.equalsIgnoreCase( e.getMessage() ), 'Unexpected error message received.  Received ' + e.getMessage());
        }
    }
    
    @IsTest
    private static void givenVisualForceComponentBindingNotProviderWhenGetInstanceThenBindingException()
    {
        // Given
        di_Binding bindingVF3 = di_Binding.newInstance(
            di_Binding.BindingType.VisualforceComponent,
            Bob.class.getName(), null, null, Bob.class.getName(), null);
        
        // When
        try {
            Object boundInstance1 = bindingVF3.getInstance();
        // Then
            System.assert(false, 'Unexpected behavior.  Expected that BinderException to be thrown.');
        }
        catch (System.Exception e){
            System.assert(e instanceof di_Binding.BindingException, 'Unexpected behavior.  Since the ProviderName was a fake, non-existent class, the di_Binding.BindingException should have been thrown.  Instead received ' + e);
            System.assert('Visualforce Component binding di_BindingTest.Bob must point to a class implementing the Provider interface.'.equalsIgnoreCase( e.getMessage() ), 'Unexpected error message received.  Received ' + e.getMessage());
        }
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
    
    public class Zoro {

    }
    
    public class VFTestBinding {
        public String Name {get;private set;}
        public VFTestBinding() { }
        public VFTestBinding(String name) { this.Name = name; }
    }

    public class ProviderImpl implements di_Binding.Provider {
        public Object newInstance(Object params) {
            return new Bob((String) params);
        }
    }
    
    public class VFProviderImpl implements di_Binding.Provider {
        public Object newInstance(Object params) {
            return new VFTestBinding((String) params);
        }
    }
}