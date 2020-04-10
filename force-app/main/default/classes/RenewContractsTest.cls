@isTest
public class RenewContractsTest {
    @isTest
    public static void tesRenewContracts() {
        Date todayDate = System.today();
        Date oldDate = todayDate - 180;
        Date contractStartDate = oldDate - 180;

        System.debug('RenewContractsTest.testSchedulable: todayDate:'+todayDate+' oldDate:'+oldDate);

        Id recordTypeId = [select Id from RecordType where DeveloperName = 'Subscription_Agreement' limit 1].Id;
        System.debug('RenewContractsTest.testSchedulable: recordTypeId:'+recordTypeId);

        Account account = new Account();
        account.Name = 'A Test Account';
        account.Type = 'Prospect';

        insert account;
        Contract contract = new Contract();
        contract.AccountId = account.Id;
        contract.Status = 'Draft';
        contract.StartDate = contractStartDate;
        contract.ContractTerm = 12;
        contract.SBQQ__RenewalQuoted__c = false;
        contract.QS_Renewal_Creation_Date__c = oldDate;
        contract.RecordTypeId = recordTypeId;
        insert contract;

        Test.startTest();
        Database.executeBatch(new RenewContracts());
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Contract WHERE SBQQ__RenewalQuoted__c = true].size());
    }
}