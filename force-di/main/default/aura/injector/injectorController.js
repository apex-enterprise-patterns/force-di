({
    doInit : function(cmp, event, helper) {
        
        // Resolve the given binding
        var action = cmp.get("c.getInstance");
        action.setStorable(true); // TODO: Investigate a means to have a more global client side cache for all vc bindings on the client
        action.setParams({ bindingName : cmp.get("v.binding") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Construct attributes to pass on to injected component
                var componentAttrs = {};
                var injectAttrs = cmp.get("v.body");
                for(var attrIdx in injectAttrs) {
                    var injectAttr = injectAttrs[attrIdx];
                    componentAttrs[injectAttr.get('v.name')] = injectAttr.get('v.value');
                }
                // Inject the component bound to the given binding
                var componentName = response.getReturnValue();
                $A.createComponent(
                    componentName,
                    componentAttrs,
                    function(newCmp, status, errorMessage){
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
                            var body = cmp.get("v.body");
                            body.push(newCmp);
                            cmp.set("v.body", body);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                            // Show error message
                        }
                    }
                );                
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})
