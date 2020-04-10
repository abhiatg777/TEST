public class SP_SalesPlanValidations {
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
	/*public static void validateRequiredActions (Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
		for (Opportunity newOpp : newOpps.values()) {
			String oppRecordType = SP_RecordTypeManager.getNameById(newOpp.RecordTypeId, 'Opportunity');
			//Opportunity Stage has changed - check for uncompleted required Tasks
			if (newOpp.StageName != oldOpps.get(newOpp.Id).StageName && newOpp.StageName != 'Closed Lost') {
				List<QS_Objective_Action__c> reqActions = [SELECT Id, Name, QS_Opportunity_Type__c, QS_Opportunity_Order_Type__c, QS_Opportunity_Order_SubType__c, QS_Effective_Date__c, QS_Exempt_Profiles__c, QS_Exempt_Users__c, QS_Exempt_Products__c 
														  FROM QS_Objective_Action__c 
														 WHERE QS_Stage_Name__c = :oldOpps.get(newOpp.Id).StageName 
														       AND QS_Action_Type__c = 'Required'
                                                        	   AND (QS_Opportunity_Record_Type__c INCLUDES (:oppRecordType))
														       AND (QS_Opportunity_Type__c INCLUDES (:newOpp.Type)
														       AND QS_Opportunity_Order_Type__c INCLUDES (:newOpp.QS_Order_Type__c)
														       AND QS_Opportunity_Order_SubType__c INCLUDES (:newOpp.QS_Order_Sub_Type__c))];
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
					
					/*if ((( req.QS_Opportunity_Type__c.contains(newOpp.Type))
					     && (req.QS_Opportunity_Order_Type__c.contains(newOpp.QS_Order_Type__c)) 
					     && (req.QS_Opportunity_Order_SubType__c.contains(newOpp.QS_Order_Sub_Type__c))
                         && req.QS_Opportunity_Record_Type__c.contains(oppRecordType))
					    && (req.QS_Effective_Date__c <= newOpp.CreatedDate || req.QS_Effective_Date__c == null)) {
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
	}*/

}