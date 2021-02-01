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

public with sharing class di_BindingParam {

    public static Map<String, Object> parameters { get; set; }

    // -----------------------------------------------------------

    @InvocableMethod(
        label = 'Get Value'
    )
    public static List<Response> invoke( List<Request> requests ) {

        List<Response> responses = new List<Response>();

        for ( Request req : requests ) {

            Response res = new Response();

            if ( parameters != null ) {

                Object value = parameters.get( req.paramName );

                if ( value != null ) {

                    if ( value instanceof Decimal ) { // handles Decimal, Long, Double, Integer

                        Decimal decimalValue = (Decimal) value;
                        res.longValue = toLongValue( decimalValue );
                        res.decimalValue = decimalValue;
                        res.stringValue = toStringValue( decimalValue );
                        res.booleanValue = toBooleanValue( decimalValue );
                        res.dateValue = toDateValue( decimalValue );
                        res.dateTimeValue = toDateTimeValue( decimalValue );

                    } else if ( value instanceof Decimal[] ) {

                        Decimal[] decimalValues = (Decimal[]) value;
                        res.decimalValues = decimalValues;
                        for ( Decimal decimalValue : decimalValues ) {
                            res.longValues.add( toLongValue( decimalValue ) );
                            res.stringValues.add( toStringValue( decimalValue ) );
                            res.booleanValues.add( toBooleanValue( decimalValue ) );
                            res.dateValues.add( toDateValue( decimalValue ) );
                            res.dateTimeValues.add( toDateTimeValue( decimalValue ) );
                        }

                    } else if ( value instanceof String ) {

                        String stringValue = (String) value;
                        res.longValue = toLongValue( stringValue );
                        res.decimalValue = toDecimalValue( stringValue );
                        res.stringValue = stringValue;
                        res.booleanValue = toBooleanValue( stringValue );
                        res.dateValue = toDateValue( stringValue );
                        res.dateTimeValue = toDateTimeValue( stringValue );

                    } else if ( value instanceof String[] ) {

                        String[] stringValues = (String[]) value;
                        res.stringValues = stringValues;
                        for ( String stringValue : stringValues ) {
                            res.longValues.add( toLongValue( stringValue ) );
                            res.decimalValues.add( toDecimalValue( stringValue ) );
                            res.booleanValues.add( toBooleanValue( stringValue ) );
                            res.dateValues.add( toDateValue( stringValue ) );
                            res.dateTimeValues.add( toDateTimeValue( stringValue ) );
                        }

                    } else if ( value instanceof Boolean ) {

                        Boolean booleanValue = (Boolean) value;
                        res.longValue = toLongValue( booleanValue );
                        res.decimalValue = toDecimalValue( booleanValue );
                        res.stringValue = toStringValue( booleanValue );
                        res.booleanValue = booleanValue;
                        res.dateValue = toDateValue( booleanValue );
                        res.dateTimeValue = toDateTimeValue( booleanValue );

                    } else if ( value instanceof Boolean[] ) {

                        Boolean[] booleanValues = (Boolean[]) value;
                        res.booleanValues = booleanValues;
                        for ( Boolean booleanValue : booleanValues ) {
                            res.longValues.add( toLongValue( booleanValue ) );
                            res.decimalValues.add( toDecimalValue( booleanValue ) );
                            res.stringValues.add( toStringValue( booleanValue ) );
                            res.dateValues.add( toDateValue( booleanValue ) );
                            res.dateTimeValues.add( toDateTimeValue( booleanValue ) );
                        }

                    } else if ( value instanceof Date ) {

                        Date dateValue = (Date) value;
                        res.longValue = toLongValue( dateValue );
                        res.decimalValue = toDecimalValue( dateValue );
                        res.stringValue = toStringValue( dateValue );
                        res.booleanValue = toBooleanValue( dateValue );
                        res.dateValue = dateValue;
                        res.dateTimeValue = toDateTimeValue( dateValue );

                    } else if ( value instanceof Date[] ) {

                        Date[] dateValues = (Date[]) value;
                        res.dateValues = dateValues;
                        for ( Date dateValue : dateValues ) {
                            res.longValues.add( toLongValue( dateValue ) );
                            res.decimalValues.add( toDecimalValue( dateValue ) );
                            res.stringValues.add( toStringValue( dateValue ) );
                            res.booleanValues.add( toBooleanValue( dateValue ) );
                            res.dateTimeValues.add( toDateTimeValue( dateValue ) );
                        }

                    } else if ( value instanceof DateTime ) {

                        DateTime dateTimeValue = (DateTime) value;
                        res.longValue = toLongValue( dateTimeValue );
                        res.decimalValue = toDecimalValue( dateTimeValue );
                        res.stringValue = toStringValue( dateTimeValue );
                        res.booleanValue = toBooleanValue( dateTimeValue );
                        res.dateValue = toDateValue( dateTimeValue );
                        res.dateTimeValue = dateTimeValue;

                    } else if ( value instanceof DateTime[] ) {

                        DateTime[] dateTimeValues = (DateTime[]) value;
                        res.dateTimeValues = dateTimeValues;
                        for ( DateTime dateTimeValue : dateTimeValues ) {
                            res.longValues.add( toLongValue( dateTimeValue ) );
                            res.decimalValues.add( toDecimalValue( dateTimeValue ) );
                            res.stringValues.add( toStringValue( dateTimeValue ) );
                            res.booleanValues.add( toBooleanValue( dateTimeValue ) );
                            res.dateValues.add( toDateValue( dateTimeValue ) );
                        }

                    }

                    // if a collection was provided, then as convenience populate the single result value of same type
                    if ( res.longValue     == null && !res.longValues.isEmpty() )     { res.longValue = res.longValues[0]; }
                    if ( res.decimalValue  == null && !res.decimalValues.isEmpty() )  { res.decimalValue = res.decimalValues[0]; }
                    if ( res.stringValue   == null && !res.stringValues.isEmpty() )   { res.stringValue = res.stringValues[0]; }
                    if ( res.booleanValue  == null && !res.booleanValues.isEmpty() )  { res.booleanValue = res.booleanValues[0]; }
                    if ( res.dateValue     == null && !res.dateValues.isEmpty() )     { res.dateValue = res.dateValues[0]; }
                    if ( res.dateTimeValue == null && !res.dateTimeValues.isEmpty() ) { res.dateTimeValue = res.dateTimeValues[0]; }

                    // if a single value was provided, then as convenience add it to empty collection of same type
                    if ( res.longValue     != null && res.longValues.isEmpty() )     { res.longValues.add( res.longValue ); }
                    if ( res.decimalValue  != null && res.decimalValues.isEmpty() )  { res.decimalValues.add( res.decimalValue ); }
                    if ( res.stringValue   != null && res.stringValues.isEmpty() )   { res.stringValues.add( res.stringValue ); }
                    if ( res.booleanValue  != null && res.booleanValues.isEmpty() )  { res.booleanValues.add( res.booleanValue ); }
                    if ( res.dateValue     != null && res.dateValues.isEmpty() )     { res.dateValues.add( res.dateValue ); }
                    if ( res.dateTimeValue != null && res.dateTimeValues.isEmpty() ) { res.dateTimeValues.add( res.dateTimeValue ); }

                } else {

                    System.debug( LoggingLevel.WARN, 'BindingParam.parameters.get("' + req + '") is null' );

                }

            } else {

                System.debug( LoggingLevel.WARN, 'BindingParam.parameters is null' );

            }

            System.debug( 'paramName=' + req );
            System.debug( res );

            responses.add( res );

        }

        return responses;
    }

    // toLongValue
    // -----------------------------------------------------------

    private static Long toLongValue( Decimal value ) {
        return ( value == null ? null : value.longValue() );
    }

    private static Long toLongValue( String value ) {
        return ( ( value == null || !value.isNumeric() ) ? null : Long.valueOf( value ) );
    }

    private static Long toLongValue( Boolean value ) {
        return ( value == null ? null : value ? 1 : 0 );
    }

    private static Long toLongValue( Date value ) {
        return ( value == null ? null : toLongValue(
            DateTime.newInstance( value.year(), value.month(), value.day(), 0, 0, 0 )
        ));
    }

    private static Long toLongValue( DateTime value ) {
        return ( value == null ? null : value.getTime() );
    }

    // toDecimalValue
    // -----------------------------------------------------------

    private static Decimal toDecimalValue( String value ) {
        return ( ( value == null || !value.isNumeric() ) ? null : Decimal.valueOf( value ) );
    }

    private static Decimal toDecimalValue( Boolean value ) {
        return ( value == null ? null : value ? 1 : 0 );
    }

    private static Decimal toDecimalValue( Date value ) {
        return ( value == null ? null : toDecimalValue(
            DateTime.newInstance( value.year(), value.month(), value.day(), 0, 0, 0 )
        ));
    }

    private static Decimal toDecimalValue( DateTime value ) {
        return ( value == null ? null : value.getTime() );
    }

    // toStringValue
    // -----------------------------------------------------------

    // Because of oddity that Date, when cast to Object,
    // will output the date and time, then providing a method
    // to ensure dates are handled as we'd actually expect them to be.
    // https://twitter.com/DouglasCAyers/status/1023410001103269890
    private static String toStringValue( Date value ) {
        return ( value == null ? null : String.valueOf( value ) );
    }

    private static String toStringValue( DateTime value ) {
        return ( value == null ? null : String.valueOf( value ) );
    }

    private static String toStringValue( Object value ) {
        return ( value == null ? null : String.valueOf( value ) );
    }

    // toBooleanValue
    // -----------------------------------------------------------

    private static Boolean toBooleanValue( Decimal value ) {
        return ( value == null ? false : ( value > 0 ) );
    }

    private static Boolean toBooleanValue( String value ) {
        return ( value == null ? false : Boolean.valueOf( value ) );
    }

    private static Boolean toBooleanValue( Date value ) {
        return ( value == null ? false : true );
    }

    private static Boolean toBooleanValue( DateTime value ) {
        return ( value == null ? false : true );
    }

    // toDateValue
    // -----------------------------------------------------------

    private static Date toDateValue( Decimal value ) {
        return ( value == null ? null : DateTime.newInstance( value.longValue() ).date() );
    }

    private static Date toDateValue( String value ) {
        try {
            return ( value == null ? null : Date.valueOf( value ) ); // yyyy-MM-dd or yyyy-MM-dd HH:mm:ss
        } catch ( Exception e ) {
            return null;
        }
    }

    private static Date toDateValue( Boolean value ) {
        return null;
    }

    private static Date toDateValue( DateTime value ) {
        return ( value == null ? null : value.date() );
    }

    // toDateTimeValue
    // -----------------------------------------------------------

    private static DateTime toDateTimeValue( Decimal value ) {
        return ( value == null ? null : DateTime.newInstance( value.longValue() ) );
    }

    private static DateTime toDateTimeValue( String value ) {
        try {
            return ( value == null ? null : DateTime.valueOf( value ) ); // yyyy-MM-dd HH:mm:ss
        } catch ( Exception e ) {
            return toDateValue( value ); // retry, maybe string is only yyyy-MM-dd
        }
    }

    private static DateTime toDateTimeValue( Boolean value ) {
        return null;
    }

    private static DateTime toDateTimeValue( Date value ) {
        return ( value == null ? null : DateTime.newInstance( value.year(), value.month(), value.day(), 0, 0, 0 ) );
    }

    // -----------------------------------------------------------

    public class Request {

        @InvocableVariable(
            label = 'Parameter Name'
            required = true
        )
        public String paramName;

    }

    public class Response {

        @InvocableVariable(
            label = 'Number'
            description = 'Whole number (no decimals)'
        )
        public Long longValue;

        @InvocableVariable(
            label = 'Decimal'
            description = 'Number that may include decimal places'
        )
        public Decimal decimalValue;

        @InvocableVariable(
            label = 'Text'
            description = 'Text value'
        )
        public String stringValue;

        @InvocableVariable(
            label = 'Boolean'
            description = 'true/false'
        )
        public Boolean booleanValue;

        @InvocableVariable(
            label = 'Date'
        )
        public Date dateValue;

        @InvocableVariable(
            label = 'Date/Time'
        )
        public DateTime dateTimeValue;

        @InvocableVariable(
            label = 'Number Collection'
            description = 'Collection of whole numbers'
        )
        public Long[] longValues = new Long[] {};

        @InvocableVariable(
            label = 'Decimal Collection'
            description = 'Collection of numbers that may include decimal places'
        )
        public Decimal[] decimalValues = new Decimal[] {};

        @InvocableVariable(
            label = 'Text Collection'
            description = 'Collection of text values'
        )
        public String[] stringValues = new String[] {};

        @InvocableVariable(
            label = 'Boolean Collection'
            description = 'Collection of true/false values'
        )
        public Boolean[] booleanValues = new Boolean[] {};

        @InvocableVariable(
            label = 'Date Collection'
            description = 'Collection of date values'
        )
        public Date[] dateValues = new Date[] {};

        @InvocableVariable(
            label = 'Date/Time Collection'
            description = 'Collection of date/time values'
        )
        public DateTime[] dateTimeValues = new DateTime[] {};

    }

}