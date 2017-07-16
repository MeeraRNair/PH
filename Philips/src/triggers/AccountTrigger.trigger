trigger AccountTrigger on Account (after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        AccountTriggerHandler.selectRecords(Trigger.new, Trigger.oldMap);
    }
}