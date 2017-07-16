({
	doInit : function(component, event, helper) {
        
        console.log('1');
        helper.getRecords(component, 'All');
        console.log('1a');
    },
    
     // check which tab user has selected and if we need to fetch data from heroku
	selectTab: function(component, event, helper) {
        
        var selLink = event.target;
		var index = selLink.getAttribute("tabindex");
		if (index == 1)
            component.set("v.trendType","Product");
        else
            component.set("v.trendType","Competitor");
        
        helper.changeTab(component, index);
        helper.getRecords(component);
    },
    
    filterRecords : function(component, event, helper) {
        console.log(component.get("v.searchCriteria"));
        component.set("v.searchCriteria", event.currentTarget.id);
        console.log(component.get("v.searchCriteria"));
        helper.getRecords(component, event.currentTarget.id);        
    },
    
    back : function(componenet,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
    },
})