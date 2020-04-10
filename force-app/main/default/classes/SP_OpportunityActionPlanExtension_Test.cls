@isTest(SeeAllData=true)
public class SP_OpportunityActionPlanExtension_Test {
    public static testMethod void testOpportunityActionPlanController() {
        String testString;
        
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        Account acc = new Account(Name='Acc1');
    	insert acc;
        
        Opportunity opp = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='1 - Plan', closedate=Date.today(), AccountId=acc.Id);
        system.debug('@opp'+opp);
        insert opp;
        
        QS_Stage_Objective__c testStageObject = new QS_Stage_Objective__c(name='1 - Plan');
        testStageObject.QS_Opportunity_Record_Type__c = 'Products and Services';
        insert testStageObject;
        
        QS_Objective_Action__c testObjectiveAction = new QS_Objective_Action__c();
        testObjectiveAction.QS_Stage_Objective__c = testStageObject.Id;
        testObjectiveAction.QS_Opportunity_Record_Type__c = 'Products and Services';
        testObjectiveAction.Name = 'Discover?';
        insert testObjectiveAction;
        
        QS_SP_Exempt_Products__c testExmp = new QS_SP_Exempt_Products__c();
        testExmp.Name = 'test1';
        insert testExmp;
        
         QS_SP_Exempt_Products__c testExmp2 = new QS_SP_Exempt_Products__c();
        testExmp2.Name = 'test2';
        insert testExmp2;
        
        
        Profile p = [Select Id FROM Profile WHERE Name='System Administrator'];
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='SPTEST1@noemail.com');
        insert user;
        User user2 = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='SPTEST2@noemail.com');
        user2.ManagerId = user.Id;
        user2.FirstName = 'test';
        insert user2;
        
        System.runAs(user2) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('/apex/SP_OpportunityActionPlan'));
            System.currentPageReference().getHeaders().put('X-Salesforce-Forwarded-To','test.test');
            SP_OpportunityActionPlanExtension testExtension = new SP_OpportunityActionPlanExtension(new ApexPages.StandardController(opp));
            testString = testExtension.blockTitle;
            testExtension.saveActions();
            testExtension.selectedObjId = testStageObject.Id;
            testExtension.mgrEmail = 'test@nomail.com';
            testExtension.cancelActions();
            
            
            testExtension.FSMapFunc();
            testExtension.closeMgrDialog();
            testExtension.showMgrDialog();
            testExtension.requestCoaching();
            testExtension.requestCoachingNoMgr();
            testExtension.coachingInfo();
            //testExtension.saveActions();
            SP_OpportunityActionPlanExtension.checkExemptProducts('test1;test2');
            testExtension.currentView = 'commit';
            test.stopTest();
        }
        SP_OpportunityActionPlanExtension.createCoachingTask(opp.id,'1 - Plan', UserInfo.getUserId());
    }
}