({
    doInit : function(component, event, helper) {
       // helper.doInit(component, event);
        var comLong1;
        if(navigator.geolocation){
        navigator.geolocation.getCurrentPosition(function(position){
            alert('Latitude:'+position.coords.latitude+'   Longitude:'+ position.coords.longitude);
        helper.setGeo(component, position.coords.latitude,position.coords.longitude);

        comLong1 = position.coords.longitude;
    });
  }
        //helper.findAndFocus();
        //var comLong = component.get("v.comLong");
    } 
})