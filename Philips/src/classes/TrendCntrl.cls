public class TrendCntrl {

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
            //  oppty.addToWrapper(stageName, tmpMap.get(stageName));
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
            //  oppty.addToWrapper(stageName, tmpMap.get(stageName));
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
    
    
    //Revathy's code starts here
    // Product tab-similar opps


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
 
         List<AggregateResult> probabiltyWonproducts=  [ Select ProductCode, Count(Id ) cnt
                                                         From  OpportunityLineItem 
                                                         WHERE OpportunityId!= :recordId AND Opportunity.StageName='Closed Won' AND Product2Id IN :setProductIds GROUP BY ROLLUP (ProductCode) ];
         
         
         List<AggregateResult> probabiltyLostproducts=  [ Select ProductCode, Count(Id ) cnt
                                                         From  OpportunityLineItem 
                                                         WHERE OpportunityId!= :recordId AND Opportunity.StageName='Closed Lost' AND Product2Id IN : setProductIds GROUP BY ROLLUP (ProductCode) ];
         
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
             Decimal probabiltyWon = 0;
             Decimal probabiltyLost = 0;
             List<Decimal> probability = new List<Decimal>();
             if((w+l)>0){
                probabiltyWon = (w/(w+l))*100;
                probabiltyLost = (l/(w+l))*100;
             }
             probability.add(probabiltyWon);
             probability.add(probabiltyLost);
             probabilitychart.put(oppl.ProductCode,probability);
             
         }
          System.debug('pc-->'+probabilitychart);
         return probabilitychart;
     }
     
    @AuraEnabled
    public static InsightsResponse getCompetitorInsight(Id opptyId, String searchcriteria){
        
        Integer wonCount = 0;
        Integer lostCount = 0;
        Map<String, Map<String, decimal>> dataMap = new Map<String, Map<String, decimal>>();      
        InsightsResponse response = new InsightsResponse();
        List<OpportunityReportResponse> responseList = new List<OpportunityReportResponse>();
        Opportunity oppRecord = [SELECT Id, accountId, Primary_Competitor__c  From Opportunity WHERE id = :opptyId];
        List<OpportunityLineItem> oliList = new  List<OpportunityLineItem>();
        
        List<AggregateResult> groupedResults = new List<AggregateResult> ();        
        if(searchcriteria == 'All'){
            
            groupedResults = [SELECT Product2.ProductCode, Opportunity.StageName, Sum(Quantity) sumQty
                              FROM OpportunityLineItem
                              WHERE Opportunity.Primary_Competitor__c = :oppRecord.Primary_Competitor__c                              
                              Group By Product2.ProductCode, Opportunity.StageName ];
            
            oliList = [SELECT OpportunityId, Opportunity.Name, Product2Id, Product2.Name, Opportunity.StageName, Opportunity.Account.Name,
                            Opportunity.CloseDate, Opportunity.Primary_Competitor__c, Opportunity.Reason_For_Close__c
                              FROM OpportunityLineItem
                              WHERE Opportunity.Primary_Competitor__c = :oppRecord.Primary_Competitor__c                              
                              Order By Product2.Name, Opportunity.Name ];
        }
        else{
            groupedResults = [SELECT Product2.ProductCode, Opportunity.StageName, Sum(Quantity) sumQty
                              FROM OpportunityLineItem
                              WHERE Opportunity.Primary_Competitor__c = :oppRecord.Primary_Competitor__c 
                              AND Opportunity.AccountId = :oppRecord.accountId
                              Group By Product2.ProductCode, Opportunity.StageName ];
            
            oliList = [SELECT OpportunityId, Opportunity.Name, Product2Id, Product2.Name, Opportunity.StageName, Opportunity.Account.Name,
                            Opportunity.CloseDate, Opportunity.Primary_Competitor__c, Opportunity.Reason_For_Close__c
                              FROM OpportunityLineItem
                              WHERE Opportunity.Primary_Competitor__c = :oppRecord.Primary_Competitor__c 
                                AND Opportunity.AccountId = :oppRecord.accountId
                              Order By Product2.Name, Opportunity.Name ];
        }
        
        for (AggregateResult agg : groupedResults){
            
            String stage = (String) agg.get('StageName');
            if ( stage != 'Closed Won' && stage != 'Closed Lost')
                stage = 'Open';
            
            String prodCode = (String)agg.get('ProductCode');   
            Map<String, Decimal> tmpStageMap = new Map<String, Decimal>();
            if(dataMap.get(prodCode) != null){
                
                tmpStageMap = dataMap.get(prodCode);
                tmpStageMap.put(stage, (decimal) agg.get('sumQty'));
                
            } else{            
                
                if ( tmpStageMap.get(stage) == null )
                    tmpStageMap.put(stage, (decimal) agg.get('sumQty'));
                else{
                    tmpStageMap.put(stage, tmpStageMap.get(stage) + (decimal) agg.get('sumQty'));
                }                    
            }
            dataMap.put(prodCode, tmpStageMap);
        }
        
        for(String prod : dataMap.keySet()){
            
            OpportunityReportResponse oppty = new OpportunityReportResponse(prod);
            Map<String, Decimal> tmpMap = dataMap.get(prod);
            
            if (tmpMap.get('Closed Won') != null)
                oppty.addToWrapper('Closed Won', tmpMap.get('Closed Won'));
            
               if (tmpMap.get('Closed Lost') != null)
                oppty.addToWrapper('Closed Lost', tmpMap.get('Closed Lost'));
           
              if (tmpMap.get('Open') != null)
                oppty.addToWrapper('Open', tmpMap.get('Open'));
           
            responseList.add(oppty);
        }
        response.chartList = responseList;
        
        
        // Query Products added to current opportunity
         List<OpportunityLineItem> oppLineItem = [Select Product2Id,Product2.ProductCode from OpportunityLineItem where OpportunityId= :opptyId];
         
         // collection of ProductIds of current Opportunity
        Set<Id> setProductIds = new Set<Id>();
         for(OpportunityLineItem oppl: oppLineItem){
             setProductIds.add(oppl.Product2Id);
         } 
             
        for (OpportunityLineItem oli : oliList){
            if (setProductIds.contains(oli.Product2Id)){
                if (oli.Opportunity.StageName == 'Closed Won')
                    wonCount = wonCount + 1;
                else if (oli.Opportunity.StageName == 'Closed Lost')
                    lostCount = lostCount + 1;
            }
            response.addToDetailList(oli);
        }
        
        Integer wonPercent = ( wonCount *100) / (wonCount + lostCount);
        response.prediction = 'Probability to win against selected competitor & product :' + wonPercent;
        return response;
    }    
     
}