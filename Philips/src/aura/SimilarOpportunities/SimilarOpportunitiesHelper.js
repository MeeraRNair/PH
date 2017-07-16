({
	getsimilaropps : function(component, searchType){
    	var recordId = component.get("v.recordId");
        var action = component.get("c.getSimilarOpportunities");
        action.setParams({
            recordId: recordId,
            searchCriteria: searchType
        });
        action.setCallback(this, function(response){
            var similarOpportunities = response.getReturnValue();
            component.set("v.similarOpportunities", similarOpportunities);
        });
        $A.enqueueAction(action);
    },
	
    getProbabilities : function(component){
    	var recordId = component.get("v.recordId");
        var action = component.get("c.getProbabilities");
        action.setParams({
            recordId: recordId,
        });
        action.setCallback(this, function(response){
            
             var state = response.getState();
            if (state === "SUCCESS") {                
                var probs = [];
                var probabilities = response.getReturnValue();
                for ( var key in probabilities ) {
                    probs.push({value:probabilities[key], key:key});
                }
            
            component.set("v.probability", probs);
            component.set("v.showBool", false);
            }
        });
        $A.enqueueAction(action);
    }
})