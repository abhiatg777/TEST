@isTest
public class Test_SCGUtils {	
    
    static testMethod void testAll()
    {
        Test.startTest();
        /*
		Account a = new Account();
		a.Name = 'Test';
		insert a;
		*/
        Account a = TestDataFactory.createAcctList(1, 'Test')[0];
        insert a;
        
        Account invalidAcct = new Account();
        try{
            update invalidAcct;
        }
        catch(Exception e) {
            SCG_Utils.GetErrorMessage(e, true);
        }
        
        SCG_Utils.GetInClause(new Set<Id> { Test.getStandardPricebookId(), UserInfo.getUserId() }, true);
        SCG_Utils.GetObject('Opportunity', new Set<string>{'Account.Name'}, 'Id=null');
        SCG_Utils.isAlreadyExecuted('test');
        SCG_Utils.isAlreadyExecuted('test',a.Id);
        SCG_Utils.setExecuted('test');
        SCG_Utils.resetExecuted('test');
        SCG_Utils.setExecuted('test',a.Id);
        SCG_Utils.resetExecuted('test',a.Id);
        SCG_Utils.resetAllExecuted();
        SCG_Utils.IsLoggedIn();
        SCG_Utils.IsPartnerUser();
        SCG_Utils.IsPortalUser();
        SCG_Utils.IsStandardUser();
        SCG_Utils.GetCleanString('TheString');
        SCG_Utils.GetCleanString('TheString', 3);
        SCG_Utils.GetRecordTypeIdsMap('Account');
        SCG_Utils.GetRecordTypeNamesMap('Account');
        SCG_Utils.GetRecordTypeId('Case','Customer Support');
        SCG_Utils.getSetting('Support');
        SCG_Utils.isRunningTest();
        
        Test.stopTest();
    }
    
    @IsTest
    static void newTests(){
        Test.startTest();
        BatchDeleteOrphanedGuestFiles batch = new BatchDeleteOrphanedGuestFiles();       
        //SCG_Utils.ScheduleJob(batch, 'BatchDeleteOrphanedGuestFiles');
        SCG_Utils.RunJob(batch, 'BatchDeleteOrphanedGuestFiles');
        Test.stopTest();
    }
}