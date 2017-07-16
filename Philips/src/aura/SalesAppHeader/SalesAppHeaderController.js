({
	fireButtonClick : function(cmp, event) {

	    var compEvents = cmp.getEvent("headerButtonClick");
        compEvents.setParams({ "fromScreen" : cmp.get("v.fromComp") });
        compEvents.fire();
        
    },
    
    back : function(componenet,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
    }
})