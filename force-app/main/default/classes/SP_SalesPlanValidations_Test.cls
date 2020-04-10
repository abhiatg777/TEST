public class SP_SalesPlanValidations_Test {

	public static testMethod void testAdvanceStage() {
		
		// Set up test data
		Account acc = new Account(Name = 'Test Account');
		insert acc;
		
        Id PRODUCTSANDSERVRTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Products and Services').getRecordTypeId();
        
		Opportunity opp = new Opportunity(Name = 'Test Oppty',recordTypeID=PRODUCTSANDSERVRTYPE, AccountId = acc.id, StageName = '1 - Plan', QS_Order_Type__c = 'New', CloseDate = Date.Today());
		insert opp;
		
        Schema.DescribeFieldResult F = Opportunity.Stagename.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();  

        map<integer,string> pMap = new map<integer,string>();

        list<string> pVal = new list<string>();
        for(Schema.PicklistEntry o: P){
            pVal.add(o.getValue());   
        }
        for(integer i = 0; i<pVal.size() ;i++){
               pMap.put(i+1,pVal[i]);            
        }
        List<QS_Opportunity_Stage__c> stgList = new List<QS_Opportunity_Stage__c>();
        for(Integer seq : pMap.keySet()) {
        	QS_Opportunity_Stage__c stg = new QS_Opportunity_Stage__c(Name = pMap.get(seq), QS_Stage_Number__c = seq);
            stgList.add(stg);
        }
        insert stgList;
		/*QS_Opportunity_Stage__c stg1 = new QS_Opportunity_Stage__c(Name = '1 - Plan', QS_Stage_Number__c = 1);
		QS_Opportunity_Stage__c stg2 = new QS_Opportunity_Stage__c(Name = '2 - Create', QS_Stage_Number__c = 2);
		QS_Opportunity_Stage__c stg3 = new QS_Opportunity_Stage__c(Name = '3 - Qualify', QS_Stage_Number__c = 3);*/
		
		
		QS_Stage_Objective__c obj1 = new QS_Stage_Objective__c(Name = 'Objective 1', QS_Opportunity_Stage__c = stgList[0].Id, QS_Order__c = 1);
		QS_Stage_Objective__c obj2 = new QS_Stage_Objective__c(Name = 'Objective 2', QS_Opportunity_Stage__c = stgList[1].Id, QS_Order__c = 2);
		QS_Stage_Objective__c obj3 = new QS_Stage_Objective__c(Name = 'Objective 3', QS_Opportunity_Stage__c = stgList[2].Id, QS_Order__c = 3);
		List<QS_Stage_Objective__c> objList = new List<QS_Stage_Objective__c>();
		objList.add(obj1);
		objList.add(obj2);
		objList.add(obj3);
		insert objList;
		
		QS_Objective_Action__c act1 = new QS_Objective_Action__c(Name = 'Not Required Action', QS_Order__c = 1, QS_Stage_Objective__c = obj1.Id);
		QS_Objective_Action__c act2 = new QS_Objective_Action__c(Name = 'Required Action', QS_Order__c = 2, QS_Stage_Objective__c = obj2.Id, QS_Action_Type__c = 'Required', QS_Opportunity_Order_Type__c = 'New');
		act2.QS_Opportunity_Record_Type__c = 'Products and Services';
        List<QS_Objective_Action__c> actList = new List<QS_Objective_Action__c>();
		actList.add(act1);
		actList.add(act2);
		insert actList;
		
		// Begin test
		Test.startTest();
		opp.StageName = pMap.get(2);
		update opp;
		
		System.assertEquals(pMap.get(2), opp.StageName);
		
		opp.StageName = pMap.get(3);
		try {
			update opp;
		}
		catch (Exception e) {
			System.debug('Caught exception');
		}
		
		Opportunity getOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
		System.assertNotEquals(pMap.get(3), getOpp.StageName);
		
		Task tsk = new Task(WhatId = opp.Id, QS_StageObjectiveID__c = obj2.Id, QS_ObjectiveActionID__c = act2.Id);
		tsk.Status = 'Completed';
		insert tsk;
		
		update opp;
		
		getOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
		System.assertEquals(pMap.get(3), getOpp.StageName);
		
		Test.stopTest();
	}

}