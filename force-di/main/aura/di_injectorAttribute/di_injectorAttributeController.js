({
	handleValueChange : function(component, event, helper) {
        let name = component.get('v.name');
		let newValue = event.getParam('value');
        
        let changeEvent = component.getEvent('attributeChangeEvent');
        changeEvent.setParams({ 'name' : name, 'newValue' : newValue });
        changeEvent.fire();
	}
})