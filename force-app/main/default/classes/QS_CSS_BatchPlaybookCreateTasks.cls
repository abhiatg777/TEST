global with sharing class QS_CSS_BatchPlaybookCreateTasks implements Database.Batchable<SObject>, Schedulable {
	
    public static Set<Id> CustomerAlerts = new Set<Id>();
    public static final string JobName = 'QS_CSS_BatchPlaybookCreateTasks';
    
    //Empty Constructor
    global QS_CSS_BatchPlaybookCreateTasks() {system.debug('Empty Constructor');}
    
    //Constructor for process builder
    global QS_CSS_BatchPlaybookCreateTasks(Set<Id> caIds) {
        CustomerAlerts = caIds;
        //QS_vcg_utils.showdebug('Ids in batch constructor ' + CustomerAlerts);
    }
    
    //Only used if job is going to be scheduled
    //Default is to run from a process builder
    global void execute(SchedulableContext sc) {
		QS_VCG_Utils.RunJob(new QS_CSS_BatchPlaybookCreateTasks(), JobName);
        //QS_vcg_utils.showdebug('Ids in batch schedulable ' + CustomerAlerts);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //QS_vcg_utils.showdebug('Ids in batch start ' + CustomerAlerts);
        
        return Database.getQueryLocator(
            [
                SELECT Id
                FROM QS_CSS_Customer_Alert__c
                WHERE Id IN :CustomerAlerts
            ]
        );
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        for(sObject obj : scope) {
			(new QS_CSS_PlaybookUtils()).createTasks(obj.id);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        //Cannot reschedule itself as it needs customeralerts to process
		//QS_VCG_Utils.ScheduleJob(new QS_CSS_BatchPlaybookCreateTasks(), JobName);
    }
}