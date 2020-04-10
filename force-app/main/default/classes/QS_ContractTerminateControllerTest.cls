@isTest(seeAllData = false)
public class QS_ContractTerminateControllerTest {
    
    
    
    public QS_ContractTerminateControllerTest()
    {
        
    }
    
    @isTest static void ContractTerminateControllerTest1()
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
        
        
        ContractTerminateController cnt = new ContractTerminateController();
        List<Contract> contractList = new List<Contract>();
        contractList.add(childlevelContract);
        
        cnt.selectedContracts = contractList;
        cnt.setcurrentId(childlevelContract.Id);
        cnt.getObjectStructure();
        cnt.formatObjectStructure(childlevelContract.Id);
        cnt.getContracts();
        cnt.strUrl = 'test';
        cnt.redirectNow = false;
        
        PageReference newPageRef;
        newPageRef = cnt.Next();
        newPageRef = cnt.Save();
        newPageRef = cnt.Cancel();
        
        
    }

}