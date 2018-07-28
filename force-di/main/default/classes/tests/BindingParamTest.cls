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
private class BindingParamTest {

    @IsTest
    private static void givenStringsWhenGetParameterThenGetValues() {

        Map<String, Object> inputs = new Map<String, Object>{
            'text' => 'Quick brown fox',
            'number' => '42',
            'truthy' => 'true',
            'falsey' => 'false',
            'date' => Date.newInstance( 2018, 8, 18 ),
            'dateTime' => DateTime.newInstance( 2018, 8, 18, 8, 8, 8 ),
            'strings' => new String[] { 'apple', '1', null }
        };

        BindingParam.Request request;
        BindingParam.Response response;

        Test.startTest();

        BindingParam.parameters = inputs;

        // text

        request = new BindingParam.Request();
        request.paramName = 'text';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( null, response.longValue );
        System.assertEquals( null, response.decimalValue );
        System.assertEquals( inputs.get('text'), response.stringValue );
        System.assertEquals( false, response.booleanValue );
        System.assertEquals( null, response.dateValue );
        System.assertEquals( null, response.dateTimeValue );

        // number

        request = new BindingParam.Request();
        request.paramName = 'number';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 42, response.longValue );
        System.assertEquals( 42.0, response.decimalValue );
        System.assertEquals( inputs.get('number'), response.stringValue );
        System.assertEquals( false, response.booleanValue );
        System.assertEquals( null, response.dateValue );
        System.assertEquals( null, response.dateTimeValue );

        // truthy

        // falsey

        // date

        // dateTime

        Test.stopTest();

    }

}