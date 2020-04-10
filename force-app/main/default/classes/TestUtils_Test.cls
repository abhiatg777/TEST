@isTest
private class TestUtils_Test {

    static testMethod void testOLIs() {
        Account a = TestUtils.getAccount('Test');
        insert a;
        
        Opportunity o = TestUtils.getOpportunity(a, 'Test');
        o.Master_Agreement__c = '8000H0000001Gth';
        o.StageName = 'Create';
        insert o;
        
        OpportunityLineItem oli = TestUtils.getOLI(o);
        
        Product2 p = TestUtils.getProduct('Test Prod');
        insert p;
        
        OpportunityLineItem oli2 = TestUtils.getOLI(o, p);
    }
    
    
    static testMethod void testGetCase() {
        Case c = TestUtils.getCase();
    }

    
    static testMethod void runTest() {
        TestUtils t = new TestUtils();
        t.dummyCode();
    }



}