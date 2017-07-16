({
    navigateToDetailsView : function(accountId) {
        console.log('##accountid:'+accountId);
        var eventnav = $A.get("e.force:navigateToSObject");
        eventnav.setParams({
            "recordId": accountId,
            "isredirect":true
        });
        eventnav.fire();
    },
    
    
 
})