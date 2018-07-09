/**
 * TriggerInjector is not part of the DI library (see force-di-trigger-demo), it is an example of using the lib to manage multiple bindings
 **/
trigger AccountTrigger on Account (before insert) {
    TriggerInjector.handle(Account.getSObjectType(), new TriggerInjector.TriggerHandlerFieldSetContext());
}