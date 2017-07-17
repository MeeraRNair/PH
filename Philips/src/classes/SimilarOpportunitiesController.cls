/*Created By: Revathy Sudhindran
* Created on: 13-july-2017
* Project: Philips Hackathon
* Description: Controller to fetch Similar Opportunities
*/

public class SimilarOpportunitiesController { 

     @AuraEnabled
     public static List<SimilarOppWrapperClass.DisplaySimilarOpps> getSimilarOpportunities (Id recordId, String searchCriteria) {
         
         List<SimilarOppWrapperClass.DisplaySimilarOpps> lstOppRecords = new List<SimilarOppWrapperClass.DisplaySimilarOpps>();
         Opportunity currOpportunity = [SELECT Name, AccountId FROM Opportunity WHERE Id=:recordId]; 
         
         // Query Products added to current opportunity
         List<OpportunityLineItem> oppLineItem = [Select Product2Id,Product2.ProductCode from OpportunityLineItem where OpportunityId= :recordId];
         
         // collection of ProductIds of current Opportunity
           Set<Id> setProductIds = new Set<Id>();
             for(OpportunityLineItem oppl: oppLineItem){
                 setProductIds.add(oppl.Product2Id);
             } 
         
         List<OpportunityLineItem> otherOppLineItemsWithSameProduct = [ SELECT opportunityId,Product2.ProductCode FROM OpportunityLineitem WHERE CreatedDate = THIS_YEAR AND product2Id IN :setProductIds order by CreatedDate DESC LIMIT 10];
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
             oppWithSameProduct = [SELECT Id, Name, StageName,CreatedDate,CloseDate,Reason_For_Close__c,MainCompetitors__c
                                                  FROM Opportunity
                                                  WHERE Id != :recordId AND Id IN :mapOppIdstopdtCodelist.keySet() AND CreatedDate = THIS_YEAR Order by CreatedDate Desc  LIMIT 10];//Limited to 10 just for demo
            }
            else{
                oppWithSameProduct = [SELECT Id, Name, StageName,CreatedDate,CloseDate,Reason_For_Close__c,MainCompetitors__c
                                                  FROM Opportunity
                                                  WHERE AccountId=:currOpportunity.AccountId AND Id != :recordId AND Id IN :mapOppIdstopdtCodelist.keySet() AND CreatedDate = THIS_YEAR Order by CreatedDate Desc  LIMIT 10];
            }
         
         
         for(Opportunity opty:oppWithSameProduct){
             
             SimilarOppWrapperClass.DisplaySimilarOpps tmpOppRecords = new SimilarOppWrapperClass.DisplaySimilarOpps();
             tmpOppRecords.opp = opty;
             tmpOppRecords.productCodeList = mapOppIdstopdtCodelist.get(opty.Id);
             lstOppRecords.add(tmpOppRecords);
             
         }
        
         return lstOppRecords;
         

     }

@AuraEnabled
     public static Map<String,List<Decimal>> getProbabilities (Id recordId) {
         
        Map<String,List<Decimal>> probabilitychart = new Map<String,List<Decimal>>();
        Opportunity currOpportunity = [SELECT Name, AccountId FROM Opportunity WHERE Id=:recordId]; 
         // Query Products added to current opportunity
         List<OpportunityLineItem> oppLineItem = [Select Product2Id,ProductCode from OpportunityLineItem where OpportunityId= :recordId];
         
         // collection of ProductIds of current Opportunity
           Set<Id> setProductIds = new Set<Id>();
             for(OpportunityLineItem oppl: oppLineItem){
                 setProductIds.add(oppl.Product2Id);
             } 
 
         List<AggregateResult> probabiltyWonproducts=  [ Select ProductCode, Count(Id) cnt
                                                         From  OpportunityLineItem 
                                                         WHERE OpportunityId!= :recordId AND Opportunity.StageName='Closed Won' AND Product2Id IN :setProductIds  GROUP BY ProductCode ];
         
         
         List<AggregateResult> probabiltyLostproducts=  [ Select ProductCode, Count(Id) cnt
                                                         From  OpportunityLineItem 
                                                         WHERE OpportunityId!= :recordId AND Opportunity.StageName='Closed Lost' AND Product2Id IN : setProductIds GROUP BY ProductCode ];
         
         Map<String, decimal> pdtcodetoCountWon= new Map<String, Decimal>();
         Map<String, decimal> pdtcodetoCountLost= new Map<String, Decimal>();
         for (AggregateResult agg : probabiltyWonproducts){
            
            String pdtCode = (String) agg.get('ProductCode');
             pdtcodetoCountWon.put(pdtcode,(Decimal) agg.get('cnt')!=null? (Decimal) agg.get('cnt'):0);
         }
          for (AggregateResult agg : probabiltyLostproducts){
            
            String pdtCode = (String) agg.get('ProductCode');
             pdtcodetoCountLost.put(pdtcode,(Decimal) agg.get('cnt')!=null? (Decimal) agg.get('cnt'):0 );
         }
         for(OpportunityLineItem oppl: oppLineItem){
             Decimal w=pdtcodetoCountWon.get(oppl.productCode)!=null? pdtcodetoCountWon.get(oppl.productCode):0;
             Decimal l=pdtcodetoCountLost.get(oppl.productCode)!=null?pdtcodetoCountWon.get(oppl.productCode):0;
             if((w+l)>0){
             Decimal probabiltyWon = (w/(w+l))*100;
             Decimal probabiltyLost = (l/(w+l))*100;
             List<Decimal> probability = new List<Decimal>();
             probability.add(probabiltyWon);
             //probability.add(probabiltyLost);
             probabilitychart.put(oppl.ProductCode,probability);
             }
         }
         
         System.debug('pc-->'+probabilitychart);
         return probabilitychart;
     }
      
    


 @AuraEnabled
public static List<String> getProbabilityReason (Id recordId) {
         
        Map<String,List<Decimal>> probabilitychart = new Map<String,List<Decimal>>();
        Opportunity currOpportunity = [SELECT Name, AccountId FROM Opportunity WHERE Id=:recordId]; 
         // Query Products added to current opportunity
         List<OpportunityLineItem> oppLineItem = [Select Product2Id,ProductCode from OpportunityLineItem where OpportunityId= :recordId];
         
         // collection of ProductIds of current Opportunity
           Set<Id> setProductIds = new Set<Id>();
             for(OpportunityLineItem oppl: oppLineItem){
                 setProductIds.add(oppl.Product2Id);
             } 
 
         Map<Id,OpportunityLineItem> probabiltyWonproducts=  new Map<Id,OpportunityLineItem>([ Select id,ProductCode, Opportunity.Reason_For_Close__c
                                                                                               From  OpportunityLineItem 
                                                                                               WHERE Opportunity.Reason_For_Close__c INCLUDES ('Product Price','Product feature') AND OpportunityId!= :recordId AND Opportunity.StageName='Closed Won' AND Product2Id IN :setProductIds ]);
         
         
         Map<Id,OpportunityLineItem> probabiltyLostproducts=  new Map<Id,OpportunityLineItem>([ Select id,ProductCode, Opportunity.Reason_For_Close__c
                                                                                                From  OpportunityLineItem 
                                                                                                WHERE Opportunity.Reason_For_Close__c INCLUDES ('Product Price','Product feature') AND OpportunityId!= :recordId AND Opportunity.StageName='Closed Lost' AND Product2Id IN :setProductIds ]);
         
         Map<String, decimal> pdtcodetoCountWon_price= new Map<String, Decimal>();
         Map<String, decimal> pdtcodetoCountWon_feature= new Map<String, Decimal>();
         Map<String, decimal> pdtcodetoCountLost_price= new Map<String, Decimal>();
         Map<String, decimal> pdtcodetoCountLost_feature= new Map<String, Decimal>();
         for (OpportunityLineItem oppl : probabiltyWonproducts.Values()){
            
            String pdtCode = oppl.ProductCode;
             if(oppl.Opportunity.Reason_for_Close__c.contains('Product Price')){
                 if(pdtcodetoCountWon_price.get(pdtcode)==null){
                    pdtcodetoCountWon_price.put(pdtcode,1);
                 }
                 else{
                    pdtcodetoCountWon_price.put(pdtcode,pdtcodetoCountWon_price.get(oppl.productCode)+1);
                 }
             }
             else{
                 if(pdtcodetoCountWon_feature.get(pdtcode)==null){
                    pdtcodetoCountWon_feature.put(pdtcode,1);
                 }
                 else{
                    pdtcodetoCountWon_feature.put(pdtcode,pdtcodetoCountWon_feature.get(oppl.productCode)+1);
                 }
            }
         }
    
        for (OpportunityLineItem oppl : probabiltyLostproducts.values()){
            
            String pdtCode = oppl.ProductCode;
           
             if(oppl.Opportunity.Reason_for_Close__c.contains('Product Price')){
                 if(pdtcodetoCountLost_price.get(pdtcode)==null){
                    pdtcodetoCountLost_price.put(pdtcode,1);
                 }
                 else{
                    pdtcodetoCountLost_price.put(pdtcode,pdtcodetoCountLost_price.get(oppl.productCode)+1);
                 }
                 
             }
             else{
                 if(pdtcodetoCountLost_feature.get(pdtcode)==null){
                    pdtcodetoCountLost_feature.put(pdtcode,1);
                 }
                 else{
                    pdtcodetoCountLost_feature.put(pdtcode,pdtcodetoCountLost_feature.get(oppl.productCode)+1);
                 }
            }
         }
          
        List<String> pdtcodeprobability = new List<String>();
         for(OpportunityLineItem oppl: oppLineItem){
             
             decimal wonprice = pdtcodetoCountWon_price.get(oppl.productcode);
             decimal wonfeature = pdtcodetoCountWon_feature.get(oppl.ProductCode);
             decimal lostprice = pdtcodetoCountLost_price.get(oppl.productcode);
             decimal lostfeature = pdtcodetoCountLost_feature.get(oppl.ProductCode);
             String type;
             String reason;
             decimal countw; decimal countl;
             if(wonprice>wonfeature){ 
                 countw =wonprice; type='Won'; reason='Product price';
             }   
             else if(wonprice<wonfeature){
                 countw=wonfeature; type='Won'; reason= 'Product feature';
             } 
             if(lostprice >lostfeature) {
                 countl=lostprice; type='Lost'; reason='Product price'; 
             } else if(lostprice<lostfeature){ 
                 countl=lostfeature; type='Lost'; reason= 'Product feature';
             }
             
             if(countw==countl ){
                      String stmnt = ' No predictions available for ' + +oppl.ProductCode ;
                      pdtcodeprobability.add(stmnt);
                 }
                 else if(countw>countl)  {
                     String stmnt = ' Opportunities with  product code '+oppl.ProductCode +' won due to '+ reason;
                      pdtcodeprobability.add(stmnt);
                 } else if(countw<countl){
                     String stmnt = ' Opportunities with  product code '+oppl.ProductCode +' lost due to '+ reason;
                      pdtcodeprobability.add(stmnt);
                 }
                 
             }
         System.debug('pc-->'+pdtcodeprobability);
         return pdtcodeprobability;
     }
      
    
    @AuraEnabled
    public static String getreport(Id recordId){
        
          Opportunity currOpportunity = [SELECT Name, AccountId FROM Opportunity WHERE Id=:recordId]; 
         // Query Products added to current opportunity
         List<OpportunityLineItem> oppLineItem = [Select Product2Id,ProductCode from OpportunityLineItem where OpportunityId= :recordId];
         
         // collection of ProductIds of current Opportunity
           Set<String> setProductIds = new Set<String>();
             for(OpportunityLineItem oppl: oppLineItem){
                 setProductIds.add(oppl.ProductCode);
             } 
 
    //Using report id for example purpose
    Report reportRec = [SELECT Id FROM Report WHERE Id = '00O7F0000030dBDUAY'];

    // Get the report metadata
Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport('00O7F0000030dBDUAY');
//Reports.ReportMetadata reportMd = new Reports.ReportMetadata();//describe.getReportMetadata();
  Reports.ReportMetadata reportMd =
          Reports.ReportManager.describeReport('00O7F0000030dBDUAY').getReportMetadata();
LIST<Reports.ReportFilter> reportFilters = new LIST<Reports.ReportFilter>();
// Override filter and run report
integer i=0;
String reportBooleanFilter ;
 for(String pdtcode: setProductIds){
    // Reports.ReportFilter filter = new Reports.ReportFilter('PRODUCT_CUSTOMER_ID','equals',pdtcode);
      Reports.ReportFilter newFilter = new Reports.ReportFilter();
      newFilter.setColumn('PRODUCT_CUSTOMER_ID');
      newFilter.setOperator('equals');
      newFilter.setValue( new List<String>(setProductIds)[0]);
      reportFilters.add(newFilter);
     //reportFilters.add(filter);
    // if(reportBooleanFilter==null) reportBooleanFilter= '1';
    // reportBooleanFilter= reportBooleanFilter+ ' OR ';
   // i++;
 }//
 //reportBooleanFilter.removeEnd(' OR ');

 
 //if(reportBooleanFilter!=null)
       reportMd.setReportBooleanFilter( reportBooleanFilter);
       reportMd.setReportFilters(reportFilters); //Ned this stmnt commented to check on the error
       Reports.ReportResults reportResult = Reports.ReportManager.runReport('00O7F0000030dBDUAY', reportMd);
       System.Debug('dd'+JSON.serialize(Reports.ReportManager.runReport('00O7F0000030dBDUAY', reportMd)));


    return JSON.serialize(reportResult);
}
    
}


 /*    public static List<Opportunity> getSimilarOpportunities (Id recordId, String searchCriteria) {
         
         Opportunity currOpportunity = [SELECT Name, AccountId FROM Opportunity WHERE Id=:recordId]; 
         
         // Query Products added to current opportunity
         List<OpportunityLineItem> oppLineItem = [Select Product2Id,Product2.ProductCode from OpportunityLineItem where OpportunityId= :recordId];
         // collection of ProductIds of current Opportunity
           Set<Id> setProductIds = new Set<Id>();
             for(OpportunityLineItem oppl: oppLineItem){
                 setProductIds.add(oppl.Product2Id);
             } 
          List<OpportunityLineItem> otherOppLineItemsWithSameProduct = [ SELECT opportunityId FROM OpportunityLineitem WHERE CreatedDate = THIS_YEAR AND product2Id IN :setProductIds order by CreatedDate DESC LIMIT 10];
          Map<Id,List<OpportunityLineItem>> setOppIds = new Map<Id,OpportunityLineItem>();
             for(OpportunityLineItem oppl: otherOppLineItemsWithSameProduct){
                 setOppIds.put(oppl.opportunityId,oppl);
             }  
         
         List<Opportunity> oppWithSameProduct =new List<Opportunity>();
        
         System.debug('SC-->'+searchCriteria);
         //Query opportunity with same products.
         if(searchCriteria == 'All'){
             System.debug(searchCriteria);
             oppWithSameProduct = [SELECT Id, Name, StageName,CreatedDate
                                                  FROM Opportunity
                                                  WHERE Id != :recordId AND Id IN :setOppIds  AND CreatedDate = THIS_YEAR Order by CreatedDate Desc  LIMIT 10];//Limited to 10 just for demo
            }
            else{
                oppWithSameProduct = [SELECT Id, Name, StageName,CreatedDate
                                                  FROM Opportunity
                                                  WHERE AccountId=:currOpportunity.AccountId AND Id != :recordId AND Id IN (SELECT opportunityId FROM OpportunityLineitem WHERE product2Id IN :setProductIds )  AND CreatedDate = THIS_YEAR Order by CreatedDate Desc LIMIT 10];
            }
        
         return oppWithSameProduct;
         

     }*/