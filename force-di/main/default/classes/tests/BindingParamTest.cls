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

        TimeZone userTimeZone = UserInfo.getTimeZone();
        DateTime testDateTime = DateTime.newInstance(2018,8,8,8,8,8);
        Long offsetMillis = userTimeZone.getOffset( testDateTime );
        Long offsetHours = offsetMillis / ( 1000 * 60 * 60 );
        String offset = ( offsetHours > 0 ? '+' + offsetHours : '' + offsetHours );
        String dateFormat = 'yyyy-MM-dd';
        String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss' + offset;

        Map<String, Object> inputs = new Map<String, Object>{
            'text' => 'Quick brown fox',
            'number' => '42',
            'truthy' => 'true',
            'falsey' => 'false',
            'date' => testDateTime.format( dateFormat ),
            'dateTime' => testDateTime.format( dateTimeFormat ),
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

        request = new BindingParam.Request();
        request.paramName = 'truthy';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( null, response.longValue );
        System.assertEquals( null, response.decimalValue );
        System.assertEquals( inputs.get('truthy'), response.stringValue );
        System.assertEquals( true, response.booleanValue );
        System.assertEquals( null, response.dateValue );
        System.assertEquals( null, response.dateTimeValue );

        // falsey

        request = new BindingParam.Request();
        request.paramName = 'falsey';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( null, response.longValue );
        System.assertEquals( null, response.decimalValue );
        System.assertEquals( inputs.get('falsey'), response.stringValue );
        System.assertEquals( false, response.booleanValue );
        System.assertEquals( null, response.dateValue );
        System.assertEquals( null, response.dateTimeValue );

        // date

        request = new BindingParam.Request();
        request.paramName = 'date';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( null, response.longValue );
        System.assertEquals( null, response.decimalValue );
        System.assertEquals( inputs.get('date'), response.stringValue );
        System.assertEquals( false, response.booleanValue );
        System.assertEquals( testDateTime.date(), response.dateValue );
        System.assertEquals( testDateTime.dateGMT(), response.dateTimeValue ); // hours will be zero'ed out

        // dateTime

        request = new BindingParam.Request();
        request.paramName = 'dateTime';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( null, response.longValue );
        System.assertEquals( null, response.decimalValue );
        System.assertEquals( inputs.get('dateTime'), response.stringValue );
        System.assertEquals( false, response.booleanValue );
        System.assertEquals( testDateTime.date(), response.dateValue );
        System.assertEquals( testDateTime, response.dateTimeValue );

        // strings

        request = new BindingParam.Request();
        request.paramName = 'strings';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 3, response.stringValues.size() );
        System.assertEquals( response.stringValue, response.stringValues[0] );

        Test.stopTest();

    }

    @IsTest
    private static void givenDecimalsWhenGetParameterThenGetValues() {

        Map<String, Object> inputs = new Map<String, Object>{
            'number' => 42,
            'truthy' => 1,
            'falsey' => 0,
            'date' => DateTime.newInstance( 2018, 8, 8, 0, 0, 0 ).getTime(),
            'dateTime' => DateTime.newInstance( 2018, 8, 8, 8, 8, 8 ).getTime(),
            'decimals' => new Long[] { 0, 1, 2 }
        };

        BindingParam.Request request;
        BindingParam.Response response;

        Test.startTest();

        BindingParam.parameters = inputs;

        // number

        request = new BindingParam.Request();
        request.paramName = 'number';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 42, response.longValue );
        System.assertEquals( 42.0, response.decimalValue );
        System.assertEquals( '42', response.stringValue );
        System.assertEquals( true, response.booleanValue );
        System.assertEquals( DateTime.newInstance(42).date(), response.dateValue );
        System.assertEquals( DateTime.newInstance(42), response.dateTimeValue );

        // truthy

        request = new BindingParam.Request();
        request.paramName = 'truthy';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 1, response.longValue );
        System.assertEquals( 1.0, response.decimalValue );
        System.assertEquals( '1', response.stringValue );
        System.assertEquals( true, response.booleanValue );
        System.assertEquals( DateTime.newInstance(1).date(), response.dateValue );
        System.assertEquals( DateTime.newInstance(1), response.dateTimeValue );

        // falsey

        request = new BindingParam.Request();
        request.paramName = 'falsey';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 0, response.longValue );
        System.assertEquals( 0, response.decimalValue );
        System.assertEquals( '0', response.stringValue );
        System.assertEquals( false, response.booleanValue );
        System.assertEquals( DateTime.newInstance(0).date(), response.dateValue );
        System.assertEquals( DateTime.newInstance(0), response.dateTimeValue );

        // date

        request = new BindingParam.Request();
        request.paramName = 'date';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 1533711600000L, response.longValue );
        System.assertEquals( 1533711600000.0, response.decimalValue );
        System.assertEquals( '1533711600000', response.stringValue );
        System.assertEquals( true, response.booleanValue );
        System.assertEquals( Date.newInstance( 2018, 8, 8 ), response.dateValue );
        System.assertEquals( DateTime.newInstance( 2018, 8, 8, 0, 0, 0 ), response.dateTimeValue );

        // dateTime

        request = new BindingParam.Request();
        request.paramName = 'dateTime';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 1533740888000L, response.longValue );
        System.assertEquals( 1533740888000.0, response.decimalValue );
        System.assertEquals( '1533740888000', response.stringValue );
        System.assertEquals( true, response.booleanValue );
        System.assertEquals( DateTime.newInstance( 2018, 8, 8, 8, 8, 8 ).date(), response.dateValue );
        System.assertEquals( DateTime.newInstance( 2018, 8, 8, 8, 8, 8 ), response.dateTimeValue );

        // decimals

        request = new BindingParam.Request();
        request.paramName = 'decimals';

        response = BindingParam.invoke( new BindingParam.Request[] { request } )[0];

        System.assertEquals( 3, response.decimalValues.size() );
        System.assertEquals( response.decimalValue, response.decimalValues[0] );

        Test.stopTest();

    }

}