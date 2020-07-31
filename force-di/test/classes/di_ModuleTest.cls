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
  * --------------
  * B Anderson : Gettting the overall code-coverage > 75%
  */ 
@IsTest
private class di_ModuleTest {

    @isTest
    static void givenBindingInModuleWhenSetTypeThenGetModule(){

        // Given
        di_Module module=new di_Module();
        di_Binding bobBinding = di_Binding.newInstance(
            di_Binding.BindingType.Apex,
            di_BindingTest.Bob.class.getName(), null, null,
            di_BindingTest.Bob.class.getName(), null);
        List<di_Binding> bindings = new List<di_Binding> {
            bobBinding
        };
        module.getBindings().add(bobBinding);
        // Then
        system.assertEquals(module, module.type(di_Binding.BindingType.Apex.name()));
        // gt bindings
        system.assertEquals(bindings, module.getBindings());
    }

    @isTest
    static void givenBadBindingTypeThenGetModuleException(){

        // Given
        di_Module module=new di_Module();
        // Then
        Boolean moduleExceptionThrown=false;
        try {
            module.type('not-valid');
        } catch(di_Module.ModuleException excp) {
            moduleExceptionThrown=true;

        }
        system.assertEquals(true,moduleExceptionThrown);
    }

    @isTest
    static void givenModuleWhenSettingValuesThenGet(){

        // Given
        di_Module module=new di_Module();
        // When
        module.type(di_Binding.BindingType.Apex)
        .data('test')
        .sequence(1)
        .bind(di_BindingTest.Bob.class);
        di_Module mod= module.to(di_BindingTest.Bob.class);
 
        List<di_Binding> bindings = module.getBindings();
     
        // Then
        system.assertEquals('test',(String)bindings[0].Data);
        system.assertEquals('apex',(String)bindings[0].BindingTypeAsString.toLowerCase());
        system.assertEquals(1,bindings[0].bindingSequence);
    }
}
