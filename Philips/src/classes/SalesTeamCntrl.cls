public class SalesTeamCntrl {
    
    //Method to calculate winning salesteam
    public String calculatewinningslaesteam(){
        
        //Variables
        String message = 'Sales Team combination who has won maximum Deals in the past:';
        Map<String,String> oppstmap = new  Map<String,String>();
        Map<String,Integer> stcnt = new  Map<String,Integer>();
        for(OpportunityTeamMember ptmmember : [SELECT Id,Name,OpportunityAccessLevel,OpportunityId,TeamMemberRole,UserId,user.name,opportunity.name 
                                               FROM OpportunityTeamMember order by OpportunityId]){
             if(oppstmap.get(ptmmember.OpportunityId)==null){
                  oppstmap.put(ptmmember.OpportunityId,ptmmember.user.name);                                     
             }  
             else{
                 oppstmap.put(ptmmember.OpportunityId,oppstmap.get(ptmmember.OpportunityId)+','+ptmmember.user.name);
             }                                      
        }
        
        System.debug(oppstmap);
        for(String sname : oppstmap.values()){
            if(stcnt.get(sname)==null){
                stcnt.put(sname,0);
                List<String> fsnamelist = sname.split(',');
                set<String> fsnameset = new set<String>();
                fsnameset.addAll(fsnamelist);
                for(String snamenext : oppstmap.values()){
                    List<String> fsnamelist1 = snamenext.split(',');
                    set<String> fsnameset1 = new set<String>();
                    fsnameset1.addAll(fsnamelist1);
                    if(fsnameset1.containsAll(fsnameset)){
                        stcnt.put(sname,stcnt.get(sname)+1);
                    }
                }   
            }
        }
         System.debug(stcnt);
         
         //find combination with maximum occurance
         String res;
         Integer cnt = 0;
          for(String comb : stcnt.keySet()){
            if(stcnt.get(comb) >= cnt){
                if(stcnt.get(comb) == cnt && cnt!=0){
                    
                    res = res+' : '+comb;
                    cnt = stcnt.get(comb);
                }   
                else {
                    res = comb;
                    cnt = stcnt.get(comb);
                }           
            }
        }
         message=message+res+'. No.of Won opportunities:'+cnt;
         System.debug(message);
        return message;
    }
    
    //Calculation for currentaccount
    public String calculatewinningslaesteam_currentaccount(String recid){
        
        //Variables
        String message = 'Sales Team combination who has won maximum Deals in the past:';
        Map<String,String> oppstmap = new  Map<String,String>();
        Map<String,Integer> stcnt = new  Map<String,Integer>();
        //select accountid for current opportunity
        List<Opportunity> opplist = [SELECT id,accountid from Opportunity WHERE id=:recid];
        for(OpportunityTeamMember ptmmember : [SELECT Id,Name,OpportunityAccessLevel,OpportunityId,TeamMemberRole,UserId,user.name,opportunity.name 
                                               FROM OpportunityTeamMember where opportunity.accountid = :opplist[0].accountid order by OpportunityId]){
             if(oppstmap.get(ptmmember.OpportunityId)==null){
                  oppstmap.put(ptmmember.OpportunityId,ptmmember.user.name);                                     
             }  
             else{
                 oppstmap.put(ptmmember.OpportunityId,oppstmap.get(ptmmember.OpportunityId)+','+ptmmember.user.name);
             }                                      
        }
        
        System.debug(oppstmap);
        for(String sname : oppstmap.values()){
            if(stcnt.get(sname)==null){
                stcnt.put(sname,0);
                List<String> fsnamelist = sname.split(',');
                set<String> fsnameset = new set<String>();
                fsnameset.addAll(fsnamelist);
                for(String snamenext : oppstmap.values()){
                    List<String> fsnamelist1 = snamenext.split(',');
                    set<String> fsnameset1 = new set<String>();
                    fsnameset1.addAll(fsnamelist1);
                    if(fsnameset1.containsAll(fsnameset)){
                        stcnt.put(sname,stcnt.get(sname)+1);
                    }
                }   
            }
        }
         System.debug(stcnt);
         
         //find combination with maximum occurance
         String res;
         Integer cnt = 0;
          for(String comb : stcnt.keySet()){
            if(stcnt.get(comb) >= cnt){
                if(stcnt.get(comb) == cnt && cnt!=0){
                    
                    res = res+' : '+comb;
                    cnt = stcnt.get(comb);
                }   
                else {
                    res = comb;
                    cnt = stcnt.get(comb);
                }           
            }
        }
         message=message+res+'. No.of Won opportunities:'+cnt;
         System.debug(message);
        return message;
    }

}