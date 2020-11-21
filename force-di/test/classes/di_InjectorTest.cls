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