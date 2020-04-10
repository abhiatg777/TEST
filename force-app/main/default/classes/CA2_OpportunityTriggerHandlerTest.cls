/******************************************************************************
 * Test class for the OpportunityTrigger and it's supporting classes 
 *
 * @Author: Magnet 360
 * @Date: Dec 29, 2016
 * @Jira: JQSR-17
 */
@isTest( SeeAllData=false )
private class CA2_OpportunityTriggerHandlerTest 
{


    static testMethod void  test_Process0QuantityOpportunityLineItems()
    {
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        
        insert newAccount;
        
   

        Product2 product1 = new Product2();
        product1.ProductCode = 'product-2';
        product1.Name = 'Hardware Product 2';
        product1.Description = 'Hardware Product 2 Description';
        product1.Family = 'HardwareFamily';
        product1.QS_Generate_Asset__c = true;
        product1.IsActive = true;
        product1.SBQQ__SubscriptionPricing__c = 'Percent Of Total';
        product1.SBQQ__SubscriptionType__c = 'Renewable';
        product1.SBQQ__SubscriptionTerm__c = 12;
        product1.SBQQ__QuantityEditable__c = true;
        product1.SBQQ__IncludeInMaintenance__c = true;
        insert product1; 
        
        Opportunity renewalOpp = new Opportunity();
        renewalOpp.AccountId = newAccount.Id;
        renewalOpp.Type='Existing Business';
        renewalOpp.QS_Order_Type__c='Subscription Renewal';    
        renewalOpp.StageName='Connect';
        renewalOpp.CloseDate = System.today();
        renewalOpp.Name = 'Test Renewal';
   
        
        insert renewalOpp;

        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        
        newQuote.SBQQ__Type__c = 'Renewal';
        newQuote.SBQQ__ExpirationDate__c = System.today().addDays(200);
        newQuote.SBQQ__Account__c = newAccount.Id;
        newQuote.SBQQ__Opportunity2__c = renewalOpp.Id;
        newQuote.ApprovalStatus__c = 'Approved';
        newQuote.SBQQ__Primary__c = true;
        insert newQuote;

        SBQQ__QuoteLine__c newQuoteLine = new  SBQQ__QuoteLine__c();
        newQuoteLine.SBQQ__Product__c = product1.Id;
        newQuoteLine.SBQQ__Quantity__c = 0;
       // newQuoteLine.QS_Account__c = newAccount.Id;
        newQuoteLine.SBQQ__Quote__c = newQuote.Id;
        insert newQuoteLine;

        QS_Customer_Asset__c ca = new QS_Customer_Asset__c();
        ca.QS_Account__c = newAccount.Id; 
        ca.QS_Asset_Status__c = 'Active';
        ca.QS_Product__c = product1.Id;
        insert ca; 
        QS_customer_asset_settings__c cAssetSetting = new QS_customer_asset_settings__c();
        cAssetSetting.QS_Expiration_Days__c = 1;
        insert cAssetSetting;
         
         
        QS_Customer_Asset_Detail__c cad = new QS_Customer_Asset_Detail__c(QS_Customer_Asset__c = ca.id,QS_Currently_Active__c=False,QS_Asset_Status__c = 'Pending Activation',QS_Start_Date__c = System.today().addDays(-365),QS_End_Date__c = System.today().addDays(+5));
        cad.QS_Product__c = product1.Id;
        insert cad;
         renewalOpp.SBQQ__PrimaryQuote__c = newQuote.Id;
         renewalOpp.StageName = 'Closed Won';
        // update renewalOpp;
        
        CA2_OpportunityTriggerHandler thl = new CA2_OpportunityTriggerHandler();
        List<Opportunity> listOfOpp = new List<Opportunity>();
        listOfOpp.add(renewalOpp);
      //  thl.addDecommissionRecordsForZeroedOutProducts(listOfOpp);
        thl.processZeroedOutQuoteLines(listOfOpp);
        thl.getDecommissionRecordByQuoteLine(newQuoteLine, ca);
        thl.UpdateHistoricalCadsPendingRenewal(listOfOpp);
        
        

    }
}// /END Test Class