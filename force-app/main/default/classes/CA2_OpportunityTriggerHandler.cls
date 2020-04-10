/* Author: Ved Swaminathan
 * Function: addDecommissionRecordsForZeroedOutProducts
 * Description: For any closed opportunities, that are either won or lost, 
 * this function identifies the 0 quantity quote line items, identifies the Customer Assets and Details related to 
 * those and sets them to Expired and also creates a decommission record for the Assets
 * 
 */


public class CA2_OpportunityTriggerHandler {
    public CA2_OpportunityTriggerHandler() {

    }
    
  
    Public void addDecommissionRecordsForZeroedOutProducts(List<Opportunity> oppList)
    {
        List<Opportunity> listOfClosedOpportunities = new List<Opportunity>();
        List<Opportunity> listOfClosedRenewals = new List<Opportunity>();
        System.debug('OPP LIST SIZE' + oppList.size());
        for(Opportunity opp : oppList)
        {
            string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.recordtypeid).getname();
            if(opp.IsClosed)
                listOfClosedOpportunities.add(opp);
            
            if(recordtypename.contains('Renewal') && opp.IsClosed)
            {
                listOfClosedRenewals.add(opp);
            }
            System.debug('listOfClosedRenewals' + listOfClosedRenewals);    
        }
        
        if(listOfClosedOpportunities.size()>0)
            processZeroedOutQuoteLines(listOfClosedOpportunities);
        
        if(listOfClosedRenewals.size()>0)
            UpdateHistoricalCadsPendingRenewal(listOfClosedRenewals);
    }
    
    public void processZeroedOutQuoteLines(List<Opportunity> closedOpps)
    {
        QS_customer_asset_settings__c CS_flag = QS_customer_asset_settings__c.getInstance();
        Set<Id> primaryQuoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> lstOfDecmmProcessedQL = new List<SBQQ__QuoteLine__c>();
        for(Opportunity opp : closedOpps)
        {
            
            primaryQuoteIds.add(opp.SBQQ__PrimaryQuote__c);
        }
      
       
        List<SBQQ__QuoteLine__c> quoteLineItems = [select Id,SBQQ__Product__c,QS_Account_Id__c,SBQQ__Quantity__c, 
                                                   QS_Quote_Type__c,SBQQ__Quote__r.SBQQ__StartDate__c,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.IsWon,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.CloseDate,
                                                   QS_Booking_Date__c
                                                   from SBQQ__QuoteLine__c 
                                                   where SBQQ__Quote__c in: primaryQuoteIds and QS_Decomm_On_Renewal_Processed__c =: false];
        
        
        Set<Id> setOfProductIds = new Set<id>();
        Set<Id> setOfAccountIds = new Set<Id>();
        Set<Id> setOfProcessedCustomerAssets = new Set<Id>();
        List<QS_Customer_Asset_Detail__c> listOfCADRecordsToExpire = new List<QS_Customer_Asset_Detail__c>();
        List<QS_Customer_Asset_Detail__c> listOfDecommRecordsToInsert = new List<QS_Customer_Asset_Detail__c>();        
        for(SBQQ__QuoteLine__c ql : quoteLineItems)
        {
             if(
                ( 
                    ((ql.SBQQ__Quantity__c == 0 && ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.IsWon && CS_flag.Contracting_Opp_No_CAD_Creation__c == false) 
                        || (!ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.IsWon))
               )
               && ql.QS_Quote_Type__c=='Renewal' 
            )
            {
                setOfProductIds.add(ql.SBQQ__Product__c);
                setOfAccountIds.add(ql.QS_Account_Id__c);
            }
                
            
        }
        System.debug('setOfProductIds ' + setOfProductIds);
        System.debug('setOfAccountIds ' + setOfAccountIds);
        List<QS_Customer_Asset__c> listOfCustomerAssetsToAddDecommissionRecords = [select Id, QS_Product__c,QS_Account__c,
                                                                                   (
                                                                                       select Id,
                                                                                        QS_Asset_Status__c,
                                                                                        QS_Currently_Active__c,
                                                                                        QS_Product__c,
                                                                                        QS_Start_Date__c,
                                                                                        QS_Booking_Date__c,
                                                                                        QS_End_Date__c,
                                                                                        QS_Terminated_Date__c,
                                                                                        QS_Contract__r.StartDate,
                                                                                        QS_Contract__r.EndDate
                                                                                        FROM QS_Customer_Asset_Details__r
                                                                                   ) FROM QS_Customer_Asset__c 
                                                                            where QS_Product__c in: setOfProductIds and QS_Account__c in: setOfAccountIds];
        
        
        System.debug('listOfCustomerAssetsToAddDecommissionRecords ' + listOfCustomerAssetsToAddDecommissionRecords);
        if(listOfCustomerAssetsToAddDecommissionRecords.size() > 0)
        {
            try{
             for(SBQQ__QuoteLine__c currentLine : quoteLineItems)
             {
                 for(QS_Customer_Asset__c customerAsset : listOfCustomerAssetsToAddDecommissionRecords)
                 {
                     if(customerAsset.QS_Account__c == currentLine.QS_Account_Id__c && currentLine.SBQQ__Product__c == customerAsset.QS_Product__c)
                       {
                           listOfDecommRecordsToInsert.add(getDecommissionRecordByQuoteLine(currentLine,customerAsset));
                       }
                
                 }
                 currentLine.QS_Decomm_On_Renewal_Processed__c = true;
                 lstOfDecmmProcessedQL.add(currentLine);
                 
             }
                
            System.debug('List of Decommission Records to Insert' + listOfDecommRecordsToInsert);     
            insert listOfDecommRecordsToInsert;
            update listOfCADRecordsToExpire;
            update lstOfDecmmProcessedQL;   
            }catch(Exception ex)
            {
                System.debug('ERROR Occurred' + ex.getMessage());
            }
        }
        
    }

    public QS_Customer_Asset_Detail__c getDecommissionRecordByQuoteLine(SBQQ__QuoteLine__c quoteLine,QS_Customer_Asset__c customerAsset)
    {
        try
        {
            System.debug('In createDecommissionedRecord');
            QS_Customer_Asset_Detail__c decommRecordToBeCreated = new QS_Customer_Asset_Detail__c();
            decommRecordToBeCreated.QS_Start_Date__c = quoteLine.SBQQ__Quote__r.SBQQ__StartDate__c;
            decommRecordToBeCreated.QS_End_Date__c = quoteLine.SBQQ__Quote__r.SBQQ__StartDate__c;
            decommRecordToBeCreated.QS_Booking_Date__c = quoteLine.QS_Booking_Date__c;
            decommRecordToBeCreated.QS_Asset_Status__c = 'Decommissioned';
            decommRecordToBeCreated.QS_CA_Quantity__c = 0;
            decommRecordToBeCreated.QS_Quantity__c = 0;
            decommRecordToBeCreated.QS_Annual_Recurring_Revenue__c = 0;
            decommRecordToBeCreated.QS_Product__c = customerAsset.QS_Product__c;
            decommRecordToBeCreated.QS_Customer_Asset__c = customerAsset.Id;
            decommRecordToBeCreated.QS_Quote_Line__c = quoteLine.Id;
            decommRecordToBeCreated.QS_Previous_Contract__c = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c;
            decommRecordToBeCreated.QS_Apex_Created_Decommission_Record__c = true;
            return decommRecordToBeCreated;
           
            
        }
        Catch(Exception ex)
        {
            System.debug('Exception Occurred' + ex.getMessage() + ' at LINE Number' + ex.getLineNumber());
            
            return null;    
        }
            
    }
    
    public void UpdateHistoricalCadsPendingRenewal(List<Opportunity> closedRenewalOpps)
    {
        System.debug('In update historicals');
        //Identify Contract for which these opps are these renewals
        Set<Id> setOfOpportunityIds = (new Map<Id,SObject>(closedRenewalOpps)).keySet();
        System.debug('setOfOpportunityIds' + setOfOpportunityIds);
        List<Contract> contractListWithRenewalOpps = [select Id from Contract where SBQQ__RenewalOpportunity__c in: setOfOpportunityIds];
        Set<Id> setOfContractIds = (new Map<Id,SObject>(contractListWithRenewalOpps)).keySet();
        System.debug('setOfContractIds' + setOfContractIds);
        
        List<QS_Customer_Asset_Detail__c> lstOfCadsRelatedToClosedContracts 
            = [select Id, QS_Asset_Status__c from QS_Customer_Asset_Detail__c 
               where QS_Contract__c in: setOfContractIds and QS_Asset_Status__c = 'Pending Renewal'];
        List<QS_Customer_Asset_Detail__c> listOfCADsForUpdate = new List<QS_Customer_Asset_Detail__c>();
        for(QS_Customer_Asset_Detail__c currentCAD : lstOfCadsRelatedToClosedContracts)
        {
            currentCAD.QS_Asset_Status__c = 'Expired';
            listOfCADsForUpdate.add(currentCAD);            
        }
        update listOfCADsForUpdate;
        
    }
    
}