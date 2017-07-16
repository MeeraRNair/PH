({
    setGeo : function(component, latPos,longPos ) {
        //alert('alt'+latPos+'    long: '+longPos);

        console.log("Latitude is 777777:"+latPos+ "longitude"+longPos);

        var action = component.get("c.findAll");
        action.setParams({ 
        "comLat": latPos,"comLong": longPos
    	});
        /*action.setParams({ 
        "comLong": 10.12
    	});*/
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@ state:'+state);
            component.set("v.accounts", response.getReturnValue());
            var event = $A.get("e.c:AccountsLoaded");
            event.setParams({"accounts": response.getReturnValue()});
            event.fire();
        });
        console.log('Latitude is @Meg:');
    	$A.enqueueAction(action);

    },
    
    findAndFocus : function(et) {
        alert('hii'+et);
    
	},
    
})