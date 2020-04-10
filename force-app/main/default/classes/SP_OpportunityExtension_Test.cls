@istest
public class SP_OpportunityExtension_Test{
    public static testMethod void testOpportunityAdvanceStageController(){
        Account acc = new Account(Name='Acc1');
    	insert acc;
    	Contact con = new Contact(firstname='asd',lastname='dsf',AccountId=acc.Id);
        insert con;
        
        QS_Opportunity_Stage__c oppStage1 = new QS_Opportunity_Stage__c();
        oppStage1.Name = '1 - Plan';
        insert oppStage1;
        
        QS_Opportunity_Stage__c oppStage2 = new QS_Opportunity_Stage__c();
        oppStage2.Name = '2 - Develop';
        oppStage2.QS_Next_Stage__c = oppStage1.id;
        insert oppStage2;
        
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        Opportunity testOpportunity = new Opportunity(Name='asdasd',RecordTypeId=PRODUCTSANDSERVRTYPE,stagename='1 - Plan', closedate=Date.today(), Contact__c=con.Id, AccountId=acc.Id);
        testOpportunity.QS_Opportunity_Stage__c = oppStage1.Id;
        insert testOpportunity;
        
        
        SP_OpportunityExtension testOpportunityExtension = new SP_OpportunityExtension(new ApexPages.StandardController(testOpportunity));
        if(testOpportunityExtension.OppStage == null){}
        if(testOpportunityExtension.nextStage == null){}
        if(testOpportunityExtension.advancementCriteria == null){}
        if(testOpportunityExtension.readyToAdvance){}
        testOpportunityExtension.advanceStage();
    }
}