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
private class di_BindingTest {

    @IsTest
    private static void givenApexBindingWhenGetInstanceThenInstance() {
        // Given
        di_Binding binding = di_Binding.newInstance(
            di_Binding.BIndingType.Apex,
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
            di_Binding.BIndingType.Apex,
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

    public class Bob {
        public String Name {get;private set;}
        public Bob() { }
        public Bob(String name) { this.Name = name; }
    }

    public class ProviderImpl implements di_Binding.Provider {
        public Object newInstance(Object params) {
            return new Bob((String) params);
        }
    }
}
