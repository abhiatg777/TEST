/*
*CA2_SubscriptionTrigger
*Created:
* 02.07.2019 : Saketha Angirekula : Trigger to insert Customer Asset and Customer Asset Detail records on insert of Subscription.
* Trigger on Subscription object. Logic handled in CA2_SubscriptionTriggerHandler
*
*Updated:
*/
trigger CA2_SubscriptionTrigger on SBQQ__Subscription__c (after insert, after update, before update, before insert, before delete, after delete, after undelete) {
	new CA2_SubscriptionTriggerHandler().run();
}