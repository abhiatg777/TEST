trigger CA2_CustomerAssetTrigger on QS_Customer_Asset__c  (after insert, after update, before update, before insert, before delete, after delete, after undelete) {
	new CA2_CustomerAssetTriggerHandler().run();
}