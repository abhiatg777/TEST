/**
 * Util class that contains static methods and holds
 * static sets with all the relevant fields that are maintained
 * across Vista Asset handler classes.
 * 
 * @author Advanced Technology Group (www.atginfo.com)
 * @date
 */
 public without sharing class CA2_CustomerAssetUtil {
    public static QS_customer_asset_settings__c CS_flag = QS_customer_asset_settings__c.getInstance();
    public static Map<Id, Product2> queryProductsById(Set<Id> setProdIds) {
        if(setProdIds == null || setProdIds.isEmpty()) {
            return new Map<Id, Product2>();
        }
        return new Map<Id, Product2>([SELECT Id, SBQQ__PricingMethod__c, SBQQ__SubscriptionPricing__c, QS_Auto_Activate__c, QS_Auto_Deactivate__c 
                                                                    FROM Product2 
                                                                    WHERE QS_Generate_Asset__c = true AND Id IN :setProdIds]);
    }

    public static List<QS_Customer_Asset__c> queryCAByUniqueId(Set<String> uniqueIdSet) {
        if(uniqueIdSet == null || uniqueIdSet.isEmpty()) {
            return new List<QS_Customer_Asset__c>();
        } 
        return [SELECT Id, QS_Product__c, QS_Customer_Asset_Unique_Id__c, QS_Quantity__c, QS_Product__r.QS_Generate_Asset__c, QS_Product__r.QS_Auto_Activate__c, QS_Product__r.QS_Auto_Deactivate__c 
                                                                    FROM QS_Customer_Asset__c 
                                                                    WHERE QS_Customer_Asset_Unique_Id__c IN :uniqueIdSet];
    }
    /**
     * Private set that holds all the relevant fields for Subscriptions.
     */     
     public static Set<String> Subscription_CAUniqueId(List<SBQQ__Subscription__c> Subscriptions){         
         //Find the QS_Customer_Asset_Unique_Id__c from the Subscriptions
         List<SBQQ__Subscription__c> SubscriptionWithCustomerAsset = [SELECT id,QS_Customer_Asset_Unique_Id__c,QS_Booking_Date__c FROM SBQQ__Subscription__c
                                                                      where id in :Subscriptions];       
         //Create the set of Id who have CustomerId
         Set<String> mapCustomerAsset = new Set<String>();
         for(SBQQ__Subscription__c s: SubscriptionWithCustomerAsset){
             mapCustomerAsset.add(s.QS_Customer_Asset_Unique_Id__c);
         }
         
         return mapCustomerAsset;
   
     }
                                                                             
     public static Set<String> getMatchingKeys(List<Asset> assets){
         //Find the QS_Customer_Asset_Unique_Id__c from the Assets
         //Create the set of Id who have CustomerId
         Set<String> uniqueIdSet = new Set<String>();
         for(Asset a: assets){
             if(!String.IsBlank(a.QS_Customer_Asset_Unique_Id__c)) {
                 uniqueIdSet.add(a.QS_Customer_Asset_Unique_Id__c);
             }
         }
         return uniqueIdSet;
   
     }
      public static Set<String> getMatchingKeys(List<SBQQ__SubscribedAsset__c> subAssets){
         Set<String> uniqueIdSet = new Set<String>();
         for(SBQQ__SubscribedAsset__c a: subAssets){
             if(!String.IsBlank(a.QS_Customer_Asset_Unique_Id__c)) {
                 uniqueIdSet.add(a.QS_Customer_Asset_Unique_Id__c);
             }
         }
         
         //Return the Customer Asset Id list                                                         
         return uniqueIdSet;                                                
   
     }
     public static QS_customer_asset_settings__c CASettings { get {
        if(CASettings == null) {
            CASettings = QS_customer_asset_settings__c.getInstance();
        }
        return CASettings;
    } set; }

     public static QS_Customer_Asset_Detail__c CustomerAssetDetailStatus(QS_Customer_Asset_Detail__c cad, QS_Customer_Asset__c ca, Product2 product,Map<String,Decimal> mapCaIdToQuantity ){
        return CustomerAssetDetailStatus(null, cad, ca, product,mapCaIdToQuantity);
     }
     public static QS_Customer_Asset_Detail__c CustomerAssetDetailStatus(SBQQ__Subscription__c sub, QS_Customer_Asset_Detail__c cad, QS_Customer_Asset__c ca, Product2 product,Map<String,Decimal> mapCaIdToQuantity ){
         Integer afterDays = CASettings == null || Integer.valueOf(CASettings.QS_Expiration_Days__c) == null ? 0 : Integer.valueOf(CASettings.QS_Expiration_Days__c);
         Date currentDate = System.today();
         Date startDate = cad.QS_Start_Date__c;
         Date endDate = cad.QS_End_Date__c;
         Boolean autoActivate = product.QS_Auto_Activate__c;
         system.debug('AutoActivate ' + autoActivate);
         system.debug('CASettings== ' + CASettings);
         system.debug('afterDays== ' + afterDays);
         Boolean autoDeactivate = product.QS_Auto_Deactivate__c;
         Integer detailQty = Integer.valueOf(cad.QS_Quantity__c);
         integer customerAssetQty = 0;
         Date effective_terminated_Date;
         if(mapCaIdToQuantity.containsKey(ca.Id)) {
             customerAssetQty = Integer.valueOf(mapCaIdToQuantity.get(ca.Id));
         }
		
        system.debug('util sub' + sub);
        system.debug('Util cad' + cad);
        system.debug('Util ca' + ca);
       
         Date effectiveEndDate;         
         
         //For Asset (dont have startDate)
         if(startDate == NULL){
             startDate = currentDate;
         }
         
         //calculate the Effective End Date
         if(endDate != NULL){
             effectiveEndDate = endDate + afterDays;
         } else {
             //if is an Asset then never expired
             effectiveEndDate = currentDate + 2;
         }
         //IF 0 QTY POT, and the revised subscription is populated, then process normally,

         		if(cad.QS_Terminated_Date__c != null)
                    {
                        System.debug('CAD Terminated Date' + cad.QS_Terminated_Date__c);
                        effective_terminated_Date = Date.valueOf(cad.QS_Terminated_Date__c.addDays(1));
                    	
                        if(currentDate > effective_terminated_Date 
                       	&& cad.QS_Asset_Status__c <> 'Reduced' 
                        && cad.QS_Asset_Status__c <> 'Pending Reduction'
                       	&& cad.QS_Asset_Status__c <> 'Expired')
                    	{
                            SYstem.debug('In Decom Logic');
                            cad.QS_Asset_Status__c = 'Decommissioned';
                            cad.QS_Transaction_Type__c = 'Decommission';
                           
                        }
                        
                        if(currentDate <= effective_terminated_Date 
                       	&& cad.QS_Asset_Status__c <> 'Reduced'
                        && cad.QS_Asset_Status__c <> 'Pending Reduction'   
                       	&& cad.QS_Asset_Status__c <> 'Expired')
                    	{
                            SYstem.debug('In Pending Decommission Logic');
                            cad.QS_Asset_Status__c = 'Pending Decommission';
                          cad.QS_Transaction_Type__c = 'Decommission';
                        }
                        
						return cad;                        
                    }
         
            if(sub != null && sub.SBQQ__RevisedSubscription__c != null 
               && cad.QS_Annual_Recurring_Revenue__c > 0 
               && cad.QS_Maintain_Line__c == true) 
            {
                if (AutoActivate == True 
                    && startDate <= currentDate 
                    && currentDate < effectiveEndDate) {
                    // if the Dates felt out inside in the requirement
                    cad.QS_Asset_Status__c = 'Active';
                     cad.QS_Transaction_Type__c = 'Sale';
                                        
                } else {
                    if (currentDate < effectiveEndDate) {
                        cad.QS_Asset_Status__c = 'Pending Activation';
                         cad.QS_Transaction_Type__c = 'Sale';
						                   
                        
                    } else {
                        //Expired Customer Asset Detail
                        if(currentDate >= effectiveEndDate){
                            cad.QS_Asset_Status__c = 'Expired';
                             cad.QS_Transaction_Type__c = 'Sale';
                            
                        }                        
                    }                    
                }
            } else if((sub == null || sub.SBQQ__RevisedSubscription__c == null) && detailQty == 0)
            { 
               
                //IF detailQty == 0, the Status = Pending Decommission or Decommission
                 if(AutoDeactivate == True || startDate <= currentDate) {
                     
                    cad.QS_Asset_Status__c = 'Pending Decommission';
                      cad.QS_Transaction_Type__c = 'Decommission';
                     
                 } else {
                    cad.QS_Asset_Status__c = 'Decommissioned';
                      cad.QS_Transaction_Type__c = 'Decommission';
                      
                    
                 }
            } else if (detailQty > 0) {
                if (AutoActivate == True && startDate <= currentDate && currentDate < effectiveEndDate) {
                    cad.QS_Asset_Status__c = 'Active';
                     cad.QS_Transaction_Type__c = 'Sale';
                  } else {
                   
                    if (currentDate < startDate) {
                       
                        cad.QS_Asset_Status__c = 'Pending Activation'; 
                         cad.QS_Transaction_Type__c = 'Sale';
                        
                        
                    } else {
                        //Expired Customer Asset Detail
                        if(currentDate > effectiveEndDate){
                            cad.QS_Asset_Status__c = 'Expired';
                             cad.QS_Transaction_Type__c = 'Sale';
                            
                            
                            
                        }                        
                    }                    
                }
            }
           
         cad.QS_Currently_Active__c = getCurrentlyActiveflagFromCAD(cad);		

         return cad;
     }
	
     	public static Boolean getCurrentlyActiveflagFromCAD(QS_Customer_Asset_Detail__c cad)
        {
            Date currentDate = System.today();
            if(cad.QS_Asset_Status__c == 'Expired')
                {
                    return false;
                }
            	else if(cad.QS_End_Date__c < currentDate)
                {
                    return false;
                }    
                else if(cad.QS_End_Date__c >= currentDate && cad.QS_Start_Date__c <= currentDate)
                {
                    return true;
                }
                else if(cad.QS_End_Date__c > currentDate && cad.QS_Start_Date__c > currentDate)
                {
                    return false;
                }
				if(cad.QS_End_Date__c == null){
					return false;
				}
            
            return false;
            
        }

     
}