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
private class BindingTest {

    @IsTest
    private static void givenApexBindingWhenGetInstanceThenInstance() {
        // Given
        Binding binding = Binding.newInstance(
            Binding.BIndingType.Apex, 
            Bob.class.getName(), null, null, Bob.class.getName(), null);
        // When
        Object boundInstance = Binding.getInstance();
        // Then
        System.assert(boundInstance instanceof Bob);
    }

    @IsTest
    private static void givenApexBindingWhenGetInstanceWithParamThenInstanceWithParam() {
        // Given
        Binding binding = Binding.newInstance(
            Binding.BIndingType.Apex, 
            Bob.class.getName(), null, null, ProviderImpl.class.getName(), null);
        // When
        Object boundInstance = Binding.getInstance('Some value');
        // Then
        System.assert(boundInstance instanceof Bob);
        System.assertEquals('Some value', ((Bob) boundInstance).Name);
    }

    public class Bob { 
        public String Name {get;private set;}
        public Bob() { }
        public Bob(String name) { this.Name = name; }
    }

    public class ProviderImpl implements Binding.Provider { 
        public Object newInstance(Object params) {
            return new Bob((String) params);
        }
    }
}
