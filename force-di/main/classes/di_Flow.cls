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

/**
 * Fluent wrapper around Flow.Interview, to improve API and mocking
 **/
public class di_Flow {

    private Flow.Interview flow = null;
    @testVisible
    private Set<String> outputVarsNames;
    @testVisible
    private Set<String> outputVarsNamesRequired;

    public di_Flow(Flow.Interview flow) {
        this.flow = flow;
        init();
    }

    /**
    * Include the following parameter in the output map
    **/
    public di_Flow output(String variableName) {
        outputVarsNames.add(variableName);
        return this;
    }

    /**
    * Ensure the following parameter is returned and if not throw an exception
    **/
    public di_Flow required(String variableName) {
        output(variableName);
        outputVarsNamesRequired.add(variableName);
        return this;
    }

    /**
    * Runs the Flow
    **/
    public Map<String, Object> run() {
        try {
            flow.start();
            Map<String, Object> outputVars = new Map<String, Object>();
            for(String outputVar : outputVarsNames) {
                Object outputVarValue = flow.getVariableValue(outputVar);
                if(outputVarValue!=null) {
                    outputVars.put(outputVar, outputVarValue);
                } else if(outputVarsNamesRequired.contains(outputVar)) {
                    throw new FlowException('Output variable ' + outputVar + ' expected but not returned from Flow');
                }
            }
            return outputVars;
        }
        finally {
            init();
        }
    }

    /**
    * Runs the Flow returns the given parameter
    **/
    public Object returning(String outputVariableName) {
        return required(outputVariableName).run().get(outputVariableName);
    }

    /**
     * Reset the state of this Flow after each run
     **/
    private void init() {
        outputVarsNames = new Set<String>();
        outputVarsNamesRequired = new Set<String>();
    }

    public class FlowException extends Exception {}
}