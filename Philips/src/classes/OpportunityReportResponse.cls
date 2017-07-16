public class OpportunityReportResponse {
	
    @AuraEnabled public String product {get; set;}
    @AuraEnabled public list<wcWrapperClass> wcList {get;set;}
        
    public OpportunityReportResponse(String prod){
        
        this.product = prod;
        wcList = new list<wcWrapperClass>();
    }
    
    public void addToWrapper(String stageName, decimal sumAmount){

        wcWrapperClass wcRec = new wcWrapperClass();
        wcRec.stage = stageName;
        //wcRec.sumQuantity = sumQty;
        wcRec.sumAmount = sumAmount;
        
        wcList.add(wcRec);
        
    }
    
    public class wcWrapperClass{
        @AuraEnabled public String stage {get; set;}
       // @AuraEnabled public Decimal sumQuantity {get; set;}
        @AuraEnabled public Decimal sumAmount {get; set;}
    }
}