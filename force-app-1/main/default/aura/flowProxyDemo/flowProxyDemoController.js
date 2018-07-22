({
    /**
     * Example of handling when the flow status changes (e.g. started => finished)
     * and logging any output variables from the flow.
     */
    handleFlowProxyStatusChanged: function ( component, event, helper ) {
        console.log( 'handling flow status change in proxy demo component:' );
        for ( var attr in event.getParams() ) {
            console.log( attr, event.getParams()[attr] );
        }
    }
})