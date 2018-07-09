/**
 * Example Injector.Binding.. usage showing how to return multiple bindings based on custom criteria
 *   (also includes an example of a multiple pass approach to allow binding impls to optimize each other)
 **/
public class TriggerInjector {

    /**
     * Looks for multiple "trigger handler" bindings for a given SObjectType
     **/
    public static void handle(SObjectType triggerType, TriggerHandlerContext ctx) {
        // Discover ordered bindings made against the given sobject type 
        List<Binding> bindings = 
            Injector.Bindings
                .with(Binding__mdt.BindingObject__c, triggerType.getDescribe().getName())
                .orderBy(Binding__mdt.BindingSequence__c)
                .get();
        // Construct the handlers
        List<TriggerHandler> handlers = new List<TriggerHandler>();        
        for(Binding binding : bindings) {
            Object handler = binding.getInstance();
            if(handler instanceof TriggerHandler) {
                handlers.add((TriggerHandler) handler);
            } else {
                throw new TriggerInjectorException('Binding for ' + binding.DeveloperName + ' must extend Injector.TriggerHandler');                    
            }
        }
        // Trigger contexts allow for the client to perform optimizations and aggregations
        if(ctx!=null) {
            for(TriggerHandler handler : handlers) {                
                handler.pre(ctx);
            }
            ctx.handle(triggerType);
        }
        // Ask each handler to perform its work
        for(TriggerHandler handler : handlers) {
            handler.handle(ctx);
        }
    }

    /**
     * Simple injection framework for Apex Trigger handlers (should work with multiple trigger handling frameworks)
     **/
    public abstract class TriggerHandler {
        /**
         * Trigger handlers (optionally) use context methods to predescribe needs such as queries and fields
         **/
        public virtual void pre(TriggerHandlerContext ctx) { }
        /**
         * The actual trigger logic, assumes it has access to Trigger class methods and properties
         **/
        public abstract void handle(TriggerHandlerContext ctx);
    }

    /**
     * Intended to be subclassed and passed to the triggerHandlers method
     **/ 
    public abstract class TriggerHandlerContext {
        /**
         * Called by the framework after the TriggerHandler.pre methods have all been called
         **/
        public abstract void handle(SObjectType parentType);
    }

    /**
     * Example trigger handler context that aggregates related record queries accross handlers
     **/
    public class TriggerHandlerFieldSetContext extends TriggerHandlerContext {

        private Map<SObjectField, Set<SObjectField>> fieldSets = new Map<SObjectField, Set<SObjectField>>();
        private Map<SObjectField, List<SObject>> relatedRecordSet = new Map<SObjectField, List<SObject>>();

        public void addFieldSet(SObjectField relatedField, Set<SObjectField> fields) {
            Set<SObjectField> fieldSet = fieldSets.get(relatedField);
            if(fieldSet==null) {
                fieldSet = new Set<SObjectField>();
                fieldSets.put(relatedField, fieldSet);
            }
            fieldSet.addAll(fields);
        }        

        public override void handle(SObjectType parentType) {
            Map<SObjectField, Schema.ChildRelationship> childRelationships = new Map<SObjectField, Schema.ChildRelationship>();
            Set<Id> parentIds = new Set<Id>();
            if(Trigger.oldMap!=null) {
                parentIds.addAll(Trigger.oldMap.keySet());
            }
            if(Trigger.newMap!=null) {
                parentIds.addAll(Trigger.newMap.keySet());
            }
            // TODO: Cache some of this and differ the query to the getRelatedRecordSet method call
            for(Schema.ChildRelationship childRelationship : parentType.getDescribe().getChildRelationships()) {
                SObjectField relatedField = childRelationship.getField();
                if(fieldSets.containsKey(relatedField)) {
                    Set<SObjectField> fields = getRelatedFieldSet(relatedField);
                    List<String> fieldNames = new List<String>();
                    for(SObjectField field : fields) {
                        fieldNames.add(field.getDescribe().getName());
                    }
                    List<SObject> childRecords = 
                        Database.query(
                            String.format('select {0} from {1} where {2} in :parentIds', 
                                new List<String> { 
                                    String.join(fieldNames, ','), 
                                    childRelationship.getChildSObject().getDescribe().getName(), 
                                    relatedField.getDescribe().getName() }));
                    relatedRecordSet.put(relatedField, childRecords);
                }
            }
        }

        public List<SObject> getRelatedRecordSet(SObjectField relatedField) {
            return relatedRecordSet.get(relatedField);
        }

        public Set<SObjectField> getRelatedFieldSet(SObjectField relatedField) {
            return fieldSets.get(relatedField);
        }
    }

    public class TriggerInjectorException extends Exception {}
}
