({

    getRecords : function(component, searchType){
        
        var recordId = component.get("v.recordId");
        component.set("v.showChart",  false);
     	if (searchType === undefined)
            searchType = 'All';
        
        var action = component.get("c.getOpportunityProductTrend");        
        action.setParams({
            "opptyId": recordId,
            "searchcriteria":searchType            
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
    
    getCompRecords : function(component, searchType){
        
        var recordId = component.get("v.recordId");
        
        component.set("v.showCompetitorChart",  false);
       
     	if (searchType === undefined)
            searchType = 'All';
        
        var action = component.get("c.getCompetitorInsight");        
        action.setParams({
            "opptyId": recordId,
            "searchcriteria":searchType            
        });
                
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if ( state === "SUCCESS"){
           		component.set("v.compResponse",  response.getReturnValue());
                component.set("v.showCompetitorChart",  true);
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
        console.log('changetab');
        console.log(index);
        
        if ( index == 1 ){
            
            var otherTab1 = component.find('Tab2');
            var otherTab1Data = component.find('Tab2Data');
            
            var otherTab2 = component.find('Tab3');
            var otherTab2Data = component.find('Tab3Data');
            
            var selectedTab = component.find('Tab1');           
            var selectedTabData = component.find('Tab1Data');           
            
        } else if ( index == 2 ){
            
             var otherTab1 = component.find('Tab1');
            var otherTab1Data = component.find('Tab1Data');
            
            var otherTab2 = component.find('Tab3');
            var otherTab2Data = component.find('Tab3Data');
            
            var selectedTab = component.find('Tab2');           
            var selectedTabData = component.find('Tab2Data'); 
            
        } else if ( index == 3 ){
            
            var otherTab1 = component.find('Tab1');
            var otherTab1Data = component.find('Tab1Data');
            
            var otherTab2 = component.find('Tab2');
            var otherTab2Data = component.find('Tab2Data');
            
            var selectedTab = component.find('Tab3');           
            var selectedTabData = component.find('Tab3Data');           
        }  
        
        $A.util.addClass(selectedTab, 'slds-active');
        $A.util.addClass(selectedTabData, 'slds-show');
        $A.util.removeClass(selectedTabData, 'slds-hide');
        
        $A.util.removeClass(otherTab1, 'slds-active');  
         $A.util.removeClass(otherTab1Data, 'slds-show');
        $A.util.addClass(otherTab1Data, 'slds-hide');
        
        $A.util.removeClass(otherTab2, 'slds-active');
     	 $A.util.removeClass(otherTab2Data, 'slds-show');
        $A.util.addClass(otherTab2Data, 'slds-hide');
    }
})