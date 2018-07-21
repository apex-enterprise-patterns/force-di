({
    doInit: function ( component, event, helper ) {

        var flowName = '';
        var flowInputVariables = [];

        var injectAttrs = component.get( 'v.injectorAttributes' );

        for( var attrIdx in injectAttrs ) {

            var injectAttr = injectAttrs[attrIdx];

            var flowInputVar = {
                'name': injectAttr.get( 'v.name' ),
                'value': injectAttr.get( 'v.value' ),
                'type': 'String' // TODO: convert javascript data types to flow data types
                                 // https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_config_for_flow_tips_map.htm
            };

            console.log( flowInputVar );

            if ( flowInputVar.name.toLowerCase() == 'flowname' ) {
                flowName = flowInputVar.value;
            } else {
                // lightning:flow will throw error if we send more
                // input variables than are actually defined in the flow.
                // therefore, since 'flowName' is specific to our proxy component,
                // then we don't assume we can pass it to the flow.
                flowInputVariables.push( flowInputVar );
            }

        }

        if ( !$A.util.isEmpty( flowName ) ) {

            var p = new Promise( function( resolve, reject ) {

                $A.createComponent(
                    'lightning:flow',
                    {
                        'aura:id' : 'flow',
                        'onstatuschange' : component.getReference( 'c.onstatuschangeProxy' )
                    },
                    function( newCmp, status, errorMessage ) {
                        if ( status === 'SUCCESS' ) {
                            resolve( newCmp );
                        } else {
                            reject( errorMessage || status );
                        }
                    }
                );

            }).then( $A.getCallback( function( newFlowCmp ) {

                var flowContainer = component.find( 'flowContainer' );

                flowContainer.get( 'v.body' ).forEach( function( cmp, idx ) {
                    cmp.destroy();
                });

                flowContainer.set( 'v.body', newFlowCmp );

                newFlowCmp.startFlow( flowName, flowInputVariables );

            })).catch( $A.getCallback( function( err ) {

                console.error( 'Error creating flow component' ); // TODO raise error?
                console.error( err );

            }));

        } else {

            console.error( '"flowName" attribute required' ); // TODO raise error?

        }

    },

    onstatuschangeProxy: function( component, event, helper ) {
        var paramsToCopy = [ 'flowTitle', 'status', 'guid', 'outputVariables' ];
        var proxyEvent = component.getEvent( 'injectorFlowProxyStatusChanged' );
        paramsToCopy.forEach( function( paramName ) {
            proxyEvent.setParam( paramName, event.getParam( paramName ) );
        });
        proxyEvent.fire();
    }
})