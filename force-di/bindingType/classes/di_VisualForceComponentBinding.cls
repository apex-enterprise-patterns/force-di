/**
 * File Name: di_VisualForceComponentBinding 
 * Description: Bindings to VF Components via Provider interface (required)
 */
public with sharing class di_VisualForceComponentBinding extends di_Binding
{
	public  override Object newInstance(Object params)
	{
		// Type binding?
		if ( To instanceof String )
		{
			// Visualforce Components references must be made via an Apex class implementing the Provider interface
			String className = (String) To;
			Type toType = NamespacePrefix==null ? Type.forName(className) : Type.forName(NamespacePrefix, className);
			if ( toType==null )
			{
				throw new BindingException('Visualforce Component binding ' + DeveloperName + ' implementation ' + className + ' does not exist.');
			}
			// Visualforce Components have to be resolved via a Provider
			Object toObject = toType.newInstance();
			IsProvider = toObject instanceof Provider;
			if ( IsProvider )
			{
				return ((Provider) toObject).newInstance(params);
			}
			throw new BindingException('Visualforce Component binding ' + DeveloperName + ' must point to a class implementing the Provider interface.');
		}
		// Instance binding
		return To;
	}
}