/**
 * File Name: di_FlowBinding 
 * Description: Bindings to Flows (Provider interface not currently supported)
 */
public with sharing class di_FlowBinding extends di_Binding
{
	public  override Object newInstance(Object params)
	{
		// Flow name binding?
		if ( To instanceof String )
		{
			String flowName = (String) To;
			if ( params instanceof Map<String, Object> )
			{
				return new di_Flow(Flow.Interview.createInterview(flowName, (Map<String, Object>) params));
			}
			return new di_Flow(Flow.Interview.createInterview(flowName, new Map<String, Object>()));
		}
		// Instance binding
		return To;
	}
}