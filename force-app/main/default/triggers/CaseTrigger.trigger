trigger CaseTrigger on Case (before insert, before update, after insert, after update, after delete) {

    //TODO: Need to add some kind of disable automation logic for code, not sure what the current approach is for SCG
    
    if (Trigger.isAfter)
    {
        //if(UserInfo.getUserId() == '00522000001XOf4AAG')
        	CaseTriggerHandler.countBugCases(Trigger.oldMap, Trigger.newMap);
    }
    
}