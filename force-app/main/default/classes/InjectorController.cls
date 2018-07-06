public with sharing class InjectorController {

    @AuraEnabled
    public static String getInstance(String bindingName) {
        return (String) Injector.getInstance(bindingName);
    }
}
