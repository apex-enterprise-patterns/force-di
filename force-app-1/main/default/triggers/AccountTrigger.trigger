trigger AccountTrigger on Account (before insert) {
    Injector.triggerHandlers(Account.getSObjectType(), new Injector.TriggerHandlerFieldSetContext());
}