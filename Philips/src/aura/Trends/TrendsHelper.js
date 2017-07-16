({
    
    getRecords : function(component, searchType){
        console.log(component.get("v.searchCriteria"));
        var recordId = component.get("v.recordId");
        component.set("v.showChart",  false);
     	if (searchType === undefined)
            searchType = 'All';
        
        var action = component.get("c.getOpportunityTrend");        
        action.setParams({
            "opptyId": recordId,
            "searchcriteria":searchType,
            "varTrendType":component.get("v.trendType")            
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if ( state === "SUCCESS"){
           		component.set("v.TrendList",  response.getReturnValue());
                component.set("v.showChart",  true);
       		}
        });
        $A.enqueueAction(action);
        
    },
    
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
            component.set("v.showtable", true);
            }
        });
        $A.enqueueAction(action);
    },
    // helper method to show selected tab and hide previously selected tab
    changeTab : function(component, index) {
        
        if ( index == 1 ){
            
            var otherTab1 = component.find('Tab2');
            var otherTab2 = component.find('Tab3');
            var selectedTab = component.find('Tab1');           
            
        } else if ( index == 2 ){
            
            var otherTab1 = component.find('Tab1');
            var otherTab2 = component.find('Tab3');
            var selectedTab = component.find('Tab2');           
        } else if ( index == 3 ){
            
            var otherTab1 = component.find('Tab1');
            var otherTab2 = component.find('Tab2');
            var selectedTab = component.find('Tab3');          
        }  
        $A.util.addClass(selectedTab, 'slds-active'); 
        $A.util.removeClass(otherTab1, 'slds-active');   
        $A.util.removeClass(otherTab2, 'slds-active');
     
    }
})