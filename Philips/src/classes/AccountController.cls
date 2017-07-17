public with sharing class AccountController {
    public static Decimal latParam = 9.95762;
    public static Decimal longParam  = 76.25115;

    @AuraEnabled
    public static List<Account> findAll(Decimal comLat,Decimal comLong) {
        system.debug('#####COMVALUES'+comLat+':::'+comLong);
        latParam = comLat;
        longParam = comLong;
    //public static List<Account> findAll(Decimal comLong) {
     
    //return(Database.Query('Select Id,Name,BillingLatitude, BillingLongitude,AnnualRevenue,Industry,Rating,BillingCity from Account where BillingLatitude != NULL AND BillingLongitude != NULL AND Distance(Location__c,Geolocation('+comLat+','+comLong+'),\'mi\') < 2000 limit 50'));
     return(Database.Query('Select Id,Name,BillingLatitude, BillingLongitude,AnnualRevenue,Industry,Rating,BillingCity from Account where BillingLatitude != NULL AND BillingLongitude != NULL AND Distance(Location__c,Geolocation(9.77,77.55),\'mi\') < 2000 limit 50'));

    }

    
    @AuraEnabled
    public static List<Account> saveAccount (Integer dist) {
    System.debug('Params  '+latParam+'::::'+longParam);
    System.debug('acc  '+dist);
    return [Select id, name, BillingLatitude, BillingLongitude 
            				FROM Account
            				WHERE BillingLatitude != NULL AND BillingLongitude != NULL AND DISTANCE(Location__c, GEOLOCATION(:latParam, :longParam),'mi') <: dist 
            				LIMIT 50];
	
    
    //return acc;
    } 
    
     @AuraEnabled
  public static List<String> getAccount(String ObjectApi_name,String Field_name){ 

  List<String> lstPickvals=new List<String>();
  Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
    Sobject Object_name = targetType.newSObject();
  Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
    Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
    Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
    List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
    for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
      lstPickvals.add(a.getValue());//add the value  to our final list
   }

  return lstPickvals;
}
}