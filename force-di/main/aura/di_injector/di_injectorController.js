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

({
    doInit : function(cmp, event, helper) {

        // Resolve the given binding
        var action = cmp.get("c.getBinding");
        action.setParams({ bindingName : cmp.get("v.bindingName") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var bindingInfo = response.getReturnValue();
                var injectAttrs = cmp.get("v.body");
               
                // Construct attributes to pass on to injected component
                var componentName = null;
                var componentAttrs = {};
                
                
                if(bindingInfo.BindingTypeAsString == 'Flow') {
                    componentName = 'c:di_injectorFlowProxy';
                    componentAttrs['flowName'] = bindingInfo.To;
                    componentAttrs['injectorAttributes'] = injectAttrs;
                } else if(bindingInfo.BindingTypeAsString == 'LightningComponent') {
                    let bindingId =  cmp.get('v.bindingId');
                    if (typeof bindingId === 'undefined') {
                        cmp.set('v.bindingId', 'di_component');
                    }
                    componentAttrs['aura:id'] = cmp.get('v.bindingId');
                    componentName = bindingInfo.To;
                    for (var attrIdx in injectAttrs) {
                        var injectAttr = injectAttrs[attrIdx];
                        componentAttrs[injectAttr.get('v.name')] = injectAttr.get('v.value');
                    }
                } else {
                    console.log("Binding type " + bindingInfo.BindingTypeAsString + ' not supported');
                    return;
                }
                
                // Inject the component bound to the given binding
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
    },
    
    // Added by : Listen to attribute value change
    //
    // added a handler to capture the di_injectorAttributeChangeEvent. When it comes in, 
    // the handleChangeEvent() function looks at the bindingId variable stored in the component, 
    // finds the component based on this ID, and changes the specified attribute to the 'newValue'.
    //
    // The only not-so-pretty thing here is that sometimes (e.g. in case of the spinner) the value 
    // changed while $A.createComponent was still running (i.e. the Lightning Component hadn't 
    // been put on the DOM yet). So in that case, we just wait 100ms and try again.
    handleChangeEvent : function(component, event, helper) {

        let bindingId = component.get('v.bindingId');
        let auraCmp = component.find(bindingId);

        // Sometimes value will change while the Aura Component hasn't
        // been added to the DOM yet; wait 100ms and try again
        if (typeof(auraCmp) === undefined) {
            setTimeout(function() {
                this.handleChangeEvent(component, event, helper);
            }, 100);
        } else {
            let name  = event.getParam('name');
            let newValue  = event.getParam('newValue');
            auraCmp.set('v.' + name, newValue);
        }
    }
})
