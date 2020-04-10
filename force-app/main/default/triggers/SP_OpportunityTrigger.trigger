trigger SP_OpportunityTrigger on Opportunity (before update) {

	//disabled for bulk updatess
	//Mar21: Commented out the below logic and moved it to OpportunityTriggerHandler
	//We can delete this Trigger if the team is okay with it
	/*
	if (Trigger.size == 1) {
		SP_SalesPlanValidations.validateRequiredActions(Trigger.newMap, Trigger.oldMap);
	}
	*/
}