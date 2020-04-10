@IsTest
public class Test_CommunityController {

    @TestSetup
    static void setup()
    {
        ContentVersion cv = new ContentVersion(ContentLocation = 'S',
                                             Origin = 'H',
                                             PathOnClient = 'Test Path',
                                             SharingOption = 'A',
                                             Title = 'Test Title',
                                             VersionData = blob.valueOf('Test Data'));
        insert cv;
    }
    
    @isTest
    static void testGetUser()
    {
		String userId = CommunityController.getUserId();
        
        system.assertEquals(UserInfo.getUserId(), userId);
    }
    
    @isTest
    static void testGetRecordTypeId()
    {
		String recordTypeId = CommunityController.getRecordTypeId();
        
        system.assertEquals(SCG_Utils.GetRecordTypeId('Case', 'Customer Support'), recordTypeId);
    }
    
    @isTest
    static void testCheckBusinessHours()
    {
        boolean result = CommunityController.checkBusinessHours('MINDBODY');
        
        system.assertEquals(true, result);
    }
    
    @isTest
    static void testInsertGuestCase()
    {
        Case c = new Case(SuppliedName = 'Test Case Name',
                         SuppliedEmail = 'test@test.com',
                         SuppliedPhone = '555-555-5555',
                         Product__c = 'MINDBODY',
                         Site_ID__c = 'Test Case Site ID',
                         I_need_help_with__c = 'Other',
                         Severity__c = 'Low',
                         Subject = 'Test Case Subject',
                         Description = 'Test Case Description');
        
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        string caseId = CommunityController.insertGuestCase(c, string.valueOf(cv.ContentDocumentId));
        
        Case insertedCase = [SELECT Id from Case limit 1];
        system.assertEquals(caseId, insertedCase.Id);
    }
    
    @isTest
    static void testVerifyCaptcha()
    {
        //Set mock callout class
        HttpMockResponseGenerator mock = new HttpMockResponseGenerator();
        mock.response.setHeader('Content-Type', 'application/json');
        mock.response.setBody('{"success": true}');
        mock.response.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class,mock);
        
        // Call method to test
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock
        Test.startTest();
        system.assertEquals(CommunityController.verifyCaptcha('test'), true);
        Test.stopTest();
    }
    
}