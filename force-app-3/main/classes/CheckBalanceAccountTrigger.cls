public class CheckBalanceAccountTrigger extends TriggerInjector.TriggerHandler {

    public override void pre(TriggerInjector.TriggerHandlerContext ctx) {
        // Declare need for Department field
        ((TriggerHandlerFieldSetContext) ctx).addFieldSet(
            Contact.fields.AccountId, new Set<SObjectField> { Contact.fields.Department });
    }

    public override void handle(TriggerInjector.TriggerHandlerContext ctx) {
        // Query Contacts
        List<Contact> contacts = (List<Contact>) 
            ((TriggerHandlerFieldSetContext) ctx).getRelatedRecordSet(Contact.fields.AccountId);
        System.debug('CheckBalanceAccountTrigger');            
    }
}