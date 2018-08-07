({
    /**
     * Given a the data type from an injector attribute component,
     * infers the corresponding Flow data type.
     *
     * https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_config_for_flow_tips_map.htm
     * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_primitives.htm
     */
    getFlowDataTypeForApexDataType: function( apexDataType ) {

        // TODO support collection types

        var flowDataTypeMappings = {
            'integer' : 'Number',
            'long' : 'Number',
            'double' : 'Number',
            'decimal' : 'Number',
            'string' : 'String',
            'boolean' : 'Boolean',
            'date' : 'Date',
            'datetime' : 'DateTime'
        };

        var flowDataType = flowDataTypeMappings[apexDataType.toLowerCase()];

        if ( $A.util.isEmpty( flowDataType ) ) {
            flowDataType = 'SObject'; // default
        }

        return flowDataType;
    }
})