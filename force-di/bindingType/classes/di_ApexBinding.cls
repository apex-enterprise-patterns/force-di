/**
 * File Name: di_ApexBinding 
 * Description: Bindings to Apex classes (optionally via Provider interface)
 */
public with sharing class di_ApexBinding extends di_Binding
{
	public override Object newInstance(Object params)
	{
		// Type binding?
		if ( To instanceof String )
		{
			// Leverage namespace if the Binding has one
			String className = (String) To;
			Type toType = NameSpacePrefix==null ? Type.forName(className) : Type.forName(NamespacePrefix, className);
			if ( toType == null )
			{
				throw new BindingException('Apex binding ' + DeveloperName + ' implementation ' + To + ' does not exist');
			}
			Object toObject = toType.newInstance();
			// Is this Apex binding resolved via a Provider?
			IsProvider = toObject instanceof Provider;
			if ( IsProvider )
			{
				return ((Provider) toObject).newInstance(params);
			}
			else if ( params != null )
			{
				// Params supplied but the binding does not reference a Provider?
				throw new BindingException('Apex binding ' + DeveloperName + ' implementation ' + className + ' does not implement the Provider interface.');
			}
			return toObject;
		}
		// Instance binding
		return To;
	}
}