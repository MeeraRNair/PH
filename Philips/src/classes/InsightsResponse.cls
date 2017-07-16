public class InsightsResponse {
    
    @AuraEnabled public List<OpportunityReportResponse> chartList {get; set;}
    @AuraEnabled public List<wcDetails> wcDetailList {get; set;}
    @AuraEnabled public String prediction {get; set;}
    
    public InsightsResponse(){
		chartList = new List<OpportunityReportResponse>();
        wcDetailList = new List<wcDetails>();
        prediction = '';
    }
    
    public void addToDetailList(OpportunityLineItem oli){
   		wcDetails wcRec = new wcDetails();
        wcRec.opptyName = oli.Opportunity.Name;
        wcRec.opptyId = oli.OpportunityId;
        wcRec.closeDate = oli.Opportunity.CloseDate;
        wcRec.stage = oli.Opportunity.Stagename;
        wcRec.reason = oli.Opportunity.Reason_For_Close__c;
        wcRec.product = oli.Product2.Name;
        wcRec.account = oli.Opportunity.Account.Name;
        wcRec.competitor = oli.Opportunity.Primary_Competitor__c;
               
        wcDetailList.add(wcRec);
    }
    
    public class wcDetails{
        @AuraEnabled public Id opptyId {get; set;}        
        @AuraEnabled public String opptyName {get; set;}
        @AuraEnabled public date closeDate {get; set;}
        @AuraEnabled public String stage {get; set;}
        @AuraEnabled public String reason {get; set;}
        @AuraEnabled public String product {get; set;}
        @AuraEnabled public String account {get; set;}
        @AuraEnabled public String competitor {get; set;}

        public wcDetails(){
            
        } 
    }

}