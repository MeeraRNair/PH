/*Created By: Revathy Sudhindran
* Created on: 13-july-2017
* Project: Philips Hackathon
* Description: Controller to fetch lead trend
*/
public class TrendLeadController {


     @AuraEnabled
    public static List<SimilarOppWrapperClass.DisplaySimilarLeads> getSimilarLeads (Id recordId, String searchCriteria){
    
       /*  List<SimilarOppWrapperClass.DisplaySimilarLeads> lstLeadRecords = new List<SimilarOppWrapperClass.DisplaySimilarLeads>();
         Lead currLead = [SELECT Id,Name, Product_Interests__C FROM Lead WHERE Id=:recordId]; 
         String[] pdtInterests=currentLead.Product_Interests__C.split(',');
         
		//Leads closed convereted recently  with same product series
         List<Lead> otherLeadWithSameProductseries = [ SELECT ConvertedopportunityId,Product_Interests__C FROM Lead WHERE CloseDate = THIS_YEAR AND Product_Interests__C   INCLUDES :pdtInterests AND ConvertedopportunityId.StageName='Closed Won' order by CreatedDate DESC LIMIT 10];
		 
         
         Map<Id,String> mapOppIdstopdtCodelist = new Map<Id,String>();
          
         for(OpportunityLineItem oppl: otherOppLineItemsWithSameProduct){
                 
                 String pdtcode = oppl.Product2.ProductCode;
                 if(mapOppIdstopdtCodelist.containsKey(oppl.OpportunityId)){
                     
                     pdtcode = mapOppIdstopdtCodelist.get(oppl.OpportunityId)+', '+oppl.Product2.ProductCode; // if opportunity has more than one same product
                 }
                 
                 mapOppIdstopdtCodelist.put(oppl.opportunityId,pdtcode);
             } 	
         
         List<Opportunity> oppWithSameProduct =new List<Opportunity>();
    
         //Query opportunity with same products.
         if(searchCriteria == 'All'){
             System.debug(searchCriteria);
         	 oppWithSameProduct = [SELECT Id, Name, StageName,CreatedDate
                                                  FROM Opportunity
                                                  WHERE Id != :recordId AND Id IN :mapOppIdstopdtCodelist.keySet() AND CreatedDate = THIS_YEAR Order by CreatedDate Desc  LIMIT 10];//Limited to 10 just for demo
     		}
    		else{
        		oppWithSameProduct = [SELECT Id, Name, StageName,CreatedDate
                                                  FROM Opportunity
                                                  WHERE AccountId=:currOpportunity.AccountId AND Id != :recordId AND Id IN :mapOppIdstopdtCodelist.keySet() AND CreatedDate = THIS_YEAR Order by CreatedDate Desc  LIMIT 10];
            }
         
         
         for(Opportunity opty:oppWithSameProduct){
             
             SimilarOppWrapperClass.DisplaySimilarOpps tmpOppRecords = new SimilarOppWrapperClass.DisplaySimilarOpps();
             tmpOppRecords.opp = opty;
             tmpOppRecords.productCodeList = mapOppIdstopdtCodelist.get(opty.Id);
             lstOppRecords.add(tmpOppRecords);
             
         }
        
         return lstOppRecords;*/
         return null;
         

     }

}