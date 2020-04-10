public with sharing class CreateCaseExt {
  
    /**
     * NOTE: This class is still in use by both the portal and staff-facing case wizards.
     *       Would suggest separating out since they are relatively different processes with different requirements.
     *       Once that has been done, review the following:
     *
     * @todo  Review the following and see if we can remove the item and all associated logic
     *           - isPortal
     *           - InstRec
     *           - isChangeAsset
     *           - Others?
     * 
     * Ved Swaminathan: 07/10/2019
     * -- Cleaned Up a lot of commented code
     * -- Removed makeDependentPicklistSelectionsForAsset function and its related calls. Function Contained only commented code
     */
    public AccountModel am{get; private set;}
    private final Account a;
    private Contact con;
    private Case c;
    private final String caseID;
    private final String CaseRecordType;
    private final String parentCaseID;
    private final Id dummyConID;
    public String prodFamily {get; set;}
    public String prodLine {get; set;}
    public String conFirstName {get; set;}
    public String conLastName {get; set;}
    public String conEmail {get; set;}
    public List<Contact> dscList {get; private set;}
    
    public CaseComment caseComment {get; set;}
    
    public Boolean isPortal {get; private set;}
    public Boolean isInternalUser {get; private set;}
    //public Boolean isManager {get; private set;}
    public Boolean InstRec {get; private set;}
    public Boolean isChangeAsset {get; private set;}
    public Boolean useDefaultAssignmentRules {get; set;}
    public List<SelectOption> accountOptions {get; private set;}
    public List<SelectOption> contactOptions {get; private set;}
    //public List<SelectOption> entitlementOptions {get; private set;}
    public List<SelectOption> productFamilyOptions {get; private set;}
    public List<SelectOption> productLineOptions {get; private set;}
    public List<SelectOption> assetOptions{get; private set;}
    private Boolean initialChangeAssetLoad {get; set;}
    
    private ApexPages.StandardController thisStd;
    
    /**
     * Constructor Class
     */
    public CreateCaseExt(ApexPages.StandardController std)
    {
        
        
        InstRec = false;
        this.thisStd = std;
        
        caseID = ApexPages.currentPage().getParameters().get('id'); // CONSTANTS.QRY_STRING_CASE_ID);
        //Grab RecordType from URL
        CaseRecordType = ApexPages.currentPage().getParameters().get('RecordType');
      
        System.debug('\n\ncaseId = '+caseID+'\n\n');
        System.debug('\n\nCaseRecordType = '+CaseRecordType+'\n\n');
        
        if(caseID == null)
        {
            /** @todo  Move all of this code into a 'CurrentUser' class that has the logic in one place to determine whether a user is a portal user or not.
                       PortalUser class could be an extension of CurrentUser. CurrentUser would also have logic for isInternalUser as well. */
            User u = [Select Id, ProfileId, Profile.UserLicense.LicenseDefinitionKey, ContactID, Contact.AccountID from User where id= :UserInfo.getUserId()];
            System.debug('xyzzy - License Key: ' + u.Profile.UserLicense.LicenseDefinitionKey);
            isPortal = (u.ContactId != null);
            //isManager = (u.ProfileId == SystemIds__c.getInstance().ProfileId_CustomerSupportMgr__c || u.ProfileId == SystemIds__c.getInstance().ProfileId_SysAdmin__c);
            
            this.c = (Case)std.getRecord(); 
            this.isChangeAsset = false;
            
            parentCaseID = ApexPages.currentPage().getParameters().get('def_parent_id');
          if (parentCaseID != null) {
            c.ParentId = parentCaseID;
            c.put('ParentId', parentCaseID);
          }
            
            if(isPortal)
            {
                isInternalUser = false;
                c.AccountID = u.Contact.AccountID;
                c.ContactID = u.ContactID;
                System.debug('\n\nc.AccountID = ' + c.AccountID + '\n\n');
//                c.Origin = Constants.DEFAULT_ORIGIN_PORTAL;
                useDefaultAssignmentRules = true;
            }
            else
            {
                // 'Internal User' means any staff that is not Customer Support
                //isInternalUser =    u.ProfileId != supportUserProfileId
                //                 && u.ProfileId != supportMgrProfileId;
                isInternalUser = true;
                
                c.AccountId = ApexPages.currentPage().getParameters().get('def_account_id'); // Constants.QRY_STRING_ACCOUNT_ID);
                c.ContactId = ApexPages.currentPage().getParameters().get('def_contact_id'); // Constants.QRY_STRING_CONTACT_ID);

				c.put('ContactId', c.ContactId);

                if (isInternalUser) {
                    useDefaultAssignmentRules = true;
                }
                else {
                    useDefaultAssignmentRules = false;
                }
            }   
      
            caseComment = new CaseComment();
            initialChangeAssetLoad = false;
        }
        else
        {
            this.c = (Case)std.getRecord(); 
            this.isChangeAsset = true;
            isPortal = false;
            initialChangeAssetLoad = false; // temp
        }
        
        if(c.AccountID == null)
        {
           if (isInternalUser) {
                productFamilyOptions = getDefaultProductFamilyOptions();
                
                c.put('Product_Family_Name__c', productFamilyOptions[0].getValue());
            }
            contactOptions = new List<SelectOption>();
       }
        else {
            try
            {
                a = [SELECT ID, Name, RecordTypeId FROM Account WHERE id = :c.AccountID];
            }
            catch(QueryException qexc)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Invalid Account Id in URL.')); // System.label.Invalid_Account_ID_URL_param));
                return ;
            }
            
            am = new AccountModel(a, isPortal);
            loadData();
        }
    }
    
    /**
     *
     */
    private void loadData()
    {
        am.getAccounts();
        accountOptions = am.accountOptions;
        makeDependentPicklistSelections(c.AccountID, 'AccountID');
        
        makeDependentPicklistSelectionsForAccount();
        
        c.put('Product_Family_Name__c', productFamilyOptions[0].getValue());
         
    } 
    
    /**
     *
     */
    public void makeDependentPicklistSelectionsForAccount()
    {
        if(!isPortal)
        {
            if(c.ContactId != null && (String)c.ContactId != (String)dummyConID)
            {
                try
                {
                    Contact onlyContactAVailable = [Select ID, AccountID, LastName, FirstName 
                                                        from Contact where id=: c.ContactID ];
                    contactOptions = new List<SelectOption>();
                    contactOptions.add(new SelectOption(onlyContactAvailable.id, onlyContactAvailable.LastName+', '+onlyContactAvailable.FirstName));
                    makeDependentPicklistSelections(c.ContactID, 'ContactID');
                }
                catch(Exception exc)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ')); // System.label.General_Error_On_Case+': '+exc));
                }
            }
            else
            {
                System.debug('Going to AccountModel for Acc ID: ' + c.AccountID);
                Account acc = [SELECT ID, Name, RecordTypeId FROM Account WHERE id = :c.AccountID];
                am = new AccountModel(acc, isPortal);
                contactOptions = am.getContactOptionsByAccount(c.AccountID, c.ContactId);
                makeDependentPicklistSelections(contactOptions, 'ContactID');
            }
        }

        contactOptions = am.getContactOptionsByAccount(c.AccountID, c.ContactId);
        //contactOptions.add(new SelectOption(dummyConID, 'Create New'));
        //if (contactOptions.size() > 1 && (String)c.ContactId == (String)dummyConID) {
        c.put('ContactId', null);
        //}
        
        productFamilyOptions = am.getProductFamilyOptionsByAccount(c.AccountID);
        c.put('Product_Family_Name__c', productFamilyOptions[0].getValue());
//        makeDependentPicklistSelections(productFamilyOptions, 'Product_Family_Name__c');
        makeDependentPicklistSelectionsForProductFamily();
        
    }    
    
    /**
     *
     */
    public List<SelectOption> getDefaultProductFamilyOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult F = Case.Product_Family_Name__c.getDescribe();
        for (Schema.PicklistEntry p : F.getPicklistValues()) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        
        return options;
    }    
    
    /**
     *
     */
    public void makeDependentPicklistSelectionsForProductFamily()
    {
        productLineOptions = am.getProductLineOptionsByProductFamily(c.Product_Family_Name__c);
        makeDependentPicklistSelections(productLineOptions, 'Product_Line_Name__c');
        
        makeDependentPicklistSelectionsForProductLine();
        
        c.put('Product_Family_Name__c', this.prodFamily);
        
        assetOptions = am.getAssetOptionsByProductFamily(c.Product_Family_Name__c);
		makeDependentPicklistSelections(assetOptions, 'AssetId');
        
        
    }
    
    /**
     *
     */
    public void makeDependentPicklistSelectionsForProductLine()
    {
        assetOptions = am.getAssetOptionsByProductFamilyAndProductLine(c.Product_Family_Name__c, c.Product_Line_Name__c);
        System.debug('PL ASTS: ' + assetOptions);
        
        makeDependentPicklistSelections(assetOptions, 'AssetId');
        
        c.put('Product_Line_Name__c', this.prodLine);
    }
    
     
   
    private void makeDependentPicklistSelections(List<SelectOption> options, String fieldName)
    {
      System.debug('ENTERING DP PICKLIST');
        if(options != null  && !initialChangeAssetLoad && options.size() != 0)
        {
            System.debug('\n\noptions[0].getValue() = '+options[0].getValue()+'\n\n');
            c.put(fieldName, options[0].getValue());
            
        }
    }
    
    /**
     *
     */
    private void makeDependentPicklistSelections(String value, String fieldName)
    {
        if(value != null  && !initialChangeAssetLoad)
        {   
        	c.put(fieldName,value);    
        }
    }
    
   
    public PageReference saveOnly()
    {
        System.debug(am);
        SavePoint sp = Database.setSavePoint();
        
        try
        {
            if (am == null) {
                if (isInternalUser) {
                    // Internal Users allowed to save cases without an account or contact
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    c.setOptions(dmo);
                    //Asset ast = [Select Id from Asset WHERE Id=:c.AssetId];
                    //c.AssetId = null;
                    //System.debug(c);
                    upsert c;
                    
                    // Do we need to do anything else here? Apply default assignment rules, etc?
                    
                    // Redirect user to view ticket
                    PageReference pr = new PageReference('/' + c.Id);
                    
                    return pr;
                }
                else {
                    // Account is required for Non-Internal Users (Support staff)
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Account is required'));
                    return null;
                }
            }
            else {
               // Are we creating a new Contact?
               System.debug('MM Selected:' + (String)c.ContactId);
               System.debug('MM Dummy:' + (String)dummyConID);
               if ((String)c.ContactId == (String)dummyConID) {
                     Contact con = new Contact(FirstName = conFirstName, LastName = conLastName, Email = conEmail, AccountId = c.AccountId);
                     insert con;
                     
                     c.ContactId = con.Id;
               }
                /*Asset ast = [Select Id from Asset WHERE Id=:c.AssetId];
                c.AssetId = null;*/
               PageReference pr = am.saveCase(c, caseComment, 'parent', useDefaultAssignmentRules, isChangeAsset, InstRec);
               
               if (!isPortal && !isInternalUser && pr != null) {
                    // Support users - redirect to the edit page
                    // and return back to the ticket from there
                    String editPageRetURL = '/' + c.Id;
                    pr = new PageReference('/' + c.Id + '/e?retURL=' + editPageRetURL);
               }
               
               return pr;
            }
        }
        catch(Exception ex)
        {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: ' + ex)); // System.label.General_Error_On_Case+': '+ex));
                Database.rollBack(sp);
                return null;
        }
    }
    
    
 
    public Pagereference saveAndAttach()
    {
        SavePoint sp = Database.setSavePoint();
        
        try
        {
            if (am == null) {
                if (isInternalUser) {
                    // Internal Users allowed to save cases without an account or contact
                    upsert c;
                    
                    // Do we need to do anything else here? Apply default assignment rules, etc?
                    
                    // Redirect user to view ticket
                    PageReference pr = new PageReference('/' + c.Id);
                    
                    return pr;
                }
                else {
                    // Account is required for Non-Internal Users (Support staff)
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Account is required'));
                    return null;
                }
            }
            else {
              // Are we creating a new Contact?
                if ((String)c.ContactId == (String)dummyConID) {
                     Contact con = new Contact(FirstName = conFirstName, LastName = conLastName, Email = conEmail, AccountId = c.AccountId);
                     insert con;
                     
                     c.ContactId = con.Id;
                }
                PageReference pr = am.saveCase(c, caseComment, 'attach', useDefaultAssignmentRules, false, InstRec);
                return returnPortalOrInternalUserNavigation(pr,isPortal,isInternalUser);
                
            }
        }
        catch(Exception exc)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error: '+exc)); // System.label.General_Error_On_Case+': '+exc));
            Database.rollBack(sp);
            return null;
        }
    }
    
    public PageReference returnPortalOrInternalUserNavigation(PageReference pr, Boolean isPortal, Boolean isInternalUser)
    {
        		if (!isPortal && !isInternalUser && pr != null) {
                    // Support users - redirect to the attach page
                    // then the case edit page after that
                    // and return back to the ticket from the edit page
                    // Have to make sure the urls are properly encoded and double-encoded to properly be unencoded at each step
                    String editPageRetURL = '/' + c.Id;
                    String attachPageRetURL = '/' + c.Id + '/e?retURL=' + EncodingUtil.urlEncode(editPageRetURL, 'UTF-8');
                    String redirectURL = '/p/attach/NoteAttach?pid='+c.Id+'&parentname=&retURL=' + EncodingUtil.urlEncode(attachPageRetURL, 'UTF-8');
                    pr = new PageReference(redirectURL);
                }
                else if (isPortal && pr != null) {
                    // For portal users, redirect them to a custom VF page that allows them to
                    // save an attachment to a ticket (which they can't do using oob functionality because
                    // they don't have edit permission on tickets)
                    String redirectURL = '/apex/AttachmentUpload?pid='+c.Id;
                    pr = new PageReference(redirectURL);
                }
                else
                {
                    return pr;
                }
         
        return null;
    }
    
    public PageReference doCancel() {
        return this.thisStd.cancel();
    }
    
    /**
     * Stub method that can be called just to have the page reloaded
     *
     * @author  Lawrence Coffin <lawrence.coffin@cloudsherpas.com>
     * @since   May 5, 2013
     */
    public void refreshPage() {}
    

   
}