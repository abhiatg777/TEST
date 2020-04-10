@isTest
public class SP_OpportunityActionManager_Test{
    public static testMethod void testOpportunityActionManagerClass(){
    	Account acc = new Account(Name='Acc1');
    	insert acc;
    	Contact con = new Contact(firstname='asd',lastname='dsf',AccountId=acc.Id);
        insert con;
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='Prospecting', closedate=Date.today(), Contact__c=con.Id, AccountId=acc.Id);
        system.debug('@opp'+opp);
        insert opp;
        
        QS_Stage_Objective__c testStageObject = new QS_Stage_Objective__c(name='Prospecting');
        testStageObject.QS_Opportunity_Record_Type__c = 'Products and Services';
        insert testStageObject;
        
        QS_Objective_Action__c testObjectiveAction = new QS_Objective_Action__c();
        testObjectiveAction.QS_Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.QS_Opportunity_Record_Type__c = 'Products and Services';
        insert testObjectiveAction;
        
        List<QS_Stage_Objective__c> testListStageObjective = new List<QS_Stage_Objective__c>(); 
        testListStageObjective.add(testStageObject);
        List<Task> testListTask = new list<Task>();
        Task testTask = new Task();
  
        //insert testTask;
        
        Map<Id,QS_Objective_Action__c> testMap = new Map<Id,QS_Objective_Action__c>();
        Id testId;
        //OpportunityActionManager main class
        SP_OpportunityActionManager testOpportunityActionManager = new SP_OpportunityActionManager(testListStageObjective, testListTask, testMap, opp.Id);
        list<Task> opActs = testOpportunityActionManager.oppActions;
        if(testOpportunityActionManager.stageObjectives == null){}
        testOpportunityActionManager.clear();
        if(testOpportunityActionManager.commitObjectives == null){}
        if(testOpportunityActionManager.advancementCriteria == null){}
        testOpportunityActionManager.resetTasks(testListTask);
        //Objective inner class
        //system.debug('@Select Id,Contact__c,Name,StageName,RecordTypeId from Opportunity'+[Select Id,Contact__c,Name,StageName,RecordTypeId from Opportunity]);
        Id conId = [Select Id,Contact__c,Name,StageName,RecordTypeId from Opportunity where Id =: opp.Id].Contact__c;
        
        SP_OpportunityActionManager.Objective testObjective = new SP_OpportunityActionManager.Objective(testStageObject, opp.Id,conId);
        if(testObjective.actions == null){}
        if(testObjective.isEmpty){}
        testObjective.add(testTask,testObjectiveAction,0);
        //Action inner class
        SP_OpportunityActionManager.Action testAction = new SP_OpportunityActionManager.Action(testObjectiveAction, opp.Id,conId);
        if(testAction.subject == null){}
        if(testAction.committed == null){}
        testAction.linkToView();
        String testVal = '';
        Boolean testBol = testAction.requiredToAdvance;
        testVal = testAction.relatedStage;
        testVal = testAction.oppTypes;
        testVal = testAction.orderTypes;
        testVal = testAction.orderSubTypes;
        testVal = testAction.actionType;
        testBol = testAction.exemptProds;
        testVal = testAction.bgColor;
        
    }
}