/*------------------------------------------------------------
Description: Opportunity Trigger
Test Class: 
History
05/27/16    ATG Created
------------------------------------------------------------*/
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
    new OpportunityTriggerHandler().run();    

}