
public with sharing class RequestScopeInvocable {

    public static Map<String, Object> parameters { get; set; }

    // ------------------------

    @InvocableMethod(
        label = 'Get Value'
    )
    public static List<Result> invoke( List<String> paramNames ) {

        List<Result> paramValues = new List<Result>();

        for ( String paramName : paramNames ) {

            Result r = new Result();

            if ( parameters != null ) {

                Object value = parameters.get( paramName );

                if ( value != null ) {

                    if ( value instanceof Decimal ) {

                        Decimal decimalValue = (Decimal) value;
                        r.longValue = decimalValue.longValue();
                        r.decimalValue = decimalValue;
                        r.stringValue = String.valueOf( decimalValue );
                        r.booleanValue = ( decimalValue != 0 );

                    } else if ( value instanceof String ) {

                        String stringValue = (String) value;
                        if ( stringValue.isNumeric() ) {
                            r.longValue = Long.valueOf( stringValue );
                            r.decimalValue = Decimal.valueOf( stringValue );
                        }
                        r.stringValue = stringValue;
                        r.booleanValue = ( String.isNotBlank( stringValue ) && stringValue != 'false' && stringValue != '0' );

                    } else if ( value instanceof Boolean ) {

                        Boolean booleanValue = (Boolean) value;
                        r.longValue = ( booleanValue ? 1 : 0 );
                        r.decimalValue = ( booleanValue ? 1 : 0 );
                        r.stringValue = String.valueOf( booleanValue );
                        r.booleanValue = booleanValue;

                    }

                    if ( r.longValue    != null ) { r.longValues.add( r.longValue ); }
                    if ( r.decimalValue != null ) { r.decimalValues.add( r.decimalValue ); }
                    if ( r.stringValue  != null ) { r.stringValues.add( r.stringValue ); }
                    if ( r.booleanValue != null ) { r.booleanValues.add( r.booleanValue ); }

                } else {

                    System.debug( LoggingLevel.WARN, 'RequestScopeInvocable.parameters.get("' + paramName + '") is null' );

                }

            } else {

                System.debug( LoggingLevel.WARN, 'RequestScopeInvocable.parameters is null' );

            }

            System.debug( 'paramName=' + paramName );
            System.debug( r );

            paramValues.add( r );

        }

        return paramValues;
    }

    public class Result {

        @InvocableVariable
        public Long longValue;

        @InvocableVariable
        public Decimal decimalValue;

        @InvocableVariable
        public String stringValue;

        @InvocableVariable
        public Boolean booleanValue;

        @InvocableVariable
        public Long[] longValues = new Long[] {};

        @InvocableVariable
        public Decimal[] decimalValues = new Decimal[] {};

        @InvocableVariable
        public String[] stringValues = new String[] {};

        @InvocableVariable
        public Boolean[] booleanValues = new Boolean[] {};

    }

}