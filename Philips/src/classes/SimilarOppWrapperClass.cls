public class SimilarOppWrapperClass {
    
    public class DisplaySimilarOpps {
        

        @AuraEnabled public Opportunity opp;
        @AuraEnabled public string productCodeList;
   
        public DisplaySimilarOpps(){
            opp=null;
            productCodeList='';
			
        }
    }
    public class DisplaySimilarLeads {
        

        @AuraEnabled public Lead leads;
        @AuraEnabled public string productSeries;
   
        public DisplaySimilarLeads(){
            leads=null;
            productSeries='';
			
        }
    }
}