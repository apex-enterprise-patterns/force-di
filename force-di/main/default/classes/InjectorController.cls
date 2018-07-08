public with sharing class InjectorController {

    public ApexPages.StandardController StandardController;

    public InjectorController(ApexPages.StandardController StandardController) {
        this.StandardController = StandardController;
    }

    public InjectorController getThis() {
        return this;
    }

    @AuraEnabled
    public static String getInstance(String bindingName) {
        return (String) Injector.getInstance(bindingName);
    }
}
