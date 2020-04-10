@IsTest
public class QuoteTriggerHandlerTest {
    @IsTest
    static void updateOppWithPrimaryQuote(){
        //Inserting Account
        Account acct = new Account();
        acct.Name = 'TestAccount';
        acct.Type = 'Customer';
        insert acct;
        //Insert Primary BillTo
        QS_Bill_To_Ship_To__c btSt = new QS_Bill_To_Ship_To__c();
        //btSt.QS_Primary__c = true;
        btSt.QS_Account__c = acct.Id;
        btSt.QS_Bill_To__c = true;
        btSt.QS_Street_1__c = 'Test Street';
        btSt.QS_City__c = 'Test City';
        btSt.QS_State__c = 'Test State';
        btSt.QS_Country__c = 'Test Country';
        btSt.QS_Zip_Postal_Code__c  = '12345';
        btSt.QS_Email__c = 'Test@gmail.com';
        btSt.QS_Invoice_via_Email__c = true;
        insert btSt;
        //Insert Primary ShipTo
        QS_Bill_To_Ship_To__c btSt2 = new QS_Bill_To_Ship_To__c();
        //btSt.QS_Primary__c = true;
        btSt.QS_Account__c = acct.Id;
        btSt.QS_Ship_To__c = true;
        btSt.QS_Street_1__c = 'Test Street';
        btSt.QS_City__c = 'Test City';
        btSt.QS_State__c = 'Test State';
        btSt.QS_Country__c = 'Test Country';
        btSt.QS_Zip_Postal_Code__c  = '12345';
        btSt.QS_Email__c = 'Test@gmail.com';
        btSt.QS_Invoice_via_Email__c = true;
        insert btSt2;
        //Insert Opp
        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.Name = 'TestOpp';
        opp.Type = 'New Customer';
        opp.StageName = 'Diagnosing';
        opp.QS_Order_Type__c = 'New';
        opp.CloseDate = System.today()+30;
        opp.QS_Sales_Forecast_Category__c = '3 - Pipeline';
        opp.QS_Bill_To__c = null;
        opp.QS_Ship_To__c = null;
        insert opp;
        //Insert Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__Account__c = acct.Id;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.QS_Bill_To__c = btSt.Id;
        //quote.QS_Ship_To__c = btSt2.Id;
        insert quote;


        opp = [SELECT Id, QS_Bill_To__c, QS_Ship_To__c FROM Opportunity WHERE Id= :opp.Id];
        System.assertEquals(btSt.Id, opp.QS_Bill_To__c);
        System.debug(opp.QS_Bill_To__c);
        System.debug(opp.Id);
    }

}