public class CaseTriggerHandler {

    public static void countBugCases(Map<Id, Case> oldMap, Map<Id, Case> newMap)
    {
        Set<Id> bugIds = new Set<Id>();
        Set<Id> countUpdated = new Set<Id>();
        List<AggregateResult> totalCaseCount = new List<AggregateResult>();
        Map<Id, Bug__c> toUpdate = new Map<Id, Bug__c>();
        if(newMap == null) return;
        //Loop through all cases and add any Bug Ids that were affected
        //Have to get bug Ids from before and after the update to bug records that lost cases
        for(Case c : newMap.values())
        {
            //If the Bug value did not change on the case record, skip
            if(oldMap!= null && c.Bug__c == oldMap.get(c.Id).Bug__c)
                continue;
            
            //Inserted Case/bug added to case/bug value changed on case object
            if(c.Bug__c != null)
                bugIds.add(c.Bug__c);
            
            //Updated Case, case no longer related to a bug
            //need this to update the case count on any bug records that lost case(s)
            if(oldMap!= null && oldMap.get(c.Id).Bug__c != null && c.Bug__c != oldMap.get(c.Id).Bug__c)
                bugIds.add(oldMap.get(c.Id).Bug__c);
        }
        //system.debug('bugIds = ' + bugIds);

        if(bugIds.isEmpty() || bugIds == null) return;
        //Aggregate list only includes Bug Ids with related cases after the update        
        //Number of cases grouped by Bug Id
        totalCaseCount = [SELECT Count(Id) total, Bug__c FROM Case 
                          WHERE Bug__c IN :bugIds GROUP BY Bug__c];
        //system.debug('totalCaseCount = ' + totalCaseCount);

        if(!totalCaseCount.isEmpty()) 
        {
            //Set the Case Count field for each Bug 
            for(AggregateResult ar : totalCaseCount)
            {
                //system.debug('ar = ' + ar);
                Bug__c b = new Bug__c();
                b.Id = (Id)ar.get('Bug__c');
                b.Case_Count__c = (Integer)ar.get('total');
                toUpdate.put(b.Id, b);
            }
            //system.debug('toUpdate = ' + toUpdate);
        }
		
        if(!bugIds.isEmpty()) 
        {
            clearCaseCount(bugIds, countUpdated, toUpdate);
        }

        if(!toUpdate.isEmpty())
        {
            update toUpdate.Values();
        }
    }
    
    //This method is used to set the Case Count/Open Case Count field to 0 if all cases are removed from a Bug
    public static Map<Id, Bug__c> clearCaseCount(Set<Id> bugIds, Set<Id> openCheck, map<Id, Bug__c> toUpdate)
    {
        Map<Id, Bug__c> tempMap = new Map<Id, Bug__c>();
        for(Id bugId : bugIds)
        {
            //If the toUpdate list doesn't include the eeId, that means that totalCaseCount list didn't find any cases attached to the EE
            //Set both fields to 0
            if(!toUpdate.containsKey(bugId))
            {
                Bug__c b = new Bug__c();
                b.Id = bugId;
                b.Case_Count__c = 0;
                toUpdate.put(b.Id, b);
            }

        }
        return toUpdate;
    }
}