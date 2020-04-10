/*
*CA2_AssetTrigger
*Created:
* 02.07.2019 : Saketha Angirekula : Trigger to insert Customer Asset and Customer Asset Detail records on insert of Asset.
* Trigger on Asset object. Logic handled in CA2_AssetTriggerHandler
*
*Updated:
*/
trigger CA2_AssetTrigger on Asset (after insert, after update, before update, before insert, before delete, after delete, after undelete) {
	new CA2_AssetTriggerHandler().run();
}