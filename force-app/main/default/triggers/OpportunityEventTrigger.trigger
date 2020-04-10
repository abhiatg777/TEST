trigger OpportunityEventTrigger on Opportunity_Event__e (after insert) {
    Map<Id,Opportunity_Event__e> oppEventMap = new Map<Id,Opportunity_Event__e>();
    List<String> oppIdList = new List<String>();
    List<String> quoteIdList = new List<String>();
    List<SBQQ__Quote__c> quoteUpdate = new List<SBQQ__Quote__c>();
    List<Opportunity> oppUpdate = new List<Opportunity>();
    
    for (Opportunity_Event__e oppEvent : Trigger.new) {
        if (oppEvent.Opportunity_Id__c != Null && oppEvent.Quote_Id__c != Null) {
            oppEventMap.put(oppEvent.Opportunity_Id__c,oppEvent);
            oppIdList.add(oppEvent.Opportunity_Id__c);
            quoteIdList.add(oppEvent.Quote_Id__c);
        }
    }
    for (SBQQ__Quote__c quote : [SELECT Id, ApprovalStatus__c, SBQQ__Status__c
                            FROM SBQQ__Quote__c
                            WHERE Id
                            IN: quoteIdList]) {
        if (quote.Id != Null) {
            quote.ApprovalStatus__c = 'Approved';
            quote.SBQQ__Status__c = 'Approved';
            quoteUpdate.add(quote);
        }
    }

    update quoteUpdate;

    for (Opportunity opp : [SELECT Id, SBQQ__Ordered__c, StageName
                            FROM Opportunity
                            WHERE Id
                            IN: oppIdList]) {
        if (opp.Id != Null && opp.SBQQ__Ordered__c == False) {
            opp.SBQQ__Ordered__c = True;
            opp.StageName = 'Closed Won';
            oppUpdate.add(opp);
        }
    }
    update oppUpdate;

}