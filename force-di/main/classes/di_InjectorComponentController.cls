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

public with sharing class di_InjectorComponentController {

    public String BindingNameValue {set;get;}

    public Object ParametersValue {set;get;}

    public ApexPages.Component getInject() {
        ApexPages.Component cmp = null;
        di_Binding bindingInfo = getBinding(BindingNameValue);
        switch on bindingInfo.BindingType {
            when Flow {
                cmp = (ApexPages.Component) getInjectorFlowProxyInstance((String) bindingInfo.To, ParametersValue);
            }
            when else {
                cmp = (ApexPages.Component) di_Injector.Org.getInstance(BindingNameValue, ParametersValue);
            }
        }
        return cmp;
    }

    public static di_Binding getBinding(String bindingName) {
        return di_Injector.Org.Bindings.byName(bindingName).get()[0];
    }

    // To avoid "Operation cast is not allowed on type" error, then
    // masking the component behind a generic Object return type.
    // For some odd reason, this compiles and works.
    @testVisible
    private Object getInjectorFlowProxyInstance(String flowName, Object params) {
        return new Component.di_injectorFlowProxy(
            flowName = flowName,
            inputVariables = params
        );
    }

}