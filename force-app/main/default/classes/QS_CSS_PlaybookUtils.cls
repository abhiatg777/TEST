public class QS_CSS_PlaybookUtils {
    private Map<Id,QS_CSS_Customer_Alert__c> mCustomerAlerts = new Map<Id,QS_CSS_Customer_Alert__c>();
    private Map<Id,QS_Playbook__c> mPlaybooks = new Map<Id,QS_Playbook__c>();
    private Map<Id,QS_Playbook_Task__c> mPBTasks = new Map<Id,QS_Playbook_Task__c>();
    public Map<Id,Integer> mPBTaskToTotalDays = new Map<Id,Integer>();
    public Map<Id,string> mUserIdToTimeZoneKey = new Map<Id,String>();
    
    public void SetTotalTaskDays(List<QS_Playbook_Task__c> Tasks)
    {
        //get the playbook ids
        Set<Id> playbookIds = new Set<Id>();
        for(QS_Playbook_Task__c pbTask : Tasks)
        {
            playbookIds.add(pbTask.QS_Playbook__c);
        }
        if(playbookIds.isEmpty()) return;
        //now, get the playbooks and tasks
        List<QS_Playbook__c> playbooks = [
            select id
            ,QS_Total_Task_Days__c
            ,(
                select id
                ,QS_Days_After__c
                ,QS_Dependent_Task__c
                ,QS_Playbook__c
                from QS_Playbook_Tasks__r
                
            )
            from QS_Playbook__c 
            where id=:playbookIds
        ];
        Integer newMax=0;
        List<QS_Playbook__c> toUpdate = new List<QS_Playbook__c>();
        for(QS_Playbook__c playbook : playbooks)
        {
            // playbook
            setMaps(playbook.QS_Playbook_Tasks__r);
            newMax=setTotalDays();
            if(newMax!=playbook.QS_Total_Task_Days__c)
            {
                playbook.QS_Total_Task_Days__c=newMax;
                toUpdate.add(playbook);
            }
        }
        if(!toUpdate.isEmpty())
        {
            QS_VCG_Utils.setExecuted('QS_PlaybookTrigger');
            update toUpdate;
            QS_VCG_Utils.resetExecuted('QS_PlaybookTrigger');
        }
    }
    private void setMaps(List<QS_Playbook_Task__c> playbookTasks)
    {
        mPBTasks=new Map<Id,QS_Playbook_Task__c>(playbookTasks);       
    }
    private Integer setTotalDays()
    {
        Integer maxDays=0,currentMax=0;
        //loop through each and get the days for each task
        for(QS_Playbook_Task__c playbookTask : mPBTasks.values())
        {
            maxDays=setTotalDays(playbookTask.Id);
            mPBTaskToTotalDays.put(playbookTask.Id,maxDays);
            if(maxDays>currentMax)
            {
                currentMax=maxDays;
            }
        }
        return currentMax;
    }
    private integer setTotalDays(Id theId)
    {        
        QS_Playbook_Task__c task=mPBTasks.get(theId);
        if(task.QS_Days_After__c==null) task.QS_Days_After__c=0;
        Integer currentCount=task.QS_Days_After__c.intValue();
        if(task.QS_Dependent_Task__c!=null)
        {
            currentCount+=setTotalDays(task.QS_Dependent_Task__c);
        }
        return currentCount;
    }
    //call this from PB for running with a batch class
    public void CreateTasksJob(List<QS_CSS_Customer_Alert__c> CustomerAlerts) {        
        //first get a list of ca ids that need tasks
        Set<Id> caIds = getCAIdsWithPlaybooks(CustomerAlerts,false);
        
        if(caIds.isEmpty()) return;         
        
        //run the job
        QS_VCG_Utils.RunJob(new QS_CSS_BatchPlaybookCreateTasks(caIds), QS_CSS_BatchPlaybookCreateTasks.JobName);
        
    }
    //call this from PB for running without a batch class
    public void CreateTasks(List<QS_CSS_Customer_Alert__c> CustomerAlerts) {
        //first get a list of ca ids that need tasks
        Set<Id> caIds = getCAIdsWithPlaybooks(CustomerAlerts,true);
        if(caIds.isEmpty()) return;
        
        for(Id caId : caIds)
        {
            CreateTasks(caId);
        }        
    }
    private Set<Id> getCAIdsWithPlaybooks(List<QS_CSS_Customer_Alert__c> CustomerAlerts,boolean doMaps)
    {        
        //doMaps is only needed if it's getting called from a PB and not for a batch class
        //otherwise, the batch class will not have access to the maps and there's no
        //need to soql
        Set<Id> accountIds = new Set<Id>();
        Set<Id> playbookIds = new Set<Id>();
        //first get a list of ca ids that need tasks
        Set<Id> caIds = new Set<Id>();
        if(CustomerAlerts==null || CustomerAlerts.isEmpty()) return caIds;
        for(QS_CSS_Customer_Alert__c customerAlert : CustomerAlerts)
        {
            if(customerAlert.QS_Playbook__c!=null){
                caIds.add(customerAlert.Id);
                if(doMaps)
                {
                    if(!playbookIds.contains(customerAlert.QS_Playbook__c)) playbookIds.add(customerAlert.QS_Playbook__c);
                    if(customerAlert.QS_Account__c!=null && !accountIds.contains(customerAlert.QS_Account__c)) accountIds.add(customerAlert.QS_Account__c);
                }
                
            }
            mCustomerAlerts.put(customerAlert.Id,customerAlert);            
        }
        if(doMaps)
        {
            setAccountToUsers(accountIds);
            setPlaybooks(playbookIds);            
        }
        return caIds;
    }
    private string accountMappingSOQL;
    private Map<string,string> mOwnerMapping;
    private Map<string,string> mAccountToOwners=new Map<string,string>();
    private Set<Id > accountOwnersProcessed=new Set<Id >();
    private void setAccountToUsers(Set<Id> accountIds){
        if(accountIds.isEmpty()) return;
        Set<Id> toFind = new Set<Id>(accountIds);
        //toFind.removeAll( mAccountToUsers.keySet());
        toFind.removeAll(accountOwnersProcessed);
        if(toFind.isEmpty()) return;
        if(accountMappingSOQL==null)
        {
            //first get all of the records from 
            //the mapping
            accountMappingSOQL = 'SELECT Id ';
            mOwnerMapping = new Map<string,string> ();
            for(QS_Playbook_Task_Owner_Mapping__c aMap : [select 
                                                          QS_Field_Mapping__c
                                                          ,QS_Playbook_Owner__c
                                                          from QS_Playbook_Task_Owner_Mapping__c])
            {
                mOwnerMapping.put(aMap.QS_Playbook_Owner__c,aMap.QS_Field_Mapping__c);
                accountMappingSOQL=accountMappingSOQL+','+aMap.QS_Field_Mapping__c +' ';
                
            }
            accountMappingSOQL=accountMappingSOQL+'FROM Account where Id =:toFind ';
        }
        QS_VCG_Utils vuTils = new QS_VCG_Utils();
        for(Account theAccount : Database.query(accountMappingSOQL))//[select id,QS_CSM__c from Account where Id=:toFind])
        {
            
            accountOwnersProcessed.add(theAccount.Id);
            for(string ownerPicklist : mOwnerMapping.keyset())
            {
                //right now this will fail hard if the field is not 
                //populated. Might change this to throw a nice error
                
                object theFieldVal=vuTils.SObjectValueHelper(mOwnerMapping.get(ownerPicklist), theAccount, null, true);
                string toUse;
                if(theFieldVal!=null)
                {
                    toUse=string.valueof(theFieldVal);
                }
                mAccountToOwners.put(theAccount.Id
                                     +ownerPicklist,
                                     toUse);
                
            }
        }
        
    }
    
    private void setPlaybooks(Set<Id> playbookIds){
        if(playbookIds.isEmpty()) return;
        Set<Id> toFind = new Set<Id>(playbookIds);
        toFind.removeAll( mPlaybooks.keySet());
        if(toFind.isEmpty()) return;
        // if(toSearch)
        for(QS_Playbook__c thePlaybook : 
            [
                select id
                ,QS_Business_Days_Only__c
                ,QS_Business_Hours__c
                ,QS_Total_Task_Days__c
                ,(
                    select id
                    ,QS_Assigned_To_Override__c
                    ,QS_Assigned_To__c
                    ,QS_Comments__c
                    ,QS_Days_After__c
                    ,QS_Dependent_Task__c
                    ,QS_Playbook__c
                    ,QS_Priority__c
                    ,QS_Reminder_Days_Before__c
                    ,QS_Reminder_Time__c
                    ,QS_Subject__c
                    ,QS_Type__c
                    from QS_Playbook_Tasks__r
                    
                )
                from QS_Playbook__c 
                where id=:toFind
            ])
        {
            mPlaybooks.put(thePlaybook.Id,thePlaybook);
        }
    }
    private void setCustomerAlerts(Set<Id> customerAlertIds){
        if(customerAlertIds.isEmpty()) return;
        Set<Id> toFind = new Set<Id>(customerAlertIds);
        toFind.removeAll( mCustomerAlerts.keySet());
        if(toFind.isEmpty()) return;
        for(QS_CSS_Customer_Alert__c theAlert : 
            [
                SELECT
                Id
                ,QS_Account__c
                ,QS_CSM__c
                ,QS_Playbook__c
                FROM
                QS_CSS_Customer_Alert__c
                WHERE Id=:customerAlertIds
            ])
        {
            mCustomerAlerts.put(theAlert.Id,theAlert);
        }
    }
    //call this from job
    public void CreateTasks(Id CustomerAlertId) 
    {
        setCustomerAlerts(new Set<Id>{customerAlertId});        
        QS_CSS_Customer_Alert__c customerAlert =mCustomerAlerts.get(CustomerAlertId);
        
        if(customerAlert.QS_Playbook__c==null) return;
        setPlaybooks(new Set<Id>{customerAlert.QS_Playbook__c});
        setAccountToUsers(new Set<Id>{customerAlert.QS_Account__c});
        QS_Playbook__c playbook = mPlaybooks.get(customerAlert.QS_Playbook__c);      
        if(playbook==null) return;
        setMaps(playbook.QS_Playbook_Tasks__r);    
        
        setTotalDays();
        
        Id defaultOwnerId=customerAlert.QS_CSM__c;
        
        //now loop and create tasks        
        List<Task> toInsert = new List<Task>();        
        for(QS_Playbook_Task__c playbookTask : mPBTasks.values())
        {
            Task newTask = new Task();
            //set owner first as we will need to determine timezone    
            newTask.ownerid=defaultOwnerId;
            if(playbookTask.QS_Assigned_To_Override__c!=null)
            {
                newTask.OwnerId= playbookTask.QS_Assigned_To_Override__c;
            }
            else if(playbookTask.QS_Assigned_To__c!=null)
            {
                newTask.OwnerId=mAccountToOwners.get(customerAlert.QS_Account__c+playbookTask.QS_Assigned_To__c);
                
            }
            if(newTask.OwnerId==null)
            {
                throw new QS_VCG_Utils.ApplicationException('No owner found for CTA ' + CustomerAlertId + ' and playbook task ' + playbookTask.Id);
            }
            setTaskDates(newTask,playbook,playbookTask,datetime.now());           
            //Set other fields here (subject, desc, etc..)
            newTask.Description = playbookTask.QS_Comments__c;
            newTask.Priority = playbookTask.QS_Priority__c;
            newTask.Subject = playbookTask.QS_Subject__c;
            newTask.Type = playbookTask.QS_Type__c;
            newTask.WhatId=CustomerAlertId;                                    
            toInsert.add(newTask);
        }
        
        if(!toInsert.isEmpty())
        {
            QS_VCG_Utils.setExecuted('TaskTrigger');
            insert toInsert;
            QS_VCG_Utils.resetExecuted('TaskTrigger');
        }
    }
    //dtToUse is usually the current user's date/time
    //It's passed in for testing different date/time
    public void SetTaskDates(Task newTask,QS_Playbook__c playbook,QS_Playbook_Task__c playbookTask,DateTime dtToUse)
    {
        //put this into a map at the top so it doesn't soql every time
        if(!mUserIdToTimeZoneKey.containsKey(newTask.OwnerId))
        {
            mUserIdToTimeZoneKey.put(newTask.OwnerId,[SELECT TimeZoneSidKey from User where id = :newTask.OwnerId].TimeZoneSidKey);
        }
        Timezone tz = Timezone.getTimeZone(mUserIdToTimeZoneKey.get(newTask.OwnerId));      
        //this will give you the offset from the timezone of the owner to GMT
        Integer offset = tz.getOffset(dtToUse);
        //make the offset minutes
        offset=offset/60000;
        //system.debug('Offset ' + offset + ' for ' + tz.getDisplayName());        
        DateTime gmtDateTime = dtToUse;    
        
        //Set due date here
        Integer daysUntilDue=mPBTaskToTotalDays.get(playbookTask.Id);
        
        //if there's businesshours specified use it otherwise don't
        //the date will get stored as date (doesn't use gmt) so 
        //get the date specific to the user 
        //        system.debug(daysUntilDue + ' ' + gmtDateTime);
        if(playbook.QS_Business_Days_Only__c)
        {                                                
            //get the next business hour if the current is not a business hour
            //So, SF BusinessHours.add function will literally add that many hours to a datetime.
            //So, if you have business hours from 8-4pm and you want it to go forward just one day, you cannot
            //add 1 day as 24 hours as the function will traverse 3 days because there are only 8 hours
            //in each day. To work around this, you must loop through each "day" by using nextStartDate per day
            long i=0;
            //it might be that the current gmt is not on a business hours so first move to business hours
            system.debug('Original gmtDateTime ' + gmtDateTime);
            gmtDateTime=BusinessHours.nextStartDate(playbook.QS_Business_Hours__c, gmtDateTime);
            system.debug('New gmtDateTime ' + gmtDateTime);
            //now loop through and add 1 day. Use a while vs a do loop b/c they
            //might have made the day due the same day
            while (i<daysUntilDue)
            {                
                gmtDateTime=gmtDateTime.addDays(1);
                gmtDateTime=BusinessHours.nextStartDate(playbook.QS_Business_Hours__c, gmtDateTime);
                i++;
                //                system.debug('New gmtDateTime ' + gmtDateTime + ' ' + i + ' OF ' + daysUntilDue);
            }            
            //            system.debug(daysUntilDue + ' ' + gmtDateTime);
        }
        else
        {
            gmtDateTime=gmtDateTime.addDays(daysUntilDue);
        }
        //now offset it
        //newTask.description+='\nunOffset' + String.valueof(gmtDateTime);
        Date activityDate=gmtDateTime.date();
        //offset to the timezone of the actual owner.
        //behind the scenes, the datetime on the variable, is set to GMT
        //So adding the offset takes it to the timezone of the actual owner
        //not the current running user so we can use .date()
        //.date() returns the date of the running user and without the offset it
        //could be off
        gmtDateTime=gmtDateTime.addMinutes(1*offset);
        newTask.ActivityDate=gmtDateTime.date();   
        //newTask.description+='\nOffset' + String.valueof(gmtDateTime);
        
        //now set the reminder 
        if(playbookTask.QS_Reminder_Days_Before__c!=null)
        {
            //first unoffset the gmt date back to gmt
            gmtDateTime=gmtDateTime.addMinutes(-1*offset);
            //newTask.description+='\nUnoffset' + String.valueof(gmtDateTime);
            Integer reminderDays=playbookTask.QS_Reminder_Days_Before__c.intValue();
            gmtDateTime = gmtDateTime.addDays(-1 * reminderDays);
            //newTask.description+='\nMinus reminder days' + String.valueof(gmtDateTime);
            //set the reminder hour to be the same as the activity date
            //unless there's one provided
            Time reminderTime=gmtDateTime.timeGmt();
            //Integer reminderHour=gmtDateTime.hourGmt();
            //newTask.description+='\nreminder hour gmt ' + String.valueof(gmtDateTime);
            if(playbookTask.QS_Reminder_Time__c!=null)
            {
                //get it from the record
                //reminderHour = Integer.valueOf(playbookTask.QS_Reminder_Time__c);
                reminderTime=playbookTask.QS_Reminder_Time__c;
            }
            //now create the time in Gmt
            //gmtDateTime=datetime.newInstanceGmt(gmtDateTime.dateGmt(), Time.newInstance(reminderHour, 0, 0, 0));
            gmtDateTime=datetime.newInstanceGmt(gmtDateTime.dateGmt(), reminderTime);
            //            system.debug('Original reminder ' + gmtDateTime);
            
            //now if there are business hours to adhere to get the next business hour if the current is not a business hour
            if(playbook.QS_Business_Days_Only__c)
            {
                //since this is a reminder, and following the business hours causes 
                //the reminder to be the same as the activity, go backwards until it doesn't
                //newTask.description+='\nactivityDate ' + String.valueof(activityDate);        
                integer i=0;
                do
                {
                    gmtDateTime=gmtDateTime.addDays(i);
                    gmtDateTime=BusinessHours.nextStartDate(playbook.QS_Business_Hours__c, gmtDateTime);    
                    //                    system.debug('New reminder ' + gmtDateTime + ' after ' + i + ' trying to get to ' + activityDate);
                    i=i-1;
                } while (activityDate<=gmtDateTime.date());
                
            }
            //now that we have the reminder date and time, offset to get
            //
            newTask.ReminderDateTime = gmtDateTime.addMinutes(1*offset);
        }      
    }

}