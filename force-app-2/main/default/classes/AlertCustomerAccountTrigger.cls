public class AlertCustomerAccountTrigger extends Injector.TriggerHandler {

    public override void pre(Injector.TriggerHandlerContext ctx) {
        // Declare need for Birthdate field
        ((TriggerHandlerFieldSetContext) ctx).addFieldSet(
            Contact.fields.AccountId, new Set<SObjectField> { Contact.fields.Birthdate, Contact.fields.Department });
    }

    public override void handle(Injector.TriggerHandlerContext ctx) {
        // Query Contacts
        List<Contact> contacts = (List<Contact>) 
            ((TriggerHandlerFieldSetContext) ctx).getRelatedRecordSet(Contact.fields.AccountId);
    }
}
