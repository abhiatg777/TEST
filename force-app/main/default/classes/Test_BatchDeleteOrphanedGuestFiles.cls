@isTest
public class Test_BatchDeleteOrphanedGuestFiles {
    
    @TestSetup
    public static void setup()
    {
        //Account a = TestDataFactory.createAccount('Test',true);   
        //Case c = new Case(Subject = 'Test Case');        
    }
    
    static ContentVersion getGuestContentVersion()
    {        
        ContentVersion v = new ContentVersion();
        v.ContentLocation='S';
        v.Origin='H';
        v.PathOnClient='testpath';
        //v.PublishStatus='P';
        v.SharingOption='A';
        v.Title='testtitle';
        v.VersionData = blob.valueOf('testdata');
        insert v;
        
        return v;
    }
	
    @isTest
    static void testFileDelete()
    {
        Test.startTest();
        SCG_Setting__mdt metaRecord = SCG_Utils.getSetting('Support');
        
        ContentVersion cv = getGuestContentVersion();
        String ownerId = UserInfo.getUserID();
        cv.OwnerId = ownerId;
        update cv;
       
        List<ContentVersion> cvs = [SELECT
                                    Id,ContentDocumentId ,ContentDocument.OwnerId
                                    FROM ContentVersion 
                                    WHERE OwnerID =:ownerId 
                                    LIMIT 1
                                   ];        
        
        Database.executeBatch(new BatchDeleteOrphanedGuestFiles());
        Test.stopTest();
        
        cvs = [SELECT Id,ContentDocumentId ,ContentDocument.OwnerId FROM ContentVersion WHERE OwnerId =: ownerId LIMIT 1];
        System.assertEquals(0, cvs.Size());
    }
    
    @isTest 
    static void scheduleJob()
    {
        Test.startTest();
        BatchDeleteOrphanedGuestFiles batch = new BatchDeleteOrphanedGuestFiles();
        batch.execute(null);
        Test.stopTest();
    }
}