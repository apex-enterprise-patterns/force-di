public with sharing class InjectorComponentController {

    public String BindingValue {set;get;}

    public InjectorController PageControllerValue {set;get;}

    public ApexPages.Component getInject() {
        // TODO: Some error handling here
        return (ApexPages.Component) Injector.getInstance(BindingValue, PageControllerValue.StandardController);
    }
}
