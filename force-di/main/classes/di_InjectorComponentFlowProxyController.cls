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

public with sharing class di_InjectorComponentFlowProxyController {

    public String FlowNameValue { get; set; }

    public Object InputVariablesValue { get; set; }

    public Component.Flow.Interview getInject() {

        Component.Flow.Interview interview = new Component.Flow.Interview();
        interview.name = FlowNameValue;

        // For a flow embedded in a Visualforce page with <flow:interview> tag,
        // there is no way to dynamically specify the input variable names at runtime.
        //
        // The <apex:param> tags are not supported in Apex to dynamically create and
        // and inject into the <flow:interview>, nor does Visualforce support bindings like
        // <apex:param name="{!v.dynamicName}"/>.
        //
        // Therefore, as a workaround, we store the input variables as a map in
        // a request-scoped static variable (a.k.a. thread locals in Java)
        // as BindingParam.parameters and then our injected flow will retrieve
        // the variable values by calling the BindingParam class' invocable method.

        if ( InputVariablesValue instanceof Map<Object, Object> ) {
            // convert map to have string keys else invoking flow will fail
            Map<Object, Object> oldMap = (Map<Object, Object>) InputVariablesValue;
            Map<String, Object> newMap = new Map<String, Object>();
            for ( Object key : oldMap.keySet() ) {
                newMap.put( String.valueOf( key ), oldMap.get( key ) );
            }
            di_BindingParam.parameters = newMap;
        } else if ( InputVariablesValue instanceof Map<String, Object> ) {
            di_BindingParam.parameters = (Map<String, Object>) InputVariablesValue;
        }

        return interview;
    }

}