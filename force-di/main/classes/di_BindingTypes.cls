/**
 * File Name: di_BindingTypes 
 * Description:
 */
public virtual with sharing class di_BindingTypes
{
	private static di_BindingTypes instance;

	protected Map<String, di_BindingType__mdt> bindingTypeByName
	{
		get
		{
			if (bindingTypeByName == null)
			{
				bindingTypeByName = new Map<String, di_BindingType__mdt>();
				for (di_BindingType__mdt record :
				[
						SELECT QualifiedAPIName,
								DeveloperName,
								NamespacePrefix,
								Type__c
						FROM di_BindingType__mdt
				])
				{
					bindingTypeByName.put(
							record.QualifiedApiName.toLowerCase(),
							record
					);
				}
			}
			return bindingTypeByName;
		}
		private set;
	}

	public static di_BindingTypes getInstance()
	{
		if (di_BindingTypes.instance == null)
		{
			di_BindingTypes.instance = new di_BindingTypes();
		}
		return di_BindingTypes.instance;
	}

	public Boolean isValid(String bindingTypeName)
	{
		return String.isNotBlank(bindingTypeName) &&
				bindingTypeByName.containsKey(bindingTypeName.toLowerCase());
	}

	public Type getType(String bindingTypeName)
	{
		di_BindingType__mdt bindingType = getBindingType(bindingTypeName);
		if (bindingType == null)
		{
			return null;
		}

		return Type.forName(
				bindingType.Type__c
		);
	}


	private di_BindingType__mdt getBindingType(String bindingTypeName)
	{
		if (!isValid(bindingTypeName))
		{
			// todo - throw exception
			return null;
		}

		return bindingTypeByName.get(bindingTypeName.toLowerCase());
	}
}