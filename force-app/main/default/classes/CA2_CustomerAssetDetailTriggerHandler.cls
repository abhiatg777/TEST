/**
 * Class responsible for managing statues between Customer Asset Details and Customer Asset they roll up to.
 *
 * @author: Renato Manzo / Advanced Technology Group (www.atginfo.com)
 */
public class CA2_CustomerAssetDetailTriggerHandler extends CA2_TriggerHandler {
    
    protected override void beforeUpdate() {
       
        if(CA2_CustomerAssetUtil.CS_flag.QS_Generate_CA_on_Update__c) {
            handleBeforeUpdate(Trigger.New,null); 
        }
       
        
    }
    protected override void afterInsert() {
        updateStatusCustomerAssets(Trigger.New); 
    }
    protected override void afterUpdate() {
        updateStatusCustomerAssets(Trigger.New); 
    }
    protected override void beforeInsert() {
        CA2_TwinField.runTwinHelper(Trigger.new);
    }
    

    public void UpdateStatusCustomerAssets(List<QS_Customer_Asset_Detail__c> lstTriggerCADetails){
        List<QS_Customer_Asset_Detail__c> cadupdate = new List<QS_Customer_Asset_Detail__c>();
        Set<Id> customerAssetIds = new Set<Id>();        
        //loop over the Customer Asset Detail and save all the CA ids
        for(QS_Customer_Asset_Detail__c cad: lstTriggerCADetails){
            //only if the id                        
            customerAssetIds.add(cad.QS_Customer_Asset__c);                
        }
        // no duplicated ids
       
        //get Master Customer Assets
        List<QS_Customer_Asset__c> customerAssets = new List<QS_Customer_Asset__c>();
        customerAssets = [SELECT Id, QS_Asset_Status__c, QS_Quantity__c , QS_End_Date__c FROM QS_Customer_Asset__c where Id =: customerAssetIds FOR UPDATE];
        update customerAssets;
      }

    public void handleBeforeUpdate(List<QS_Customer_Asset_Detail__c> lstTriggerCADetails, Date currentDate){      
        
        date dt = system.today();
        if(currentDate == null)
        {
            dt = system.today();
        }else
        {
            dt = currentDate;
        }
        
        for(QS_Customer_Asset_Detail__c cad: lstTriggerCADetails){
           
            //update Currently Active
             	if(cad.QS_Asset_Status__c == 'Expired')
                {
                    cad.QS_Currently_Active__c = false;
                }
            	else if(cad.QS_End_Date__c < dt)
                {
                    cad.QS_Currently_Active__c = false;
                }    
                else if(cad.QS_End_Date__c >= dt && cad.QS_Start_Date__c <= dt)
                {
                    cad.QS_Currently_Active__c = true;
                }
                else if(cad.QS_End_Date__c > dt && cad.QS_Start_Date__c > dt)
                {
                    cad.QS_Currently_Active__c = false;
                }
            
            if(cad.QS_End_Date__c == null)
            {
                cad.QS_Currently_Active__c = true; //For Prepertual Licenses, there is no end date.
            }
                 
        }
    }
    
    

}