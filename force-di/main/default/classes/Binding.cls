/**
 * Copyright (c) 2018, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Wrap the binding configuration to subclass it and aid in resolving the To__c field value
 *   (also leverages the Provider interface to allow for more advanced instantiation of the To__c value)
 **/
public abstract class Binding {

    public Binding__mdt Record {get;private set;}

    public String NamespacePrefix {get { return Record.NamespacePrefix; } }

    public String DeveloperName {get { return Record.DeveloperName; } }

    public String To {get { return Record.To__c; } }

    /** 
     * Wrap the binding configuration to subclass it and aid in resolving the To__c field value
     **/
    private Binding(Binding__mdt record) {
        this.record = record;
    }

    /**
     * Gets the instance of the thing the binding points to
     **/
    public Object getInstance() {
        return getInstance(null);
    }

    /**
     * Gets the instance of the thing the binding points to
     **/
    public abstract Object getInstance(Object params);

    /**
    * Allows bindings to resolve dynamically (e.g. custom constructors) based passing in params if needed
    **/
    public interface Provider {
        Object newInstance(Object params);
    }

    /**
     * Simple fluent API to resolve Bindings
     **/
    public class Query {

        private String qualifiedDeveloperName;
        private Map<SObjectField, Object> withMap = new Map<SObjectField, Object>();
        private SObjectField orderBy;

        public Query byName(String qualifiedDeveloperName) {
            this.qualifiedDeveloperName = qualifiedDeveloperName;
            return this;
        }
        public Query with(SObjectField filterField, Object value) {
            this.withMap.put(filterField, value);
            return this;
        }
        public Query orderBy(SObjectField orderByField) {
            this.orderBy = orderByField;
            return this;
        }
        public List<Binding> get() {
            // Construct fields to query
            Set<SObjectField> fields = 
                new Set<SObjectField> { 
                    Binding__mdt.QualifiedAPIName, 
                    Binding__mdt.DeveloperName,
                    Binding__mdt.NamespacePrefix,
                    Binding__mdt.To__c };
            for(SObjectField withField : withMap.keySet()) {
                fields.add(withField);                
            }
            if(orderBy!=null) {
                fields.add(orderBy);
            }
            List<String> fieldNames = new List<String>();
            for(SObjectField field : fields) {
                fieldNames.add(field.getDescribe().getName());
            }
            // Query by QualifiedName?
            String whereClause = '';
            if(qualifiedDeveloperName!=null) {
                whereClause = Binding__mdt.QualifiedAPIName.getDescribe().getName() + ' = :qualifiedDeveloperName';
            }
            // Additional critera?
            if(withMap.size()>0) {                
                for(SObjectField withField : withMap.keySet()) {
                    String value = String.valueOf(withMap.get(withField)); // Assume String values for now
                    String fieldName = withField.getDescribe().getName();
                    whereClause+= (whereClause.length()>0 ? ' and ' : '') + fieldName + ' = \'' + String.escapeSingleQuotes(value) + '\''; 
                }
            }
            // Query for bindings and wrap in the Binding class
            List<Binding> bindings = new List<Binding>();
            System.debug(whereClause);
            for(Binding__mdt bindingRecord :
                    Database.query(
                        String.format('select {0} from Binding__mdt where {1} {2}', 
                            new List<String> { 
                                String.join(fieldNames, ','),                             
                                whereClause,
                                orderBy!=null ? 'order by ' + orderBy.getDescribe().getName() : '' }))) {
                bindings.add(Binding.newInstance(bindingRecord));
            }
            this.qualifiedDeveloperName = null;
            this.withMap = new Map<SObjectField, Object>();
            this.orderBy = null;
            return bindings;
        }
    }

    public class BindingException extends Exception {}

    /**
     * Returns the applicable Binding impl to resolve the type of binding provided
     **/
    public static Binding newInstance(Binding__mdt binding) {
        // Return an applicable Binding subclass for the given binding type
        if(binding.DeveloperName.startsWithIgnoreCase('apex_')) {
            return new ApexBinding(binding);
        } else if(binding.DeveloperName.startsWithIgnoreCase('lc_')) {
            return new LightningComponentBinding(Binding);
        } else if(binding.DeveloperName.startsWithIgnoreCase('vf_')) {
            return new VisualForceComponentBinding(binding);
        }
        throw new BindingException('Binding ' + binding.DeveloperName + ' is not recognized');
    }

    /**
     * Bindings to Apex classes (optionally via Provider interface)
     **/
    private class ApexBinding extends Binding {
        private ApexBinding(Binding__mdt record) {
            super(record);
        }
        public override Object getInstance(Object params) {
            // Apex bindings honour the namespace of the defining custom metadata type record
            Type toType = NameSpacePrefix==null ? Type.forName(To) : Type.forName(NamespacePrefix, To);
            if(toType==null) {
                throw new BindingException('Apex binding ' + DeveloperName + ' implementation ' + To + ' does not exist');
            }
            Object toObject = toType.newInstance();
            // Is this Apex binding resolved via a Provider?
            if(toObject instanceof Provider) {
                return ((Provider) toObject).newInstance(params);
            } else if(params!=null) {
                // Params supplied but the binding does not reference a Provider?
                throw new BindingException('Apex binding ' + DeveloperName + ' implementation ' + To + ' does not implement the Provider interaface.'); 
            }
            return toObject;
        }
    }

    /**
     * Bindings to VF Components via Provider interface
     **/
    private class VisualForceComponentBinding extends Binding {
        private VisualForceComponentBinding(Binding__mdt record) {
            super(record);
        }
        public  override Object getInstance(Object params) {
            // Visualforce Components references must be made via an Apex class implementing the Provider interface
            Type toType = NamespacePrefix==null ? Type.forName(To) : Type.forName(NamespacePrefix, To);
            if(toType==null) {
                throw new BindingException('Visualforce Component binding ' + DeveloperName + ' implementation ' + To + ' does not exist.');
            }
            // Visualforce Components have to be resolved via a Provider
            Object toObject = toType.newInstance();
            if(toObject instanceof Provider) {
                return ((Provider) toObject).newInstance(params);
            }
            throw new BindingException('Visualforce Component binding ' + DeveloperName + ' must point to a class implementing the Provider interface.');
        }
    }

    /**
     * Bindings to Lightning Components (Provider interface not currently supported)
     **/
    private class LightningComponentBinding extends Binding {
        private LightningComponentBinding(Binding__mdt record) {
            super(record);
        }
        public  override Object getInstance(Object params) {
            // Lightning Component bindings are resolve by the Lightning Component 'inject' included in this library
            return To;
        }
    }
}
