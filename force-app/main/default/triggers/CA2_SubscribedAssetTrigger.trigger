/*
*CA2_SubscribedAssetTrigger
*Created:
* 02.07.2019 : Saketha Angirekula : Trigger to insert Customer Asset and Customer Asset Detail records on insert of SubscribedAsset.
* Trigger on SubscribedAsset object. Logic handled in CA2_AssetTriggerHandler
*
*Updated:
*/
trigger CA2_SubscribedAssetTrigger on SBQQ__SubscribedAsset__c (before insert, after update, after insert, after delete) {
	QS_customer_asset_settings__c CS_flag = QS_customer_asset_settings__c.getInstance();
    if(Trigger.isBefore && Trigger.isInsert) {
        for(SBQQ__SubscribedAsset__c sa: Trigger.new) {
            sa.QS_UpsertKey__c = sa.SBQQ__Subscription__c + '' + sa.SBQQ__Asset__c;
        }
    }
    if(Trigger.isUpdate && Trigger.isAfter || Trigger.isAfter && Trigger.isInsert) {
        CA2_AssetTriggerHandler.createCustomerAssets(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete) {
        CA2_AssetTriggerHandler.undeleteSubAssets(Trigger.old);
    }
}