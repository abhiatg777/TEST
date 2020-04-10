global class BatchDeleteOrphanedGuestFiles implements Database.Batchable<SObject>, Schedulable
{
    public static final string jobName = 'BatchDeleteOrphanedGuestFiles';
    
    //Constructors
    global BatchDeleteOrphanedGuestFiles() {}
    
    global void execute(SchedulableContext sc)
    {
        SCG_Utils.RunJob(new BatchDeleteOrphanedGuestFiles(), jobName);
    }
   
    //Start
    global database.queryLocator start(Database.BatchableContext bc) 
    {
        Integer i=-10;
        Id ownerId = UserInfo.getUserId();        
            
        if(!Test.isRunningTest())
        { 
            SCG_Setting__mdt metaRecord = SCG_Utils.getSetting('Support');
            
            //pull the interval
            i = metaRecord.Orphan_File_Deletion_Interval__c.IntValue();
            ownerId = metaRecord.Customer_Community_Guest_User_ID__c;
        }

        return Database.getQueryLocator([
            SELECT Id
            FROM ContentDocument
            WHERE
            OwnerId =: ownerId
            AND 
            SystemModStamp<:DateTime.now().addMinutes(-i) 
            ]);
    }
    
    //Execute
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        delete scope;
        
    }
    
    //Finish
    global void finish(Database.BatchableContext bc)
    {
		SCG_Utils.ScheduleJob(new BatchDeleteOrphanedGuestFiles(), jobName);
    }
}