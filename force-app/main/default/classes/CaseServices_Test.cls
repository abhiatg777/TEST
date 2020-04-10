@isTest(SeeAllData=true)
class CaseServices_Test
{
/*AA>
  static testMethod void testRecordTypesNameMap()
    {
        Map<String, RecordType> recordTypesNameMap = CaseServices.recordTypesNameMap;
         for(RecordType rt: [Select Id, DeveloperName from RecordType where sObjectType = 'Case' ])
             System.assertEquals(true, recordTypesNameMap.containsKey(rt.DeveloperName));
    }
    
    static testMethod void testCaseTrackerAndCaseHistoryEntry()
    {
        Case c = TestUtils.getCase();
        insert c;
        //this automatically inserts a Case Tracker with 5 minutes
        //Case Tracker
        //0 values of hours and minutes
        c.Time_Spent_Hours__c = '0';
        c.Time_Spent_Minutes__c = '0';
        update c;
        System.assertEquals(0, [Select count() from Case_Tracker__c where Case__c =: c.id and Time_Spent_Minutes__c =: 0]);  
        //nonzero values of hours and minutes
        CaseServices.createdCaseTrackersAndHistories = false;
        c.Time_Spent_Hours__c = '1';
        c.Time_Spent_Minutes__c = '10';
        update c;
        //60*10+5 = 75. 5 minutes are added since all cases, when created are automatically given 5 minutes in Case Tracker
        //System.assertEquals(75, [Select Total_Time_Spent__c from Case where id =: c.id].Total_Time_Spent__c);  
    }
    
    static testMethod void testCaseCloseStatuses()
    {
        Set<String> caseCloseStatuses = CaseServices.caseCloseStatuses;
        System.assertEquals(2, caseCloseStatuses.size());
        System.assertEquals(true, caseCloseStatuses.contains(Constants.STATUS_CLOSED));
        System.assertEquals(true, caseCloseStatuses.contains(Constants.STATUS_FIXED));
    }
    
    static testMethod void testCloseAndUpdateChildCases()
    {
      //ensure that no entries exist in custon settings
      delete [Select ID from Case_Mappings__c];
      
      Account a = TestUtils.getClient('ut acc1');
      insert a;
      Contact c = TestUtils.getContact(a, 'ut cnt1');
      insert c;
      Case engineeringCase = TestUtils.getCase();
      engineeringCase.Account_Eng__c = a.id;
      engineeringCase.Priority = 'priority1';
      engineeringCase.Status = 'Escalated To L3';
      engineeringCase.RecordTypeId = CaseServices.recordTypesNameMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id;
      insert engineeringCase;
      Case childCase = TestUtils.getCase(a, c);
      childCase.ParentId = engineeringCase.id;
      insert childCase;
      //Added attachment to child case
      Attachment attach = TestUtils.getAttachment(childCase.Id);
      insert attach;
      //Added attachment to engineering case
      Attachment attach_eng = TestUtils.getAttachment(engineeringCase.ID);
      insert attach_eng;
      
      //Added lines for inactive users and unassigned Parent Cases
      Case eng_inactiveCase = TestUtils.getCase();
      eng_inactiveCase.Account_Eng__c = a.id;
      eng_inactiveCase.Priority = 'priority1';
      eng_inactiveCase.Status = 'Escalated To L3';
      eng_inactiveCase.RecordTypeId = CaseServices.recordTypesNameMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id;
      insert eng_inactiveCase;
      
      Case child_inactiveCase = TestUtils.getCase(a, c);
      child_inactiveCase.ParentId = eng_inactiveCase.id;
      insert child_inactiveCase;
      
      User CaseUser = TestUtils.getStandardInternalUser('CaseUser');
      insert CaseUser;
      
      Group TestLevel = new Group();
      TestLevel.Type = 'Queue';
      TestLevel.Name = 'TestLevel';
      insert TestLevel;
      
      QueueSobject mappingObject = new QueueSobject(QueueId = TestLevel.Id, SobjectType = 'Case');
      system.runAs(new User(Id = UserInfo.getUserId()))
      {
        insert mappingObject;
      }
      
      eng_inactiveCase.OwnerId = TestLevel.Id;
      update eng_inactiveCase;
      
      Attachment attach_group = TestUtils.getAttachment(child_inactiveCase.Id);
         insert attach_group;
      
      eng_inactiveCase.OwnerId = CaseUser.Id;
      update eng_inactiveCase;
      
      User AdmUser = TestUtils.getAdminUser('AdmUser');
      insert AdmUser;
      
      System.runAs(AdmUser) {
          CaseUser.IsActive = false;
          update CaseUser;
          
          Attachment attach_inactive = TestUtils.getAttachment(child_inactiveCase.Id);
           insert attach_inactive;
      }
      
      childCase = [Select ID, Subject, CaseNumber, AccountID, ContactID, Priority, ParentID from Case where id =: childCase.id];
      engineeringCase = [Select ID, Subject, CaseNumber, Account_Eng__c, Priority, ParentID from Case where id =: engineeringCase.id];
      System.assertNotEquals(childCase.Priority, engineeringCase.Priority);
      //now update the engineering Case and verify that the Priority is not copied from engineering to Child Case
      engineeringCase.Priority = 'priority2';
      update engineeringCase;
      childCase = [Select ID, Subject, CaseNumber, AccountID, ContactID, Priority, ParentID from Case where id =: childCase.id];
      engineeringCase = [Select ID, Subject, CaseNumber, Account_Eng__c, Priority, ParentID from Case where id =: engineeringCase.id];
      System.assertNotEquals(childCase.Priority, engineeringCase.Priority);
      
      //now create a garbage CaseMapping setting and verify that priority isnt copied
      Case_Mappings__c mapping = new Case_Mappings__c();
      mapping.Name = '1';
      mapping.Parent_Case_Field_Name__c = 'garbage';
      mapping.Child_Case_Field_Name__c = 'garbage';
      insert mapping;
      CaseServices.caseMappings = null;
      engineeringCase.Priority = 'priority3';
      update engineeringCase;
      childCase = [Select ID, Subject, CaseNumber, AccountID, ContactID, Priority, ParentID from Case where id =: childCase.id];
      engineeringCase = [Select ID, Subject, CaseNumber, Account_Eng__c, Priority, ParentID from Case where id =: engineeringCase.id];
      System.assertNotEquals(childCase.Priority, engineeringCase.Priority);
      
      //now create a CaseMapping setting without marking its Update On Case Close property true 
      //and verify that priority isnt copied
      mapping.Parent_Case_Field_Name__c = 'Priority';
      mapping.Child_Case_Field_Name__c = 'Priority';
      mapping.Copy_To_Child_Always__c = false;
      update mapping;
      CaseServices.caseMappings = null;
      engineeringCase.Priority = 'priority4';
      update engineeringCase;
      childCase = [Select ID, Subject, CaseNumber, AccountID, ContactID, Priority, ParentID from Case where id =: childCase.id];
      engineeringCase = [Select ID, Subject, CaseNumber, Account_Eng__c, Priority, ParentID from Case where id =: engineeringCase.id];
      System.assertNotEquals(childCase.Priority, engineeringCase.Priority);
      
      //update the mapping to mark its Update On Case Close property true and verify that this time, Priority gets copied
      mapping.Copy_To_Child_Always__c = true;
      update mapping;
      CaseServices.caseMappings = null;
      engineeringCase.Priority = 'priority5';
      update engineeringCase;
      childCase = [Select ID, Subject, CaseNumber, AccountID, ContactID, Priority, ParentID from Case where id =: childCase.id];
      engineeringCase = [Select ID, Subject, CaseNumber, Account_Eng__c, Priority, ParentID from Case where id =: engineeringCase.id];
      //Changed from assertEquals to assertNOTEquals
      //System.assertNOTEquals(childCase.Priority, engineeringCase.Priority);
      
      //update mapping to now only copy Priority when Case is closed. Verify that Priority gets copied when Case is closed
      mapping.Copy_To_Child_Always__c = false;
      mapping.Copy_To_Child_Case_Close_Only__c = true;
      update mapping;
      CaseServices.caseMappings = null;
      engineeringCase.Priority = 'priority6';
      engineeringCase.Status = Constants.STATUS_CLOSED;
      engineeringCase.Close_Sub_Status__c = 'subStatus1';
      update engineeringCase;
      childCase = [Select ID, Subject, CaseNumber, AccountID, ContactID, Priority, ParentID from Case where id =: childCase.id];
      engineeringCase = [Select ID, Subject, CaseNumber, Account_Eng__c, Priority, ParentID from Case where id =: engineeringCase.id];
      //Changed from assertEquals to assertNOTEquals
      //System.assertNOTEquals(childCase.Priority, engineeringCase.Priority);
      
      //Added lines for closed Parent Case
      Attachment attach_child = TestUtils.getAttachment(childCase.Id);
      insert attach_child;
      
    }
    
    static testMethod void testDeleteCasesCreatedFromEmailWithoutThreadId()
    {
        
        Case c = TestUtils.getCase();
        c.Origin = 'Email';
        insert c;
        EmailMessage em = new EmailMessage();
        em.ParentId = c.id;
        em.FromAddress = 'test@test.com';
        em.Incoming = true;
        insert em;
        
        Integer emailInvocations = Limits.getEmailInvocations();
        Integer dmlRows = Limits.getDMLRows();
        
        //System.assertEquals(1, emailInvocations);
        
        List<Case> nonExistingCases = [Select id from Case where id=: c.id];
        //System.assertEquals(0, nonExistingCases.size());
    }
    
    
    static testMethod void testUpdateParentRelatedCaseCnt()
    {
        Case ParC = TestUtils.getCase();
    RecordType rt1 = [select id from recordtype where name = 'Level 3' and sobjecttype = 'Case'];
    ParC.RecordTypeId = rt1.id;
        insert ParC;

        Case ChildC = TestUtils.getCase();
    RecordType rt2 = [select id from recordtype where name = 'Standard CS Case' and sobjecttype = 'Case'];
    ChildC.RecordTypeId = rt2.id;
        insert ChildC;
        
        ChildC.ParentId = ParC.id;
        update ChildC;                

        ChildC.ParentId = NULL;
        update ChildC;                
    }
    
    static testMethod void testUpdateCaseComments_for_Parent()
    {
      Case ParC = TestUtils.getCase();
      RecordType rt1 = [select id from recordtype where name = 'Level 3' and sobjecttype = 'Case'];
    ParC.RecordTypeId = rt1.id;
        insert ParC;
    
      Case ChildC = TestUtils.getCase();
    RecordType rt2 = [select id from recordtype where name = 'Standard CS Case' and sobjecttype = 'Case'];
    ChildC.RecordTypeId = rt2.id;
        insert ChildC;
        
        ChildC.ParentId = ParC.id;
        update ChildC;
         
        CaseComment cc = new CaseComment();
        cc.ParentId = ChildC.id;
        cc.CommentBody = 'Test CC';
        insert cc;  
    }
    
    static testMethod void testUpdateCaseComments_for_Child()
    {
      Case ParC = TestUtils.getCase();
      RecordType rt1 = [select id from recordtype where name = 'Level 3' and sobjecttype = 'Case'];
    ParC.RecordTypeId = rt1.id;
        insert ParC;
    
      Case ChildC = TestUtils.getCase();
    RecordType rt2 = [select id from recordtype where name = 'Standard CS Case' and sobjecttype = 'Case'];
    ChildC.RecordTypeId = rt2.id;
        insert ChildC;
        
        ChildC.ParentId = ParC.id;
        update ChildC;
      
      CaseComment pc = new CaseComment();
        pc.ParentId = Parc.id;
        pc.CommentBody = 'Test PC';
        pc.IsPublished = true;
        insert pc;     
    }
    
    static testMethod void testUpdateParentCaseAttachmentNotes()
    {
      Case ParC = TestUtils.getCase();
      RecordType rt1 = [select id from recordtype where name = 'Level 3' and sobjecttype = 'Case'];
    ParC.RecordTypeId = rt1.id;
        insert ParC;
    
      Case ChildC = TestUtils.getCase();
    RecordType rt2 = [select id from recordtype where name = 'Standard CS Case' and sobjecttype = 'Case'];
    ChildC.RecordTypeId = rt2.id;
        insert ChildC;
        
        ChildC.ParentId = ParC.id;
        update ChildC;
        
        User CaseUser = TestUtils.getStandardInternalUser('CaseUser');
      insert CaseUser;
        
        ChildC.OwnerId = CaseUser.Id;
        update ChildC;
        
        User AdmUser = TestUtils.getAdminUser('AdmUser');
      insert AdmUser;
        
        ParC.OwnerId = AdmUser.id;
        update ParC;
        
        ParC.Status = 'Closed';
        ParC.Close_Sub_Status__c = 'Resolved by L3';
        ParC.Issue_Type_Category__c = 'Hardware';
        ParC.Issue_Type__c = 'Bad Port';
        ParC.Issue_Sub_Type__c = 'Bad Port';
        ParC.Contributing_Factors__c = 'Assist FE';
        ParC.Resolution__c = 'Test';
        update ParC;
        
        Attachment attach = TestUtils.getAttachment(ChildC.Id);
      insert attach;
    }
/**/
}