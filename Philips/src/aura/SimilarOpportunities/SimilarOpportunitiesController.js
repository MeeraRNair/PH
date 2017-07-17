({
    doInit : function(component, event, helper) {
        helper.getsimilaropps(component,'All');
        helper.getProbabilities(component);
        helper.getProbabilityReason(component);
    },

    navToRecord : function (component, event, helper) {
        var selectedItem = event.currentTarget;
        console.log(selectedItem);
        var recordId = selectedItem.dataset.record;
        console.log(recordId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    
    goThere : function(componenet,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
    },
    
	filterRecords : function(component, event, helper) {
      
        var recordId = component.get("v.recordId");
        var action = component.get("c.getSimilarOpportunities");
        action.setParams({
            recordId: recordId,
            searchCriteria: component.get("v.searchCriteria")
        });
        action.setCallback(this, function(response){
            var similarOpportunities = response.getReturnValue();
            component.set("v.similarOpportunities", similarOpportunities);
        });
        $A.enqueueAction(action);
      
	}
})