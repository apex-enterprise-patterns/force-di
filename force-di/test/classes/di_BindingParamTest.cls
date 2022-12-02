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
private class di_BindingParamTest {

    @IsTest
    private static void givenNullInputWhenGetParameterThenGetNullValue() {

        Map<String, Object> inputs = null;

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        request = new di_BindingParam.Request();
        request.paramName = 'foo';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.isNull(response.stringValue );
        Assert.isNull(response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        Assert.areEqual( 0, response.longValues.size() );
        Assert.areEqual( 0, response.decimalValues.size() );
        Assert.areEqual( 0, response.stringValues.size() );
        Assert.areEqual( 0, response.booleanValues.size() );
        Assert.areEqual( 0, response.dateValues.size() );
        Assert.areEqual( 0, response.dateTimeValues.size() );

        Test.stopTest();

    }

    @IsTest
    private static void givenUnknownKeyWhenGetParameterThenGetNullValue() {

        Map<String, Object> inputs = new Map<String, Object>();

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        request = new di_BindingParam.Request();
        request.paramName = 'foo';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.isNull(response.stringValue );
        Assert.isNull(response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        Assert.areEqual( 0, response.longValues.size() );
        Assert.areEqual( 0, response.decimalValues.size() );
        Assert.areEqual( 0, response.stringValues.size() );
        Assert.areEqual( 0, response.booleanValues.size() );
        Assert.areEqual( 0, response.dateValues.size() );
        Assert.areEqual( 0, response.dateTimeValues.size() );

        Test.stopTest();

    }

    @IsTest
    private static void givenDecimalsWhenGetParameterThenGetValues() {

        Long expectedDateMillisGMT = DateTime.newInstance( 2018, 8, 8, 0, 0, 0 ).getTime();
        Long expectedDateTimeMillisGMT = DateTime.newInstance( 2018, 8, 8, 8, 8, 8 ).getTime();

        Map<String, Object> inputs = new Map<String, Object>{
            'number' => 42,
            'truthy' => 1,
            'falsey' => 0,
            'date' => expectedDateMillisGMT,
            'dateTime' => expectedDateTimeMillisGMT,
            'decimals' => new Decimal[] { 0, 1, 2 }
        };

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        // number

        request = new di_BindingParam.Request();
        request.paramName = 'number';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 42, response.longValue );
        Assert.areEqual( 42.0, response.decimalValue );
        Assert.areEqual( '42', response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.areEqual( DateTime.newInstance(42).date(), response.dateValue );
        Assert.areEqual( DateTime.newInstance(42), response.dateTimeValue );

        // truthy

        request = new di_BindingParam.Request();
        request.paramName = 'truthy';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 1, response.longValue );
        Assert.areEqual( 1.0, response.decimalValue );
        Assert.areEqual( '1', response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.areEqual( DateTime.newInstance(1).date(), response.dateValue );
        Assert.areEqual( DateTime.newInstance(1), response.dateTimeValue );

        // falsey

        request = new di_BindingParam.Request();
        request.paramName = 'falsey';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 0, response.longValue );
        Assert.areEqual( 0, response.decimalValue );
        Assert.areEqual( '0', response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.areEqual( DateTime.newInstance(0).date(), response.dateValue );
        Assert.areEqual( DateTime.newInstance(0), response.dateTimeValue );

        // date

        request = new di_BindingParam.Request();
        request.paramName = 'date';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( expectedDateMillisGMT, response.longValue );
        Assert.areEqual( expectedDateMillisGMT, response.decimalValue );
        Assert.areEqual( String.valueOf( expectedDateMillisGMT ), response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.isTrue( DateTime.newInstance( expectedDateMillisGMT ).date().isSameDay( response.dateValue ) );
        Assert.areEqual( DateTime.newInstance( expectedDateMillisGMT ), response.dateTimeValue );

        // dateTime

        request = new di_BindingParam.Request();
        request.paramName = 'dateTime';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( expectedDateTimeMillisGMT, response.longValue );
        Assert.areEqual( expectedDateTimeMillisGMT, response.decimalValue );
        Assert.areEqual( String.valueOf( expectedDateTimeMillisGMT ), response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.isTrue( DateTime.newInstance( expectedDateTimeMillisGMT ).date().isSameDay( response.dateValue ) );
        Assert.areEqual( DateTime.newInstance( expectedDateTimeMillisGMT ), response.dateTimeValue );

        // decimals

        request = new di_BindingParam.Request();
        request.paramName = 'decimals';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 3, response.decimalValues.size() );
        Assert.areEqual( response.decimalValue, response.decimalValues[0] );

        Test.stopTest();

    }

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

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        // text

        request = new di_BindingParam.Request();
        request.paramName = 'text';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.areEqual( inputs.get('text'), response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        // number

        request = new di_BindingParam.Request();
        request.paramName = 'number';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 42, response.longValue );
        Assert.areEqual( 42.0, response.decimalValue );
        Assert.areEqual( inputs.get('number'), response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        // truthy

        request = new di_BindingParam.Request();
        request.paramName = 'truthy';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.areEqual( inputs.get('truthy'), response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        // falsey

        request = new di_BindingParam.Request();
        request.paramName = 'falsey';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.areEqual( inputs.get('falsey'), response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        // date

        request = new di_BindingParam.Request();
        request.paramName = 'date';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.areEqual( inputs.get('date'), response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.areEqual( testDateTime.date(), response.dateValue );
        Assert.areEqual( testDateTime.date(), response.dateTimeValue.dateGmt() ); // hours will be zero'ed out

        // dateTime

        request = new di_BindingParam.Request();
        request.paramName = 'dateTime';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.isNull(response.longValue );
        Assert.isNull(response.decimalValue );
        Assert.areEqual( inputs.get('dateTime'), response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.areEqual( testDateTime.date(), response.dateValue );
        Assert.areEqual( testDateTime, response.dateTimeValue );

        // strings

        request = new di_BindingParam.Request();
        request.paramName = 'strings';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 3, response.stringValues.size() );
        Assert.areEqual( response.stringValue, response.stringValues[0] );

        Test.stopTest();

    }

    @IsTest
    private static void givenBooleansWhenGetParameterThenGetValues() {

        Map<String, Object> inputs = new Map<String, Object>{
            'truthy' => true,
            'falsey' => false,
            'booleans' => new Boolean[] { true, false }
        };

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        // truthy

        request = new di_BindingParam.Request();
        request.paramName = 'truthy';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 1, response.longValue );
        Assert.areEqual( 1.0, response.decimalValue );
        Assert.areEqual( 'true', response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        // falsey

        request = new di_BindingParam.Request();
        request.paramName = 'falsey';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 0, response.longValue );
        Assert.areEqual( 0, response.decimalValue );
        Assert.areEqual( 'false', response.stringValue );
        Assert.areEqual( false, response.booleanValue );
        Assert.isNull(response.dateValue );
        Assert.isNull(response.dateTimeValue );

        // booleans

        request = new di_BindingParam.Request();
        request.paramName = 'booleans';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 2, response.booleanValues.size() );
        Assert.areEqual( response.booleanValue, response.booleanValues[0] );

        Test.stopTest();

    }

    @IsTest
    private static void givenDatesWhenGetParameterThenGetValues() {

        Date testDate = Date.today();
        DateTime testDateTime = DateTime.newInstance( testDate.year(), testDate.month(), testDate.day(), 0, 0, 0 );

        Map<String, Object> inputs = new Map<String, Object>{
            'date' => testDate,
            'dates' => new Date[] { testDate, testDate.addDays(1) }
        };

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        // date

        request = new di_BindingParam.Request();
        request.paramName = 'date';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( testDateTime.getTime(), response.longValue );
        Assert.areEqual( testDateTime.getTime(), response.decimalValue );
        Assert.areEqual( String.valueOf( testDate ), response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.areEqual( testDate, response.dateValue );
        Assert.areEqual( testDateTime, response.dateTimeValue );

        // dates

        request = new di_BindingParam.Request();
        request.paramName = 'dates';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 2, response.dateValues.size() );
        Assert.areEqual( response.dateValue, response.dateValues[0] );

        Test.stopTest();

    }

    @IsTest
    private static void givenDateTimesWhenGetParameterThenGetValues() {

        Date testDate = Date.today();
        DateTime testDateTime = DateTime.newInstance( testDate.year(), testDate.month(), testDate.day(), 0, 0, 0 );

        Map<String, Object> inputs = new Map<String, Object>{
            'dateTime' => testDateTime,
            'dateTimes' => new DateTime[] { testDateTime, testDateTime.addDays(1) }
        };

        di_BindingParam.Request request;
        di_BindingParam.Response response;

        Test.startTest();

        di_BindingParam.parameters = inputs;

        // date

        request = new di_BindingParam.Request();
        request.paramName = 'dateTime';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( testDateTime.getTime(), response.longValue );
        Assert.areEqual( testDateTime.getTime(), response.decimalValue );
        Assert.areEqual( String.valueOf( testDateTime ), response.stringValue );
        Assert.areEqual( true, response.booleanValue );
        Assert.areEqual( testDateTime.date(), response.dateValue );
        Assert.areEqual( testDateTime, response.dateTimeValue );

        // dates

        request = new di_BindingParam.Request();
        request.paramName = 'dateTimes';

        response = di_BindingParam.invoke( new di_BindingParam.Request[] { request } )[0];

        Assert.areEqual( 2, response.dateTimeValues.size() );
        Assert.areEqual( response.dateTimeValue, response.dateTimeValues[0] );

        Test.stopTest();

    }

}