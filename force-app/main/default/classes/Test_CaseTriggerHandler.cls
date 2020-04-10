@IsTest
public class Test_CaseTriggerHandler {

    @testSetup
    public static void setup()
    {
		Account a = TestDataFactory.createAcctList(1, 'Test Account')[0];
        insert a;
        
        Bug__c b = TestDataFactory.createBug(true);
    }
    
    static Account theAccount 
    {
        get {return [select id from Account limit 1];}
    }
    
    static Bug__c theBug
    {
        get {return [select id, Case_Count__c from Bug__c limit 1];}
    }

    @isTest
    public static void testCountBugCases()
    {
        Test.startTest();
        Case c = TestDataFactory.createCase(theAccount);
        c.Bug__c = theBug.Id;
        c.Product_Instance_Identifier__c = 'Test Product Instance Identifier';
        c.Steps_to_Reproduce__c = 'Test Steps to Reproduce';
        insert c;
        
        system.assertEquals(1,theBug.Case_Count__c);
        
        c.Bug__c = null;
        c.Product_Instance_Identifier__c = null;
        c.Steps_to_Reproduce__c = null;
        update c;
        
        system.assertEquals(0, theBug.Case_Count__c);
        Test.stopTest();
    }
    
}