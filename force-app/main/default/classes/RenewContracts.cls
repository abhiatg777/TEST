public without sharing class RenewContracts implements Database.Batchable<sObject>, Schedulable {
  private Set<Id> contractIds {get; set;}
  //subscriptions to query are done through ATG_GetContractsToRenew. 
  public RenewContracts() {

  }
  public void execute(System.SchedulableContext context) {
      Database.executeBatch(new RenewContracts(), 1);
  }
  // Database.Batchable Implementation
  String query;

  public Database.QueryLocator start(Database.BatchableContext batchableContext){
    query = ' SELECT Id, QS_Renewal_Creation_Date__c '
            + ' FROM Contract '
            + ' WHERE '
            + ' (QS_Renewal_Creation_Date__c <= TODAY AND SBQQ__RenewalQuoted__c = false AND RecordType.DeveloperName = \'Subscription_Agreement\')';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Contract> contracts){

    List<Contract> renewalQuoteContracts = new List<Contract>();

    Date today = Date.today();

    for (Contract contract : contracts) {
      if (contract.QS_Renewal_Creation_Date__c <= today) {
        renewalQuoteContracts.add(contract);
      }
    }

    for (Contract contract : renewalQuoteContracts) {
      contract.SBQQ__RenewalQuoted__c = true;
    }

    handleUpdateContracts(contracts);
  }

  public void finish(Database.BatchableContext batchableContext) { }

  

  @TestVisible
  private static void handleUpdateContracts(List<Contract> contracts) {
      List<Database.SaveResult> saveResults = Database.update(contracts, Test.isRunningTest());
  }
}