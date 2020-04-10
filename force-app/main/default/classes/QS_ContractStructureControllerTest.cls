@isTest(seeAllData = false)
public class QS_ContractStructureControllerTest {
    
    
    
    public QS_ContractStructureControllerTest()
    {
        
    }
    
    @isTest static void ContractStructureControllerTest1()
    {
        
        Account newAccount = new Account();
        newAccount.Name = 'testAccount';
        insert newAccount;
        
        
        Contract toplevelContract = new Contract();
        toplevelContract.AccountId = newAccount.Id;
        toplevelContract.Status = 'Draft';
        toplevelContract.ContractTerm = 36;
        toplevelContract.StartDate = System.today();
        toplevelContract.SBQQ__MasterContract__c = true;
        insert toplevelContract;
        
        Contract childlevelContract = new Contract();
        childlevelContract.AccountId = newAccount.Id;
        childlevelContract.Status = 'Draft';
        childlevelContract.ContractTerm = 36;
        childlevelContract.StartDate = System.today();
        childlevelContract.SBQQ__MasterContract__c = false;
        childlevelContract.QS_Parent_Contract__c = toplevelContract.id;
        
        insert childlevelContract;
        
        
        ContractStructureController cnt = new ContractStructureController();
        cnt.setcurrentId(childlevelContract.Id);
        cnt.getObjectStructure();
        cnt.formatObjectStructure(childlevelContract.Id);
        cnt.strUrl = 'test';
        cnt.redirectNow = false;
        
        
    }

}