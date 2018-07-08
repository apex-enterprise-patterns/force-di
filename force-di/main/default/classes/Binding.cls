public abstract class Binding {

    public String Namespace {get;private set;}

    public String Name {get;private set;}

    public String To {get;private set;}

    private Binding(String namespace, String name, String to) {
        this.Namespace = namespace;
        this.Name = name;
        this.To = to;
    }

    public static Binding newInstance(Binding__mdt binding) {
        // Return an applicable Binding subclass for the given binding type
        if(binding.DeveloperName.startsWithIgnoreCase('apex_') || 
           binding.DeveloperName.startsWithIgnoreCase('trigger_')) {
            return new ApexBinding(binding.NamespacePrefix, binding.DeveloperName, binding.To__c);
        } else if(binding.DeveloperName.startsWithIgnoreCase('lc_')) {
            return new LightningComponentBinding(binding.NamespacePrefix, binding.DeveloperName, binding.To__c);
        } else if(binding.DeveloperName.startsWithIgnoreCase('vf_')) {
            return new VisualForceComponentBinding(binding.NamespacePrefix, binding.DeveloperName, binding.To__c);
        }
        throw new BindingException('Binding ' + binding.DeveloperName + ' is not recognized');
    }

    public abstract Object getInstance(Object params);

    private class ApexBinding extends Binding {
        public ApexBinding(String nameSpace, String name, String to) {
            super(nameSpace, name, to);
        }
        public override Object getInstance(Object params) {
            // Apex bindings honour the namespace of the defining custom metadata type record
            Type toType = NameSpace==null ? Type.forName(To) : Type.forName(Namespace, To);
            if(toType==null) {
                throw new BindingException('Apex binding ' + Name + ' implementation ' + To + ' does not exist');
            }
            Object toObject = toType.newInstance();
            // Is this Apex binding resolved via a Provider?
            if(toObject instanceof Provider) {
                return ((Provider) toObject).newInstance(params);
            } else if(params!=null) {
                // Params supplied but the binding does not reference a Provider?
                throw new BindingException('Apex binding ' + Name + ' implementation ' + To + ' does not implement the Provider interaface.'); 
            }
            return toObject;
        }
    }

    private class VisualForceComponentBinding extends Binding {
        public VisualForceComponentBinding(String nameSpace, String name, String to) {
            super(nameSpace, name, to);
        }
        public  override Object getInstance(Object params) {
            // Visualforce Components references must be made via an Apex class implementing the Provider interface
            Type toType = NameSpace==null ? Type.forName(To) : Type.forName(Namespace, To);
            if(toType==null) {
                throw new BindingException('Visualforce Component binding ' + Name + ' implementation ' + To + ' does not exist.');
            }
            // Visualforce Components have to be resolved via a Provider
            Object toObject = toType.newInstance();
            if(toObject instanceof Provider) {
                return ((Provider) toObject).newInstance(params);
            }
            throw new BindingException('Visualforce Component binding ' + Name + ' must point to a class implementing the Provider interface.');
        }
    }

    private class LightningComponentBinding extends Binding {
        public LightningComponentBinding(String nameSpace, String name, String to) {
            super(nameSpace, name, to);
        }
        public  override Object getInstance(Object params) {
            // Lightning Component bindings are resolve by the Lightning Component 'inject' included in this library
            return to;
        }
    }

    public class BindingException extends Exception {}
}
