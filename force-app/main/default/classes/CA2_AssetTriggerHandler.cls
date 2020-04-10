/**
 * Class to insert Customer Asset and Customer Asset Detail records on insert of Asset and SubscribedAsset.
 *
 * @author: Saketha Angirekula / Advanced Technology Group (www.atginfo.com)
 */
public class CA2_AssetTriggerHandler extends CA2_TriggerHandler {
    
    /**
     * Handler entry point after insert.
     */
    protected override void afterInsert(){
        createCustomerAssets((List<Asset>)Trigger.new, new Map<Id, SBQQ__SubscribedAsset__c>());
    }
    /**
     * Handler entry point after update.
     */
    protected override void afterUpdate(){
        if(CA2_CustomerAssetUtil.CS_flag.QS_Generate_CA_on_Update__c) {
            createCustomerAssets((List<Asset>)Trigger.new, new Map<Id, SBQQ__SubscribedAsset__c>());    
        }
    }
    
    /**
     * Creates Customer Assets based on Subscribed Assets list.
     * @param subAssetList list of subscribed assets.
     */
    public static void createCustomerAssets(List<SBQQ__SubscribedAsset__c> subAssetList) {
        Set<String> setExistingAssetIds = new Set<String>();
        //this map holds the assetId as key and subscriobption id as value. this is used to get the subscription based on asset Id
        Map<Id, SBQQ__SubscribedAsset__c> subAssetById = new Map<Id, SBQQ__SubscribedAsset__c>(subAssetList);
        Set<Id> assetIdSet = new Set<Id>();
        for(SBQQ__SubscribedAsset__c subAsset: subAssetList) {
            if(subAsset.SBQQ__Asset__c != null && !setExistingAssetIds.Contains(subAsset.SBQQ__Asset__c)) {
                if(subAsset.SBQQ__Asset__c != null) {
                    assetIdSet.add(subAsset.SBQQ__Asset__c);
                }
            }
        }
        List<Asset> listAsset = [SELECT Product2Id, QS_Booking_Date__c,CurrencyIsoCode, QS_Effective_Start_Date__c, SBQQ__SubscriptionStartDate__c, Product2.SBQQ__SubscriptionBase__c, SBQQ__SubscriptionEndDate__c, Quantity,AccountId,QS_Customer_Asset_Unique_Id__c,SBQQ__ListPrice__c,SBQQ__PricingMethod__c,QS_Net_Price__c 
                                FROM Asset 
                                WHERE Id IN: assetIdSet];
        
        if(listAsset.size() > 0) {
            CA2_AssetTriggerHandler.createCustomerAssets(listAsset, subAssetById);
        }
    }
    /**
     * Creates Customer Assets based on list of associated assets and subscribed assets.
     * @param lstAssets Assets list.
     * @param subAssetById Subscribed assets map.
     */
    public static void createCustomerAssets(List<Asset> lstAssets, Map<Id, SBQQ__SubscribedAsset__c> subAssetById) {
        // this list is to hold the new list of customerassets that needs to be inserted
        List<QS_Customer_Asset__c> listCustomerAssetToInsert = new List<QS_Customer_Asset__c>();
        Set<Id> setProdIds = new Set<Id>();
        // This map is to Hold Asset ProductId as key and Asset as Value and it is used to get the asset based on product id
        for(Asset asset : lstAssets) {
            setProdIds.add(asset.Product2Id);
        }
        setProdIds.remove(null);
        if(setProdIds.size() > 0) {
            Set<String> existingCustomerAssetKeys = new Set<String>();
            Map<Id, Product2> generateAssetProductById = CA2_CustomerAssetUtil.queryProductsById(setProdIds);
            //This list hold the filtered asserts based on Product that has generate asset true
            List<Asset> assetsToProcess = new List<Asset>();
            for(Asset asset : lstAssets) {
                if(generateAssetProductById.containskey(asset.Product2Id)) {
                    assetsToProcess.add(asset);
                }
            }
            if(assetsToProcess.size() > 0) {
                Set<String> customerAssetUniqueIdSet = new Set<String>();
                customerAssetUniqueIdSet = CA2_CustomerAssetUtil.getMatchingKeys(assetsToProcess);
                // if is an Asset use the Function getMatchingKeys called from the Asset Trigger Handler
                List<QS_Customer_Asset__c> customerAssets = CA2_CustomerAssetUtil.queryCAByUniqueId(customerAssetUniqueIdSet);
                if(customerAssets.size() > 0) {
                    for(QS_Customer_Asset__c ca : customerAssets) {
                        existingCustomerAssetKeys.add(ca.QS_Customer_Asset_Unique_Id__c);
                    }
                }
                //Insert CustomerAsset record
                for(Asset asset : assetsToProcess) {
                    Boolean createdMatchingSA = false;
                    if(!createdMatchingSA) {
                        if(!existingCustomerAssetKeys.contains(asset.QS_Customer_Asset_Unique_Id__c)) {
                            QS_Customer_Asset__c cAsset = new QS_Customer_Asset__c();
                            if(generateAssetProductById.keySet().contains(asset.Product2Id)){
                                cAsset.QS_Account__c = asset.AccountId;
                                cAsset.QS_Product__c = asset.Product2Id;
                                cAsset.QS_Customer_Asset_Unique_Id__c = asset.QS_Customer_Asset_Unique_Id__c;
                                cAsset.CurrencyIsoCode = asset.CurrencyIsoCode;
                                cAsset.QS_Product_Category__c = 'Asset';
                                existingCustomerAssetKeys.add(asset.QS_Customer_Asset_Unique_Id__c);//prevent double adds
                                listCustomerAssetToInsert.add(cAsset);
                            }
                        }
                    }
                }
                insert listCustomerAssetToInsert;

                // add the customer assets thats need be inserted to the main list of customerassers
                customerAssets.addAll(listCustomerAssetToInsert);
                if(subAssetById.size() > 0) {
                    insertCustomerAssetDetailForSubscribedAssets(assetsToProcess, customerAssets, subAssetById, generateAssetProductById); 
                } else {
                    insertCustomerAssetDetail(assetsToProcess, customerAssets, generateAssetProductById);
                }
            }
        }

    }
    
    /**
     * Method inserts Customer Asset Detail records on insert of Asset.
     * @param assetsToProcess Assets objects to be processed.
     * @param customerAssets Customer Assets related to assets.
     * @param generateAssetProductById map of product IDs.
     */
    public static void insertCustomerAssetDetail(List<Asset> assetsToProcess, List<QS_Customer_Asset__c> customerAssets, Map<Id, Product2> generateAssetProductById) {
        Map<String, QS_Customer_Asset__c> customerAssetByKey = new Map<String, QS_Customer_Asset__c>();
        Set<String> caids = new Set<String>();
        for(QS_Customer_Asset__c ca: customerAssets) {
            customerAssetByKey.put(ca.QS_Customer_Asset_Unique_Id__c, ca);
            caids.add(ca.id);
        }

        List<QS_Customer_Asset_Detail__c> lstcad = [SELECT id,QS_Quantity__c,QS_Customer_Asset__c,QS_Booking_Date__c from QS_Customer_Asset_Detail__c where QS_Customer_Asset__c In :caids and QS_Renewed_Date__c = null]; 
        Map<String,Decimal> mapCaIdToQuantity = new Map<String,Decimal>(); 
        for(QS_Customer_Asset_Detail__c cad:lstcad)  {
           if(mapCaIdToQuantity.containsKey(cad.QS_Customer_Asset__c)) {
               Decimal quantity = mapCaIdToQuantity.get(cad.QS_Customer_Asset__c);
               mapCaIdToQuantity.put(cad.QS_Customer_Asset__c,quantity + cad.QS_Quantity__c);
           } else {
              mapCaIdToQuantity.put(cad.QS_Customer_Asset__c,cad.QS_Quantity__c); 
           }
        }
        List<QS_Customer_Asset_Detail__c> customerAssetDetailToInsert = new List<QS_Customer_Asset_Detail__c>();

        for(Asset asset : assetsToProcess) {
            QS_Customer_Asset_Detail__c cAssetDetail = new QS_Customer_Asset_Detail__c();
            cAssetDetail.QS_UniqueKey__c = asset.Id;
            QS_Customer_Asset__c cAsset = customerAssetByKey.get(asset.QS_Customer_Asset_Unique_Id__c);
            if(cAsset == null || generateAssetProductById.get(cAsset.QS_Product__c) == null) { continue; }
            cAssetDetail.QS_Customer_Asset__c = cAsset.Id;
            cAssetDetail.QS_Product__c = cAsset.QS_Product__c;
            cAssetDetail.QS_Asset__c = asset.Id;
            cAssetDetail.QS_Quantity__c = asset.Quantity;
            cAssetDetail.QS_One_Time_Fee__c =  asset.QS_Net_Price__c;
            cAssetDetail.QS_Annual_Recurring_Revenue__c = 0;
            cAssetDetail.CurrencyIsoCode = asset.CurrencyIsoCode;
            if(asset.QS_Effective_Start_Date__c != null) {
                cAssetDetail.QS_Start_Date__c = asset.QS_Effective_Start_Date__c;
            }
            
            QS_Customer_Asset_Detail__c cAssetDetailStatus = CA2_CustomerAssetUtil.CustomerAssetDetailStatus(cAssetDetail, cAsset, generateAssetProductById.get(cAsset.QS_Product__c), mapCaIdToQuantity);
            cAssetDetail.QS_Asset_Status__c = cAssetDetailStatus.QS_Asset_Status__c;
            cAssetDetail.QS_Currently_Active__c = cAssetDetailStatus.QS_Currently_Active__c;                      
            

            customerAssetDetailToInsert.add(cAssetDetail);
        }
        upsert customerAssetDetailToInsert QS_Customer_Asset_Detail__c.QS_UniqueKey__c;
    }
    /**
     * Method inserts Customer Asset Detail records on insert of Subscribed Assets.
     * @param assetsToProcess Assets objects to be processed.
     * @param customerAssets Customer Assets related to assets.
     * @param subAssetById map of Subscribed Assets.
     * @param generateAssetProductById map of product IDs.
     */
    public static void insertCustomerAssetDetailForSubscribedAssets(List<Asset> assetsToProcess, List<QS_Customer_Asset__c> customerAssets, Map<Id, SBQQ__SubscribedAsset__c> subAssetById, Map<Id, Product2> generateAssetProductById) {
        Map<String, QS_Customer_Asset__c> customerAssetByKey = new Map<String, QS_Customer_Asset__c>();
        Set<String> caids = new Set<String>();
        for(QS_Customer_Asset__c ca: customerAssets) {
            customerAssetByKey.put(ca.QS_Customer_Asset_Unique_Id__c, ca);
            caids.add(ca.id);
        }

        List<QS_Customer_Asset_Detail__c> customerAssetDetailToInsert = new List<QS_Customer_Asset_Detail__c>();       
        Set<Id> setSubscriptionIds = new Set<Id>();
        for(SBQQ__SubscribedAsset__c sa: subAssetById.values()) {
            setSubscriptionIds.add(sa.SBQQ__Subscription__c);
        }
       
        List<QS_Customer_Asset_Detail__c> lstcad = [SELECT id,QS_Quantity__c,QS_Customer_Asset__c,QS_Booking_Date__c from QS_Customer_Asset_Detail__c where QS_Customer_Asset__c In :caids]; 
        Map<String,Decimal> mapCaIdToQuantity = new Map<String,Decimal>(); 
        for(QS_Customer_Asset_Detail__c cad: lstcad){
           if(mapCaIdToQuantity.containsKey(cad.QS_Customer_Asset__c)) {
               Decimal quantity = mapCaIdToQuantity.get(cad.QS_Customer_Asset__c);
               mapCaIdToQuantity.put(cad.QS_Customer_Asset__c,quantity + cad.QS_Quantity__c);
           } else {
              mapCaIdToQuantity.put(cad.QS_Customer_Asset__c, cad.QS_Quantity__c); 
           }
        }
        
        Map<Id, SBQQ__Subscription__c> subscriptionById = new Map<Id, SBQQ__Subscription__c>();
        if(setSubscriptionIds.size() > 0) {
            //Get subscription's net price for ARR calculation
            subscriptionById = new Map<Id, SBQQ__Subscription__c>([SELECT Id, SBQQ__StartDate__c, SBQQ__RevisedSubscription__c,QS_Booking_Date__c, SBQQ__RevisedSubscription__r.SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__EndDate__c, SBQQ__Contract__c, SBQQ__NetPrice__c, SBQQ__ListPrice__c, QS_Customer_Asset_Unique_Id__c 
                                                                        FROM SBQQ__Subscription__c 
                                                                        WHERE Id IN :setSubscriptionIds]);
        }
        //Insert CustomerAssetDetail record
        for(SBQQ__SubscribedAsset__c sa: subAssetById.values()) {
            for(Asset asset : assetsToProcess) {
                if(sa.SBQQ__Asset__c == asset.Id) {
                    Id subId = sa.SBQQ__Subscription__c;
                    QS_Customer_Asset_Detail__c cAssetDetail = new QS_Customer_Asset_Detail__c();
                    cAssetDetail.QS_UniqueKey__c = sa.Id;
                    cAssetDetail.QS_Subscribed_Asset__c = sa.Id;
                    SBQQ__Subscription__c subsc = subscriptionById.get(subId);
                    QS_Customer_Asset__c cAsset = customerAssetByKey.get(subsc.QS_Customer_Asset_Unique_Id__c);
                    if(cAsset == null) {
                        cAsset = customerAssetByKey.get(asset.QS_Customer_Asset_Unique_Id__c);
                    }
                    if(cAsset == null || generateAssetProductById.get(cAsset.QS_Product__c) == null) { continue; }
                    cAssetDetail.QS_Customer_Asset__c = cAsset.Id;
                    cAssetDetail.QS_Product__c = subsc.SBQQ__Product__c;
                    cAssetDetail.QS_Asset__c = asset.Id;
                    cAssetDetail.QS_One_Time_Fee__c = 0;
                    cAssetDetail.CurrencyIsoCode = asset.CurrencyIsoCode;
                    //cAssetDetail.QS_Booking_Date__c = subsc.QS_Booking_Date__c;
                    cAssetDetail.QS_Contract__c = subsc.SBQQ__Contract__c;
                    cAssetDetail.QS_Start_Date__c = subsc.SBQQ__StartDate__c;
                    cAssetDetail.QS_End_Date__c = subsc.SBQQ__EndDate__c;
                    if(sa.QS_Created_By_Apex__c) {
                        cAssetDetail.QS_Quantity__c = subsc.SBQQ__Quantity__c;    
                    } else {
                        cAssetDetail.QS_Quantity__c = sa.QS_Subscription_Quantity__c;
                    }
                    
                    cAssetDetail.QS_Subscription__c = subsc.Id;
                    cAssetDetail.QS_Maintain_Line__c = true;
                    //if amendment
                    //Calculate CAD Status
                    QS_Customer_Asset_Detail__c cAssetDetailStatus = CA2_CustomerAssetUtil.CustomerAssetDetailStatus(subsc, cAssetDetail, cAsset, generateAssetProductById.get(cAsset.QS_Product__c), mapCaIdToQuantity);
                    cAssetDetail.QS_Asset_Status__c = cAssetDetailStatus.QS_Asset_Status__c;
                    cAssetDetail.QS_Currently_Active__c = cAssetDetailStatus.QS_Currently_Active__c;
                    cAssetDetail.QS_Annual_Recurring_Revenue__c = sa.QS_Annual_Recurring_Revenue__c;
                    customerAssetDetailToInsert.add(cAssetDetail);
                }
            }
        }

        System.debug('customerAssetDetailToInsert==' + customerAssetDetailToInsert);
        upsert customerAssetDetailToInsert QS_Customer_Asset__c.QS_UniqueKey__c;
    }
    /**
     * Undelete handler for subscribed assets.
     * @param subAssetlist list of subscribed assets.
     */
    public static void undeleteSubAssets(List<SBQQ__SubscribedAsset__c> subAssetList) {
        Set<Id> toUndelete = new Set<Id>();
        for(SBQQ__SubscribedAsset__c sa: subAssetList) {
            if(sa.QS_Created_By_Apex__c) {
                toUndelete.add(sa.Id);
            }
        }
        if(toUndelete.size() > 0) {
            undeleteSubAssetsIDs(toUndelete);
        }
    }
    @future
    private static void undeleteSubAssetsIDs(Set<Id> subAssetIDs) {
        List<SBQQ__SubscribedAsset__c> saList = new List<SBQQ__SubscribedAsset__c>();
        for(Id i: subAssetIDs) {
            saList.add(new SBQQ__SubscribedAsset__c(Id = i));
        }
        try {
            undelete saList;
        } catch (Exception e) {
            System.debug(e);
        }
    }
}