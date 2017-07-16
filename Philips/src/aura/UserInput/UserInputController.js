({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAccount");
        console.log("action in do init" +action);
        action.setParams({"ObjectApi_name": "Account",
                         "Field_name": "Type"});
    	action.setCallback(this, function(a) {
     		component.set("v.AcTypes", a.getReturnValue());
    	});
    	$A.enqueueAction(action); 
    },
    
    jsLoaded: function(component, event, helper) {

        setTimeout(function() {
         console.log('@@ inside jsloaded:');   
            var map = L.map('map').setView([9.9955096, 76.3530599], 10);
            L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: 'Tiles © Esri'
                }).addTo(map);
             
            component.set("v.map", map);
            
        });
    },
  

jsLoadednew: function(component, event, helper) {

    setTimeout(function() {

        var map = L.map('map', {zoomControl: false}).setView([37.784173, -122.401557], 14);

        L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',

            {

               attribution: 'Tiles © Esri'

            }).addTo(map);

 


        L.marker([37.784173, -122.401557]).addTo(map)

            .bindPopup('Home of Dreamforce');

});

},



    createAccount : function(component, event, helper) {
        var len = component.get("v.distance");
        var tp = component.get("v.accounttype");
        var action = component.get("c.saveAccount");
        action.setParams({ 
            "dist": len,
            "AType" : tp
        });
      
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@ state:'+state);
           // component.set("v.accounts", response.getReturnValue());
            console.log('@@ res:'+response.getReturnValue());
            var event = $A.get("e.c:AccountsLoaded");
            event.setParams({"accounts": response.getReturnValue()});
            event.fire();
        });
        $A.enqueueAction(action)
	},
    
    accountsLoaded: function(component, event, helper) {
    
            // Add markers
            var map = component.get('v.map');
        	//map.removeLayer(L.marker);
            var accounts = event.getParam('accounts');
        	console.log('##acc:'+accounts);
            for (var i=0; i<accounts.length; i++) {
                var account = accounts[i];
                var latLng = [account.BillingLatitude, account.BillingLongitude ];
                console.log('##latLng:'+latLng);
                L.marker(latLng, {account: account}).addTo(map).bindPopup(account.Name).on('dblclick', function(event) {
                    console.log(event.target.options.account.Id);
                    helper.navigateToDetailsView(event.target.options.account.Id);
                });
                
            }   
       },
})