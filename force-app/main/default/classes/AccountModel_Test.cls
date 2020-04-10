@isTest
class AccountModel_Test
{

    static testMethod void testConstructorsForCaseCreation()
    {
        //test the constructor with account and isPortal flag as arguments
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        AccountModel am = new AccountModel(a, false);
        System.assertEquals(a.id, am.record.id);
        System.assertEquals(am.isPortal, false);
        
        am = new AccountModel(a, true);
        System.assertEquals(a.id, am.record.id);
        System.assertEquals(am.isPortal, true);
        
        //test the overloaded constructor with just Account argument
        am = new AccountModel(a);
        System.assertEquals(a.id, am.record.id);
        //verify that with this overload, Isportal is always defaulted to false
        System.assertEquals(am.isPortal, false);
        
    }
    
    static testMethod void testGetAccounts()
    {
        Account client = TestUtils.getAccount('ut acc1');
        insert client;
        AccountModel am = new AccountModel(client);
        am.getAccounts();
        System.assertEquals(am.accountOptions.size() , 0);
    }
        
    static testMethod void testGetContacts()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        
        Contact c1 = TestUtils.getContact(a, 'c1');
        //c1.Contact_Status__c = 'Active';
        insert c1;
        Contact c2 = TestUtils.getContact(a, 'c2');
        //c2.Contact_Status__c = 'Active';
        insert c2;
        
        AccountModel am = new AccountModel(a);
        am.getAccounts();
        am.getSupportContactOptionsByAccount(a.id,c1.id);
        am.getSupportContacts(c1.id);
        am.getSupportContactOptionsByAccount(a.id, c1.id);
        Set<Id> accSet = new Set<Id>();
        accSet.add(a.id);
        am.getContacts(accSet, c1.id);
        
        System.assertEquals(am.mapAccountToContacts.size(), 1 );
        System.assertEquals(am.mapAccountToContacts.get(a.id).size(), 2 );
        System.assertEquals(am.mapAccountToContacts.get(a.id)[0].getValue(), c1.id );
        System.assertEquals(am.mapAccountToContacts.get(a.id)[1].getValue(), c2.id );
    }
    
    static testMethod void testGetProductFamiliesProductLinesAndAssets()
    {
        Account a = TestUtils.getAccount('ut acc1');
        insert a;
        Product2 p1 = TestUtils.getProduct('up1', 'family1'); insert p1;
        Product2 p2 = TestUtils.getProduct('up2', 'family2'); insert p2;
        Asset va1 = TestUtils.getAsset(a, p1); va1.Name = 'v1'; insert va1;
        Asset va2 = TestUtils.getAsset(a, p2); va2.Name = 'v2'; insert va2;
        
        AccountModel am = new AccountModel(a);
        am.getAccounts();
       
    }
    
    static testMethod void testGetDependantSelectOptionsMethods()
    {
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Contact c = TestUtils.getContact(a, 'ut ct1');
        insert c;
        Product2 p = TestUtils.getProduct('ut prod1', 'family1');
        insert p;
        Asset va = TestUtils.getAsset(a, p);
        insert va;
        
        Test.startTest();
        AccountModel am = new AccountModel(a, false);
        
        am.getAccounts();        
        
        List<SelectOption> contactList = am.getContactOptionsByAccount(a.Id, null);
        //System.assertEquals(1, contactList.size());
        //System.assertEquals(Constants.NO_CONTACTS_AVAILABLE, contactList[0].getLabel());
        
        List<SelectOption> pfList = am.getProductFamilyOptionsByAccount(a.Id);
        //System.assertEquals(1, pfList.size());
        //System.assertEquals(Constants.NO_PRODUCT_FAMILIES_AVAILABLE, pfList[0].getLabel());
        
        List<SelectOption> astList = am.getAssetOptionsByProductFamily('Bullhorn ATS/CRM');
        //System.assertEquals(1, astList.size());
        //System.assertEquals(Constants.NO_ASSETS_AVAILABLE, astList[0].getLabel());
        
        contactList = am.getContactOptionsByAccount(a.id, null);
        //System.assertEquals(1, contactList.size());
        //System.assertEquals(c.id, contactList[0].getValue());
        
        pfList = am.getProductFamilyOptionsByAccount(a.id);
        //System.assertEquals(2, pfList.size());
        //System.assertEquals('family1', pfList[1].getValue());
        
        astList = am.getAssetOptionsByProductFamily('Bullhorn ATS/CRM');
        //System.assertEquals(2, astList.size());
        //System.assertEquals(va.id, astList[1].getValue());
        
        Test.stopTest();
      
        
    }


	static testMethod void testProductFamilyOptionsByAccount()
	{
        Account parentAccount = TestUtils.getAccount('ParentAccount');
        insert parentAccount;
		Account a = TestUtils.getAccount('ut acc1');
        a.Parent = parentAccount;
        insert a;

		Product2 currentProduct = CA2_CPQTestUtil.createProduct('Product2','Subscription','GC1060',null,null,null,true,true);
		currentProduct.Family = 'Subscription';
		update currentProduct;
		PricebookEntry obj = (PricebookEntry)PricebookEntry.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            true // loadDefaultValues
        );
        obj.UnitPrice = 100;
        obj.Pricebook2Id = Test.getStandardPricebookId();
        obj.Product2Id = currentProduct.Id;
        obj.isActive = true;
		insert obj;
		Set<Id> newSetOfAccountId = new Set<Id>();
		newSetOfAccountId.add(a.id);
		
		//PricebookEntry pbe = CA2_CPQTestUtil.createPriceBookEntry(currentProduct,true,true);


		Asset newAsset = new Asset();
		newAsset.Product2Id = currentProduct.Id;
		newAsset.AccountId = a.Id;
		newAsset.Name = 'First asset';

		insert newAsset;


		AccountModel newAccountModelObject = new AccountModel(a);
		List<SelectOption> newListOfSelectOption = new List<SelectOption>();
		
		newListOfSelectOption.add(new SelectOption('Subscription','Subscription'));
		Map<String, List<SelectOption>> mapAccountToProductFamilies = new Map<String,List<SelectOption>>();
		mapAccountToProductFamilies.put(a.Id,newListOfSelectOption);
		newAccountModelObject.mapAccountToProductFamilies = mapAccountToProductFamilies;
		newAccountModelObject.getProductLineOptionsByProductFamily('Subscription');
		newAccountModelObject.getProductFamiliesProductLinesAndAssets(newSetOfAccountId);
               
		//newAccountModelObject.getProductFamilyOptionsByAccount(a.id,parentAccount.Id);
				


	}

	static testMethod void saveCaseTest(){

	Account a = TestUtils.getAccount('ut acc1');
        insert a;
	
	Contact newContact = new Contact();
	newContact.LastName = 'TestLastName';
	newContact.Title = 'newTitle';
	newContact.Email = 'newEmail@gmail.com';
	newContact.AccountId = a.Id;
	insert newContact;
	
	Case newCase = new Case();
	List<RecordType> caseRecordTypeId = [SELECT id,SobjectType from RecordType where SobjectType='Case'];
	if(caseRecordTypeId.size() >0 )
	{
		newCase.RecordTypeId = caseRecordTypeId[0].Id;
	}
	
	newCase.Account = a;
	newCase.Contact = newContact;
	newCase.Subject = 'Test Sub';
	newCase.AccountId = a.Id;
	newCase.ContactId = newContact.Id;
	newCase.Description = 'Test Descrip';
	newCase.Status = 'New';
	newCase.Priority = 'High';
	newCase.Origin = 'Email';
	insert newCase;

	
	AccountModel model = new AccountModel(a,true);
	model.saveCase(newCase,null,'parent',true,false,true);
	model.saveCase(newCase,null,'attach',false,true,false);
	
	AccountModel model2 = new AccountModel(a,false);

	model2.saveCase(newCase,null,'parent',true,true,true);
	model2.saveCase(newCase,null,'attach',false,false,false);
        
    


	}

}