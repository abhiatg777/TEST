/*------------------------------------------------------------
Author: ATG
Description: Quote Trigger
Test Class: 
History
05/27/16    ATG Created
------------------------------------------------------------*/
trigger QuoteTrigger on SBQQ__Quote__c (before insert, before update, before delete, after insert, after update, after delete) {
    new QuoteTriggerHandler().run();    

}