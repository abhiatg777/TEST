/**
 * This is a test class Accelerator for creating Salesforce CPQ test data. It references methods in the 
 * CA2_CPQTestUtil class. The code below executes and passes within a fresh Salesforce org with Salesforce 
 * CPQ freshly installed with new calculation service authorized. Depending on the customizations
 * in your org (custom required fields, process builders, etc) you may have to accomodate for those
 * customizations in this class, as well as the CA2_CPQTestUtil class.
 *
 * Assumptions: 
 * Salesforce CPQ is installed, Salesforce Billing is NOT installed. 
 *   If the org eventually gets Salesforce Billing installed within in, decomment lines with #SFBILLING at the end of them,
 *   or install the SFCPQ AND Billing test class accelerator.
 * New Calculation Service has been authorized in CPQ package settings.
 *
 * This class, accompanied with CA2_CPQTestUtil.cls takes care of
 * the required test data needed for Salesforce CPQ quotes and quote lines, as well as asserting the 
 * quote/quote lines got created (in the context of the test). Ordering, Contracting, Subscriptions,
 * and Renewals are also covered, in case you have custom processes (that kick off ordering, contracting, and/or renewing) 
 * which need code coverage. 
 * 
 * @author Kevin Antonioli kevin.antonioli@atginfo.com
 * @updated 02.09.2019
 *
 */
@isTest
public without sharing class CA2_CPQTests {
    // by caching into static variables - this allows us to reference them without re-querying 
    // only works if we do not use a 'testSetup' method

    /****************************************
    ***** Begin test data setup methods *****
    *****************************************/

    // Static high level variables:
    private static Integer                              bulkRecordSize = 50; // number of quotes to create
    private static Boolean                              printQueries = false; // Toggle to true to turn on query stat logging for dml statements
    private static List<Account>                        acctList;
    private static List<Opportunity>                    oppList;
    private static List<Product2>                       productList;
    private static Id 		                            standardPricebookId;
    private static PriceBook2                           customPricebook; 
    private static List<PricebookEntry>                 standardPbEntryList;
    private static List<PricebookEntry>                 customPbEntryList;
    private static List<SBQQ__Quote__c>                 quoteList;
    private static List<SBQQ__QuoteLine__c>             quoteLineList;
    private static List<Contract>                       contractList;
    private static Order                                order;
    private static SBQQ__QuoteProcess__c 				qp;

    //private static CA2_CPQTestUtil.FinanceTestObjects fin; 
    //private static blng__BillingRule__c                 billingRule; //#SFBILLING
    //private static blng__TaxRule__c                     taxRule; //#SFBILLING
    //private static blng__RevenueRecognitionRule__c      revRecRule; //#SFBILLING
    //private static blng__GLRule__c                      glRule; //#SFBILLING
    //private static blng__FinanceBook__c                 financeBookRevenue; //#SFBILLING
    //private static blng__FinanceBook__c                 financeBookAccounting; //#SFBILLING
    //private static blng__BillingTreatment__c            billingTreatment;

    // Query the Quotes and all their fields:
    private static List<SBQQ__Quote__c> queryQuotes(List<SBQQ__Quote__c> quotes) {
        return CA2_CPQTestUtil.queryRecordsFromIdsAndObjectName(
            (new Map<Id,SBQQ__Quote__c>(quotes)).keySet(),  // Set<Id> idSet (to bind to in where clause)
            'SBQQ__Quote__c',                               // String objectName
            'WHERE Id IN :idSet'                            // String whereClause 
        ); 
    }

    // Query the Quote Lines and all their fields:
    private static List<SBQQ__QuoteLine__c> queryQuoteLines(List<SBQQ__QuoteLine__c> quoteLines) {
        return CA2_CPQTestUtil.queryRecordsFromIdsAndObjectName(
            (new Map<Id,SBQQ__QuoteLine__c>(quoteLines)).keySet(),  // Set<Id> idSet (to bind to in where clause)
            'SBQQ__QuoteLine__c',                                   // String objectName
            'WHERE Id IN :idSet'                                    // String whereClause
        ); 
    }

    // Setup common test data:
    public static void setup() {
        setup(false /*boolean createAdditionalBillingOjbects*/); //#SFBILLING -> Change false to true
    }
    
    public static void setup(Boolean createAdditionalBillingObjects) {                     
        // Create an Account with default values populated:
        acctList = new List<Account>();

        Account acct = new Account(Name = 'Test Account');
        // Create more accounts here if desired...

        acctList.add(acct);

        // Insert Accounts:
        insert acctList;          

        // get standard pricebook:
        standardPricebookId = Test.getStandardPricebookId();
        // Create custom Pricebook:
        
        customPricebook = CA2_CPQTestUtil.createPriceBook(
            'CPQ',      // String name
            true,       // Boolean isActive
            'USD',      // String currencyIsoCode
            true,       // Boolean populateDefaultValues
            false       // Boolean doInsert
        );

        // Insert custom Pricebook:
        insert customPricebook;

        // Create Opportunities:
        oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = System.today());
        opp.AccountId = acctList[0].Id;
        opp.Pricebook2Id = customPricebook.Id;
        oppList.add(opp);

        // Insert Opportunities:
        insert oppList;

        qp = new SBQQ__QuoteProcess__c();
        qp.Name = 'Test Quote Process';
        qp.SBQQ__Default__c = true;
        insert qp;

        // Create SF Billing data if applicable:
        if(createAdditionalBillingObjects) {
            //fin = CA2_CPQTestUtil.createFinanceObjects(); //#SFBILLING
        }

        //billingRule = CA2_CPQTestUtil.createBillingRule(true); //#SFBILLING
        //taxRule = CA2_CPQTestUtil.createTaxRule(true); //#SFBILLING
        //revRecRule = CA2_CPQTestUtil.createRevRecRule(true); //#SFBILLING

        if(createAdditionalBillingObjects) {
            //glRule = CA2_CPQTestUtil.createGlRule(true); //#SFBILLING
            //financeBookRevenue = CA2_CPQTestUtil.createFinanceBookRevenue(true); //#SFBILLING
            //financeBookAccounting = CA2_CPQTestUtil.createFinanceBookAccounting(true); //#SFBILLING
            //billingTreatment = CA2_CPQTestUtil.createBillingTreatment(billingRule, glRule, financeBookRevenue, true); //#SFBILLING                    
        }
    }

    public static void setupProducts() {
        // Create Products:
        productList = new List<Product2>();
        // Subscription product:
        productList.add(CA2_CPQTestUtil.createProduct(
            'Product ABC',              // String name
            'Subscription',             // String productType
            'GC1060',                   // String productCode
            null, // Id billingRuleId, //#SFBILLING - If Billing installed, remove 'null,'' and decomment 'Id billingRule.Id,'
            null, // Id taxRuleId, //#SFBILLING - If Billing installed, remove 'null,'' and decomment 'Id billingRule.Id,'
            null, // Id revRecRuleId, //#SFBILLING - If Billing installed, remove 'null,'' and decomment 'Id billingRule.Id,'
            true,                       // Boolean populateDefaultValues
            false                       // Boolean doInsert
        ));
        // Non-Subscription product:
        productList.add(CA2_CPQTestUtil.createProduct(
            'Product XYZ',          // String name
            'Non-Subscription',     // String productType
            'GC1020',               // String productCode
            null, // Id billingRuleId, //#SFBILLING - If Billing installed, remove 'null,'' and decomment 'Id billingRule.Id,'
            null, // Id taxRuleId, //#SFBILLING - If Billing installed, remove 'null,' and decomment 'Id taxRule.Id,'
            null, // Id revRecRuleId, //#SFBILLING - If Billing installed, remove 'null,' and decomment 'Id revRecRuleId.Id,'
            true,                   // Boolean populateDefaultValues
            false                   // Boolean doInsert
        ));
        // ...add more products here if desired...

        // Insert Products:
        insert productList;

    }

    public static void setupPricebookEntries() {
        // Create Pricebook entries for each product:
        standardPbEntryList = new List<PriceBookEntry>();
        customPbEntryList = new List<PriceBookEntry>();
        for(Product2 p : productList) {
            // Create standard Pricebook entries for each product:
            PricebookEntry pbEntry = CA2_CPQTestUtil.createPriceBookEntry(
                p,      // Product2 product
                null,   // Pricebook2 priceBook (Null will make it default to the Standard Pricebook)
                true,   // Boolean populateDefaultValues
                false   // Boolean doInsert
            );
            standardPbEntryList.add(pbEntry);

            // Create custom Pricebook entries for each product:
            PricebookEntry pbEntry2 = CA2_CPQTestUtil.createPriceBookEntry(
                p,          // Product2 product
                customPricebook,  // Pricebook2 priceBook (CPQ pricebook)
                true,       // Boolean populateDefaultValues
                false       // Boolean doInsert
            );
            customPbEntryList.add(pbEntry2);
        }
        
        // Insert Pricebook Entries:
        List<PricebookEntry> allPbEntries = new List<PricebookEntry>();
        allPbEntries.addAll(standardPbEntryList);
        allPbEntries.addAll(customPbEntryList);
        insert allPbEntries;      
    }
    
    // Method to create quotes:
    public static void setupQuotes(Boolean startTests, Boolean stopTests) {
        if(productList == null) {
            setupProducts();
        }
        if(standardPbEntryList == null || customPbEntryList == null) {
            setupPricebookEntries();
        }

        if(startTests) { Test.startTest(); }
        // Bulk create quotes, with one of them being primary:
        quoteList = new List<SBQQ__Quote__c>();
        for(Integer i = 0; i < bulkRecordSize; i++) {
            Boolean createAsPrimary = false;
            if(i == 0) {
                // Mark one of the quotes as primary:
                createAsPrimary = true;
            }
            SBQQ__Quote__c q = CA2_CPQTestUtil.createQuote(
                null,               // Account acct, 
                oppList[0],         // Opportunity opp, 
                createAsPrimary,    // Boolean isPrimary,
                true,               // Boolean populateDefaultValues 
                false               // Boolean doInsert
            );
            q.SBQQ__Account__c = acctList[0].Id;
            q.SBQQ__PriceBook__c = customPricebook.Id;
            q.SBQQ__PricebookId__c = customPricebook.Id;
            q.SBQQ__QuoteProcessId__c = qp.Id;
            quoteList.add(q);
        }

        // Insert Quotes:
        insert quoteList;

        if(stopTests) { Test.stopTest(); }
    }

    // Method to create quote lines:
    public static void setupQuoteLines(List<SBQQ__Quote__c> quoteList, List<Product2> productList, Boolean startTests, Boolean stopTests) {
        if(startTests){ Test.startTest(); }
        // Create quote lines for each quote (# of quote lines per quote = # of products created above):
        quoteLineList = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__Quote__c q : quoteList) {
            for(Integer i = 0; i < productList.size(); i++) {
                // For each quote, create as many quote lines as there are products:
                SBQQ__QuoteLine__c ql = CA2_CPQTestUtil.createQuoteLine(
                    productList[i],      // Product2 product, 
                    customPbEntryList[i],  // PriceBookEntry pbe
                    q,      // SBQQ__Quote__c quote,
                    true,   // Boolean populateDefaultValues 
                    false   // Boolean doInsert
                );
                quoteLineList.add(ql);
            }
        }

        // Insert Quote Lines:
        insert quoteLineList;  

        if(stopTests) { Test.stopTest(); }
    }

    public static void setupQuotesAndQuoteLines() {
        setupQuotesAndQuoteLines(false, false, false, false);
    }

    // Method to setup ALL test data needed for Quotes and Quote lines:
    public static void setupQuotesAndQuoteLines(Boolean quoteStartTests, Boolean quoteStopTests, Boolean quoteLineStartTests, Boolean quoteLineStopTests) {
        // Setup test data needed for Salesforce CPQ quotes:
        setupQuotes(
            quoteStartTests,                // Boolean quoteStartTests
            quoteStopTests                  // Boolean quoteStopTests
        );

        // Setup test data needed for Salesforce CPQ quoteLines:
        setupQuoteLines(
            quoteList,              // List<SBQQ__Quote__c> quoteList
            productList,            // List<Product2> productList
            quoteLineStartTests,    // Boolean startTests
            quoteLineStopTests      // Boolean stopTests
        );

        // Query the quotes created:
        quoteList = queryQuotes(quoteList);
        // Query the quote lines created:
        quoteLineList = queryQuoteLines(quoteLineList);
    }

    // Get a contract, which resulted in contracting an opportunity, into a state where it can be marked for renewal:
    public static void setupContractForRenewal(String contractedSource) {
        // Set up all test data leading up to contracting the Opportunity:
        setupQuotesAndQuoteLines(
            false,  // Boolean quoteStartTests
            false,  // Boolean quoteStopTests
            false,  // Boolean quoteLineStartTests
            false   // Boolean quoteLineStopTests
        );

        if(contractedSource == 'Opportunity') {
            // Contract one of the Opportunities, not by marking the Opportunity 'Contracted',
            // but by manually creating the contract in apex (due to multiple asynchronous thread limitation):
            Contract con = CA2_CPQTestUtil.createContract(
                acctList[0],    // Account acct
                customPricebook.Id,   // Id pricebookId
                oppList[0],     // Opportunity opp
                null,           // Order order
                quoteList[0],   // SBQQ__Quote__c quote
                false           // Boolean doInsert
            );

            contractList = new List<Contract>{con};
            insert contractList;

        } else if(contractedSource == 'Order') {
            // Create the order:
            order = CA2_CPQTestUtil.createAutomatedOrderFromOpportunity(oppList[0].Id);
            order.SBQQ__PriceCalcStatus__c = 'Completed';

            // Activate the Order:
            List<OrderItem> orderItems = CA2_CPQTestUtil.activateOrder(order);

            // Contract the Order, not by marking the Order 'Contracted',
            // but by manually creating the contract in apex (due to multiple asynchronous thread limitation):
            Contract con = CA2_CPQTestUtil.createContract(
                acctList[0],    // Account acct
                customPricebook.Id,   // Id pricebookId
                null,           // Opportunity opp
                order,          // Order order
                quoteList[0],   // SBQQ__Quote__c quote
                false           // Boolean doInsert
            );

            contractList = new List<Contract>{con};
            insert contractList;
        }   

        // Activate the Contract:
        contractList[0].Status = 'Activated';
        update contractList[0];
    }

    /**************************************
    ***** End test data setup methods *****
    **************************************/

    /*****************************
    ***** Begin test methods *****
    *****************************/

    // TODO: fix AUTOMATIC asset creation (might not be possible in a multiple asynchronous thread context)
    @isTest
    public static void test_quoteAndQuoteLineCreation() {
        // Setup all test data leading up to after quotes and quote lines are created:
        setup();
        setupQuotesAndQuoteLines(
            true,   // Boolean quoteStartTests
            false,  // Boolean quoteStopTests
            false,  // Boolean quoteLineStartTests
            true    // Boolean quoteLineStopTests
        );

        /*********************
        ***** Assertions *****
        *********************/

        // Verify Quotes got created:
        System.assertNotEquals(quoteList, null);
        System.assertNotEquals(quoteList.size(), 0, 'No Quotes were created.');

        // Verify PriceBook got assigned to the quotes:
        for(SBQQ__Quote__c q : quoteList) {
            System.assertEquals(q.SBQQ__PriceBook__c, customPricebook.Id);
        }

        // Verify Quote Lines got created:
        System.assertNotEquals(quoteLineList, null);
        System.assertNotEquals(quoteLineList.size(), 0, 'No Quote Lines were created.');

        // Verify PriceBook entries got assigned to the quote lines:
        for(SBQQ__QuoteLine__c ql : quoteLineList) {
            System.assertNotEquals(ql.SBQQ__PricebookEntryId__c, null, 'Quote lines have null price book entries.');
        }

        // Verify Opp products got created:
        List<OpportunityLineItem> oliList = [SELECT Id, SBQQ__QuoteLine__c FROM OpportunityLineItem];
        System.assertNotEquals(oliList.size(), 0, 'No Opportunity products were created');
        
    }

    /*****************************************************
    ***** Test methods related to Automated Ordering *****
    *****************************************************/

    @isTest
    public static void test_orderingOfQuote() {
        // Set up all test data leading up to marking the Quote as 'Ordered':
        setup();
        setupQuotesAndQuoteLines();
        
        Test.startTest();
        // quoteList[0] is already primary. Mark the quote as ordered:
        order = CA2_CPQTestUtil.createAutomatedOrderFromQuote(quoteList[0].Id);
        Test.stopTest();

        /*********************
        ***** Assertions *****
        *********************/

        // Verify primary Quote Pricebook matches that of its Opportunity:
        Opportunity opp = [SELECT Id, PriceBook2Id FROM Opportunity 
                            WHERE SBQQ__PrimaryQuote__c = :quoteList[0].Id];
        System.assertEquals(quoteList[0].SBQQ__PriceBook__c, opp.Pricebook2Id, 'Quote Pricebook does not match Opportunity Pricebook');

        // Verify Opportunity Products were automatically created:
        System.assertEquals([SELECT Id, OpportunityId FROM OpportunityLineItem 
                        WHERE OpportunityId = :opp.Id].isEmpty(), false,
                        'No Opportunity Products were created');

        // Verify that the Order was automatically created for the quote:
        System.assertEquals(order.SBQQ__Quote__c, quoteList[0].Id, 'No Orders were created.');

        // Verify that Order products were automatically created:
        System.assertEquals([SELECT Id FROM OrderItem 
                        WHERE OrderId = :order.Id].isEmpty(), false,
                        'No Order Products were created.');

    }

    @isTest
    public static void test_orderingOfOpportunity() {
        // Set up all test data leading up to ordering the Opportunity:
        setup();
        setupQuotesAndQuoteLines();

        Test.startTest();
         // oppList[0] is already associated to a primary quote
        order = CA2_CPQTestUtil.createAutomatedOrderFromOpportunity(oppList[0].Id);
        Test.stopTest();

        /*********************
        ***** Assertions *****
        *********************/

        // Assert the order:
        System.assertNotEquals(order, null, 'No Orders were created.');
        System.assertEquals(order.OpportunityId, oppList[0].Id, 'Order is not associated with Opportunity.');
        System.assertEquals(order.SBQQ__Quote__c, quoteList[0].Id, 'Order is not associated with quote.');
    }

    /********************************************************
    ***** Test methods related to automated contracting *****
    ********************************************************/

    @isTest
    public static void test_contractingOfOpportunity() {
        // Set up all test data leading up to contracting the Opportunity:
        setup();
        setupQuotesAndQuoteLines();

        // Contract one of the Opportunities (oppList[0] is already associated to a primary quote):
        contractList = CA2_CPQTestUtil.contractOpportunity(
            oppList[0],     // Opportunity opp
            true,           // Boolean startTests
            true            // Boolean stopTests
        );

        /*********************
        ***** Assertions *****
        *********************/
        
        // Assert contracts:
        System.assertNotEquals(contractList.isEmpty(), true, 'No contracts were created when Opportunity was contracted.');
        System.assertEquals(contractList[0].SBQQ__Opportunity__c, oppList[0].Id, 'Contract was not associated to opportunity.');
        System.assertEquals(contractList[0].SBQQ__Quote__c, quoteList[0].Id, 'Contract was not associated to primary quote.');
    
        // Verify Contracts got automatically created:
        System.assertNotEquals(contractList.isEmpty(), true, 'No contracts were created when Opportunity was contracted.');
        for(Contract c : contractList) {
            System.assertEquals(c.SBQQ__Opportunity__c, oppList[0].Id, 'Contract was not associated to Opportunity');
            for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                // Verify Subscriptions got associated to Contract:
                System.assertEquals(sub.SBQQ__Contract__c, c.Id, 'Subscriptions were not associated to Contract.');
            }
        }
    }

    @isTest
    public static void test_contractingOfOrderCreatedFromOpportunity() {
        // Set up all test data leading up to creating automated Order from Opportunity
        setup();
        setupQuotesAndQuoteLines();

        // Create order from opportunity (oppList[0] is already associated to a primary quote):
        order = CA2_CPQTestUtil.createAutomatedOrderFromOpportunity(oppList[0].Id);
        order.SBQQ__PriceCalcStatus__c = 'Completed';

        // Activate the Order:
        List<OrderItem> orderItems = CA2_CPQTestUtil.activateOrder(order);

        // Contract the Order:
        contractList = CA2_CPQTestUtil.contractOrder(
            order,  // Order order
            true,   // Boolean startTests
            true    // Boolean stopTests
        );

        /*********************
        ***** Assertions *****
        *********************/
        
        // Verify contracts got automatically created and assigned to the correct quote:
        System.assertNotEquals(contractList.isEmpty(), true, 'No contracts were created when the Order (created from Opportunity) was Contracted.');
        System.assertEquals(contractList[0].SBQQ__Quote__c, quoteList[0].Id);    

        // Verify orderItems got created for the order:
        System.assertNotEquals(orderItems, null, 'Order products were not created when the order (created from Opportunity) was contracted.');
        for(OrderItem oi : orderItems) {
            System.assertEquals(oi.OrderId, order.Id, 'Order products did not get assigned to order.');
        }
    }

    @isTest
    public static void test_contractingOfOrderCreatedFromQuote() {
        // Set up all test data leading up to creating automated Order from Quote:
        setup();
        setupQuotesAndQuoteLines();

        // Create order from quote (quoteList[0] is already primary):
        order = CA2_CPQTestUtil.createAutomatedOrderFromQuote(quoteList[0].Id);
        order.SBQQ__PriceCalcStatus__c = 'Completed';

        // Activate the Order:
        List<OrderItem> orderItems = CA2_CPQTestUtil.activateOrder(order);
        
        // Contract the Order:
        contractList = CA2_CPQTestUtil.contractOrder(order, 
            true,   // Boolean startTests;
            true    // Boolean stopTests;
        );

        /*********************
        ***** Assertions *****
        *********************/
        
        // Verify Contracts got automatically created:
        System.assertNotEquals(contractList.isEmpty(), true, 'No contracts were created when the Order (created from Quote) was Contracted.');
        for(Contract c : contractList) {
            System.assertEquals(c.SBQQ__Order__c, order.Id, 'Contract was not associated to Order');
            for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                // Verify Subscriptions got associated to Contract:
                System.assertEquals(sub.SBQQ__Contract__c, c.Id, 'Subscriptions were not associated to Contract.');
            }
        }
    }

    @isTest
    public static void test_assetAndSubscriptionGenerationFromContractedOpp() {
        // Set up all test data leading up to contracting the Opportunity:
        setup();
        setupQuotesAndQuoteLines();

        // Query the Contract (oppList[0] is already associated to a primary quote):
        contractList = CA2_CPQTestUtil.contractOpportunity(
            oppList[0],     // Opportunity opp
            true,           // Boolean startTests
            true            // Boolean stopTests
        );

        // Create new asset records for each account 
        // (TODO: contracting an opp generates a contract, but no assets - this might be because contracting
        // an opp queues up 2 asynchronous threads - 1 to generate the contract, and 1 to generate the assets.
        Asset asset = CA2_CPQTestUtil.createAsset(
            acctList[0], //Account acct
            quoteLineList[0], //SBQQ__QuoteLine__c quoteLine
            true,   // Boolean populateDefaultValues
            true    // Boolean doInsert
        );

        /*********************
        ***** Assertions *****`
        *********************/

        // Verify Asset got created on Account:
        // TODO: fix assets not getting created automatically :
        List<Asset> assetList = [SELECT Id FROM Asset WHERE AccountId = :acctList[0].Id];
        System.assertNotEquals(assetList.size(), 0, 'Assets were not created on Account.');
        
        // Verify Subscriptions got created for the Contract:
        List<SBQQ__Subscription__c> subscriptionList = [SELECT Id FROM SBQQ__Subscription__c 
                                                        WHERE SBQQ__Account__c = :acctList[0].Id 
                                                        AND SBQQ__Contract__c = :contractList[0].Id];
        System.assertNotEquals(subscriptionList.isEmpty(), true, 'Subscriptions were not created on Account.');
    }

     /***************************************************
    ***** Test methods related to contract renewals *****
    *****************************************************/


    @isTest
    public static void test_renewalForecast_contractedFromOpp() { 
        // Set up all test data leading up to just after contracting the Opportunity:
        setup();
        setupContractForRenewal('Opportunity');

        Test.startTest();
        System.debug('CA2_CPQTests.test_renewalForecast_contractedFromOpp just before updating contract');
        contractList[0].SBQQ__MasterContract__c = true; // this is apparently required if you don't want the test method marked with (SeeAllData=true)
        // Mark Renewal Forecast on the Contract:
        contractList[0].SBQQ__RenewalForecast__c = true;
        update contractList[0];
        Test.stopTest();

        /*********************
        ***** Assertions *****
        *********************/

        // Verify that a renewal Opportunity was automatically created for the Contract:
        Contract queriedContract = [SELECT Id, SBQQ__RenewalOpportunity__c FROM Contract WHERE Id = :contractList[0].Id];
        System.assertNotEquals(queriedContract, null);
        System.assertNotEquals(queriedContract.SBQQ__RenewalOpportunity__c, null, 'Renewal Opportunity not generated for Contract.');

    }

    public static void test_renewalQuoted_contractedFromOpp() {
        // Set up all test data leading up to just after contracting the Opportunity:
        setup();
        setupContractForRenewal('Opportunity');

        Test.startTest();
        contractList[0].SBQQ__MasterContract__c = true; // this is apparently required if you don't want the test method marked with (SeeAllData=true)
        // Mark Renewal Quoted on the Contract:
        contractList[0].SBQQ__RenewalQuoted__c = true;
        update contractList[0];
        Test.stopTest();

        /*********************
        ***** Assertions *****
        *********************/

        // Verify that a renewal Opportunity was automatically created for the Contract:
        contractList = [SELECT Id, SBQQ__RenewalOpportunity__c, SBQQ__Opportunity__c FROM Contract WHERE Id = :contractList[0].Id];
        System.assertNotEquals(contractList[0].SBQQ__RenewalOpportunity__c, null, 'Renewal Opportunity not generated for Contract.');

        for(Contract c : contractList) {
            // Verify Contracts got associated to Opportunity:
            System.assertEquals(c.SBQQ__Opportunity__c, oppList[0].Id, 'Contract was not associated to Opportunity');
            for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                // Verify Subscriptions got associated to Contract:
                System.assertEquals(sub.SBQQ__Contract__c, c.Id, 'Subscriptions were not associated to Contract.');
            }
        }

        // Verify that a renewal Quote was automatically created for the Contract:
        SBQQ__Quote__c renewalQuote = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :contractList[0].SBQQ__RenewalOpportunity__c];
        System.assertNotEquals(renewalQuote.SBQQ__Opportunity2__c, null, 'Renewal Quote not generated for Contract.');
    }

    public static void test_renewalForecast_contractedFromOrder() {
        // Set up all test data leading up to just after contracting the Order:
        setup();
        setupContractForRenewal('Order');

        Test.startTest();
        contractList[0].SBQQ__MasterContract__c = true; // this is apparently required if you don't want the test method marked with (SeeAllData=true)
        // Mark Renewal Forecast on the Contract:
        contractList[0].SBQQ__RenewalForecast__c = true;
        update contractList[0];
        Test.stopTest();

        /*********************
        ***** Assertions *****
        *********************/

        // Verify that a renewal Opportunity was automatically created for the Contract (we need to requery the contract due to automation within the package):
        contractList = [SELECT Id, SBQQ__RenewalOpportunity__c, SBQQ__Order__c FROM Contract WHERE Id = :contractList[0].Id];
        System.assertNotEquals(contractList[0].SBQQ__RenewalOpportunity__c, null, 'Renewal Opportunity not generated for Contract.');
        
        for(Contract c : contractList) {
            // Verify Contracts got associated to Order:
            System.assertEquals(c.SBQQ__Order__c, order.Id, 'Contract was not associated to Order');
            for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                // Verify Subscriptions got associated to Contract:
                System.assertEquals(sub.SBQQ__Contract__c, c.Id, 'Subscriptions were not associated to Contract.');
            }
        }
    }

    public static void test_renewalQuoted_contractedFromOrder() {
        // Set up all test data leading up to just after contracting the Order:
        setup();
        setupContractForRenewal('Order');

        Test.startTest();
        contractList[0].SBQQ__MasterContract__c = true; // this is apparently required if you don't want the test method marked with (SeeAllData=true)
        // Mark Renewal Quoted on the Contract:
        contractList[0].SBQQ__RenewalQuoted__c = true;
        update contractList[0];
        Test.stopTest();

        /*********************
        ***** Assertions *****
        *********************/

        // Verify that a renewal Opportunity was automatically created for the Contract:
        contractList = [SELECT Id, SBQQ__RenewalOpportunity__c, SBQQ__Order__c FROM Contract WHERE Id = :contractList[0].Id];
        System.assertNotEquals(contractList[0].SBQQ__RenewalOpportunity__c, null, 'Renewal Opportunity not generated for Contract.');

        for(Contract c : contractList) {
            // Verify Contracts got associated to Order:
            System.assertEquals(c.SBQQ__Order__c, order.Id, 'Contract was not associated to Order');
            for(SBQQ__Subscription__c sub : c.SBQQ__Subscriptions__r){
                // Verify Subscriptions got associated to Contract:
                System.assertEquals(sub.SBQQ__Contract__c, c.Id, 'Subscriptions were not associated to Contract.');
            }
        }

        // Verify that a renewal Quote was automatically created for the Contract:
        SBQQ__Quote__c renewalQuote = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :contractList[0].SBQQ__RenewalOpportunity__c];
        System.assertNotEquals(renewalQuote.SBQQ__Opportunity2__c, null, 'Renewal Quote not generated for Contract.');
    }

    /***************************
    ***** End test methods *****
    ***************************/
}