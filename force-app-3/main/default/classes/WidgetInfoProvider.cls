public class WidgetInfoProvider implements Provider {
    public Object newInstance(Object params) {
        return new Component.widgetInfo(standardController = (ApexPages.StandardController) params);
    }
}
