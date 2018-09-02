public with sharing class WidgetInfoController {

    public ApexPages.StandardController StandardControllerValue {get;set;}

    public class IProvider implements di_Binding.IProvider {
        public Object newInstance(Object params) {
            return new Component.widgetInfo(standardController = (ApexPages.StandardController) params);
        }
    }
}
