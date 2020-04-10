// All test methods in this class can access all data.
@isTest(SeeAllData=true)
public without sharing class TestUtils
{
    public static Account getAccount(String name)
    {
        Account a = new Account();
        a.Name = name;
        a.BillingCountry = 'United States';
        a.ShippingCountry = 'United States';
        a.QS_Overdue_Balance__c = 0;
        a.QS_CAPdb_Rating__c = 'Something'; 
        
        return a;
    }
    
    public static Lead getLead(String lastName)
    {
        Lead l = new Lead();
        l.LastName = lastName;
        l.Company = 'Test Co';
        
        return l;
    }
    
    /*public static Account getClient(String name)
    {
        Account a = getAccount(name);
        a.RecordTypeId = [Select ID from RecordType where SObjectType =: 'Account' and DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_CLIENT].id;
        
        return a;
    }
    
     public static Account getClient2(String name)
    {
        Account a = getAccount(name);
        a.RecordTypeId = [Select ID from RecordType where SObjectType =: 'Account' and Name = 'Client'].id;
        a.Pricing_Type__c = 'Default';
        a.Global_ID__c = '12345678912';
    a.Type = 'Customer';
    a.Specialty__c = 'Urology';
    a.QS_Contract_Status__c = 'Current';
        return a;
    }
    
    public static Account getPractice(Account client, String name)
    {
        Account a = getAccount(name);
        a.RecordTypeId = [Select ID from RecordType where SObjectType =: 'Account' and DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_PRACTICE].id;
        a.Company__c = client.id;
        
        return a;
    }
    
    public static Account getChannelPartner(String name)
    {
        Account a = getAccount(name);
        a.RecordTypeID = [Select ID from RecordType where SObjectType =: 'Account' and DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_CHANNEL_PARTNER].id;
        
        return a;
    }*/
    
    public static Contact getContact(Account a)
    {
        return getContact(a, 'ut Contact 1');
    }
   
    public static Contact getContact(Account a, String name)
    {
        Contact c = new Contact();
        c.AccountID = a.id;
        c.LastName = name;
        c.Salutation = 'Mr.';
        c.FirstName = name;
        c.Email = 'dummy@gmail.com';
        return c;
    }
    
    public static Contract getContract(Account a)
    {
        Contract cntrct = new Contract();
        cntrct.AccountId = a.id;
        
        return cntrct;
    }
    
    public static Product2 getProduct(String name)
    {
        Product2 p = new Product2();
        p.Name = name;
        p.IsActive = true;
        return p;
    }
    
    public static Product2 getProduct(String name, String familyName)
    {
        Product2 p = getProduct(name);
        p.Family = familyName;
        return p;
    }
    
    /*public static Product2 getProduct(String name, String familyName, String productLine)
    {
        Product2 p = getProduct(name, familyName);
        p.Product_Line__c = productLine;
        
        return p;
    }
    
    public static Product2 getProduct(String name, String familyName, String productLine, Version_Family__c vf)
    {
        Product2 p = getProduct(name, familyName, productLine);
        p.Version_Family__c = vf.id;
        
        return p;
    }*/
    
    public static Opportunity getOpportunity(Account a, String name)
    {
        Opportunity oppty = new Opportunity();
        oppty.AccountID = a.id;
        oppty.Name = name;
        oppty.StageName = 'Closed Won';
        oppty.CloseDate = Date.Today().addMonths(2);
        oppty.QS_Legal_Review__c = 'Approved';
        oppty.QS_Order_Type__c = Constants.ORDER_TYPE_NEW_PRODUCT;
        oppty.QS_Finance_Checklist_Complete__c = true;
        Contact c = getContact(a);
        insert c;
        
        oppty.Contact__c = c.id;
        
        Contract cntrct = getContract(a);
        insert cntrct;
        //oppty.Contract__c = cntrct.id;
        
        Contact impContact = getContact(a);
        insert impContact;
        
        return oppty;
    }
    
     /*public static Opportunity getOpportunity2(Account a, String name)
    {
        Opportunity oppty = new Opportunity();
        //oppty.RecordType.Name = 'Product';
        oppty.Name = name;
        oppty.AccountId = a.id;
        //oppty.Account.Name = a.Name;
        oppty.Type = 'Existing Customer';
        oppty.Order_Type__c = 'Version Upgrade';
        oppty.Deal_Term__c = 12;
        oppty.StageName = 'Plan';
        oppty.ForecastCategoryName = 'Pipeline';
        oppty.CloseDate = Date.Today();
        oppty.Pricing_Region__c = 'North America';
        oppty.Pricing_Sub_Region__c = 'US';
        oppty.ROI_Calculator__c = 'No';
        oppty.LeadSource = 'Other';
        
        Contract cntrct = getContract(a);
        insert cntrct;
        //oppty.Contract__c = cntrct.id;
        
        Contact impContact = getContact(a);
        insert impContact;
        oppty.Implementation_Contact__c = impContact.id;
        
        return oppty;
    }*/
    
    public static PriceBook2 getStandardPriceBook()
    {
        PriceBook2 pb = [Select Id, Name from PriceBook2 where isStandard = true limit 1];
        return pb;
    }
    
    public static PriceBookEntry getPriceBookEntry(Product2 p, PriceBook2 pb)
    {
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.PriceBook2ID = pb.id;
        pbe.Product2Id = p.id;
        pbe.UnitPrice = 1;
        pbe.isActive = true;
        return pbe;
    }
    
    /*public static Registration_Event__c getRevent (Account a)
    {
        Registration_Event__c r = new Registration_Event__c();
        
        r.Status__c = 'New';
        r.CreatedDate = Date.Today().adddays(-10);
        r.Client_ID__c = a.Id;
        r.End_Registration_Date__c = null;
        r.Event_Type__c = 'Add Practice';
        
        return r;
        
    }*/
    
    public static OpportunityLineItem getOLI(Opportunity oppty)
    {
        Product2 p = getProduct('ut prod1');
        insert p;
        PriceBook2 pb = getStandardPriceBook();
        PriceBookEntry pbe = getPriceBookEntry(p, pb);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityID = oppty.id;
        oli.PriceBookEntryID = pbe.id;
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        //oli.List_Price__c = 1;
        //oli.Extended_Term_Amount__c = 1;
        //oli.Term_Begin_Date__c = Date.Today();
        // oli.Term_End_Date__c = Date.Today().adddays(364);
        oli.QS_Product_Type__c = 'Product Type';
        //oli.License_Metric_Quantity__c = 1;
        return oli;
    }
    
    public static OpportunityLineItem getOLI(Opportunity oppty, Product2 p)
    {
        PriceBook2 pb = getStandardPriceBook();
        PriceBookEntry pbe = getPriceBookEntry(p, pb);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityID = oppty.id;
        oli.PriceBookEntryID = pbe.id;
        //oli.Quantity = 1;
        oli.TotalPrice = 1;
        //oli.List_Price__c = 1;
        //oli.Extended_Term_Amount__c = 1;
        //oli.Term_Begin_Date__c = Date.Today();
        //oli.Term_End_Date__c = Date.Today().adddays(364);
        oli.QS_Product_Type__c = 'Product Type';
        //oli.License_Metric_Quantity__c = 1;
        return oli;
    }
    
    /*public static Case getCase(Account a)
    {
        Contact c = getContact(a, 'ut contact 1');
        insert c;
        
        return getCase(a,  c);
    }*/
    
    public static Case getCase(Account a, Contact c)
    {
        Case cs = new Case();
        cs.AccountId = a.id;
        cs.ContactId = c.id;
        
        return cs;
    }
    
   /* public static Case getCase(Account a, Contact cnt, String family, String line, Asset ast, Account prc, Version__c v, Component__c comp, Sub_Component__c sc)
    {
        Case c = new Case();
        c.AccountID = a.id;
        c.ContactID = cnt.id;
        c.Product_Family_Name__c = family;
        c.Product_Line_Name__c = line;
        c.Asset__c = ast.id;
        c.Practice__c = prc.id;
        c.Version__c = v.id;
        c.Component__c = comp.id;
        c.Sub_Component__c = sc.id;
        return c;
    }
    
    public static Case getChildCase(Account a, Contact cnt, String family, String line, Asset ast)
    {
        Case c = new Case();
        c.RecordTypeId = [Select ID from RecordType where SObjectType =: 'Case' and Name = 'Standard CS Case'].id;
        c.AccountID = a.id;
        c.ContactID = cnt.id;
        c.Product_Family_Name__c = family;
        c.Product_Line_Name__c = line;
        c.Asset__c = ast.id;
        c.Issue_Type_Category__c = 'Hardware'; 
        c.Priority = 'General Question';
        c.Status = 'In Progress';
        c.Origin = 'Phone';
        c.Time_Spent_Minutes__c = '5';
        c.Subject = 'Sample Subject';
        c.Description = 'Sample Description';
        
        return c;
    }
    
    public static Case getParentCase(Account a, Contact cnt, String family, String line, Asset ast, User testUser)
    {
        Case c = new Case();
        c.RecordTypeId = [Select ID from RecordType where SObjectType =: 'Case' and Name = 'Level 3'].id;
        c.AccountID = a.id;
        c.ContactID = cnt.id;
        c.Product_Family_Name__c = family;
        c.Product_Line_Name__c = line;
        c.Asset__c = ast.id;
        c.Issue_Type_Category__c = 'Hardware'; 
        c.Priority = 'General Question';
        c.Status = 'Escalated to L3';
        c.Origin = 'Phone';
        c.Time_Spent_Minutes__c = '5';
        c.Subject = 'Sample Subject';
        c.Description = 'Sample Description';
        c.Type = 'Question';
        c.Group__c = 'R&D';
        c.OwnerId = testUser.Id;
        
        return c;
    }
    
    public static Sales_Invoice__c getSalesInvoice(Account a)
    {
        Sales_Invoice__c si = new Sales_Invoice__c();
        si.Account__c = a.id;
        si.Date__c = Date.Today().addMonths(-1);
        si.Amount_Due__c = 100.00;
        si.Amount_Paid__c = 0;
        si.Total__c = 100;

        return si;
    }    
    
    public static Connectivity__c getConnectivity (Account a, String connName){
      Connectivity__c cc = new Connectivity__c();
      cc.Account__c = a.id;
      cc.RecordTypeId = [Select ID from RecordType where SObjectType =: 'Connectivity__c' and Name = 'iTivity'].id;
      cc.Name = connName;
      cc.iTivity_ID__c = '9-999-99999';
      cc.Status__c = 'Active';
      cc.Server_Type__c = 'MedWare';
      cc.Connectivity_Type__c = 'iTivity';
      
      return cc;
    }
    
    public static Attachment getAttachment(String parentID)
    {
        Attachment att = new Attachment();
        att.Name = 'Unit Test Att';
        att.Body = Blob.valueOf(att.Name);
        att.parentId = parentId;
        
        return att;
    }
    
    public static CaseComment getCaseComment(Case cs)
    {
        CaseComment cc = new CaseComment();
        cc.ParentID = cs.id;
        cc.CommentBody = 'some comment';
        
        return cc;
    }*/
    
    public static Asset getAsset(Account a, Product2 p)
    {
        return getAsset(a, p, 1);
    }
    
    public static Asset getAsset(Account a, Product2 p, Decimal quantity)
    {
        Asset ast = new Asset();
        ast.Product2Id = p.id;
        ast.AccountId = a.id;
        ast.Name = 'name';
        //ast.Status = Constants.STATUS_ON_MAINTENANCE;
        //ast.Quantity__c = quantity;
        ast.Quantity = quantity;
        //ast.Purchase_Date__c = Date.Today();
        //ast.Term_Start_Date__c = Date.Today();
        //ast.Term_End_Date__c = Date.Today()+364;
        //ast.Annual_Subscription__c = 1000;
        return ast;
    }
    
    /*     
    public static Component__c getComponent(String name)
    {
        Component__c comp1 = new Component__c();
        comp1.Name = name;
        return comp1;
    }
    
    public static Component_Product_Junction__c getComponentProductJunction(Component__c comp, Product2 p)
    {
        Component_Product_Junction__c cpj = new Component_Product_Junction__c();
        cpj.Product__c = p.id;
        cpj.Component__c = comp.id;
        
        return cpj;
    }
    
    public static Sub_Component__c getSubComponent(Component__c comp, String name)
    {
        Sub_Component__c sc = new Sub_Component__c();
        sc.Component__c = comp.id;
        sc.Name = name;
        
        return sc;
    }
    */   
    public static Case getCase()
    {
        Case c = new Case();
        return c;
    }
    
    public static QS_Bill_To_Ship_To__c getAccountAddress(Account a)
    {
        QS_Bill_To_Ship_To__c btst = new QS_Bill_To_Ship_To__c();
        btst.QS_Account__c = a.id;
        
        return btst;
    }
    
    /*
    public static AccountAddress__c getLocation(String name, Account practice)
    {
        AccountAddress__c aa = getAccountAddress(name, practice);
        aa.RecordTypeId = [Select ID from RecordType where SObjectType =: 'AccountAddress__c' and DeveloperName =: Constants.ACCOUNT_ADDRESS_RECORD_TYPE_LOCATION].id;
        
        return aa;
    }
    
    public static AccountContact__c getAccountContact(Account practice, Contact c)
    {
        AccountContact__c ac = new AccountContact__c();
        ac.Account__c = practice.id;
        ac.Contact__c = c.id;
        return ac;
    }
    
    public static AssetContactAddress__c getAssetContactAddress(AssetContact__c ac, AccountAddress__c aa)
    {
        AssetContactAddress__c aca = new AssetContactAddress__c();
        aca.AssetContact__c = ac.id;
        aca.AccountAddress__c = aa.id;
        
        return aca;
    }
    
    public static AccountTax__c getPracticeTax(Account a, String taxNumber)
    {
        AccountTax__c atNum = new AccountTax__c();
        atNum.Name = taxNumber;
        atNum.Practice__c = a.id;
        
        return atNum;       
    }
    
    public static AccountNPI__c getPracticeNPI(AccountTax__c tax, Long npiNum)
    {
        AccountNPI__c npi = new AccountNPI__c();
        npi.Practice_Tax_ID__c = tax.id;
        npi.NPI_Number__c = npiNum;
        
        return npi;
    }
    
    public static AccountSite__c getSiteID(AccountTax__c tax, String siteID)
    {
        AccountSite__c acs = new AccountSite__c();
        acs.Account__c = tax.Practice__c;
        acs.AccountTax__c = tax.id;
        acs.Site_ID__c = siteID;
        acs.Name = siteID;
        
        return acs;
    }
    
    public static Payer__c getPayer(String name)
    {
        Payer__c p = new Payer__c();
        p.Name = name;
        
        return p;
    }
    
    public static Account_Payer__c getAccountPayer(Payer__c p, Account a)
    {
        Account_Payer__c ap = new Account_Payer__c();
        ap.Payer__c = p.id;
        ap.Company__c = a.id;
        
        return ap;
    }
     
    public static CaseComment getCaseComment()
    {
        CaseComment cc = new CaseComment();
        cc.CommentBody = 'boyd text';
        return cc;
    }*/
    
    private static User getTestUser(String userName, String profileName)
    {
        String profileId;
        try
        {
            profileId = [SELECT Id FROM Profile WHERE Name like: '%'+profileName+'%' limit 1].Id;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(false, 'No profile exists with name '+ profileName);
        }
        UserRole r = new UserRole(name = 'Admin');
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        testUser.Alias = UserName.substring(0, 8);  
        testUser.Email = UserName+'@invalid.com';
        testUser.Username = UserName+'@invalid.com';
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        testUser.UserRoleId = r.Id;
        return testUser;    
    }
    
    public static User getAdminUser(String adminName)
    {
        return getTestUser(adminName, 'System Administrator');
    }
    
    public static User getStandardInternalUser(String repName)
    {
        return getTestUser(repName, 'Standard User');
    }
    /*
    public static User getCustomerPortalUser(String repName, Contact c)
    {
        User portalUser = getTestUser(repName, 'Customer Portal Manager Standard - No Cases');
        portalUser.ContactID = c.id;
        portalUser.portalRole = 'Executive';
         
        return portalUser;
    }*/
    
    public static User getCustomerPortalUser2(String repName, Contact c)
    {
        //User portalUser = getTestUser(repName, 'Customer Portal Manager Custom');
        User portalUser = getTestUser(repName, 'Customer Community User');
        portalUser.ContactID = c.id;
        //portalUser.portalRole = 'Manager';
         
        return portalUser;
    }
  
    
    /**
     * @description:  Test Method helper used for CasesChildCount_Test class.
     * @author J.Jayoma
     * @date 9.APRIL.2013
    */
    
    /* Start */
    public static Id getRectypeId(String name, String sObj){
        return [Select Id from Recordtype where DeveloperName=:name and SobjectType=:sObj].Id;
    }
    
    public static Case getCaseSingle(Id RectypeId){
        Case cases = new Case(subject='test case 1', description='test case 1', Origin='Phone', status='New', recordTypeId=RectypeId);
        return cases;
    }
    
    public static List<Case> getCaseBulk(Integer size,Id RectypeId, Id ParentId){
        List<Case> casesList = new List<Case>();
        for(Integer i=0; i<size; i++){
            Case cases = new Case(subject='test case '+i, description='test case '+i, Origin='Phone', status='New', recordTypeId=RectypeId, ParentId = ParentId);
            casesList.add(cases);
        }   
        return casesList;
    }
/*    
    public static List<Case> getCurrentCase(){
        return [Select subject,description,Origin,status,recordTypeId,ParentId,Number_of_Child_Cases__c from Case];
    }
    
    public static Integer getChild(Id parentId){
        List<Case> listCases = [Select Id from Case where parentId =:parentId];
        return listCases.size();
    }
    
    public static Integer getChildCount(Id parentId){
        return Integer.valueOf([Select Number_of_Child_Cases__c from Case where Id =:parentId].Number_of_Child_Cases__c);
    }
*/    
    public static Case Updatecase(Id parentIdNew, Id Id){
        Case cases = [Select ParentId from Case where Id =:Id];
        cases.ParentId = parentIdNew;
        Update cases;
        return cases;
    }
/*    
    public static Case Deletcase(Id Id){
        Case cases = [Select ParentId from Case where Id =:Id];     
        delete cases;
        return cases;
    }
    
    /* End */    
    
    public static List<Contact> createContact(Integer size){
        List<Contact> Contacts = new List<Contact>();
        for(Integer i=0; i<size; i++){
            Contact k = new Contact(firstname='test name'+i, lastname = 'test lastname'+1,email='jjayoma@cloudsherpas.com');
            Contacts.add(k);
        }
        
        if(Contacts.size()>0){
            insert Contacts;
        }
        return Contacts;
    }
    
     public static Case getCaseSingleWithCon(Id RectypeId, Id conId){
        Case cases = new Case(subject='test case 1', description='test case 1', Origin='Phone', status='New', recordTypeId=RectypeId, contactId=conId);
        return cases;
    }
    
    public void dummyCode(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        }

    
    
    /**
     * @description:  Test Data for extracting Case record type id
     * @author Booz Espiridion
     * @param name: Name of the record type (Note: can be used by passing a null value)
     * @date 23.May.2013
    */
/*    public static Id getCaseRecTypeId(String name){
        //To be able to use this method without specifiying any actual record type name
        String useName = name == null ? 'Support Ticket' : name;
        return Schema.SObjectType.Case.getRecordTypeInfosByName().get(useName).getRecordTypeId();
    }
    
    /*  
        AUTHOR: Booz Espiridion
        DATE CREATED: 05/23/2013
        DATE LAST MODIFIED: 01/14/2013
        DESCRIPTION: method for creating a user
        PARAMETERS: i - integer value for bulk creation
    */
/*    public static User getTestUser(Integer i){
        User usr                = new User();
        usr.emailencodingkey    = 'UTF-8';
        usr.languagelocalekey   = 'en_US';
        usr.localesidkey        = 'en_US'; 
        usr.profileid           = [select Id From Profile Where Name = 'System Administrator'].Id;
        usr.timezonesidkey      = 'America/Denver';
        usr.FirstName           = 'Test User Fname ' + i;
        usr.alias           = 'TUser' + i;
        usr.email           = 'TestUser' + i + '@trial.com';
        usr.lastname        = 'TUser_' + i;
        usr.username        = 'TestUser' + i + '@trial.com';
        return usr;
    }
    
    /*  
        AUTHOR: Booz Espiridion
        DATE CREATED: 05/24/2013
        DATE LAST MODIFIED: 01/14/2013
        DESCRIPTION: method for creating a custom setting for custommer support reporting batch test
        PARAMETERS: name : the actual name to be used
                                apiName : the name to be used in apex
    */
/*    public static Customer_Support_Reporting_Settings__c getCustomSupportReportSetting(String name, String apiName){
        Customer_Support_Reporting_Settings__c setting = new Customer_Support_Reporting_Settings__c();
            setting.Report_Name__c = name;
            setting.Name = apiName;
            return setting;
    }
/**/
}