global with sharing class di_BindingConfigWrapper {
    // Constructor to inject the data through test class.
    global di_BindingConfigWrapper(   String qualifiedAPIName
                                    , String developerName
                                    , String namespacePrefix
                                    , String type
                                    , String to
                                    , String bindingObject
                                    , String bindingObjectQualifiedApiName
                                    , String bindingObjectAlternate
                                    , Decimal bindingSequence){
        this.QualifiedAPIName = qualifiedAPIName;
        this.DeveloperName = developerName;
        this.NamespacePrefix = namespacePrefix;
        this.Type = type;
        this.To = to;
        this.BindingObject = bindingObject;
        this.BindingObjectQualifiedApiName = bindingObjectQualifiedApiName;
        this.BindingObjectAlternate = bindingObjectAlternate;
        this.BindingSequence = bindingSequence;
    }
   //Constructor to inject the data  from a metadata  by giving reference of metadata
    global di_BindingConfigWrapper(di_Binding__mdt bindingConfig){
        this.QualifiedAPIName = bindingConfig.QualifiedApiName;
        this.DeveloperName = bindingConfig.DeveloperName;
        this.NamespacePrefix = bindingConfig.NamespacePrefix;
        this.Type = bindingConfig.Type__c;
        this.To = bindingConfig.To__c;
        this.BindingObject = bindingConfig.BindingObject__c;
        this.BindingObjectQualifiedApiName = bindingConfig.BindingObject__r.QualifiedApiName;
        this.BindingObjectAlternate = bindingConfig.BindingObjectAlternate__c;
        this.BindingSequence = bindingConfig.BindingSequence__c;
    }
    global String QualifiedAPIName{get;set;}
    global String DeveloperName{get;set;}
    global String NamespacePrefix{get;set;}
    global String Type{get;set;}
    global String To{get;set;}
    global String BindingObject{get;set;}
    global String BindingObjectQualifiedApiName{get;set;}
    global String BindingObjectAlternate{get;set;}
    global Decimal BindingSequence{get;set;}
}
