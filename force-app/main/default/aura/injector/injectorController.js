({
    doInit : function(cmp, event, helper) {
        var attrs = cmp.get("v.body");
        console.log(attrs[0].get('v.name') + ' = ' + attrs[0].get('v.value'));
    }
})
