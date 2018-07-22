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

public with sharing class RequestScopeInvocable {

    public static Map<String, Object> parameters { get; set; }

    // ------------------------

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

                    if ( value instanceof Decimal ) {

                        Decimal decimalValue = (Decimal) value;
                        res.longValue = decimalValue.longValue();
                        res.decimalValue = decimalValue;
                        res.stringValue = String.valueOf( decimalValue );
                        res.booleanValue = ( decimalValue != 0 );

                    } else if ( value instanceof String ) {

                        String stringValue = (String) value;
                        if ( stringValue.isNumeric() ) {
                            res.longValue = Long.valueOf( stringValue );
                            res.decimalValue = Decimal.valueOf( stringValue );
                        }
                        res.stringValue = stringValue;
                        res.booleanValue = ( String.isNotBlank( stringValue ) && stringValue != 'false' && stringValue != '0' );

                        try { res.dateValue = Date.parse( stringValue ); } catch ( Exception e ) { }
                        try { res.dateTimeValue = DateTime.parse( stringValue ); } catch ( Exception e ) { }

                    } else if ( value instanceof Boolean ) {

                        Boolean booleanValue = (Boolean) value;
                        res.longValue = ( booleanValue ? 1 : 0 );
                        res.decimalValue = ( booleanValue ? 1 : 0 );
                        res.stringValue = String.valueOf( booleanValue );
                        res.booleanValue = booleanValue;

                    } else if ( value instanceof Date ) {

                        Date dateValue = (Date) value;
                        res.stringValue = dateValue.format();
                        res.booleanValue = true;
                        res.dateValue = dateValue;
                        res.dateTimeValue = DateTime.newInstance( dateValue.year(), dateValue.month(), dateValue.day() );

                    } else if ( value instanceof DateTime ) {

                        DateTime dateTimeValue = (DateTime) value;
                        res.stringValue = dateTimeValue.format();
                        res.booleanValue = true;
                        res.dateValue = dateTimeValue.date();
                        res.dateTimeValue = dateTimeValue;

                    }

                    if ( res.longValue     != null ) { res.longValues.add( res.longValue ); }
                    if ( res.decimalValue  != null ) { res.decimalValues.add( res.decimalValue ); }
                    if ( res.stringValue   != null ) { res.stringValues.add( res.stringValue ); }
                    if ( res.booleanValue  != null ) { res.booleanValues.add( res.booleanValue ); }
                    if ( res.dateValue     != null ) { res.dateValues.add( res.dateValue ); }
                    if ( res.dateTimeValue != null ) { res.dateTimeValues.add( res.dateTimeValue ); }

                } else {

                    System.debug( LoggingLevel.WARN, 'RequestScopeInvocable.parameters.get("' + req + '") is null' );

                }

            } else {

                System.debug( LoggingLevel.WARN, 'RequestScopeInvocable.parameters is null' );

            }

            System.debug( 'paramName=' + req );
            System.debug( res );

            responses.add( res );

        }

        return responses;
    }

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