 @isTest
private with sharing class di_InjectorCMPFlowProxyControllerTest {

    @isTest
    private static void givenValueWhenGetInjectThenThrowException(){
        String FlowNameValue = 'AccountRecordFlow';
        Object InputVariablesValue = 'Account';
        di_InjectorComponentFlowProxyController newObj = new di_InjectorComponentFlowProxyController();
        try {
        newObj.getInject();
        } catch(Exception e){
            System.assertEquals(e.getMessage().contains('Invalid value for property name'), true, 'correct Exception is thrown');
        }
    }

}
