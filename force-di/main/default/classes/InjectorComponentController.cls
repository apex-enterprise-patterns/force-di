public with sharing class InjectorComponentController {

    public String BindingNameValue {set;get;}

    public Object ParametersValue {set;get;}

    public ApexPages.Component getInject() {
        return (ApexPages.Component) Injector.getInstance(BindingNameValue, ParametersValue);
    }
}
