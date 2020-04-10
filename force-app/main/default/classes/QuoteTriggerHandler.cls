/*------------------------------------------------------------
Author: ATG
Description: SBQQ__Quote__c trigger handler
History
05/27/2016    ATG Created

------------------------------------------------------------*/
public class QuoteTriggerHandler extends TriggerHandler {
    protected override void afterInsert(){
        updateOppOnPrimaryQuoteInsert(Trigger.new);

    }

    protected override void afterUpdate(){
        updateOppOnPrimaryQuoteUpdate((Map<Id,SBQQ__Quote__c>)Trigger.newMap);

    }

    //If Quote is Primary, the related oppotunity gets updated with fields.
    public static void updateOppOnPrimaryQuoteInsert (List<SBQQ__Quote__c> quoteValues){
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(SBQQ__Quote__c quoteValue: quoteValues){
            if (quoteValue.Id != null && quoteValue.SBQQ__Primary__c == True) {
                oppIdSet.add(quoteValue.SBQQ__Opportunity2__c);
            }

            if (!oppIdSet.isEmpty()) {
                for (Opportunity opp : [SELECT Id, QS_Billing_Frequency__c, QS_Bill_To__c, QS_Ship_To__c, QS_Subscription_Term__c,
                                        QS_Contract_Term__c
                                        FROM Opportunity
                                        WHERE Id 
                                        IN:oppIdSet]) {
                    //opp.QS_Billing_Frequency__c = quoteValue.QS_Billing_Frequency__c; //This field doesnt exist on Quote object
                    opp.QS_Bill_To__c = quoteValue.QS_Bill_To__c;
                    opp.QS_Ship_To__c =	quoteValue.QS_Ship_To__c;
                    //opp.QS_Subscription_Term__c = quoteValue.QS_Subscription_Term__c; //This field doesnt exist on Quote object
                    opp.QS_Contract_Term__c = quoteValue.QS_Contract_Term__c;
                    
                        oppList.add(opp);

                }
                
            }
        }  
                    update oppList;  
    }

    //Logic to update related Opportunity with fields when a Primary Quote is updated
    public static void updateOppOnPrimaryQuoteUpdate (Map<Id,SBQQ__Quote__c> quoteMap){
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for (SBQQ__Quote__c quoteValue : quoteMap.values()) {
            if (quoteValue.Id != null && quoteValue.SBQQ__Primary__c == true) {
                oppIdSet.add(quoteValue.SBQQ__Opportunity2__c);
            }

            if (!oppIdSet.isEmpty()) {
                for (Opportunity opp : [SELECT Id,QS_Billing_Frequency__c, QS_Bill_To__c, QS_Ship_To__c, QS_Subscription_Term__c,
                                        QS_Contract_Term__c
                                        FROM Opportunity
                                        WHERE Id
                                        IN: oppIdSet]) {
                    //opp.QS_Billing_Frequency__c = quoteValue.QS_Billing_Frequency__c;
                    opp.QS_Bill_To__c = quoteValue.QS_Bill_To__c;
                    opp.QS_Ship_To__c =	quoteValue.QS_Ship_To__c;
                    //opp.QS_Subscription_Term__c = quoteValue.QS_Subscription_Term__c;
                    opp.QS_Contract_Term__c = quoteValue.QS_Contract_Term__c;
                    
                    oppList.add(opp);
                }
                
            }
            
        }
                    update oppList;
    }

}