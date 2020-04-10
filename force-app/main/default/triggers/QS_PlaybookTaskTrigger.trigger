trigger QS_PlaybookTaskTrigger on QS_Playbook_Task__c (after insert,after update) {
	if(QS_VCG_Utils.SkipTrigger('QS_PlaybookTaskTrigger')) return;
    if(Trigger.isInsert || Trigger.isUpdate)
    {
        (new QS_CSS_PlaybookUtils()).SetTotalTaskDays(Trigger.New);
    }
}