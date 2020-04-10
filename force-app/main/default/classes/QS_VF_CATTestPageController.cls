public class QS_VF_CATTestPageController {
    public static List<QS_Customer_Asset_Detail__c> cadList {get;set;}
    public static QS_Customer_Asset__c currentAsset {get;set;}
    public static QS_Customer_Asset_Detail__c currentCAD {get;set;}
    public static Date dt = Date.today();
    public static String cadName {get;set;}
    public static Date cadDate {get;set;}
    
    public static QS_customer_asset_settings__c CASettings { get {
        if(CASettings == null) {
            CASettings = QS_customer_asset_settings__c.getInstance();
        }
        return CASettings;
    } set; }
    
    public QS_VF_CATTestPageController()
    {
        Id currentAssetId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Current Asset ID' + currentAssetId);
        currentAsset = [select Name,QS_Account__r.Name,QS_Product__r.Name,QS_Asset_Status__c,QS_Quantity__c,
                            QS_Annual_Recurring_Revenue__c,
                            QS_Start_Date__c,QS_End_Date__c,
                            QS_Effective_Decommision_Date__c
                            from QS_Customer_Asset__c 
                            where Id =: currentAssetId LIMIT 1];    
        
        cadList = 
                [select Id, Name,QS_Start_Date__c,QS_End_Date__c,QS_Asset_Status__c,QS_Customer_Asset__r.Name,
                 QS_Annual_Recurring_Revenue__c,QS_CA_Quantity__c,QS_Booking_Date__c,
                 QS_Currently_Active__c 
                 from QS_Customer_Asset_Detail__c 
                 where QS_Customer_Asset__c =: currentAssetId];
        
        
    }
    
    
    public static void getAssetAndCadDetails(){
            
            try
            {
            Id currentAssetId = ApexPages.currentPage().getParameters().get('id');
            System.debug('Current Asset ID' + currentAssetId);
            currentAsset = [select Name,QS_Account__r.Name,QS_Product__r.Name,QS_Asset_Status__c,QS_Quantity__c,
                                QS_Annual_Recurring_Revenue__c,
                                QS_Start_Date__c,QS_End_Date__c,
                                QS_Effective_Decommision_Date__c
                                from QS_Customer_Asset__c 
                                where Id =: currentAssetId LIMIT 1];   
            cadList = 
                [select Id, Name,QS_Start_Date__c,QS_End_Date__c,QS_Asset_Status__c,QS_Customer_Asset__r.Name,
                 QS_Annual_Recurring_Revenue__c,QS_CA_Quantity__c,QS_Currently_Active__c, QS_Booking_Date__c 
                 from QS_Customer_Asset_Detail__c 
                 where QS_Customer_Asset__c =: currentAsset.Id];
                          
            }catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
            
            
            
        }
    
    
    public static void UpdateCADDate(){
        
            FunctionToLoopThroughProcessCAD(currentAsset);
            getAssetAndCadDetails();
    }
    public static void FunctionToLoopThroughProcessCAD(QS_Customer_Asset__c workingAssetRecord)
    {
        Id currentAssetId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Current Asset ID' + currentAssetId);
        currentAsset = [select Name,QS_Account__r.Name,QS_Product__r.Name,QS_Asset_Status__c,QS_Quantity__c,
                            QS_Annual_Recurring_Revenue__c,
                            QS_Start_Date__c,QS_End_Date__c,
                            QS_Effective_Decommision_Date__c
                            from QS_Customer_Asset__c 
                            where Id =: currentAssetId LIMIT 1];   
        System.debug('Current Asset ID' + currentAsset);
        
        List<QS_Customer_Asset_Detail__c> 
            lstcad = [SELECT Id, QS_Asset_Status__c, QS_Quantity__c,QS_Customer_Asset__c,QS_Currently_Active__c, 
                           QS_End_Date__c,QS_Start_Date__c, QS_Product__r.QS_Auto_Activate__c, QS_Product__r.QS_Auto_Deactivate__c,
                           QS_Contract__r.SBQQ__RenewalOpportunity__r.IsWon,QS_Contract__r.SBQQ__RenewalOpportunity__r.IsClosed,
                           QS_Contract__r.SBQQ__RenewalOpportunity__r.CloseDate,QS_Contract__r.EndDate,QS_Terminated_Date__c,
                           QS_Contract__r.SBQQ__Opportunity__r.CloseDate,QS_Contract__r.SBQQ__Opportunity__c 
                      from QS_Customer_Asset_Detail__c 
                      where QS_Customer_Asset__c =: currentAssetID]; 
        
        
        CA2_CustomerAssetDetailStatusBatchable batchJob = new CA2_CustomerAssetDetailStatusBatchable();
        batchJob.executeBatchJob(lstcad,cadDate);
        CA2_CustomerAssetDetailTriggerHandler cdh = new CA2_CustomerAssetDetailTriggerHandler();
        cdh.handleBeforeUpdate(lstcad,cadDate);
        
        }
    
    
   
    
   
}