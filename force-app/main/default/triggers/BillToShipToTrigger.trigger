trigger BillToShipToTrigger on QS_Bill_To_Ship_To__c (after insert, after update, before insert, before update)
{
if(ByPassTrigger__c.getInstance(System.UserInfo.getUserId()).isDisabled__c== false){


    if(Trigger.isBefore)
    {
        if(Trigger.isInsert) BillToShipToTriggerHandler.onBeforeInsert(Trigger.new);
        //if(Trigger.isUpdate) BillToShipToTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert) BillToShipToTriggerHandler.onAfterInsert(Trigger.newMap);
        if(Trigger.isUpdate) BillToShipToTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
}

}