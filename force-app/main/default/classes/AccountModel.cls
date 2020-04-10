public with sharing class AccountModel
{
    
    private boolean ClientInstall = false;
//    public String regEventType {get; set;}

    public AccountModel(Account a, Boolean isPortal)
    {
        record = a;
        if(isPortal == null) isPortal = false;
        
        this.isPortal = isPortal;
    }
    
    public AccountModel(Account a)
    {
        this(a, false);
    }
    
    public Account record {get; set;}
    public Boolean isCommitted{ get{return (record != null && record.Id != null);}}
    public Boolean isPortal{get; private set;}
    
    public List<SelectOption> accountOptions;
    
    public Map<String, List<SelectOption>> mapAccountToContacts {get; private set;}
    public Map<String, List<SelectOption>> mapAccountToSupportContacts {get; private set;}
    //public Map<String, List<SelectOption>> mapAccountToEntitlements {get; private set;}
    //public Map<String, List<SelectOption>> mapEntitlementToProductFamilies {get; set;}
    //public Map<String, List<SelectOption>> mapEntProductFamilyToAssets {get; set;}
    public Map<String, List<SelectOption>> mapAccountToProductFamilies {get; set;}
    public Map<String, List<SelectOption>> mapProductFamilyToProductLines {get; set;}
    public Map<String, List<SelectOption>> mapPfProductLineToAssets {get; set;}
    //public Map<String, List<SelectOption>> mapAssetToPractices {get; set;}
    //public Map<String, List<SelectOption>> mapAssetToVersions {get; private set;}
    //public Map<String, List<SelectOption>> mapVersionFamilyToVersions {get; private set;}   
    //public Map<String, List<SelectOption>> mapAssetToComponents {get; private set;}
    //public Map<String, List<SelectOption>> mapComponentToSubComponents {get; private set;}
    
    //Map<ID, Entitlement__c> entitlementMap = new Map<ID, Entitlement__c>();
    Map<ID, Asset> assetMap = new Map<ID, Asset>();
    Map<ID, Account> accountMap = new Map<ID, Account>();
    
    public void getAccounts()
    {
        accountOptions = new List<SelectOption>();
        accountMap.put(record.id, record);
        
        
        getContacts(accountMap.keySet(),  null);
        getSupportContacts(accountMap.keySet(),  null);
        getProductFamiliesProductLinesAndAssets(accountMap.keySet());
        
    }
    
    public void getContacts(Set<ID> accountIDs, String contactId)
    {
        mapAccountToContacts = new Map<String, List<SelectOption>>();
        //If a Contact is already selected, put it first in the list
        if (contactId != null) {
          List<Contact> selectedContacts = [SELECT ID, AccountID, LastName, FirstName
                         FROM Contact
                          WHERE Id = :contactId
                          AND AccountID IN :accountIDs];
            if (selectedContacts.size() > 0) {
              Contact selectedContact = selectedContacts[0];
              List<SelectOption> contactList;
              if(mapAccountToContacts.containsKey(selectedContact.AccountID))
                  contactList = mapAccountToContacts.get(selectedContact.AccountID);
              else
                  contactList = new List<SelectOption>();
            
            contactList.add(new SelectOption(selectedContact.id, selectedContact.LastName+', '+selectedContact.FirstName));
            mapAccountToContacts.put(selectedContact.AccountID, contactList);
            }
        }
        for(Contact cnt: [SELECT ID, AccountID, LastName, FirstName 
                          FROM Contact 
                          WHERE AccountID IN :accountIDs
                          ORDER BY LastName, FirstName
                          LIMIT 999])
/** @todo  Is there a 'Status' or 'Active' flag we should filter on?
                                AND Contact_Status__c = 'Active' */
        {
          if ((String)cnt.Id != contactId) {
              List<SelectOption> contactList;
              if(mapAccountToContacts.containsKey(cnt.AccountID))
                  contactList = mapAccountToContacts.get(cnt.AccountID);
              else
                  contactList = new List<SelectOption>();
            
              contactList.add(new SelectOption(cnt.id, cnt.LastName+', '+cnt.FirstName));
              mapAccountToContacts.put(cnt.AccountID, contactList);
          }
        }
    }
    
    public void getSupportContacts(Set<ID> accountIDs, String contactId)
    {
        mapAccountToSupportContacts = new Map<String, List<SelectOption>>();
        //If a Contact is already selected, put it first in the list
        if (contactId != null) {
            List<Contact> selectedContacts = [SELECT ID, AccountID, LastName, FirstName, Account.RecordTypeId
                                       FROM Contact
                                       WHERE Id = :contactId
                                       AND AccountID IN :accountIDs];
            if (selectedContacts.size() > 0) {
                Contact selectedContact = selectedContacts[0];
                List<SelectOption> contactList;
                if(mapAccountToSupportContacts.containsKey(selectedContact.AccountID))
                    contactList = mapAccountToSupportContacts.get(selectedContact.AccountID);
                else
                    contactList = new List<SelectOption>();
                
                contactList.add(new SelectOption(selectedContact.id, selectedContact.LastName+', '+selectedContact.FirstName));
                mapAccountToSupportContacts.put(selectedContact.AccountID, contactList);
            }
        }
        
        //
        // Select Designated Support Contact and Account Record Type as well. We filter on these below as appropriate
        //
        for(Contact cnt: [SELECT Id, LastName, FirstName,
                                 AccountId,
                                 Account.RecordTypeId
                          FROM Contact 
                          WHERE AccountID IN :accountIDs
                          ORDER BY LastName, FirstName
                          LIMIT 999])
/** @todo  Is there a 'Status' or 'Active' flag we should filter on?
                                AND Contact_Status__c = 'Active' */
        {
            if ((String)cnt.Id != contactId) {
                
                if (!mapAccountToSupportContacts.containsKey(cnt.AccountId)) {
                  // Create SelectOption list if it doesn't already exist
                  mapAccountToSupportContacts.put(cnt.AccountId, new List<SelectOption>());
                }
                
                mapAccountToSupportContacts.get(cnt.AccountID).add(new SelectOption(cnt.Id, cnt.LastName + ', ' + cnt.FirstName));
            }
        }
    }
    
    public List<Contact> getSupportContacts(Id accId) {
      return [SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = :accId];
    }
    
    public void getProductFamiliesProductLinesAndAssets(Set<ID> accountIDs)
    {
        if(accountIDs != null && accountIDs.size() > 0)
        {
            mapAccountToProductFamilies = new Map<String, List<SelectOption>>();
            Map<String, Set<String>> mapAccountToProductFamiliesSet = new Map<String, Set<String>>();
            Map<String, List<String>> mapAccountToProductFamiliesList = new Map<String, List<String>>();
            Map<String, Set<String>> mapProductFamilyToProductLineSet = new Map<String, Set<String>>();
            mapProductFamilyToProductLines = new Map<String, List<SelectOption>>();
            mapPfProductLineToAssets = new Map<String, List<SelectOption>>();
            assetMap = new Map<ID, Asset>();
            Map<ID, Set<ID>> mapProductToAssets = new Map<ID, Set<ID>>();
            //Map<ID, ID> mapProductToVersionFamily = new Map<ID, ID>();
            
            //
            // NOTE: The filters on this query need to match up with the query done in CP_VF_PostLogin.getAvailableProducts()
            //
            for(Asset va: [SELECT ID, Name, Product2Id, Product2.Name, Product2.Family, Product2.Product_Line__c, AccountId 
                           FROM Asset
                           WHERE AccountId IN :accountIDs
                              //   AND Status = :Constants.STATUS_ON_MAINTENANCE
                                 AND Product2Id != NULL
                                 AND Product2.IsActive = TRUE
                          ORDER BY Product2.Family ASC
                          LIMIT 1000])
            {
                List<String> productFamiliesList;
                Set<String> productFamiliesSet;
                if(mapAccountToProductFamiliesList.containsKey(va.AccountId)) {
                    productFamiliesList = mapAccountToProductFamiliesList.get(va.AccountId);
                    productFamiliesSet = mapAccountToProductFamiliesSet.get(va.AccountId);
                }
                else {
                    productFamiliesList = new List<String>();
                    productFamiliesSet = new Set<String>();
                }
                if(!GenericServices.isNullOrEmpty(va.Product2.Family) && !productFamiliesSet.contains(va.Product2.Family))
                {   
                    productFamiliesList.add(va.Product2.Family);
                    productFamiliesSet.add(va.Product2.Family);
                    mapAccountToProductFamiliesSet.put(va.AccountId, productFamiliesSet);
                    mapAccountToProductFamiliesList.put(va.AccountId, productFamiliesList);
                }   
                
                Set<String> productLines;
                if(mapProductFamilyToProductLineSet.containsKey(va.Product2.Family))
                    productLines = mapProductFamilyToProductLineSet.get(va.Product2.Family);
                else
                    productLines = new Set<String>();
                if(!GenericServices.isNullOrEmpty(va.Product2.Product_Line__c))
                {
                    productLines.add(va.Product2.Product_Line__c);
                    mapProductFamilyToProductLineSet.put(va.Product2.Family, productLines);
                }   
                
                
                String assetKey = va.Product2.Family+va.Product2.Product_Line__c;
                System.debug(assetKey);
                List<SelectOption> assetList;
                if(mapPfProductLineToAssets.containsKey(assetKey))
                    assetList = mapPfProductLineToAssets.get(assetKey);
                else
                    assetList = new List<SelectOption>();
                assetList.add(new SelectOption(va.id, va.Name));
                mapPfProductLineToAssets.put(assetKey, assetList);
                
                
                Set<ID> assetIDs;
                if(mapProductToAssets.containsKey(va.Product2Id))
                    assetIDs = mapProductToAssets.get(va.Product2Id);
                else
                    assetIDs = new Set<ID>();
                assetIDs.add(va.id); 
                mapProductToAssets.put(va.Product2Id, assetIDs);
                
                assetMap.put(va.id, va);
                //if(!GenericServices.isNullOrEmpty(va.Product2.Version_Family__c))
                //    mapProductToVersionFamily.put(va.Product2Id, va.Product2.Version_Family__c);
            }
            System.debug(mapPfProductLineToAssets);
            //now convert the Set of Product Families in the map to List<SelectOption>
            for(String actID: mapAccountToProductFamiliesList.keySet())
            {
                List<String> familyList = new List<String>();
                familyList.addAll(mapAccountToProductFamiliesList.get(actID));
                List<SelectOption> familySO = new List<SelectOption>();
                for(String family: familyList)
                    familySO.add(new SelectOption(family, family));
                
                mapAccountToProductFamilies.put(actID, familySO);
            }
            
            //now convert the Set of Product Lines in the map to List<SelectOption>
            for(String pf: mapProductFamilyToProductLineSet.keySet())
            {
                List<String> productLineList = new List<String>();
                productLineList.addAll(mapProductFamilyToProductLineSet.get(pf));
                List<SelectOption> productLineSO = new List<SelectOption>();
                for(String pl: productLineList)
                    productLineSO.add(new SelectOption(pl, pl));
                
                mapProductFamilyToProductLines.put(pf, productLineSO);
            }
            
            //getPractices(assetMap.keySet());
            //getVersions(mapProductToAssets, mapProductToVersionFamily);
            //getComponents(mapProductToAssets);
        }
    }    

    public List<SelectOption> getContactOptionsByAccount(String actID, String contactId)
    {
        System.debug('Getting Contact Options');
        Set<ID> acts = new Set<Id>();
        acts.add(actId);
        getContacts(acts, contactId);
        List<SelectOption> contactOptions = new List<SelectOption>();
        if (actId != null) {
          if(mapAccountToContacts != null && mapAccountToContacts.containsKey(actID))
              contactOptions = mapAccountToContacts.get(actID);
          else
              contactOptions.add(new SelectOption('', '-- no contacts available --')); // Constants.NO_CONTACTS_AVAILABLE));
        }
        // Else if actId == null, just return an empty list
        
        system.debug('\n\ncontactoptions size='+contactOptions.size()+'\n');
        
        return contactOptions;
    }
    
    public List<SelectOption> getSupportContactOptionsByAccount(String actID, String contactId)
    {
        System.debug('Getting Support Contact Options');
        Set<ID> acts = new Set<Id>();
        acts.add(actId);
        getSupportContacts(acts, contactId);
        List<SelectOption> contactOptions = new List<SelectOption>();
        if (actId != null) {
            if(mapAccountToSupportContacts != null && mapAccountToSupportContacts.containsKey(actID) && mapAccountToSupportContacts.get(actID).size() > 0) {
                contactOptions = mapAccountToSupportContacts.get(actID);
            }
            else
                contactOptions.add(new SelectOption('', '-- no contacts available --')); // Constants.NO_CONTACTS_AVAILABLE));
        }
        // Else if actId == null, just return an empty list
        
        system.debug('\n\nSupportContactOptions size=' + contactOptions.size() + '\n');
        
        return contactOptions;
    }
    
    public List<SelectOption> getProductFamilyOptionsByAccount(String actID)
    {
        List<SelectOption> productFamilyOptions = new List<SelectOption>();
        Set<ID> acts = new Set<ID>();
        acts.add(actID);
        getProductFamiliesProductLinesAndAssets(acts);
        if(mapAccountToProductFamilies != null && mapAccountToProductFamilies.containsKey(actID))
        {
            //productFamilyOptions.add(new SelectOption('', Constants.NONE));
            productFamilyOptions.addAll(mapAccountToProductFamilies.get(actID));
        }
        else
            productFamilyOptions.add(new SelectOption('', Constants.NO_PRODUCT_FAMILIES_AVAILABLE));
        
        return productFamilyOptions;
        
    }
    
    public List<SelectOption> getProductFamilyOptionsByAccount(String actID, String parentId)
    {
        List<SelectOption> productFamilyOptions = new List<SelectOption>();
        Set<ID> acts = new Set<ID>();
        acts.add(actID);
        if (parentId != null) {
            acts.add(parentId);
        }
        getProductFamiliesProductLinesAndAssets(acts);
        if(mapAccountToProductFamilies != null && (mapAccountToProductFamilies.containsKey(actID) || (parentId != null && mapAccountToProductFamilies.containsKey(parentId))))
        {
            productFamilyOptions.add(new SelectOption('', 'Select One'));
            if (mapAccountToProductFamilies.get(actID) != null) {
                productFamilyOptions.addAll(mapAccountToProductFamilies.get(actID));
            }
            // Add any Product Families available to the Parent
            if (parentId != null) {
                for (SelectOption parSO : mapAccountToProductFamilies.get(parentId)) {
                    Boolean found = false;
                    for (SelectOption chiSO : productFamilyOptions) {
                        if (chiSO.getValue() == parSO.getValue()) {
                            found = true;
                        }
                    }
                    if (!found) {
                        productFamilyOptions.add(parSO);
                    }
                }
                //productFamilyOptions.addAll(mapAccountToProductFamilies.get(parentId));
            }
            productFamilyOptions.add(new SelectOption('Customer Community','Customer Community'));
        }
        else
            productFamilyOptions.add(new SelectOption('', 'No Product Families Available'));
        
        return productFamilyOptions;
        
    }
    
    public List<SelectOption> getProductLineOptionsByProductFamily(String family)
    {
        List<SelectOption> productLineOptions = new List<SelectOption>();
        if(mapProductFamilyToProductLines != null && mapProductFamilyToProductLines.containsKey(family))
        {
            //productLineOptions.add(new SelectOption('', Constants.NONE));
            productLineOptions.addAll(mapProductFamilyToProductLines.get(family));
        }
        else
            productLineOptions.add(new SelectOption('', Constants.NO_PRODUCT_LINES_AVAILABLE));
        
        return productLineOptions;
    }
    
    public List<SelectOption> getAssetOptionsByProductFamilyAndProductLine(String family, String productLine)
    {
        String key = family+productLine;
        System.debug('productFamlineKey '+key);
        System.debug('prouct line to asset map '+mapPfProductLineToAssets);
        List<SelectOption> assetOptions = new List<SelectOption>();
        if(mapPfProductLineToAssets != null && mapPfProductLineToAssets.containsKey(key))
        {
            //assetOptions.add(new SelectOption('', Constants.NONE));
            System.debug('addingassets to assetOptions');
            assetOptions.addAll(mapPfProductLineToAssets.get(key));
        }
        else
            assetOptions.add(new SelectOption('', Constants.NO_ASSETS_AVAILABLE));
        
        return assetOptions;
    }
    
    public List<SelectOption> getAssetOptionsByProductFamily(String family)
    {
        List<SelectOption> assetOptions = new List<SelectOption>();
        if(mapPfProductLineToAssets != null && mapPfProductLineToAssets.containsKey(family))
        {
            //assetOptions.add(new SelectOption('', Constants.NONE));
            assetOptions.addAll(mapPfProductLineToAssets.get(family));
        }
        else
            assetOptions.add(new SelectOption('', Constants.NO_ASSETS_AVAILABLE));
        
        return assetOptions;
    }
    
//    public PageReference saveCase(CaseModel cm, CaseComment cc, string redirectType, Boolean useDefaultAssignmentRules, Boolean isChangeAsset, Boolean InstRec)
    public PageReference saveCase(Case c, CaseComment cc, string redirectType, Boolean useDefaultAssignmentRules, Boolean isChangeAsset, Boolean InstRec)
    {
        if(redirectType != null && c != null) // cm != null && cm.record != null)
        {
            //Added conditional to check if Case is Client Install - JM - 12/18/2012
            if(InstRec)
                ClientInstall = true;
            
            if(!validate(c)) // cm.record))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Please fill in all required fields')); // System.Label.Please_fill_in_all_required_fields));
                return null;
            }
                if(useDefaultAssignmentRules)
                    c.setOptions(GenericServices.defaultAssignmentDBOptions);
//                    cm.record.setOptions(GenericServices.defaultAssignmentDBOptions);
                else
                    CaseServices.createdCaseTrackersAndHistories = true;
                                    

                upsert c;
                
                if(!useDefaultAssignmentRules)
                {
                    
                    Map<ID, Case> refCases = new Map<ID, Case>();
                    refCases.put(c.id, c);
					update refCases.get(c.id);
                    
                }
                    
                if(cc != null && cc.CommentBody != null && cc.CommentBody.length() > 0)
                {
//                    cc.ParentId = cm.record.Id;
                    cc.ParentId = c.Id;
                    cc.IsPublished = false;
                    insert cc;
                }
//            }
            

            
            String redirectURL =  '';
            
            
            if(redirectType == 'parent') // Constants.REDIRECT_PARENT)
                redirectURL = '/'+c.Id;
//                redirectURL = '/'+cm.record.Id;
            else if(redirectType == 'attach') // Constants.REDIRECT_ATTACH)
                redirectURL = '/p/attach/NoteAttach?pid='+c.Id+'&parentname=&retURL=%2F'+c.Id;
//                redirectURL = '/p/attach/NoteAttach?pid='+cm.record.Id+'&parentname=&retURL=%2F'+cm.record.Id;
            
            PageReference pr = new PageReference(redirectURL);
            pr.setRedirect(true);
                
            system.debug('\n\nIsPortal = '+isPortal+'\n');
            return pr;
        }
        return null;
    }
    
    private Boolean validate(Case c)
    {
        if
        (
            isPortal &&
            (
                GenericServices.isNullOrEmpty(c.AccountId)|| 
                GenericServices.isNullOrEmpty(c.ContactId)
//||
//                GenericServices.isNullOrEmpty(c.Product_Family_Name__c) ||
//                GenericServices.isNullOrEmpty(c.Product_Line_Name__c)
            )
            
        )return false;
            
        else if
        (
            !isPortal && !ClientInstall &&
            (
                GenericServices.isNullOrEmpty(c.AccountId)|| 
                GenericServices.isNullOrEmpty(c.ContactId)
//||
//                GenericServices.isNullOrEmpty(c.Asset__c)
            )   
        )
            return false;
        else if
        (
            !isPortal && ClientInstall &&
            (
                GenericServices.isNullOrEmpty(c.AccountId)|| 
                GenericServices.isNullOrEmpty(c.ContactId)
            )
            
        )
            return false;
        
        return true;
    }
   
}