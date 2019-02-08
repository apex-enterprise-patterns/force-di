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
public class RuntimeBindingDemoOrgTest {
    
    @IsTest
    private static void givenDisplayAndMessageWhenRunAppThenMessageReturned() {
        // Given
        di_Injector.Org.Bindings.set(new di_Module().type(String.valueOf('Apex')).apex()
                                     .bind(Message.class).sequence(1).toObject(Test.createStub(Message.class, new MockMessage('Say Something Message')))
                                     .bind(Display.class).sequence(2).toObject(Test.createStub(Display.class, new MockDisplay('Startup Message'))));
        // When
        RuntimeBindingDemoOrg.WelcomeApp app = new RuntimeBindingDemoOrg.WelcomeApp();
        String message = app.greetings();
        // Then
        System.assertEquals('Startup Message:Say Something Message', message);
    }
    
    @IsTest
    private static void givenOnlyMessageWhenRunAppThenThrowInjectorException() {
        // Given
        di_Injector.Org.Bindings.set(new di_Module().type(di_Binding.BindingType.Apex)
                                     .bind(String.valueOf('Message')).data(Test.createStub(Message.class, new MockMessage('Say Something Message'))).to(Message.class));
        
        // When
        try{
            RuntimeBindingDemoOrg.WelcomeApp app = new RuntimeBindingDemoOrg.WelcomeApp();
            String message = app.greetings();
            System.assert(false, 'Expected di_Injector.InjectorException');
        } catch(Exception ex){
        //Then
            System.assert(true, ex.getMessage().contains('di_Injector.InjectorException: Binding for "display" not found'));
        }
    }
    
    @IsTest
    private static void givenIncorrectBindingTypeWhenInjectorBindingsSetThenThrowModuleException() {
        try{
        	di_Injector.Org.Bindings.set(new di_Module().type(String.valueOf('Apex_False')).apex()
            	.bind(Message.class).sequence(1).toObject(Test.createStub(Message.class, new MockMessage('Say Something Message')))
				.bind(Display.class).sequence(2).toObject(Test.createStub(Display.class, new MockDisplay('Startup Message'))));
        	RuntimeBindingDemoOrg.WelcomeApp app = new RuntimeBindingDemoOrg.WelcomeApp();
        	String message = app.greetings();
            System.assert(false, 'Expected di_Module.ModuleException');
        } catch(Exception ex){
       	// Then 
       		System.assert(true, ex.getMessage().contains('di_Module.ModuleException: Binding type Apex_False is not valid.'));
        }
    }
    
    
    @IsTest
    private static void givenOnlyMessageWhenRunAppThenThrowInjectorException1() {
        // Given
        di_Injector.Org.Bindings.set(new di_Module().type(di_Binding.BindingType.Apex)
                                     .bind(String.valueOf('Message')).data(Test.createStub(Message.class, new MockMessage('Say Something Message'))).to(Message.class));
        
        // When
        try{
            RuntimeBindingDemoOrg.WelcomeApp app = new RuntimeBindingDemoOrg.WelcomeApp();
            String message = app.greetings();
            System.assert(false, 'Expected di_Injector.InjectorException');
        } catch(Exception ex){
        //Then
            System.assert(true, ex.getMessage().contains('di_Injector.InjectorException: Binding for "display" not found'));
        }
    }   
     
    @IsTest
    private static void givenIncorrectBindingTypeWhenInjectorBindingsSetThenThrowModuleException1() {
        // Given
         di_Injector injector = new di_Injector(new di_Module());
        
        // When
        RuntimeBindingDemoOrg.WelcomeApp app = new RuntimeBindingDemoOrg.WelcomeApp();
        String message = app.greetings();
        // Then
        //System.assertEquals('Startup Message:Say Something Message', message);
    }
    
    /**
	* Mock for Message
	**/
    private class MockMessage implements System.StubProvider {
        private String mockOutput;
        public MockMessage(String mockOutput) {
            this.mockOutput = mockOutput;
        }
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs) {
                if(stubbedMethodName == 'saySomething') {
                    return mockOutput;
                }
                return null;
            }
    }
    
    /**
	* Mock for Display
	**/
    private class MockDisplay implements System.StubProvider {
        private String mockOutput;
        public MockDisplay(String mockOutput) {
            this.mockOutput = mockOutput;
        }
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs) {
                if(stubbedMethodName == 'startup') {
                    return mockOutput;
                }
                return null;
            }
    }
}