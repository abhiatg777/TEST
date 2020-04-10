@IsTest public with sharing class QS_LeadTriggerTest {
	@IsTest(SeeAllData=true) 
    static void testLeadConversion() {
        Lead newLead = new Lead();
        newLead.FirstName = 'TestFirstName';
        newLead.LastName = 'TestLastName';
        newLead.Status = 'Open';
        newLead.Company = 'Test Company 1';
        newLead.Email = 'testemail@gmail.com';
        insert newLead;
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        insert newAccount;
        
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        lc.convertedstatus = 'Converted';
        lc.donotcreateopportunity = false;
        lc.setOpportunityName('Test Opportunity');
        lc.accountid = newAccount.Id;
		Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        
        
    }
}