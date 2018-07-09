public with sharing class WidgetInfoController {

    public ApexPages.StandardController StandardControllerValue {get;set;}
    
    public class BindingProvider implements Binding.Provider {
        public Object newInstance(Object params) {            
            return new Component.widgetInfo(standardController = (ApexPages.StandardController) params);
        }
    }
}
