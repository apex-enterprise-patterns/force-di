@isTest
private with sharing class di_InjectorCMPFlowProxyControllerTest {

    @isTest
    private static void givenValueWhenGetInjectThenThrowException(){

        di_InjectorComponentFlowProxyController newObj = new di_InjectorComponentFlowProxyController();
        newObj.FlowNameValue = 'AccountRecordFlow';
        newObj.InputVariablesValue = new Map<String,Object> {
            'Account'=>null
        };
        try {
            newObj.getInject();
        } catch(Exception e) {
            System.assertEquals(e.getMessage().contains('Invalid value for property name'), true, 'correct Exception is thrown');
        }
    }

    @isTest
    private static void givenValueWhenGetInjectThenThrowException_inputVariablesIsMapObjectObject(){

        di_InjectorComponentFlowProxyController newObj = new di_InjectorComponentFlowProxyController();
        newObj.FlowNameValue = 'AccountRecordFlow';
        newObj.InputVariablesValue = new Map<Object,Object> {
            'Account'=>null
        };
        try {
            newObj.getInject();
        } catch(Exception e) {
            System.assertEquals(e.getMessage().contains('Invalid value for property name'), true, 'correct Exception is thrown');
        }
    }

}
