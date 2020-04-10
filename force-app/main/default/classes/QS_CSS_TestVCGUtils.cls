@isTest
public class QS_CSS_TestVCGUtils {	
    
    static testMethod void testAll()
    {
		Account a = new Account();
		a.Name = 'Test';
		insert a;
        
        QS_VCG_Utils.GetInClause(new Set<Id>{Test.getStandardPricebookId(),UserInfo.getUserId()}, true);
        QS_VCG_Utils.GetErrorMessage(new QS_VCG_Utils.ApplicationException('Just a test'), true);
        QS_VCG_Utils.showConfirm('conf');
        QS_VCG_Utils.showDebug('theObject');
        QS_VCG_Utils.showError('err');
        QS_VCG_Utils.showInfo('info');
        QS_VCG_Utils.showObject('theObject');
        QS_VCG_Utils.showWarning('warn');
        ApexPages.currentPage().getParameters().put('Id','Id');
        system.assertEquals('Id',QS_VCG_Utils.GetValueFromParam('Id'));
        QS_VCG_Utils.GetObject('Opportunity', new Set<string>{'Account.Name'}, 'Id=null');
        QS_VCG_Utils.GetAllObjectNames();
        QS_VCG_Utils.GetFields('Opportunity');
        Boolean bool = QS_VCG_Utils.isDataLoadMode;
        QS_VCG_Utils.IsLoggedIn();
        QS_VCG_Utils.IsStandardUser();
        QS_VCG_Utils.IsPartnerUser();
        QS_VCG_Utils.IsPortalUser();
        QS_VCG_Utils.GetCleanString('TheString');
        QS_VCG_Utils.GetCleanString('TheString', 3);
        QS_VCG_Utils.GetRecordTypeId('Case', 'Support Issue');
        QS_VCG_Utils.GetUserIPAddress();
        QS_VCG_Utils.GetObjectKeyPrefix('Opportunity');
        QS_VCG_Utils.isAlreadyExecuted('test');
        QS_VCG_Utils.isAlreadyExecuted('test',a.Id);
        QS_VCG_Utils.setExecuted('test');
        QS_VCG_Utils.resetExecuted('test');
        QS_VCG_Utils.setExecuted('test',a.Id);
        QS_VCG_Utils.resetExecuted('test',a.Id);
        QS_VCG_Utils.resetAllExecuted();
        QS_VCG_Utils.isRunningTest();
        QS_VCG_Utils utils = new QS_VCG_Utils();
       // Account acct = Test_GenerateObjectData.getAccount(); 
//        insert acct;
        Opportunity opp = new Opportunity(name='test', closedate=System.today(), stagename='prospect', AccountId=a.Id);
        insert opp;
        //Opportunity opp = Test_GenerateObjectData.createOpportunityList(1).get(0);
        
        utils.CloneRecords(new List<SObject>(), 'Opportunity', 'sbaa__DealDesk', 'id', 'id != null');
        utils.SObjectValueHelper('name', opp, 'test', true);
        List<User> u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        QS_VCG_Utils.SendEmail(u, new List<String>{'test@email.com'}, 'subject', 'textBody', 'htmlBody', false, null);
        //QS_VCG_Utils.GetObjectFromFieldSet('Opportunity', 'sbaa__DealDesk', null, 'id != null', 'id');
        //QS_VCG_Utils.ScheduleJob(new BatchIntegrationContact(), 'BatchIntegrationContact');
        //QS_VCG_Utils.RunJob(new BatchIntegrationContact(), 'BatchIntegrationContact');
    }
    @IsTest
    static void newTests(){
        Test.startTest();
//        BatchIntegrationContact batch = new BatchIntegrationContact();       
//        QS_VCG_Utils.ScheduleJob(batch, 'BatchIntegrationContact');
        //QS_VCG_Utils.RunJob(batch, 'BatchIntegrationContact');
        Test.stopTest();
    }
}