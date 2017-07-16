public class SalesTeamCntrl {
    public String message{get;set;}
    //Method to calculate winning salesteam
    public PageReference calculatewinningslaesteam(){
        
        //Variables
        message = 'Sales Team combination who has won maximum Deals in the past:';
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
        return null;
    }
    

}