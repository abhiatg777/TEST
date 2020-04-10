@isTest
public class BillToShipToTriggerHandlerTest {
 
    @TestSetup
    
    public static void  TestData(){
  
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User internalUser = new User(Alias = 'testU', Email='saascgcase@testsaascg.com',
                    EmailEncodingKey='UTF-8', LastName='LastName', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = prof.Id,isActive=true,
                    TimeZoneSidKey='America/Los_Angeles', UserName='testuser@test.comVCG2018'); 
                    
       insert internalUser;
       
          Account account_Obj = new Account(Name = 'Test Account', Type='Client');
        Insert account_Obj;

       
    }   

    static Account testAccount {
        get{
            if(testAccount==null)
            {
                testAccount = [Select Id FROM Account limit 1];
            }
            return testAccount;
        }
        set;
    }
    
    static testMethod void testAddressSplit(){
        Test.startTest();
        for(integer i = 0; i < 2; i++){
            QS_Bill_To_Ship_To__c testAddress = new QS_Bill_To_Ship_To__c();
            
            testAddress.QS_Street_1__c = 'Street1';
            testAddress.QS_State__c = 'Illinois';
            testAddress.QS_City__c ='City';
            testAddress.QS_Zip_Postal_Code__c ='12345';
            testAddress.QS_Bill_To__c = true;
            testAddress.QS_Ship_To__c = true;
            testAddress.QS_Account__c = testAccount.Id;
            testAddress.QS_Primary__c = true;
            
            insert testAddress;
        }
        
        Test.stopTest();
        
        List<QS_Bill_To_Ship_To__c> addresses = [Select Id from QS_Bill_To_Ship_To__c where QS_Account__c=:testAccount.Id];
        
        System.assert(addresses.size() ==4);
    }
}