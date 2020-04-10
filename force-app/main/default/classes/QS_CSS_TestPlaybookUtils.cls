@IsTest
public class QS_CSS_TestPlaybookUtils {
   
    
      public static User getAdminUser(String adminName)
    {
        return getTestUser(adminName, 'System Administrator');
    }
    
    
        private static User getTestUser(String userName, String profileName)
    {
        String profileId;
        try
        {
            profileId = [SELECT Id FROM Profile WHERE Name like: '%'+profileName+'%' limit 1].Id;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(false, 'No profile exists with name '+ profileName);
        }
        UserRole r = new UserRole(name = 'Admin');
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        testUser.Alias = UserName.substring(0, 8);  
        testUser.Email = UserName+'@invalid.com';
        testUser.Username = UserName+'@invalid.com';
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        testUser.UserRoleId = r.Id;
        return testUser;    
    }
    
     static User testUser = getAdminUser(QS_VCG_Utils.Guid().replace('-',''));
    
    static QS_CSS_PlaybookUtils util = new QS_CSS_PlaybookUtils();

    @testSetup static void playbookSetup()
    {                        
        Account testAccount = new Account(
            Name = 'Test Account'
            ,QS_CSM__c=UserInfo.getUserId()
            
        );
        System.debug(testAccount);
        insert testAccount;
        
        QS_Playbook__c testPB = new QS_Playbook__c(
            Name = 'Test PB',
            QS_Total_Task_Days__c = 10
        );
        insert testPB;

        //to deploy to other orgs make sure the QS_Playbook_Owner__c 
        //value below matches one of the values found on the 
        //QS_Playbook_Owners value set. The one provide below is a default.
        QS_Playbook_Task_Owner_Mapping__c mapping = new QS_Playbook_Task_Owner_Mapping__c();
        mapping.QS_Field_Mapping__c='Parent.QS_CSM__c';
        mapping.QS_Playbook_Owner__c='Parent CSM';
        insert mapping;
        
        QS_Playbook_Task__c testPBTask = new QS_Playbook_Task__c(
            QS_Playbook__c = testPB.id,
            QS_Assigned_To_Override__c=UserInfo.getUserId(),
            QS_Days_After__c = 8,
            QS_Priority__c='High',
            QS_Subject__c = 'Test PBTask'
        );
        
        insert testPBTask;                                       
        
    }
    private static Account theAccount
    {
        get
        {
            return [select id,ownerid,parent.ownerid,parent.QS_CSM__c from account where Name='Test Account'];
        }
    }
    private static QS_Playbook__c thePlaybook
    {
        get
        {
            return [select id,QS_Business_Days_Only__c,QS_Business_Hours__c
                    ,(select id,QS_Assigned_To__c,QS_Assigned_To_Override__c from QS_Playbook_Tasks__r) from QS_Playbook__c];
        }
    }
/*    private static void debugDate(datetime thedate)
    {
        //keep in mind that: 
        //system.debug(dtToUse); //this shows in UTC
        //system.debug(string.valueOf(dtToUse)); //this converts to current timezone
        system.debug(thedate);    
        system.debug(string.valueOf(thedate));
    }
*/
    private static void testSetTaskDate(Task newTask
                                        ,QS_Playbook__c playbook
                                        ,QS_Playbook_Task__c playbookTask
                                        ,integer reminderDays
                                        ,integer dayToAssert
                                        ,integer reminderDayToAssert
                                        ,integer reminderHourToAssert
                                        ,string testType
                                        ,DateTime dtToUse)
    {
        testType=testType+'= ';
        newTask.ActivityDate=null;
        newTask.ReminderDateTime=null;    
        Date dtToAssert=date.newInstance(dtToUse.yearGmt(), dtToUse.monthGmt(), dayToAssert);
        if(reminderDays==null){
            playbookTask.QS_Reminder_Days_Before__c=null;            
        }
        else
        {
            playbookTask.QS_Reminder_Days_Before__c=reminderDays;                    
        }
        //DateTime dtToUse=datetime.newInstance(date.newInstance(2019, 01, 15), datetime.now().Time());
        system.debug('dtToUse ' + dtToUse);
        util.SetTaskDates(newTask, playbook, playbookTask,dtToUse);
        
        system.assertEquals(testType+dtToAssert, testType+newTask.ActivityDate);
        if(reminderDays==null)
        {
            system.assertEquals(null, newTask.ReminderDateTime);    
        }
        else
        {        
            
            DateTime dtExpected=datetime.newInstanceGmt(date.newInstance(dtToUse.yearGmt(), dtToUse.monthGmt(), reminderDayToAssert),Time.newInstance(reminderHourToAssert,0,0,0));
            DateTime dtActual=datetime.newInstanceGmt(newTask.ReminderDateTime.dateGmt(),newTask.ReminderDateTime.timeGmt());
//            debugDate(dtExpected);
//            debugDate(dtActual);
            system.assertEquals(testType+dtExpected,testType+dtActual);    
        }    
    }
    @isTest static void testSetTaskDates()
    {
        
        //behind the scenes any datetime variable has the utc value
        //keep in mind that: 
        //system.debug(dtToUse); //this shows in UTC
        //system.debug(string.valueOf(dtToUse)); //this converts to current timezone
        //From testing, BusinessHours.nextStartDate will take the gmt time given and find the next gmt business hours
        //Just remember that Business Hours have a timezone. So the hours returned are the next available for that timezone.
        //Based on all this, just use the current date for calculating everything
        
        //used https://www.worldtimebuddy.com/ to verify
        QS_Playbook__c playbook=thePlaybook;
        playbook.QS_Business_Hours__c=[SELECT Id FROM BusinessHours WHERE Name='QS Test Class Hours'].id;
        QS_Playbook_Task__c playbookTask=thePlaybook.QS_Playbook_Tasks__r[0];
        playbookTask.QS_Reminder_Days_Before__c=2;
        playbookTask.QS_Reminder_Time__c=time.newInstance(10, 0, 0, 0);
        integer daysUntilDue=10;
        playbookTask.QS_Subject__c='test';
        playbookTask.QS_Days_After__c=daysUntilDue;
        update playbookTask;
        util.mPBTaskToTotalDays.put(playbookTask.Id,daysUntilDue);
        Task newTask= new Task();
        testUser.TimeZoneSidKey='Europe/Dublin';
        insert testUser;
        newTask.OwnerId=testUser.Id; //set the owner that will have the different time zones
        //DateTime dtNow=datetime.newInstance(date.newInstance(2019, 01, 15), Time.newInstance(14, 0, 0, 0));// datetime.now().Time());
        DateTime dtNow=datetime.newInstanceGmt(date.newInstance(2019, 01, 15), Time.newInstance(20, 0, 0, 0));// datetime.now().Time());
                
        //Pacific Fiji asserts
        //fiji has offset of +12. 
        testUser.TimeZoneSidKey='Pacific/Fiji';
        update testUser;
        util.mUserIdToTimeZoneKey.put(newTask.OwnerId,testUser.TimeZoneSidKey);
        //no reminder,no business hours
        playbook.QS_Business_Days_Only__c=false;
        //fiji has offset of +12 on 2019.01.15 at 20pm GMT which is actually 2019.01.16 at 20am Fiji
        //So, 16+10=26
        testSetTaskDate(newTask,playbook,playbookTask,null,26,null,null,testUser.TimeZoneSidKey + ' - no reminder,no business hours',dtNow);
        //reminder,no business hours - Fiji 26th from above -2 days is 24. The 24th at 10am Fiji time is the 23rd at 22pm GMT
        testSetTaskDate(newTask,playbook,playbookTask,2,26,23,22,testUser.TimeZoneSidKey + ' - reminder,no business hours',dtNow);      
        //no reminder,business hours - 
        playbook.QS_Business_Days_Only__c=true;
        testSetTaskDate(newTask,playbook,playbookTask,null,29,null,null,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);      
        //reminder,business hours - the reminder should be 2 days before 29 but that's the 27th which is a weekend
        //and b/c we observe business hours it goes up 1 to 28. As for the hours, our test business hours are 8-5 CST
        //which 8CST=02 am Fiji on 2019.01.29
        testSetTaskDate(newTask,playbook,playbookTask,2,29,29,02,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);  

        //Dublin asserts
        testUser.TimeZoneSidKey='Europe/Dublin';
        update testUser;
        util.mUserIdToTimeZoneKey.put(newTask.OwnerId,testUser.TimeZoneSidKey);
        //no reminder,no business hours
        playbook.QS_Business_Days_Only__c=false;
        testSetTaskDate(newTask,playbook,playbookTask,null,25,null,null,testUser.TimeZoneSidKey + ' - no reminder,no business hours',dtNow);
        //reminder,no business hours - during 2019.01.15 Dublin has not offset from GMT so the reminder time is what it is 10 even in GMT        
        testSetTaskDate(newTask,playbook,playbookTask,2,25,23,10,testUser.TimeZoneSidKey + ' - reminder,no business hours',dtNow);      
        //no reminder,business hours 
        playbook.QS_Business_Days_Only__c=true;
        testSetTaskDate(newTask,playbook,playbookTask,null,29,null,null,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);      
        //reminder,business hours - the reminder should be 2 days before 29 but that's the 27th which is a weekend
        //and b/c we observe business hours it goes up 1 to 28. As for the hours, our test business hours are 8-5 CST
        //which 8CST=14 Dublin on 2019.01.28
        testSetTaskDate(newTask,playbook,playbookTask,2,29,28,14,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);      

        //GMT asserts
        testUser.TimeZoneSidKey='GMT';
        update testUser;
        util.mUserIdToTimeZoneKey.put(newTask.OwnerId,testUser.TimeZoneSidKey);
        //no reminder,no business hours
        playbook.QS_Business_Days_Only__c=false;
        testSetTaskDate(newTask,playbook,playbookTask,null,25,null,null,testUser.TimeZoneSidKey + ' - no reminder,no business hours',dtNow);
        //reminder,no business hours - GMT has no offset so it should be 10
        testSetTaskDate(newTask,playbook,playbookTask,2,25,23,10,testUser.TimeZoneSidKey + ' - reminder,no business hours',dtNow);      
        //no reminder,business hours 
        playbook.QS_Business_Days_Only__c=true;
        testSetTaskDate(newTask,playbook,playbookTask,null,29,null,null,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);      
        //reminder,business hours - the reminder should be 2 days before 29 but that's the 27th which is a weekend
        //and b/c we observe business hours it goes up 1 to 28. As for the hours, our test business hours are 8-5 CST
        //which 8CST=14 GMT on 2019.01.28
        testSetTaskDate(newTask,playbook,playbookTask,2,29,28,14,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);   
        
        //PDT asserts
        testUser.TimeZoneSidKey='America/Los_Angeles';
        update testUser;
        util.mUserIdToTimeZoneKey.put(newTask.OwnerId,testUser.TimeZoneSidKey);
        //no reminder,no business hours
        playbook.QS_Business_Days_Only__c=false;
        testSetTaskDate(newTask,playbook,playbookTask,null,25,null,null,testUser.TimeZoneSidKey + ' - no reminder,no business hours',dtNow);
        //reminder,no business hours - PDT has 7 hours offset plus Daylight = 8 so should be 02 in the am
        testSetTaskDate(newTask,playbook,playbookTask,2,25,23,2,testUser.TimeZoneSidKey + ' - reminder,no business hours',dtNow);      
        //no reminder,business hours 
        playbook.QS_Business_Days_Only__c=true;
        testSetTaskDate(newTask,playbook,playbookTask,null,29,null,null,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);      
        //reminder,business hours - the reminder should be 2 days before 29 but that's the 27th which is a weekend
        //and b/c we observe business hours it goes up 1 to 28. As for the hours, our test business hours are 8-5 CST
        //which 8CST=6 PST on 2019.01.28
        testSetTaskDate(newTask,playbook,playbookTask,2,29,28,06,testUser.TimeZoneSidKey + ' - no reminder,business hours',dtNow);                   
    }
    
    
    private static List<Task> theTasks{
        get
        {
            return [select id,OwnerId from task];
        }
        set;
    }
    @isTest static void testCA(){
        QS_CSS_Customer_Alert__c testCA = new QS_CSS_Customer_Alert__c(
            QS_Playbook__c = thePlaybook.id,
            QS_Account__c = theAccount.id
        );
        
        Test.startTest();
        //if the PB is active this will code coverage the PB code
        //but we won't know if it's active
        insert testCA;
        //so just assume it's active and delete any tasks created
        delete theTasks;
        //now call directly as if using PB withOUT job
        QS_CSS_PlaybookCreateTasksInvocable.CreateTasks(new List<QS_CSS_Customer_Alert__c>{testCA});
        system.assertEquals(theTasks.size(),1);
        system.assertEquals(theTasks[0].OwnerId,UserInfo.getUserId());
        delete theTasks;        
        //now update the assigned to and see if it works        
        insert testUser;
        Account testParent = new Account(
            Name = 'Test Parent Account'
            ,QS_CSM__c=UserInfo.getUserId()
            
        );
        testParent.QS_CSM__c=testUser.Id;
        insert testParent;
        Account childAccount=theAccount;
        childAccount.ParentId=testParent.Id;
        update childAccount;
        QS_Playbook_Task__c taskTemplate= thePlaybook.QS_Playbook_Tasks__r[0];
        taskTemplate.QS_Assigned_To_Override__c=null;
        taskTemplate.QS_Assigned_To__c=[select QS_Playbook_Owner__c FROM QS_Playbook_Task_Owner_Mapping__c LIMIT 1].QS_Playbook_Owner__c;
        update taskTemplate;
        
        QS_CSS_PlaybookCreateTasksInvocable.CreateTasks(new List<QS_CSS_Customer_Alert__c>{testCA});
        system.assertEquals(theTasks.size(),1);
        system.assertEquals(theTasks[0].OwnerId,testUser.Id);
        
        //now call directly as if using PB WITH job
        QS_CSS_PlaybookCreateTasksJobInvocable.CreateTasks(new List<QS_CSS_Customer_Alert__c>{testCA});
        Test.stopTest();
    }
    
    
   
}