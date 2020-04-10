public class CaseServices 
{
/*AA>
    public static final String SObjectName = 'Case';
    
    
    public static Map<String, RecordType> recordTypesNameMap
    {
        get
        {
            if(recordTypesNameMap == null)
                recordTypesNameMap = GenericServices.getRecordTypesNameMapBySObject(sObjectName);
            
            return recordTypesNameMap;
        }
        
        private set;
    }
    
    private static Boolean sentEmail
    {
        get
        {
            if(sentEmail == null)
                sentEmail = false;
            return sentEmail;
        }
        set;
    }
    
    //called after update to delete the Case created by E2C
    public static void deleteCasesCreatedFromEmailWithoutThreadID(Map<ID, Case> newMap)
    {
        Map<ID, Case> referenceCases = new Map<Id, Case>([Select ID, Subject,
                                                        (Select id, Subject, FromAddress from EmailMessages) 
                                                        From Case where id in: newMap.keySet()
                                                        And Created_Without_Thread_Id__c =: true
                                                        ]);
        List<Case> casesToDelete = new List<Case>();
        for(Case c: newMap.values())
        {
            if(referenceCases.containsKey(c.id))
            {
                Case refCase = referenceCases.get(c.id);
                if(refCase.EmailMessages != null 
                  && refCase.EmailMessages.size() > 0 
                  && refCase.EmailMessages[0].FromAddress != null
                  )
                {
                    if(!sentEmail)
                    {
                        try
                        {
                            //GenericServices.sendEmail(refCase.EmailMessages[0].FromAddress, 'Re: '+refCase.EmailMessages[0].Subject);
                            sentEmail = true;
                        }
                        catch(Exception exc)
                        {
                            c.addError(exc.getMessage());
                        }
                    }
                }
                casesToDelete.add(refCase);
            }
        }
        
        if(casesToDelete.size() > 0)
            delete casesToDelete;
    }
    
    

    
    
    //called from AfterUpdate trigger on Case
    public static void closeAndUpdateChildCases(Map<ID, Case> newMap, Map<ID, Case> oldMap)
    {
        Set<ID> qualifiedEngineeringCaseIDs = new Set<ID>();
        for(Case c: newMap.values())
        {
            if(   c.RecordTypeID == recordTypesNameMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id
                  && c.Status != null  
               )
            {
                qualifiedEngineeringCaseIDs.add(c.id);    
            }
        }
        
        List<Case> childCasesToUpdate = new List<Case>();
        if(qualifiedEngineeringCaseIDs.size() > 0)
        {
            //Added Priority in set fieldNames
            Set<String> fieldNames = new Set<String>{'ID', 'CaseNumber', 'ParentID', 'Subject', 'Status', 'Priority', 'Issue_Type_Category__c', 'Issue_Type__c', 'Group__c', 'IsClosed'};
            for(Case_Mappings__c cm: caseMappings.values())
            {
                if(cm.Copy_To_Child_Always__c == true || cm.Copy_To_Child_Case_Close_Only__c == true)
                {
                    fieldNames.add(cm.Child_Case_Field_Name__c);
                }
            }
            
            //String childCasesQuery = 'Select ID, CaseNumber, ParentID, Subject, AccountID'+fieldNamesCSV+' from Case where ParentID in: qualifiedEngineeringCaseIDs';
            //Updated Query to only bring in Child Cases that are open, not already closed
            String childCasesQuery = 'Select '+GenericServices.getCSVFromSet(fieldNames)+' from Case where ParentID in: qualifiedEngineeringCaseIDs and IsClosed != true';
            List<Case> childCases = new List<Case>();
            try
            {
                childCases = Database.query(childCasesQuery);
            }
            catch(Exception exc)
            {
                for(Case c: newMap.values())
                    c.addError(System.Label.Error_with_Case_Mappings_Please_revisit_them_in_Custom_Settings+exc.getMessage());
                
                return;
            }
            
            if(childCases.size() > 0)
            {
                for(Case childCase: childCases)
                {
                    Case engineeringCase = newMap.get(childCase.ParentID);
                    for(Case_Mappings__c cm: caseMappings.values())
                    {
                        if(cm.Copy_To_Child_Always__c == true && cm.Copy_To_Child_Case_Close_Only__c != true)
                        {
                            try
                            {
                                childCase.put(cm.Child_Case_Field_Name__c, engineeringCase.get(cm.Parent_Case_Field_Name__c));
                            }
                            catch(Exception exc)
                            {
                                System.debug('Exception encountered when copying '+cm.Parent_Case_Field_Name__c+' from Parent Case to Child on Parent field update: '+exc.getMessage());
                            }
                        }
                        
                        if(caseCloseStatuses.contains(engineeringCase.Status))
                        {
                            System.debug('\n\nEngineeringCase.Status = '+engineeringCase.Status+'\n');
                            
                            if(cm.Copy_To_Child_Case_Close_Only__c == true)
                            {
                                try
                                {
                                   childCase.put(cm.Child_Case_Field_Name__c, engineeringCase.get(cm.Parent_Case_Field_Name__c));
                                }
                                catch(Exception exc)
                                {
                                    System.debug('Exception encountered when copying '+cm.Parent_Case_Field_Name__c+' from Parent Case to Child on Parent Case is marked Closed: '+ exc.getMessage());
                                }
                            }
                        }
                        
                    }
                    
                    childCasesToUpdate.add(childCase);
                }
                
                try
                {
                    update childCasesToUpdate;
                }
                catch(DMLException dmle)
                {
                    for(Integer x = 0; x<=dmle.getNumDML()-1; x++)
                        for(Case c: newMap.values())
                            c.addError(dmle.getDMLMessage(x));
                }
            }
        }
    }
    
    public static Map<String, Case_Mappings__c> caseMappings
    {
        get
        {
            if(caseMappings == null)
            {
                caseMappings = Case_Mappings__c.getAll();
            }
            
            return caseMappings;
        }
        
        private set;
    }
*/    
    public static Boolean createdCaseTrackersAndHistories
    {
        get
        {
            if(createdCaseTrackersAndHistories == null)
                createdCaseTrackersAndHistories = false;
            
            return createdCaseTrackersAndHistories;
        }
    }
/*    
    public static void addCaseTrackerAndCaseHistoryEntries(Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        if(!createdCaseTrackersAndHistories)
        {
            List<Case_Tracker__c> allCaseTrackersToInsert = getCaseTrackers(newMap.values());
            insert allCaseTrackersToInsert;
            
            //List<Case_History__c> allCaseHistoriesToInsert = getCaseHistories(newMap, oldMap);
            //insert allCaseHistoriesToInsert;
            
            createdCaseTrackersAndHistories = true;
        }
        
    }
    
    
    public static List<Case_Tracker__c> getCaseTrackers(List<Case> cases)
    {
        List<Case_Tracker__c> allCaseTrackersToInsert = new List<Case_Tracker__c>();
        for(Case c: cases)
        {
            if(  c.Time_Spent_Hours__c == null && c.Time_Spent_Minutes__c == null )
                continue;
            else
            {
                integer hrs = 0;
                integer minutes = 0;
                if(c.Time_Spent_Hours__c != null) hrs = Integer.valueOf(c.Time_Spent_Hours__c);
                if(c.Time_Spent_Minutes__c != null) minutes = Integer.valueOf(c.Time_Spent_Minutes__c);
                
                integer timeInMinutes = (hrs*60)+minutes;
                if(timeInMinutes > 0)
                {
                    Case_Tracker__c ct = new Case_Tracker__c();
                    ct.Case__c = c.id;
                    ct.Time_Spent_Minutes__c = timeInMinutes;
                    allCaseTrackersToInsert.add(ct);
                }
                
                c.Time_Spent_Hours__c = null;
                c.Time_Spent_Minutes__c = null;
                if(c.Total_Time_Spent__c == null) c.Total_Time_Spent__c = 0;
                c.Total_Time_Spent__c += timeInMinutes;
            }
        }
        
        return allCaseTrackersToInsert;
    }
    
    //set of statuses that are regarded as "Closed". Used by Trigger on Case to copy values from parent Case to chlid Case
    //when the case gets any of the statuses defined in this set
    public static Set<String> caseCloseStatuses
    {
        get
        {
            if(caseCloseStatuses == null)
            {
                caseCloseStatuses = new Set<String>();
                caseCloseStatuses.add(Constants.STATUS_CLOSED);
                caseCloseStatuses.add(Constants.STATUS_FIXED);
            }
            return caseCloseStatuses;
        }
        private set;
    }   
    
    public static void UpdateParentRelatedCaseCnt (Map<ID, Case> newMap, Map<ID, Case> oldMap, boolean casedelete)
    {   
        Case nParentCase;
        Case oParentCase;
        boolean nUpdate = false; 
        boolean oUpdate = false;
        
        if (!casedelete)
        {
            for(Case nc:  newMap.values())
            {
                if (nc.ParentId != null)            
                {
                    
                    list<Case> nChildCount = [Select Id from case where parentid = :nc.Parentid ];
                    nParentCase = [Select Id,Count_of_Related_Cases__c, status from case where id = :nc.Parentid ]; 
                    nParentCase.Count_of_Related_Cases__c = nChildCount.size();
                    if (nChildCount.size() == 0) nParentCase.Count_of_Related_Cases__c = 1;                     
                    nUpdate = true;
                    if (nParentCase.Status == 'Closed') {                  
                      nc.ParentId.addError('Can\'t Update, Parent Case is Already Closed');
                    }
                    else {
                      update nParentCase;
                    }   
                }
            }   
        }
                
        for(Case oc:  oldMap.values())
        {
            if (oc.ParentId != null)            
            {

                List<Case> oChildCount = [Select Id from case where parentid = :oc.Parentid ];
                oParentCase = [Select Id,Count_of_Related_Cases__c, status from case where id = :oc.Parentid ];
                oParentCase.Count_of_Related_Cases__c = oChildCount.size();
                if (casedelete) oParentCase.Count_of_Related_Cases__c -=1;
                oUpdate = true;                   
                if (oParentCase.Status == 'Closed') {        
                  try {
                    update oParentCase;
                  }
                  catch(Exception e){    
                    //Allows for existing cases (rare) where the case is incorrectly 
                    //assigned to a parent case that is closed and the case needs to be 
                    //unassigned from the patrent.              
                  }
                }
                else {
                  update oParentCase;
                }   
            }
        }
    }
    
    public static Map<String, RecordType> recordTypeCaseMap
    {
        get
        {
            if(recordTypeCaseMap == null)
            {
                recordTypeCaseMap = GenericServices.getRecordTypesNameMapBySObject('Case');
            }
            return recordTypeCaseMap;
        }
        
        private set;
    }
    
    public static void updateParentCaseAttachmentNotes(list<case> cases, string name)
    {          
      map<ID,User>case_user = new map<ID,User>();
        list<Case> ParentCase;
        list<User> puser;
        string message;
        string user_email;
        string CaseNumber;
        string userID = ' ';
        boolean EmailEnabled;
        
        for(SendEmailEnabled__c se: [Select Enabled__c from SendEmailEnabled__c])
      EmailEnabled = se.Enabled__c;

        CaseComment ParentComment = new CaseComment(); 
        
        for (User us: [Select ID, Email, Name, isActive from User where isActive = true and UserType = 'Standard'])
      {
          case_user.put(us.id, us);
      }    
        
        for(Case cs:cases)
        {
          if(cs.RecordTypeId == CaseServices.recordTypeCaseMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id || 
              cs.RecordTypeId == CaseServices.recordTypeCaseMap.get('Internal_L3_Case').id) 
          {
              CaseNumber = cs.CaseNumber;
              ParentComment.ParentId = cs.Id;
              ParentComment.CommentBody = 'Attachment '+name+' added by '+UserInfo.getName()+' for Parent Case '+CaseNumber;    
              message = ParentComment.CommentBody;
              if(cs.Status != 'Closed')
              {
                  TriggerMonitor.ExecutedTriggers.add('CaseCommentTrigger');
                  insert ParentComment;
                  //If the User is the Parent Case Owner, then the email should not be sent
                  if(cs.OwnerId != UserInfo.getUserId())
                      userID = cs.OwnerId;
              }
              else
              {
                  message = 'Attachment added to Case '+CaseNumber+' but could not add comments because status is closed';
                  userID = UserInfo.getUserId();
              }
          }   
          else
          {   
              ParentCase = [Select ID, CaseNumber, Status, OwnerID from Case where ID=:cs.ParentId];
        
              if(ParentCase.size() > 0)
              {
                  for(Case ps: ParentCase)
                  {
                    if(ps.Status != 'Closed')
                    {
                        CaseNumber = cs.CaseNumber;
                        ParentComment.ParentId = ps.Id;
                        ParentComment.CommentBody = 'Attachment '+name+' added by '+UserInfo.getName()+' for Child Case '+CaseNumber+' - Parent Case '+ps.CaseNumber;
                        message = ParentComment.CommentBody;
                        TriggerMonitor.ExecutedTriggers.add('CaseCommentTrigger');
                        insert ParentComment;
                
                        userID=ps.OwnerId;         
                    }
                    else
                    {
                    CaseNumber = cs.CaseNumber;
                    userID = UserInfo.getUserId();
                    message = 'Attachment added to Child Case but could not add comments to closed Parent Case '+ps.CaseNumber;
                    }
                  }
                }
            }
        }
        //puser = [Select Email, Alias, IsActive from User where ID=:userID];
         
        if(userID.equals(' '))
          return;
        
        if(case_user.containskey(userID))
        {
          user_email = case_user.get(userID).Email;
           if(EmailEnabled)
           {
             MailerUtils.sendMailParentOwner(message, user_email, CaseNumber);   
             SystemLogEmailCount.checkSystemLogEmailCount('CaseAttachment');
           }
        }  
        /*if(!case_user.containskey(userID))
      {
          string userName = UserInfo.getUserName();
            user_email = case_user.get(UserInfo.getUserID()).Email;
            message = 'Warning, Owner for Case '+CaseNumber+' is not Active!!';  
      }
        else
          user_email = case_user.get(userID).Email;*/
/*AA>    }
    
  public static void updateCaseComments(list<case> cases, string comment, boolean publish)
    {
        map<ID,User>case_user = new map<ID,User>();
        set<string> ParentCaseIDs = new set<string>();
        set<string> CaseIDs = new set<string>();
        list<Case> NotifyCase = new list<Case>();
        list<CaseComment> CaseCommentInsert = new list <CaseComment>();
        string url;
        string message;
        string CaseNumber;
        string CaseOwnerID;
        string PrevOwnerID = '';
        
        string [] messages = new string[]{};
        string [] CaseNumbers = new string[]{};
        string [] Emails = new string[]{};
        Integer EmailCount = 0;
        boolean EmailEnabled;
      
        for(SendEmailEnabled__c se: [Select Enabled__c from SendEmailEnabled__c])
      EmailEnabled = se.Enabled__c;
      
      for (User us: [Select ID, Email, Name from User where IsActive = true and UserType = 'Standard'])
      {
          case_user.put(us.id, us);
      }

      for(Environment__c env: Environment__c.getall().values())
      {
          if (env.Value__c == 'Sandbox')
            url = 'https://cs12.salesforce.com/';
          else
            url = 'https://na1.salesforce.com/';
      }
      
      for(Case cs: cases)
        {
             if(cs.RecordTypeId == CaseServices.recordTypeCaseMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id ||
              cs.RecordTypeId == CaseServices.recordTypeCaseMap.get('Internal_L3_Case').id)
          {
              if(publish && cs.Status != 'Closed' && case_user.containskey(cs.OwnerID))
              {
                ParentCaseIDs.add(cs.Id);
                CaseNumber = cs.CaseNumber;
                CaseOwnerID = cs.OwnerId;
              }
          }
          /*else
          {
              if(cs.Status != 'Closed' && cs.ParentId != null && case_user.containskey(cs.ownerID))
              {
                CaseIDs.add(cs.ParentID);
                CaseNumber = cs.CaseNumber;
                CaseOwnerID = cs.OwnerId;
              }
      }*/
/*AA>        }
      
        //Child Cases
        if(!ParentCaseIDs.isEmpty())
        {
          NotifyCase = [Select ID, CaseNumber, OwnerId from Case where ParentID in: ParentCaseIDs and Status != 'Closed' ORDER BY OwnerID];
      
          system.debug('\n\nNotifyCase='+NotifyCase+'\n');
          
          for(Case nc:NotifyCase)
          {
             if(case_user.containskey(nc.OwnerID))
            {
                CaseComment comm = new CaseComment();
                comm.ParentId = nc.Id;
                comm.CommentBody = 'Comment from Parent Case ('+CaseNumber+') Owner '+case_user.get(CaseOwnerID).Name+': '+comment;
                message = comm.CommentBody;
                message+= '<br><br><a href = '+url+nc.Id+'>Link to Child Case '+nc.CaseNumber+'</a>';
                CaseCommentInsert.add(comm);
          
                if(PrevOwnerID != string.valueOf(nc.OwnerId))
                {
                  PrevOwnerID = nc.OwnerId;
                  messages.add(message);
                  Emails.add(case_user.get(nc.OwnerID).Email);
                  Casenumbers.add(Casenumber);
                  EmailCount++;
                  //MailerUtils.sendMailCaseOwner_Comment(message, case_user.get(nc.OwnerID).Email, Casenumber);
                  if(EmailEnabled)  
                    SystemLogEmailCount.checkSystemLogEmailCount('CaseComment');
                }
            }          
          }
      
          if(!CaseCommentInsert.isEmpty())
          {
            TriggerMonitor.ExecutedTriggers.add('CaseCommentTrigger');      
              insert CaseCommentInsert;
              if(EmailEnabled)
          MailerUtils.sendMailCaseOwner_CommentorStatus(messages, Emails, Casenumbers, EmailCount, 'New Comment added to Case ');
          }
        }
        //Parent Cases
        /*else if(!CaseIDs.isEmpty())
        {
          
          NotifyCase = [Select ID, CaseNumber, OwnerId from Case where ID in: CaseIDs and Status != 'Closed'];
      
      system.debug('\n\nNotifyCase='+NotifyCase+'\n');
            
          for(Case nc:NotifyCase)
          {
              if (case_user.containskey(nc.OwnerID))
              {
                system.debug('\n\ncase_user.get(nc.OwnerID).Email='+case_user.get(nc.OwnerID).Email+'\n');
                
                CaseComment comm = new CaseComment();
                comm.ParentId = nc.Id;
                comm.CommentBody = 'Comment from Child Case ('+CaseNumber+') Owner '+case_user.get(CaseOwnerID).Name+': '+comment;
                message = comm.CommentBody;
                message+= '<br><br><a href = '+url+nc.Id+'>Link to Parent Case '+nc.CaseNumber+'</a>';
                CaseCommentInsert.add(comm);
                //MailerUtils.sendMailCaseOwner_Comment(message, case_user.get(nc.OwnerID).Email, CaseNumber);
              }
          }
         
           if(!CaseCommentInsert.isEmpty())
           {
             TriggerMonitor.ExecutedTriggers.add('CaseCommentTrigger');  
             insert CaseCommentInsert;
           }
        }*/
/*AA>        else
          return;
    }
    
    public static void notifyCaseStatusChange(Map<ID, Case> newCaseMap, Map<ID, Case> oldCaseMap)
    {
        map<ID,User>case_user = new map<ID,User>();
        set<string> ParentCaseIDs = new set<string>();
        set<string> CaseIDs = new set<string>();
        list<Case> NotifyCase = new list<Case>();
        string CaseNumber = '';
        string Status = '';
        string message = '';
        string PrevOwnerID = '';
        string url;
        
        string [] messages = new string[]{};
        string [] CaseNumbers = new string[]{};
        string [] Emails = new string[]{};
        Integer EmailCount = 0;
        boolean EmailEnabled;
      
        for(SendEmailEnabled__c se: [Select Enabled__c from SendEmailEnabled__c])
      EmailEnabled = se.Enabled__c;
      
        
        for(Case cs: newCaseMap.values())
        {     
        if(cs.D1request__c != null)
          return;
        }
        
      for (User us: [Select ID, Email, Name from User where IsActive = true and UserType = 'Standard'])
      {
          case_user.put(us.id, us);
      }
    
      for(Environment__c env: Environment__c.getall().values())
      {
          if (env.Value__c == 'Sandbox')
            url = 'https://cs12.salesforce.com/';
        else
          url = 'https://na1.salesforce.com/';
      }
      
        for(Case cs: newCaseMap.values())
        {  
          system.debug('\n\ncs.id='+cs.id+'\n');
          system.debug('\n\ncs.Status='+cs.Status+'\n');
          system.debug('\n\noldCaseMap.get(cs.id).Status='+oldCaseMap.get(cs.id).Status+'\n');
        
          if(cs.Status != oldCaseMap.get(cs.id).Status)
          {
              if(cs.RecordTypeId == CaseServices.recordTypeCaseMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id ||
                  cs.RecordTypeId == CaseServices.recordTypeCaseMap.get('Internal_L3_Case').id)
              {
                  ParentCaseIDs.add(cs.Id);
                  Status = cs.Status;
                  CaseNumber = cs.CaseNumber;
              }
                else
                {
                  if(cs.ParentId != null)
                  {
                      CaseIDs.add(cs.ParentID);
                      Status = cs.Status;
                      CaseNumber = cs.CaseNumber;
                  }
                }
          }
        }
      
      //Child Cases
      if(!ParentCaseIDs.isEmpty())
      {
          system.debug('\n\nParentCaseIDs='+ParentCaseIDs+'\n');
      
          NotifyCase = [Select ID, CaseNumber, Status, OwnerId from Case where ParentID in: ParentCaseIDs and Status != 'Closed' ORDER BY OwnerID LIMIT 10];
    
          if(NotifyCase.isEmpty())
            return;
        
          for(Case nc: NotifyCase)
          {
            if(case_user.containskey(nc.OwnerID))
            {
                if(PrevOwnerID != string.valueOf(nc.OwnerId) && EmailEnabled)
                {
                  PrevOwnerID = nc.OwnerId;
                  message = 'Notification for Case: '+nc.CaseNumber+'<br>Parent Case: '+CaseNumber+' Status changed to: '+Status+'<br>';
                  message+= '<br><a href = '+url+nc.Id+'>Link to Case '+nc.CaseNumber+'</a>';
                  Emails.add(case_user.get(nc.OwnerID).Email);
                  messages.add(message);
                  Casenumbers.add(Casenumber);
                  EmailCount++;
                  //MailerUtils.sendMailCaseOwner_Status(message, case_user.get(nc.OwnerID), CaseNumber);
                  SystemLogEmailCount.checkSystemLogEmailCount('CaseStatusChange');
                }
            }
          }
          
          if(EmailCount > 0)
            MailerUtils.sendMailCaseOwner_CommentorStatus(messages, Emails, Casenumbers, EmailCount, 'Status change on Case ');
          
          TriggerMonitor.ExecutedTriggers.add('CaseTrigger');
    }
      
        //Parent Cases
        else if(!CaseIDs.isEmpty())
        {
            NotifyCase = [Select ID, CaseNumber, Status, OwnerId from Case where ID in: CaseIDs and Status != 'Closed'];
      
            if(NotifyCase.isEmpty())
                return;
        
            for(Case nc: NotifyCase)
            {
                system.debug('\n\nStatus='+Status+'\n');
          
                if (case_user.containskey(nc.OwnerID) && !Status.equals('Escalated to L3') && EmailEnabled)
                {
                  message = 'Notification for Case: '+nc.CaseNumber+'<br>Child Case: '+CaseNumber+' Status changed to: '+Status+'<br>';
                  message+= '<br><a href = '+url+nc.Id+'>Link to Case '+nc.CaseNumber+'</a>';
                  Emails.add(case_user.get(nc.OwnerID).Email);
                  messages.add(message);
                  Casenumbers.add(Casenumber);
                  EmailCount++;
                  //MailerUtils.sendMailCaseOwner_Status(message, case_user.get(nc.OwnerID), CaseNumber);
                  SystemLogEmailCount.checkSystemLogEmailCount('CaseStatusChange');
                }
            }
            
            if(EmailCount > 0)
              MailerUtils.sendMailCaseOwner_CommentorStatus(messages, Emails, Casenumbers, EmailCount, 'Status change on Case ');
                    
            TriggerMonitor.ExecutedTriggers.add('CaseTrigger');
        }
    
        else
          return;
    }
/**/
}