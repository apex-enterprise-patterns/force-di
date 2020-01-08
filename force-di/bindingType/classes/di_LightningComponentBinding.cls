/**
 * File Name: di_LightningComponentBinding 
 * Description: Bindings to Lightning Components (Provider interface not currently supported)
 */
public with sharing class di_LightningComponentBinding extends di_Binding
{
	public override Object newInstance(Object params)
	{
		// Lightning Component bindings are resolve by the Lightning 'inject' Component included in this library
		return To;
	}
}