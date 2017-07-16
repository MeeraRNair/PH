({
	doInit : function(component, event, helper) {
      
        helper.getsimilaropps(component,'All');
        helper.getProbabilities(component);
        //helper.getRecords(component, 'All');
        //console.log('1a');
    },
    
     // check which tab user has selected and if we need to fetch data from heroku
	selectTab: function(component, event, helper) {
        
        var selLink = event.target;
		var index = selLink.getAttribute("tabindex");
        helper.changeTab(component, index);
        
        if (index == 3){
           
            helper.getRecords(component, component.get("v.searchCriteria"));
        }
        else if (index == 2){
            console.log('index'+index);
            helper.getCompRecords(component, component.get("v.compFilterCriteria"));
            
        }         
                
    },
    
    filterRecords : function(component, event, helper) {
        
        component.set("v.searchCriteria", event.currentTarget.id);
        helper.getRecords(component, event.currentTarget.id);        
    },
    
    compRefresh: function(component, event, helper) {
        
        component.set("v.compFilterCriteria", event.currentTarget.id);
        helper.getCompRecords(component, event.currentTarget.id);        
    }
})