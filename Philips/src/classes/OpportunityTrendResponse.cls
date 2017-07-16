public class OpportunityTrendResponse {
	
    @AuraEnabled public Map<String, Integer> predictionMap {get; set;}
    @AuraEnabled public list<OpportunityLineItem> oliList {get;set;}
        
    public OpportunityTrendResponse(String prod){
        
        this.predictionMap = new Map<String, Integer>();
        oliList = new list<OpportunityLineItem>();
    }
    
    public void addToPredictionList(String str, Integer percent){

        predictionMap.put(str, percent);
               
    }
    
    public void addToOliList(OpportunityLineItem oli){
        
        oliList.add(oli);        
    }
        
}