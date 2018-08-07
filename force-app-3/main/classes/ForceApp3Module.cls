/**
 * Class demonstrates programatic binding configuration (as apposed to via Binding__mdt)
 *   Roughly based on the Java API. This class can be given to an Injector instance
 *     or registered via Binding__mdt and thus available to the global scope Injector
 **/
public class ForceApp3Module extends di_Module {

    public override void configure() {

        // Example SObject binding (can be used by trigger frameworks, see force-di-demo-trigger)
        bind(Account.getSObjectType()).apex().sequence(20).to(CheckBalanceAccountTrigger.class);

        // Example named binding to a Lightning component
        bind('lc_actionWidgetManage').lightningComponent().to('c:widgetManager');

        // Example named binding to a Visualforce component (via Provider)
        bind('vf_layoutWidgetInfo').visualforceComponent().to(WidgetInfoController.Provider.class);
    }
}
