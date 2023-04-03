@IsTest
private with sharing class di_FlowTest {
    @IsTest
    public static void givenNullInputWhenObjectCreatedThenSetInitialized() {
        //Given
        Flow.Interview flow = null;
        //When
        di_Flow diObj = new di_Flow(flow);
        //Then
        System.assertEquals(0, diObj.outputVarsNames.size(), 'Set is not initialized');
        System.assertEquals(0, diObj.outputVarsNamesRequired.size(), 'Set is not initialized');
    }

    @IsTest
    public static void givenStringValueWhenOutputThenStringAddedToSet() {
        //Given
        Flow.Interview flow = null;
        String variableName = 'Test';
        //When
        di_Flow diObj = new di_Flow(flow);
        diObj.output(variableName);
        //Then
        System.assertEquals(1, diObj.outputVarsNames.size(), 'value not inserted in Set');
    }

    @IsTest
    public static void givenVariableNameWhenRequiredThenValueAddedToSet() {
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

    @IsTest
    public static void givenFlowNameWhenReturningThenExceptionThrown() {
        //Given
        String flowName = 'HelloWorld';
        String variableName = 'HelloWorld';
        String outputVariableName = 'HelloWorld';
        Flow.Interview helloWorldFlow = null;
        try {
            helloWorldFlow = Flow.Interview.createInterview(flowName, new Map<String, Object>());
        } catch (System.TypeException e) {
            // Apparently flow doesn't exist; we don't want to fail the test, but unit test coverage will suffer
            System.debug('HelloWorld flow was not found. Please create to obtain sufficient test coverage.');
        }

        //When
        if (helloWorldFlow != null) {
            di_Flow diObj = new di_Flow(helloWorldFlow);
            diObj.required(variableName);
            try {
                diObj.returning(outputVariableName);
            } catch (Exception e) {
                //Then
                System.assertEquals(e.getMessage().contains('expected but not returned from Flow'), true, 'correct Exception in not thrown');
            }
        }
    }
}
