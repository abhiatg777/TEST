public without sharing class CA2_CustomerAssetTriggerHandler extends CA2_TriggerHandler {

   protected override void beforeInsert() {
       updateName(Trigger.new);
}

   protected override void beforeUpdate() {
       System.debug('BEFORE UPDATE LOGIC HIT ON CAD');
       processStatuses((List<QS_Customer_Asset__c>)Trigger.New, (Map<Id, QS_Customer_Asset__c>)Trigger.oldMap);
        updateName(Trigger.new);
}
   private void updateName(List<QS_Customer_Asset__c> newList) {
       for(QS_Customer_Asset__c ca: newList) {
           ca.Name = ca.QS_Customer_Asset_Name_Value__c;
}
}
    private void processStatuses(List<QS_Customer_Asset__c> newList, Map<Id, QS_Customer_Asset__c> oldMap) {
        //update the CAD that had been manually update
        Map<Id, QS_Customer_Asset__c> caMap = new Map<Id, QS_Customer_Asset__c>([SELECT Id,QS_Quantity__c, (SELECT Id, QS_Asset_Status__c,QS_Terminated_Date__c,CreatedDate, QS_Customer_Asset__c, QS_End_Date__c,QS_Start_Date__c, QS_Product__r.QS_Auto_Activate__c, QS_Product__r.QS_Auto_Deactivate__c FROM QS_Customer_Asset_Details__r) FROM QS_Customer_Asset__c WHERE Id IN: newList]);
        for(QS_Customer_Asset__c ca: newList) {
            Boolean hasPending = false;
            Boolean hasActive = false;
            Boolean hasDecommission = false;
            Boolean hasPendingDecommission = false;
            Boolean hasExpired = false; 
            Boolean hasPendingRenewal = false;
            Date effectiveEndDate;
            
            System.debug('In process Statuses');
            QS_Customer_Asset_Detail__c cadWithTheMostRecentServiceLevelAgreement;
            for(QS_Customer_Asset_Detail__c cad: caMap.get(ca.Id).QS_Customer_Asset_Details__r) {
        
         
                
                
                //calculate Effective End Date
                //system.debug('We are here TEST0050 ON CA:' + cad.QS_Asset_Status__c);
                // Pending Implementation to Active
                
                if(cad.QS_Asset_Status__c == 'Pending Activation') {
                    hasPending = true;
                    } else if(cad.QS_Asset_Status__c == 'Pending Decommission') {
                    hasPendingDecommission = true;
                } else if(cad.QS_Asset_Status__c == 'Decommissioned' || (cad.QS_Terminated_Date__c !=null && cad.QS_Asset_Status__c != 'Reduced' && cad.QS_Asset_Status__c != 'Expired' )) {
                    hasDecommission = true;
                    if(cad.QS_Terminated_Date__c !=null)
                        effectiveEndDate = cad.QS_Terminated_Date__c;
                    else
                        effectiveEndDate = cad.QS_Start_Date__c;
                } else if(cad.QS_Asset_Status__c == 'Expired') {
                    hasExpired = true;
                     
                } else if (cad.QS_Asset_Status__c == 'Pending Renewal'){
                    hasPendingRenewal = true;
                } else if(cad.QS_Asset_Status__c == 'Active') {
                    hasActive = true;
                } 
            }
            if((hasActive && ca.QS_Quantity__c > 0) || hasPendingDecommission)  {
                ca.QS_Asset_Status__c = 'Active';
               // ca.QS_Effective_Decommision_Date__c = null;
         
            }else if (hasDecommission && ca.QS_Total_Active__c == 0) {
                ca.QS_Asset_Status__c = 'Decommissioned';
                ca.QS_Effective_Decommision_Date__c = effectiveEndDate;
            }else if(hasExpired && !hasActive && !hasPending) {
                ca.QS_Asset_Status__c = 'Expired';
            }  else if (hasPending) {
                ca.QS_Asset_Status__c = 'Pending Activation';
            }
            QS_Customer_Asset__c oldCA = oldMap.get(ca.Id);
            if(oldCA.QS_Asset_Status__c == 'Decommissioned' && ca.QS_Asset_Status__c != 'Decommissioned')
            {
                ca.QS_Effective_Decommision_Date__c = null;
            }
            
          
        } //end for
    }
}