/*------------------------------------------------------------
Description: Opportunity Trigger Handler
History
05/27/2016    
------------------------------------------------------------*/
public class OpportunityTriggerHandler extends TriggerHandler {
    protected override void afterInsert(){
        autoRenewalMasterAgreement(Trigger.new);
    }

    protected override void afterUpdate(){
        autoRenewalPublishEvent(Trigger.new);
    }

    protected override void beforeUpdate(){

        //disabled for bulk updatess
        if (Trigger.size == 1) {
            validateRequiredActions((Map<Id,Opportunity>)Trigger.newMap, (Map<Id,Opportunity>)Trigger.oldMap);
        }

    }

    // Quick Start Sales Plan Validations
    public static string pValues(string stageNME){
        Schema.DescribeFieldResult F = Opportunity.Stagename.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();  

        map<integer,string> pMap = new map<integer,string>();
        map<string,integer> iMap = new map<string,integer>();

        list<string> pVal = new list<string>();
        for(Schema.PicklistEntry o: P){
            pVal.add(o.getValue());   
        }
        System.debug(pVal);
        System.debug('\n\n\n********pVal*******' + pVal.size() + '***********');
        for(integer i = 0; i<pVal.size() ;i++){
               pMap.put(i,pVal[i]);            
        }
        System.debug(pMap);

        for(integer i: pMap.keySet()){
            iMap.put(pMap.get(i),i);    
        }
        System.debug(stageNME);

        string retVal = pMap.get(iMap.get(stageNME) - 1);
        if(retVal == null){
            retVal = pMap.get(0);
        }
        return retVal;
        }
    
    
    public static void validateRequiredActions (Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
        
        for (Opportunity newOpp : newOpps.values()) {   
            //Opportunity Stage has changed - check for uncompleted required Tasks
            if (newOpp.StageName != oldOpps.get(newOpp.Id).StageName && newOpp.StageName != 'Closed Lost') {
                String oppRecordType = SP_RecordTypeManager.getNameById(newOpp.RecordTypeId, 'Opportunity');
                System.debug('stage name' + newOpp.StageName);
                string stageNME = pValues(newOpp.StageName);
                List<QS_Objective_Action__c> reqActions = [SELECT Id, Name, QS_Opportunity_Type__c, QS_Opportunity_Order_Type__c, QS_Opportunity_Order_SubType__c, QS_Effective_Date__c, QS_Exempt_Profiles__c, QS_Exempt_Users__c, QS_Exempt_Products__c 
                                                          FROM QS_Objective_Action__c 
                                                         WHERE QS_Stage_Name__c = :stageNME
                                                               AND QS_Action_Type__c = 'Required'
                                                               AND (QS_Opportunity_Record_Type__c INCLUDES (:oppRecordType)) 
                                                               AND (QS_Opportunity_Type__c INCLUDES (:newOpp.Type)
                                                               AND QS_Opportunity_Order_Type__c INCLUDES (:newOpp.QS_Order_Type__c)
                                                               AND QS_Opportunity_Order_SubType__c INCLUDES (:newOpp.QS_Order_Sub_Type__c))
                                                               AND (QS_Effective_Date__c= null or QS_Effective_Date__c <= :newOpp.CreatedDate.Date())];
                System.debug(reqActions);
                                                               
                List<Task> completedActions = [SELECT Id, QS_ObjectiveActionID__c 
                                                 FROM Task 
                                                WHERE WhatId = :newOpp.Id 
                                                      AND QS_StageObjectiveID__c != null
                                                      AND QS_ObjectiveActionID__c != null
                                                      AND IsClosed = true];
                
                Boolean allProdsExempt = SP_OpportunityActionPlanExtension.checkExemptProducts(newOpp.QS_SP_Products__c);
                                                      
                for (QS_Objective_Action__c req : reqActions) {
                    //is this user exempt from the Action?
                    if ((req.QS_Exempt_Users__c != null && req.QS_Exempt_Users__c.contains(UserInfo.getUserId().mid(0,15))) || (req.QS_Exempt_Profiles__c != null && req.QS_Exempt_Profiles__c.contains(UserInfo.getProfileId().mid(0,15)))) {
                        continue;
                    }
                    //are all products in the exempt list?
                    if (allProdsExempt && req.QS_Exempt_Products__c) {
                        continue;
                    }
                    
                    /*if (((newOpp.Type != null && req.QS_Opportunity_Type__c != null && req.QS_Opportunity_Type__c.contains(newOpp.Type))
                         && (newOpp.QS_Order_Type__c != null && req.QS_Opportunity_Order_Type__c != null && req.QS_Opportunity_Order_Type__c.contains(newOpp.QS_Order_Type__c)) 
                         && (newOpp.QS_Order_Sub_Type__c != null && req.QS_Opportunity_Order_SubType__c != null && req.QS_Opportunity_Order_SubType__c.contains(newOpp.QS_Order_Sub_Type__c))
                         && req.QS_Opportunity_Record_Type__c.contains(oppRecordType))
                        && (req.QS_Effective_Date__c <= newOpp.CreatedDate || req.QS_Effective_Date__c == null)) {*/
                        Boolean found = false;
                        for (Task tsk : completedActions) {
                            if (tsk.QS_ObjectiveActionID__c == req.Id) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            newOpp.addError('You cannot advance this Opportunity until all required Sales Plan actions have been completed (' + req.Name + ')');
                            break;
                        }
                    //}
                }
            }
        }
    }
    //Methid to renew Master Agreeement on Renewals
    public static void autoRenewalMasterAgreement (List<Opportunity> oppList){
        Set<Id> oppSetId = new Set<Id>();
        Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Master_Agreement').getRecordTypeId();
        List<Contract> insertContractList = new List<Contract>();

        for (Opportunity opp : oppList) {
            if (opp.Id != Null && opp.SBQQ__RenewedContract__c != Null
                //&& && opp.Auto_Renew__c == True
                ) {
                    oppSetId.add(opp.Id);                
            }
        }
            System.debug('In Auto Renewals'+ oppSetId);

        for (Opportunity opp : [SELECT Id, AccountId, SBQQ__RenewedContract__r.StartDate, SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c,
                                SBQQ__RenewedContract__r.QS_Upcoming_Renewal_Type__c, SBQQ__RenewedContract__r.EndDate
                                FROM Opportunity
                                WHERE Id
                                IN:oppSetId]) {
            if (opp.Id != null && opp.SBQQ__RenewedContract__r.QS_Upcoming_Renewal_Type__c == 'Contract Renewal') {
                Contract renewMSA = new Contract();
                renewMSA.RecordTypeId = recordTypeId;
                renewMSA.AccountId = opp.AccountId;
                renewMSA.ContractTerm = 36;
                renewMSA.StartDate = opp.SBQQ__RenewedContract__r.EndDate.addDays(1);
                renewMSA.Status = 'Activated';
                renewMSA.SBQQ__Opportunity__c = opp.Id;
                    insertContractList.add(renewMSA);
            }   
        }

        insert insertContractList;

    }


    //Publish Events for AutoRenewal Process
    public static void autoRenewalPublishEvent (List<Opportunity> oppList){
        List<Opportunity_Event__e> oppEventList = new List<Opportunity_Event__e>();
        //Id masterAgreementRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Master_Agreement').getRecordTypeId();
        List<Contract> insertContractList = new List<Contract>();

        for (Opportunity opp : oppList) {
            if (opp.Id != Null && opp.SBQQ__RenewedContract__c != Null && opp.SBQQ__PrimaryQuote__c != Null 
                && opp.SBQQ__Renewal__c == True && opp.SBQQ__Contracted__c == False
                && opp.SBQQ__Ordered__c == False && opp.StageName == 'Create'
                && opp.Auto_Renew__c == True) {
                    Opportunity_Event__e oppEvent = new Opportunity_Event__e();
                    oppEvent.Opportunity_Id__c = opp.Id;
                    oppEvent.Quote_Id__c = opp.SBQQ__PrimaryQuote__c;
                        oppEventList.add(oppEvent);          
            }
        }

        List<Database.SaveResult> results = EventBus.publish(oppEventList);
        for (Database.SaveResult sResult : results) {
            if (sResult.isSuccess()) {
                System.debug('Successfully Saved');
            } else {
                for(Database.Error eR : sResult.getErrors()) {
                   System.debug('Error returned: ' + eR.getStatusCode() + ' - ' + eR.getMessage());
                }                
            }   
        }
        

    }

}