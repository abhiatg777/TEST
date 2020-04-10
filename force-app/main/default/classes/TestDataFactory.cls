/**********************************************************
* @Author       Heidi Tang (heidi.a.tang@accenture.com)
* @Date         2016-05-25
* @Description  Test data creations for all classes
**********************************************************/
@isTest
public class TestDataFactory {
    
     /* -----------------------------Test Data for Users--------------------------*/
    
    public static User createInternalSysAdminUser(String email, String lastName, String userName, String nickName){
        
        Profile sysAdminProf = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User internalUser = new User(Alias = nickName, Email=email,
                    EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = sysAdminProf.Id,isActive=true,
                    TimeZoneSidKey='America/Los_Angeles', UserName=userName); 
                    
        return internalUser;
    }
    
    /* -----------------------------Set Record Types and Business Hours--------------------------*/
    
    public static Id getRecordTypeId(String recordTypeDevName, String objectName){
        
        RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType =:objectName AND DeveloperName = :recordtypeDevName];
        
        return recType.Id;
    } 
    
    /* -----------------------------Test Data for Custom Settings--------------------------*/
    public static void caseFieldsSetting(){
        /*List<Case_Fields__c> caseFields = new List<Case_Fields__c>();
        
        caseFields.add(new Case_Fields__c(Name = 'Account',Field_Api_Name__c = 'AccountId'));
        caseFields.add(new Case_Fields__c(Name = 'Origin',Field_Api_Name__c = 'Origin'));
        caseFields.add(new Case_Fields__c(Name = 'Customer Escalation',Field_Api_Name__c = 'Customer_Escalated__c'));
        caseFields.add(new Case_Fields__c(Name = 'Priority',Field_Api_Name__c = 'Priority'));
        caseFields.add(new Case_Fields__c(Name = 'Severity',Field_Api_Name__c = 'Severity__c'));
        
        insert caseFields;*/
    }
    
    /* -----------------------------Test Data for Multiple Records--------------------------*/
    
  public static List<Account> createAcctList(Integer noOfAccts, String acctName){
        
        List<Account> acctList = new List<Account>();
        
        for(Integer i=1;i<=noOfAccts;i++){
            acctList.add(new Account(Name = acctName +'i', BillingCountry = 'United States',
                    ShippingCountry = 'United States',QS_Overdue_Balance__c = 0,QS_CAPdb_Rating__c = 'Something'));
        }
        
        return acctList;
        
    }
    
    public static List<Contact> createConList(Integer noOfCons, String lastName){
         List<Contact> conList = new List<Contact>();
        
        for(Integer i=1;i<=noOfCons;i++){
            conList.add(new Contact(LastName = lastName +'i'));
        }
        
        return conList;
    }
    
    public static Case createCase(Account acct) {
        
        return createCase(acct, false);
    }
    
    public static Case createCase(Account acct, boolean toInsert) {
		
        Case c = new Case(Subject = 'Test Case',
                         AccountId = acct.Id);
        if(toInsert) {
			insert c;
        }
        return c;
    }
    
    public static Bug__c createBug() {
        return createBug(false);
    }
    
    public static Bug__c createBug(boolean toInsert) {
        
        Bug__c b = new Bug__c(Bug_Status__c = 'New',
                              Product_Instance_Identifier__c = 'Test Product Instance Identifier',
                              Product_Platform__c = 'MINDBODY',
                              Severity__c = 'Low',
                              Steps_to_Reproduce__c = 'Test Steps to Reproduce',
                              Title__c = 'Test Title');
        if(toInsert) {
			insert b;
        }
        
        return b;
    }
    
     public static List<QS_Key_Players_Influencers__c> createKeyInfluencer(Integer noOfKeys,String formalRole, Id opportunityId){
        List<QS_Key_Players_Influencers__c> keyList = new List<QS_Key_Players_Influencers__c>();
        
        for(Integer i=1;i<=noOfKeys;i++){
            keyList.add(new QS_Key_Players_Influencers__c(QS_Formal_Role__c=formalRole,QS_Opportunity__c=opportunityId));
        }
        
        return keyList;
    }
    /*
        public static List<Attachment> createAttachments(Integer noOfAttach, String parentId, String subjectName){
        
        List<Attachment> attachmentList = new List<Attachment>();
        
        for(Integer i=1;i<=noOfAttach;i++){
            Blob bodyBlob=Blob.valueOf(subjectName+i);
            attachmentList.add(new Attachment(ParentId=parentId,Name=subjectName+i,Body = bodyBlob));
        }
                
        return attachmentList;
    }
    
    public static List<Case_Internal_Attachment__c> createInternalAttachments(Integer noOfIntAttach, String parentId, String intName){
        
        List<Case_Internal_Attachment__c> intAttachmentList = new List<Case_Internal_Attachment__c>();
        
        for(Integer i=1;i<=noOfIntAttach;i++){
            intAttachmentList.add(new Case_Internal_Attachment__c(Case__c=parentId,Name=intName+i));
        }
                
        return intAttachmentList;
    }*/

    
}