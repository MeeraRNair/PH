public class AccountTriggerHandler {
    
    public static void selectRecords(List<Account> accList, Map<Id,Account> oldAccts){
        
        List<Id> accIdList = new List<Id>();
        for(Account acc: accList){
            if((oldAccts == null || oldAccts.get(acc.Id).BillingStreet != acc.BillingStreet || oldAccts.get(acc.Id).BillingStreet != acc.BillingStreet || oldAccts.get(acc.Id).BillingCity != acc.BillingCity || oldAccts.get(acc.Id).BillingState != acc.BillingState || oldAccts.get(acc.Id).BillingPostalCode != acc.BillingPostalCode || oldAccts.get(acc.Id).BillingCountry != acc.BillingCountry ) /*&& (acc.BillingStreet != null && acc.BillingCity!= null && acc.BillingState != null && acc.BillingPostalCode != null && acc.BillingCountry != null) */){
                accIdList.add(acc.Id);
        	}
        
        
         }
        
        if(accIdList.size()>0){
            LocationCallouts.getLocation(accIdList[0]);
        }
	}
}