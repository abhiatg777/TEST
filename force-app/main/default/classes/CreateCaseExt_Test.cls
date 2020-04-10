@isTest
public class CreateCaseExt_Test
{

    static testMethod void testConstructor()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Case cs = TestUtils.getCase();
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        Test.startTest();
        CreateCaseExt cce = new CreateCaseExt(std);
       
        
        //System.assertEquals(System.label.No_Account_provided, ApexPages.getMessages().get(0).getDetail());
        
        //provide an account and contact in query string - internal user
        cs = TestUtils.getCase();
        Contact c = TestUtils.getContact(a);
        insert c;
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_ACCOUNT_ID, a.id);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_CONTACT_ID, c.id);
        std = new ApexPages.StandardController(cs);
        cce = new CreateCaseExt(std);
        System.assertEquals(a.id, cce.am.record.id);
        System.assertEquals(a.id, cs.AccountID);
        System.assertEquals(false, cce.isPortal);
        System.assertEquals(false, cce.isChangeAsset);
        
        //call the page from portal - portal user
        Contact c2 = TestUtils.getContact(a);
        insert c2;

            std = new ApexPages.StandardController(new Case());
            cce = new CreateCaseExt(std);
            System.assertEquals(a.id, cs.AccountID);
        
    /*
        Account practice = TestUtils.getPractice(a, 'prc1');
        insert practice;
        Version_Family__c vf = TestUtils.getVersionFamily('vf1');
        insert vf;
        Version__c v1 = TestUtils.getVersion(vf, 'v1.0');
        insert v1;
        Product2 p1 = TestUtils.getProduct('ut prod1', 'family1', 'line1', vf);
        insert p1;
        Asset__c ast1 = TestUtils.getAsset(a, p1);
        insert ast1;
        AccountAsset__c aa1 = TestUtils.getAccountAsset(practice, ast1);
        insert aa1;
        Component__c comp = TestUtils.getComponent( 'comp1');
        insert comp;
        Component_Product_Junction__c cpj = TestUtils.getComponentProductJunction(comp, p1);
        insert cpj;
        Sub_Component__c sc = TestUtils.getSubComponent(comp, 'subComponent1');
        insert sc;
        cs = TestUtils.getCase(a, c, 'family1', 'line1', ast1, practice, v1, comp, sc);
        insert cs;
        ApexPages.currentPage().getParameters().put(CONSTANTS.QRY_STRING_CASE_ID, cs.id);
        std = new ApexPages.StandardController(cs);
        cce = new CaseContExt(std);
        System.assertEquals(true, cce.isChangeAsset);
        */
        Test.stopTest();
    }

    
    static testMethod void testSaveMethods()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Contact c = TestUtils.getContact(a);
        insert c;
        Case cs = TestUtils.getCase(a, c);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_ACCOUNT_ID, a.id);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_CONTACT_ID, c.id);
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        CreateCaseExt cce = new CreateCaseExt(std);
        
        
        Test.startTest();
        cce.doCancel();
        PageReference pr = cce.saveOnly();
        pr = cce.saveAndAttach();
        cce.doCancel();
        cce.refreshPage();

        
    }
    
    static testMethod void testSaveMethods2()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Contact c = TestUtils.getContact(a);
        insert c;
        Case cs = TestUtils.getCase(a, c);
       // cs.AccountID
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_ACCOUNT_ID, a.id);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_CONTACT_ID, c.id);
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        CreateCaseExt cce = new CreateCaseExt(std);
        cce.getDefaultProductFamilyOptions();
        
        
        cce.conLastName = 'testLastName';
        cce.conEmail = 'testContEmail@gmail.com';
        cce.conFirstName = 'ContfirstName';
        Test.startTest();
        cce.doCancel();
        PageReference pr = cce.saveOnly();
        pr = cce.saveAndAttach();
        cce.doCancel();
        pr = cce.returnPortalOrInternalUserNavigation(pr, false, false);
       
        cce.refreshPage();

        
    }
    
    static testMethod void testSaveMethodException()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Contact c = TestUtils.getContact(a);
        insert c;
        Case cs = TestUtils.getCase(a, c);
       // cs.AccountID
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_ACCOUNT_ID, a.id);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_CONTACT_ID, c.id);
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        CreateCaseExt cce = new CreateCaseExt(std);
        cce.getDefaultProductFamilyOptions();
        cce.c.AccountId = null;
         //cce.conLastName = 'testLastName';
        cce.conEmail = 'testContEmail@gmail.com';
        cce.conFirstName = 'ContfirstName';
        Test.startTest();
        cce.doCancel();
        PageReference pr = cce.saveOnly();
        pr = cce.saveAndAttach();
        cce.doCancel();
        cce.refreshPage();

        
    }
    static testMethod void testSaveMethodException2()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Contact c = TestUtils.getContact(a);
        insert c;
        Case cs = TestUtils.getCase(a, c);
       // cs.AccountID
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_ACCOUNT_ID, a.id);
        ApexPages.currentPage().getParameters().put(Constants.QRY_STRING_CONTACT_ID, c.id);
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        CreateCaseExt cce = new CreateCaseExt(std);
        cce.getDefaultProductFamilyOptions();
        cce.c.AccountId = null;
        cce.conLastName = 'testLastName';
        cce.conEmail = 'testContEmail';
        cce.conFirstName = 'ContfirstName';
        Test.startTest();
        cce.doCancel();
        PageReference pr = cce.saveOnly();
        pr = cce.saveAndAttach();
        cce.doCancel();
        cce.refreshPage();

        
    }
   
/**/
}