({
		jsLoaded: function(component, event, helper) {

			setTimeout(function() {
				
				var map = L.map('map').setView([9.9955096, 76.3530599], 10);
				L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
					{
						attribution: 'PHILIPS HEALTHCARE'
					}).addTo(map);
                
				component.set("v.map", map);
				
			});
		},
		
     createAccount : function(component, event, helper) {
        var len = component.get("v.distance");
        
        var action = component.get("c.saveAccount");
         action.setParams({ 
            "dist": len
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
			var accounts = event.getParam('accounts');
			var markerArray = [];
            console.log('$$$$Acc'+accounts);
			for (var i=0; i<accounts.length; i++) {
				var account = accounts[i];
				var latLng = [account.BillingLatitude, account.BillingLongitude ];
                markerArray.push(L.marker([account.BillingLatitude, account.BillingLongitude]));
                
			    L.marker(latLng, {account: account}).addTo(map).bindPopup(account.Name+"<br/>Industry:"+account.Industry+"<br/>Rating:"+account.Rating+"<br/>AnnualRevenue:"+account.AnnualRevenue+"<br/>Billing City:"+account.BillingCity).on('dblclick', function(event) {
					helper.navigateToDetailsView(event.target.options.account.Id);
				});

                
			}
			var group = L.featureGroup(markerArray);
            map.fitBounds(group.getBounds().pad(0.1));
		},
		
		accountsLoadedAfterSearch: function(Component, event, helper){
			var currentLong;
			var currentLat;
			// Add markers
			var map = component.get('v.map');
            var markerArray = [];
			            
			var accounts = event.getParam('accounts');
			for (var i=0; i<accounts.length; i++) {
				var account = accounts[i];
				var latLng = [account.BillingLatitude, account.BillingLongitude ];  
                markerArray.push(L.marker([account.BillingLatitude, account.BillingLongitude]));
				L.marker(latLng, {account: account}).addTo(map).bindPopup(account.Name).on('dblclick', function(event) {
					helper.navigateToDetailsView(event.target.options.account.Id);
				});
			} 
       
            var group = L.featureGroup(markerArray);
            map.fitBounds(group.getBounds().pad(0.1));
		}
	})