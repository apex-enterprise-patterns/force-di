@isTest
private with sharing class di_FlowTest {
    @isTest
    public static void givenNullInputWhenObjectCreatedThenSetInitialized(){
        //Given
        Flow.Interview flow = null;
        //When
        di_Flow diObj = new di_Flow(flow);
        //Then
        System.assertEquals(0, diObj.outputVarsNames.size(), 'Set is not initialized');
        System.assertEquals(0, diObj.outputVarsNamesRequired.size(), 'Set is not initialized');
    }

    @isTest
    public static void givenStringValueWhenOutputThenStringAddedToSet(){
        //Given
        Flow.Interview flow = null;
        String variableName = 'Test';
        //When
        di_Flow diObj = new di_Flow(flow);
        diObj.output(variableName);
        //Then
        System.assertEquals(1, diObj.outputVarsNames.size(), 'value not inserted in Set');
    }

    @isTest
    public static void givenVariableNameWhenRequiredThenValueAddedToSet(){
        //Given
        Flow.Interview flow = null;
        String variableName = 'Test';
        //When
        di_Flow diObj = new di_Flow(flow);
        diObj.required(variableName);
        //Then
        System.assertEquals(1, diObj.outputVarsNames.size(), 'value not inserted in Set');
        System.assertEquals(1, diObj.outputVarsNamesRequired.size(), 'value not inserted in Set');
    }

    /** 
     * Removed until further mocking support added to di_Flow 
     *  (see https://github.com/afawcett/flowextensions for ideas)
    @isTest
    public static void givenFlowNameWhenReturningThenExceptionThrown(){
        //Given
        String flowName='HelloWorld';
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new Map<String, Object>());
        String variableName = 'HelloWorld';
        String outputVariableName = 'HelloWorld';
        //When
        di_Flow diObj = new di_Flow(flow);
        diObj.required(variableName);
        try{
        diObj.returning(outputVariableName);
        } catch(Exception e){
            //Then
            System.assertEquals(e.getMessage().contains('expected but not returned from Flow'), true, 'correct Exception in not thrown');
        }
    }
    **/
}
