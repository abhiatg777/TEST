/*
*CA2_SubcriptionTriggerHandler
*Created:
* 02.07.2019 : Saketha Angirekula : Class to insert Customer Asset and Customer Asset Detail records on insert of Subscription.
*
*Updated:
* 04.22.2019 : Josh Payne: Updated the Subscription Start/End/Quantity to the dynamic formula field to accommodate MDQ Subscriptions. Updated the 'insertCustomerAssetDetail' class.
*/


public class CA2_SubscriptionTriggerHandler extends CA2_TriggerHandler {    
    Date dt = System.today();
    
    protected override void afterInsert(){
        createCustomerAssets(trigger.new);
    }
    protected override void afterUpdate() {
       if(CA2_CustomerAssetUtil.CS_flag.QS_Generate_CA_on_Update__c){
             createCustomerAssets(trigger.new);
        }
        Set<Id> allUpdatedIds = trigger.newMap.keySet();
        List<QS_Customer_Asset_Detail__c> lstCAD =  
           [select Id,QS_Subscription__r.SBQQ__TerminatedDate__c,QS_Terminated_Date__c, 
            QS_CA_Quantity__c,QS_Asset_Status__c,QS_UniqueKey__c,Name,QS_Start_Date__c,QS_End_Date__c
            from QS_Customer_Asset_Detail__c where QS_UniqueKey__c in: allUpdatedIds] ;
        
       updateHistoricalCads(lstCAD); 
        
    }
    private Map<Id, SBQQ__Subscription__c> subsWithRelated {get {
        if(subsWithRelated == null) {
            subsWithRelated = new Map<Id, SBQQ__Subscription__c>([SELECT Id,QS_Booking_Date__c,SBQQ__TerminatedDate__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.QS_Decommission_Reason__c 
                                                                                                FROM SBQQ__Subscription__c
                                                                                                WHERE Id IN: Trigger.new]);
            }
            return subsWithRelated;
    } set;}

    public static boolean bypass = false;
    public void createCustomerAssets(List<SBQQ__Subscription__c> listSubscriptions) {
        if(bypass) { return; }
        // this list is to hold the new list of customerassets that needs to be inserted
        List<QS_Customer_Asset__c> listCustomerAssetToInsert = new List<QS_Customer_Asset__c>();
        Set<Id> setProdIds = new Set<Id>();
 
        for(SBQQ__Subscription__c sub : listSubscriptions) {
            setProdIds.add(sub.SBQQ__Product__c);
        }
        setProdIds.remove(null);
        if(setProdIds.size() > 0) {
            Set<String> setExistingProdCustomerAsset = new Set<String>();
            // query all the products that have product QS_Generate_Asset__c  true 
            Map<Id, Product2> generateAssetProductById = CA2_CustomerAssetUtil.queryProductsById(setProdIds);

            List<SBQQ__Subscription__c> subscriptionsToProcess = new List<SBQQ__Subscription__c>();
            List<SBQQ__Subscription__c> subscriptionsToCreateSubAssetsFor = new List<SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c sub: listSubscriptions) {
                if(sub.SBQQ__Product__c != null && generateAssetProductById.containsKey(sub.SBQQ__Product__c) && generateAssetProductById.get(sub.SBQQ__Product__c).SBQQ__SubscriptionPricing__c != 'Percent Of Total') {
                    subscriptionsToProcess.add(sub);
                } else if (sub.QS_Product_Subscription_Pricing__c == 'Percent Of Total' && sub.SBQQ__RevisedSubscription__c != null) {
                    subscriptionsToCreateSubAssetsFor.add(sub);
                }
            }
            if(subscriptionsToProcess.size() > 0) {
                Set<String> customerAssetUniqueIdSet = new Set<String>();
                // get Customer_Asset_Unique_Ids from Subscriptios 
                customerAssetUniqueIdSet = CA2_CustomerAssetUtil.Subscription_CAUniqueId(subscriptionsToProcess);
                // if is an Asset use the Function Asset_CAUniqueId called from the Asset Trigger Handler
                List<QS_Customer_Asset__c> listCustomerAssets = CA2_CustomerAssetUtil.queryCAByUniqueId(customerAssetUniqueIdSet);
                

                if(listCustomerAssets.size() > 0) {
                    for(QS_Customer_Asset__c customerAsset : listCustomerAssets) {
                        setExistingProdCustomerAsset.add(customerAsset.QS_Customer_Asset_Unique_Id__c);
                    }
                }
                //Insert Customer asset record
                for(SBQQ__Subscription__c sub : subscriptionsToProcess) {
                    if(!setExistingProdCustomerAsset.contains(sub.QS_Customer_Asset_Unique_Id__c)) {
                        QS_Customer_Asset__c cAsset = new QS_Customer_Asset__c();
                        if(generateAssetProductById.keySet().contains(sub.SBQQ__Product__c) && sub.SBQQ__Account__c != null) {
                            cAsset.QS_Account__c = sub.SBQQ__Account__c;
                            cAsset.QS_Product__c = sub.SBQQ__Product__c;
                            cAsset.QS_Customer_Asset_Unique_Id__c = sub.QS_Customer_Asset_Unique_Id__c;
                            cAsset.CurrencyIsoCode = sub.CurrencyIsoCode;
                            cAsset.QS_Product_Category__c = 'Subscription';
                        
                            setExistingProdCustomerAsset.add(sub.QS_Customer_Asset_Unique_Id__c); //prevent double adds
                            listCustomerAssetToInsert.add(cAsset);
                        }
                    }
                }
                insert listCustomerAssetToInsert;
                listCustomerAssets.addAll(listCustomerAssetToInsert);
                System.debug('List of Customer Assets passed' + listCustomerAssetToInsert);
                
                insertCustomerAssetDetail(listSubscriptions, listCustomerAssets, generateAssetProductById);                    
                
                
                
            }
            if(subscriptionsToCreateSubAssetsFor.size() > 0) {
                System.debug('Reductions Handling Process');
                handleReductions(subscriptionsToCreateSubAssetsFor);
            }
        }
    }

    private void handleReductions(List<SBQQ__Subscription__c> subscriptionsToCreateSubAssetsFor) {
        Set<Id> parentSubscriptions = new Set<Id>();
        Set<Id> subsToReduceIds = new Set<Id>();
        for(SBQQ__Subscription__c sub: subscriptionsToCreateSubAssetsFor) {
            subsToReduceIds.add(sub.Id);
            parentSubscriptions.add(sub.SBQQ__RevisedSubscription__c);
        }
        parentSubscriptions.remove(null);
        Map<String, SBQQ__SubscribedAsset__c> subAssetToCreate = new Map<String, SBQQ__SubscribedAsset__c>();
        List<SBQQ__SubscribedAsset__c> subAssetList = [SELECT SBQQ__Asset__c, QS_Booking_Date__c, SBQQ__Subscription__c, SBQQ__Subscription__r.SBQQ__RevisedSubscription__c FROM SBQQ__SubscribedAsset__c 
                                                        WHERE ((SBQQ__Subscription__c IN: parentSubscriptions AND SBQQ__Subscription__r.SBQQ__Quantity__c > 0) 
                                                                OR (SBQQ__Subscription__r.SBQQ__RevisedSubscription__c IN: parentSubscriptions AND SBQQ__Subscription__r.SBQQ__RevisedSubscription__r.SBQQ__Quantity__c > 0)) 
                                                                AND Id NOT IN: subsToReduceIds];
            
        for(SBQQ__SubscribedAsset__c sa: subAssetList) {
            Id saParent;
            if(String.isNotBlank(sa.SBQQ__Subscription__r.SBQQ__RevisedSubscription__c)) {
                saParent = sa.SBQQ__Subscription__r.SBQQ__RevisedSubscription__c;
            } else {
                saParent = sa.SBQQ__Subscription__c;
            } 
            for(SBQQ__Subscription__c sub: subscriptionsToCreateSubAssetsFor) {
                Id parentOfRevision = sub.SBQQ__RevisedSubscription__c;
                if(saParent == parentOfRevision) {
                    subAssetToCreate.put(sub.Id + '' + sa.SBQQ__Asset__c, new SBQQ__SubscribedAsset__c(SBQQ__Subscription__c = sub.Id, SBQQ__Asset__c = sa.SBQQ__Asset__c, QS_Created_By_Apex__c = true, QS_UpsertKey__c = sub.Id + '' + sa.SBQQ__Asset__c));
                }
            }
        }
        bypass = true;
        upsert subAssetToCreate.values() SBQQ__SubscribedAsset__c.QS_UpsertKey__c;
        bypass = false;
    }
/**
* Description : Method to insert CustomerAssetDetail records
**/
    private void insertCustomerAssetDetail(List<SBQQ__Subscription__c> listSubscriptions, List<QS_Customer_Asset__c> listCustomerAssets, Map<Id, Product2> generateAssetProductById) {
        List<QS_Customer_Asset_Detail__c> listCustomerAssetDetailToInsert = new List<QS_Customer_Asset_Detail__c>();
        QS_Customer_Asset_Detail__c cAssetDetailStatus = new QS_Customer_Asset_Detail__c();
        Map<String, QS_Customer_Asset__c> customerAssetByKey = new Map<String, QS_Customer_Asset__c>();
        Set<String> caids = new Set<String>();
        for(QS_Customer_Asset__c ca: listCustomerAssets) {
            customerAssetByKey.put(ca.QS_Customer_Asset_Unique_Id__c, ca);
            caids.add(ca.id);
        }
        List<QS_Customer_Asset_Detail__c> 
            lstcad = [SELECT id,QS_Quantity__c,QS_Terminated_Date__c,QS_Booking_Date__c,QS_Asset_Status__c,QS_Customer_Asset__c,Name,QS_Start_Date__c,QS_End_Date__c,CreatedDate,
                      QS_CA_Quantity__c,QS_Subscription__r.Id,QS_Subscription__r.SBQQ__TerminatedDate__c from QS_Customer_Asset_Detail__c 
                      where QS_Customer_Asset__c In :caids AND QS_Renewed_Date__c = NULL order by CreatedDate ]; 
        System.debug('LST Cad' + lstcad);
        
        Map<String,Decimal> mapCaIdToQuantity = new Map<String,Decimal>(); 
        Date currentDate = System.today();
        for(QS_Customer_Asset_Detail__c cad:lstcad)
        {
          if(mapCaIdToQuantity.containsKey(cad.QS_Customer_Asset__c))
           {
               Decimal quantity = mapCaIdToQuantity.get(cad.QS_Customer_Asset__c);
               mapCaIdToQuantity.put(cad.QS_Customer_Asset__c,quantity + cad.QS_Quantity__c);
           }
           else
           {
               mapCaIdToQuantity.put(cad.QS_Customer_Asset__c,cad.QS_Quantity__c); 
           }
            
        }
        Date effective_terminated_Date;
        system.debug('mapCaIdToQuantity=='+mapCaIdToQuantity);
        for(SBQQ__Subscription__c sub : listSubscriptions) {
            System.debug('TIGER Quantity:' + sub.QS_CA_Quantity__c);
            if(sub.QS_CA_Quantity__c == 0 && !CA2_CustomerAssetUtil.CS_flag.Contracting_Opp_No_CAD_Creation__c)
                continue;
            QS_Customer_Asset_Detail__c cAssetDetail = new QS_Customer_Asset_Detail__c();
            cAssetDetail.QS_UniqueKey__c = sub.Id;
            QS_Customer_Asset__c cAsset = customerAssetByKey.get(sub.QS_Customer_Asset_Unique_Id__c);
            if(cAsset == null || generateAssetProductById.get(cAsset.QS_Product__c) == null) { continue; }
            cAssetDetail.QS_Customer_Asset__c = cAsset.Id;
            cAssetDetail.QS_Product__c = cAsset.QS_Product__c;
            cAssetDetail.QS_Subscription__c = sub.Id;
            cAssetDetail.QS_Contract__c = sub.SBQQ__Contract__c;
            cAssetDetail.QS_Quantity__c = sub.QS_CA_Quantity__c;           
            cAssetDetail.QS_Start_Date__c = sub.QS_CA_Start_Date__c;
            cAssetDetail.QS_One_Time_Fee__c = 0;
            cAssetDetail.CurrencyIsoCode = sub.CurrencyIsoCode;
            cAssetDetail.QS_Annual_Recurring_Revenue__c = sub.QS_Annual_Recurring_Revenue__c;
            cAssetDetail.QS_End_Date__c = sub.QS_CA_End_Date__c;
            if(subsWithRelated.get(sub.Id) != null && 
               subsWithRelated.get(sub.Id).SBQQ__QuoteLine__r != null && 
               subsWithRelated.get(sub.Id).SBQQ__QuoteLine__r.SBQQ__Quote__r != null && 
               subsWithRelated.get(sub.Id).SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r != null) {
                cAssetDetail.QS_Decommission_Reason__c = subsWithRelated.get(sub.Id).SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.QS_Decommission_Reason__c;    
            }
              if(sub.SBQQ__SegmentIndex__c <> null){
                	mapCaIdToQuantity = getMapofCAtoQUantityForCurrentPeriod(lstCad, cAsset, cAssetDetail);
                }
                
                if(sub.QS_CA_Quantity__c <= 0 || (cAssetDetail != null && cAssetDetail.QS_Terminated_Date__c != null) )           
                {
                    getAssetDetailStatusFromNegativeQuantity(cAssetDetail,sub);
                    cAssetDetail.QS_Currently_Active__c = CA2_CustomerAssetUtil.getCurrentlyActiveflagFromCAD(cAssetDetail);
                }else
                {
                    cAssetDetailStatus = CA2_CustomerAssetUtil.CustomerAssetDetailStatus(cAssetDetail, cAsset, generateAssetProductById.get(cAsset.QS_Product__c), mapCaIdToQuantity);
                    cAssetDetail.QS_Asset_Status__c = cAssetDetailStatus.QS_Asset_Status__c; 
                    
                    cAssetDetail.QS_Currently_Active__c = cAssetDetailStatus.QS_Currently_Active__c;
              
                }
                       
              
              listCustomerAssetDetailToInsert.add(cAssetDetail);
        }
        upsert listCustomerAssetDetailToInsert QS_Customer_Asset__c.QS_UniqueKey__c;
        updateHistoricalCads(lstcad);
    }
   
    
    public Map<String,Decimal> getMapofCAtoQUantityForCurrentPeriod(List<QS_Customer_Asset_Detail__c> lstCad, QS_Customer_Asset__c ca,QS_Customer_Asset_Detail__c cad)
    {
        Map<String,Decimal> returnedMap = new Map<String,Decimal>();
        for(QS_Customer_Asset_Detail__c currentCADInList : lstCad)
        {
            if(currentCADInList.QS_End_Date__c == cad.QS_End_Date__c)
            {
                if(returnedMap.containsKey(cad.QS_Customer_Asset__c))
               {
                   Decimal quantity = returnedMap.get(cad.QS_Customer_Asset__c);
                   returnedMap.put(cad.QS_Customer_Asset__c,quantity + currentCADInList.QS_Quantity__c);
               }
               else
               {
                   returnedMap.put(cad.QS_Customer_Asset__c,currentCADInList.QS_Quantity__c); 
               }
            }
        }
        System.debug('Current Iteration CAD Id' + cad.Name);
        System.debug('Current Returned Map' + returnedMap);
        return returnedMap;
    }
    
    public QS_Customer_Asset_Detail__c getAssetDetailStatusFromNegativeQuantity(QS_Customer_Asset_Detail__c cad,SBQQ__Subscription__c sub)
    {
        
        QS_Customer_Asset_Detail__c cAssetDetailStatus;
        
        	
			// Ved: For any subscription that has a 0 quantity OR a terminated date, then we know for sure its
			// decommissioned        
           	if(sub.QS_CA_Quantity__c == 0) 	
            {
                if(dt >= sub.SBQQ__StartDate__c && cad.QS_Asset_Status__c <> 'Expired' && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction')
                {
                    cad.QS_Asset_Status__c = 'Decommissioned';
                     cad.QS_Transaction_Type__c = 'Decommission';
                }else
                {
                    cad.QS_Asset_Status__c = 'Pending Decommission';
                     cad.QS_Transaction_Type__c = 'Decommission';
                }
                return cad;
            }
        
        	if(sub.SBQQ__TerminatedDate__c <> null){
                Date effective_terminated_Date = Date.valueOf(sub.SBQQ__TerminatedDate__c.addDays(1));
                 System.debug(' effective_terminated_Date' + effective_terminated_Date);
                if(dt >= effective_terminated_Date && cad.QS_Asset_Status__c <> 'Expired' && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction')
                {
                    SYstem.debug('In Decom Logic');
                    cad.QS_Asset_Status__c = 'Decommissioned';
                    cad.QS_Transaction_Type__c = 'Decommission';
                }
                
                if(dt < effective_terminated_Date && cad.QS_Asset_Status__c <> 'Expired' && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction')
                {
                    SYstem.debug('In Pending Decommission Logic');
                    cad.QS_Asset_Status__c = 'Pending Decommission';
                    cad.QS_Transaction_Type__c = 'Decommission';
                    
                }
                
            }else
            {
                        if(dt >= sub.SBQQ__StartDate__c && cad.QS_Asset_Status__c <> 'Expired' && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction')
                        {
                            cad.QS_Asset_Status__c = 'Reduced';
                           cad.QS_Transaction_Type__c = 'Reduction';
                            
                        }
                        if(dt < sub.SBQQ__StartDate__c && cad.QS_Asset_Status__c <> 'Expired' && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction')
                        {
                            cad.QS_Asset_Status__c = 'Pending Reduction';
                            cad.QS_Transaction_Type__c = 'Reduction';
                        }
            
            }
        return cad;
    }
    
    public void updateHistoricalCads(List<QS_Customer_Asset_Detail__c> lstCad)
    {
         Date currentDate = System.today();
         Date effective_terminated_Date1;
         List<QS_Customer_Asset_Detail__c> listOfCadsToUpdate = new List<QS_Customer_Asset_Detail__c>();
        for(QS_Customer_Asset_Detail__c cad:lstcad)
        {
            	if(cad.QS_CA_Quantity__c == 0)
                {
                    if(currentDate >= cad.QS_Start_Date__c)
                    {
                        cad.QS_Asset_Status__c = 'Decommissioned';
                    }else
                    {
                        cad.QS_Asset_Status__c = 'Pending Decommission';
                    }
                }else
                {
                    if(cad.QS_Terminated_Date__c != null)
                    {
                        effective_terminated_Date1 = Date.valueOf(cad.QS_Terminated_Date__c.addDays(1));
                        
                        if(currentDate >= effective_terminated_Date1 && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction' && cad.QS_Asset_Status__c <> 'Decommissioned' && cad.QS_Asset_Status__c <> 'Expired')
                        {
                            cad.QS_Asset_Status__c = 'Decommissioned';
                        }
                        
                        if(currentDate < effective_terminated_Date1 && cad.QS_Asset_Status__c <> 'Reduced' && cad.QS_Asset_Status__c <> 'Pending Reduction' && cad.QS_Asset_Status__c <> 'Decommissioned' && cad.QS_Asset_Status__c <> 'Expired')
                        {
                            cad.QS_Asset_Status__c = 'Pending Decommission';
                        }
                        cad.QS_UniqueKey__c = cad.QS_Subscription__r.Id;
                                            
                    }
                }
            
                  
            listOfCadsToUpdate.add(cad);
        }
        
        update listOfCadsToUpdate;
        
        
        
    }
}