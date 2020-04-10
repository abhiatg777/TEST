@isTest
public with sharing class EmailClassTest {
    
    static testMethod void myUnitTest() { 
        
        RecordType caseRT = [SELECT id FROM RecordType WHERE SObjectType='Case' AND Name='Support Issue'];
        Case newCase = new Case(RecordTypeId=caseRT.id,
                                        Origin='Internal',
                                        Status='Pending'
                                               );
        insert newCase;
                
        
        EmailClass.EmailTemplateEx e = new EmailClass.EmailTemplateEx();
        
        e.whatId = newCase.Id;
        e.targetId = null;
        e.templateId = null;
        e.contactEmailAddress = 'con@con.com';
        e.contactName = 'test';
        e.ccAddresses = new list<String>{'test@test.com'};
        e.bccAddresses = new list<String>{'test@test.com'};
        e.orgWideEmailAddress = [select id from OrgWideEmailAddress limit 1].Id;
        e.saveAsActivity = false;
        
        List<EmailClass.EmailTemplateEx> eList = new List<EmailClass.EmailTemplateEx>();
        eList.add(e);
        
        EmailClass.sendEmailsWithTemplate(eList);   
    }
    
    static testMethod void test2() { 
        
        Id orgWideId = [select id from OrgWideEmailAddress limit 1].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User();
        
        user.FirstName = 'Test';
        user.LastName = 'Name';
        user.CompanyName = 'IT Test Company';
        user.MobilePhone = '123-456-7890';
        
        user.Username = 'testUser1@vertafore.com';
        user.Email = 'testUser-@test.com';
        user.Alias = 'test';
        user.CommunityNickname = 'test1';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = p.Id;  
        user.LanguageLocaleKey = 'en_US';
        
        user.Street = '123 Test St';
        user.City = 'Testcity';
        //user.State = 'va'; 
        user.PostalCode = '23223';
        //user.Country = 'USA';
        
        insert user;    
        List<Id> uList = new List<Id>(); 
        uList.add(user.Id);
        
        string subject = '';
        
        for(integer i = 0; i< 256; i++){
            subject += string.valueOf(i);
        }
        
        EmailClass.sendEmailInternalUsersAsync(uList,subject,'test','test',orgWideId);
        EmailClass.sendEmailInternalUsers(uList,subject,'test','test',orgWideId);
        EmailClass.sendEmailAsync(new List<String>{'test@test.com'},new List<String>{'test@test.com'},new List<String>{'test@test.com'}, subject ,'test','test',orgWideId);
        EmailClass.sendEmail(new List<String>{'test@test.com'},new List<String>{'test@test.com'},new List<String>{'test@test.com'}, subject ,'test','test',orgWideId);
        system.assertEquals(EmailClass.truncateString('testtest',5),'te...');
        //EmailClass.isUserInInbox();
        try{
        EmailClass.sendErrorEmail('test',null); 
        }catch (exception e){
            
        }
        
        //EmailClass.sendEmailPriority(new List<String>{'test@test.com'},new List<String>{'test@test.com'},new List<String>{'test@test.com'}, subject ,'test','test',orgWideId,'test');
        system.assertEquals(EmailClass.FromAddressForCases,null);
        EmailClass.createHyperLink('test','test');
        EmailClass.convertHtmlToText('test');
        //EmailClass.sendMultipleEmails();
        EmailClass.createMail('test','test','test',orgWideId);
        EmailClass.createMail(new list<string>{'test'},'test','test',orgWideId);
        //EmailClass.grabToEmailFromListOfmail();
        EmailClass.convertTextToHtml('test');
        EmailClass.convertListStringsToOneString(new List<String>{'test','test2','test3'});
            
    }
    

}