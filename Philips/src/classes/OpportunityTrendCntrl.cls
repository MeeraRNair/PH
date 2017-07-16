public class OpportunityTrendCntrl {

    @AuraEnabled
    public static List<OpportunityReportResponse> getOpportunityTrend(Id opptyId, String searchcriteria, String varTrendType){
    	
        List<OpportunityReportResponse> responseList;
        if (varTrendType == 'Product')
            responseList = getOpportunityProductTrend(opptyId, searchcriteria);
        else
            responseList = getCompetitorTrend(opptyId, searchcriteria);
        
        return responseList;
    }
             
    public static List<OpportunityReportResponse> getOpportunityProductTrend(Id opptyId,String searchcriteria){
        
        system.debug('$$ opptyId:'+opptyId);
        Map<String, Map<String, decimal>> dataMap = new Map<String, Map<String, decimal>>();
        List<OpportunityReportResponse> responseList = new List<OpportunityReportResponse>();
        
         List<AggregateResult> oliList;
         Opportunity oppRecord;
		if(searchcriteria == 'All'){
            oliList = [SELECT Product2Id FROM OpportunityLineItem 
                       GROUP BY Product2Id
                       ORDER BY Sum(TotalPrice) DESC LIMIT 5];
        } else {
            oppRecord = [SELECT Id, accountId From Opportunity WHERE id = :opptyId];
            
            oliList = [SELECT Product2Id FROM OpportunityLineItem 
                       Where Opportunity.AccountId = :oppRecord.accountId
                       GROUP BY Product2Id
                       ORDER BY Sum(TotalPrice) DESC LIMIT 5];
        }
        Set<Id> prodIdSet = new Set<Id>();
        for (AggregateResult oli : oliList){
            prodIdSet.add((Id) oli.get('Product2Id'));
        }
        
        List<AggregateResult> groupedResults = new List<AggregateResult> ();
        
        if(searchcriteria == 'All'){
            
            groupedResults = [SELECT Product2.ProductCode, Opportunity.StageName, Sum(Quantity) sumQty, sum(TotalPrice) sumAmount
                              FROM OpportunityLineItem
                              WHERE Product2Id in :prodIdSet
                              Group By Product2.ProductCode, Opportunity.StageName ];
        }
        else{
        	groupedResults = [SELECT Product2.ProductCode, Opportunity.StageName, Sum(Quantity) sumQty, sum(TotalPrice) sumAmount
                              FROM OpportunityLineItem
                              Where Opportunity.AccountId = :oppRecord.accountId AND Product2Id in :prodIdSet
                              Group By Product2.ProductCode, Opportunity.StageName ];
        }
        
        for (AggregateResult agg : groupedResults){
         	
            String stage = (String) agg.get('StageName');
            if ( stage != 'Closed Won' && stage != 'Closed Lost')
                stage = 'Open';
            
            String prodCode = (String)agg.get('ProductCode');
            
            Map<String, Decimal> tmpStageMap = new Map<String, Decimal>();
            if(dataMap.get(prodCode) != null){
                
                tmpStageMap = dataMap.get(prodCode);
                tmpStageMap.put(stage, (decimal) agg.get('sumAmount'));
                
            } else{            
                
                if ( tmpStageMap.get(stage) == null )
                    tmpStageMap.put(stage, (decimal) agg.get('sumAmount'));
                else{
                    tmpStageMap.put(stage, tmpStageMap.get(stage) + (decimal) agg.get('sumAmount'));
                }                    
            }
            dataMap.put(prodCode, tmpStageMap);
        }
        
        for(String prod : dataMap.keySet()){
            
            OpportunityReportResponse oppty = new OpportunityReportResponse(prod);
            Map<String, Decimal> tmpMap = dataMap.get(prod);
            
            //for(String stageName : tmpMap.keySet()){                
			//	oppty.addToWrapper(stageName, tmpMap.get(stageName));
            //}
            //
            if (tmpMap.get('Closed Won') != null)
                oppty.addToWrapper('Closed Won', tmpMap.get('Closed Won'));
            
              if (tmpMap.get('Closed Lost') != null)
                oppty.addToWrapper('Closed Lost', tmpMap.get('Closed Lost'));
           
              if (tmpMap.get('Open') != null)
                oppty.addToWrapper('Open', tmpMap.get('Open'));
           
            responseList.add(oppty);
        }
          
        return responseList;
    }
    
    public static List<OpportunityReportResponse> getCompetitorTrend(Id opptyId, String searchcriteria){
        
        /*List<Opportunity> currentOpp = [SELECT id, Name, Primary_Competitor__c from Opportunity where Id = :opptyId];
        
        String[] mainCompetitors= currentOpp[0].MainCompetitors__c.split(',');
        
        
        if(searchcriteria == 'All'){
            //No of opp  that have lost to current competitor  same account/ all accounts and general reason
            List<Opportunity> oppListLost = [SELECT id, Name, Reason_For_Close__c FROM Opportunity where MainCompetitors__c =: mainCompetitors[0] and StageName='Closed Lost']; //only one competitor name  handled  for now
            //No of opp  that have Won to current competitor  same account/ all accounts
            List<Opportunity> oppListWon = [SELECT id, Name, Reason_For_Close__c FROM Opportunity where MainCompetitors__c =: mainCompetitors[0] and StageName='Closed Won']; //only one competitor name  handled  for now

        }
        
        //How to calculate the probaability
        //
        */
        
        system.debug('$$ opptyId:'+opptyId);
        Map<String, Map<String, decimal>> dataMap = new Map<String, Map<String, decimal>>();
        List<OpportunityReportResponse> responseList = new List<OpportunityReportResponse>();
        
         List<AggregateResult> opptyList;
         Opportunity oppRecord;
		if(searchcriteria == 'All'){
            opptyList = [SELECT Primary_Competitor__c FROM Opportunity 
                       GROUP BY Primary_Competitor__c
                       ORDER BY Sum(ExpectedRevenue) DESC LIMIT 5 ];
        } else {
            oppRecord = [SELECT Id, accountId From Opportunity WHERE id = :opptyId];
            
            opptyList = [SELECT Primary_Competitor__c FROM Opportunity 
                       Where Opportunity.AccountId = :oppRecord.accountId
                       GROUP BY Primary_Competitor__c
                       ORDER BY Sum(ExpectedRevenue) DESC LIMIT 5];
        }
        Set<String> compSet = new Set<String>();
        for (AggregateResult oli : opptyList){
            compSet.add((String) oli.get('Primary_Competitor__c'));
        }
        
        List<AggregateResult> groupedResults = new List<AggregateResult> ();
        
        if(searchcriteria == 'All'){
            
            groupedResults = [SELECT Primary_Competitor__c, StageName, sum(ExpectedRevenue) sumAmount
                              FROM Opportunity
                              WHERE Primary_Competitor__c in :compSet
                              Group By Primary_Competitor__c, StageName
                             ORDER By Primary_Competitor__c];
        }
        else{
        	groupedResults = [SELECT Primary_Competitor__c, StageName, sum(ExpectedRevenue) sumAmount
                              FROM Opportunity
                              WHERE AccountId = :oppRecord.accountId and Primary_Competitor__c in :compSet
                              Group By Primary_Competitor__c, StageName
                              ORDER By Primary_Competitor__c ];
        }
        
        for (AggregateResult agg : groupedResults){
         	
            String stage = (String) agg.get('StageName');
            if ( stage != 'Closed Won' && stage != 'Closed Lost')
                stage = 'Open';
            
            String prodCode = (String)agg.get('Primary_Competitor__c');
            if (prodCode == null)
                prodCode = 'Unknown';
            
            Map<String, Decimal> tmpStageMap = new Map<String, Decimal>();
            if(dataMap.get(prodCode) != null){
                
                tmpStageMap = dataMap.get(prodCode);
                tmpStageMap.put(stage, (decimal) agg.get('sumAmount'));
                
            } else{            
                
                if ( tmpStageMap.get(stage) == null )
                    tmpStageMap.put(stage, (decimal) agg.get('sumAmount'));
                else{
                    tmpStageMap.put(stage, tmpStageMap.get(stage) + (decimal) agg.get('sumAmount'));
                }                    
            }
            dataMap.put(prodCode, tmpStageMap);
        }
        
        for(String prod : dataMap.keySet()){
            
            OpportunityReportResponse oppty = new OpportunityReportResponse(prod);
            Map<String, Decimal> tmpMap = dataMap.get(prod);
            
            //for(String stageName : tmpMap.keySet()){                
			//	oppty.addToWrapper(stageName, tmpMap.get(stageName));
            //}
            //
            if (tmpMap.get('Closed Won') != null)
                oppty.addToWrapper('Closed Won', tmpMap.get('Closed Won'));
            
              if (tmpMap.get('Closed Lost') != null)
                oppty.addToWrapper('Closed Lost', tmpMap.get('Closed Lost'));
           
              if (tmpMap.get('Open') != null)
                oppty.addToWrapper('Open', tmpMap.get('Open'));
           
            responseList.add(oppty);
        }
          
        return responseList;
        
    }
     
}