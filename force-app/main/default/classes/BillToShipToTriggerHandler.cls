public class BillToShipToTriggerHandler {
    public static void onBeforeInsert(List<QS_Bill_To_Ship_To__c>newRecords)
    {
        SplitAddressRecords(newRecords);
    }
    
    public static void onAfterInsert(Map<Id, QS_Bill_To_Ship_To__c> newRecords)
    {
        updateAccountBillToShipTo(newRecords.values());
        uncheckFormerPrimaryRecords (newRecords, new Map<Id, QS_Bill_To_Ship_To__c>());
        
    }
    
    public static void onAfterUpdate(Map<Id, QS_Bill_To_Ship_To__c> newRecords, Map<Id, QS_Bill_To_Ship_To__c> oldRecords)
    {
        updateAccountBillToShipTo(newRecords.values());
        uncheckFormerPrimaryRecords(newRecords, oldRecords);

}
    
    private static void uncheckFormerPrimaryRecords(Map<Id, QS_Bill_To_Ship_To__c> newRecords, Map<Id, QS_Bill_To_Ship_To__c> oldRecords)
    {
        Set<Id> parentAccounts = new Set<Id>();
        Map<Id, QS_Bill_To_Ship_To__c> newPrimaryAddresses = new Map<Id, QS_Bill_To_Ship_To__c>();
        
        // If new record and checked, or update and new is checked, check for other primary addresses.
        for(QS_Bill_To_Ship_To__c address : newRecords.values()){
            if(address.QS_Primary__c && HasPrimaryAddressChange(address, oldRecords)){
                newPrimaryAddresses.put(address.id, address);
                parentAccounts.add(address.QS_Account__c);
            }
        }

        if(parentAccounts.isEmpty()) {return;}
            
        List<QS_Bill_To_Ship_To__c> existingPrimaries = [Select Id, QS_Bill_To__c, QS_Ship_To__c, QS_Account__c from QS_Bill_To_Ship_To__c where id NOT IN :newPrimaryAddresses.keyset() and QS_Primary__c = true and QS_Account__c =: parentAccounts];
        
        if (existingPrimaries.isEmpty()) { return; }    
        
        for(QS_Bill_To_Ship_To__c existingAddress : existingPrimaries) {
            for(QS_Bill_To_Ship_To__c newAddress : newPrimaryAddresses.values()){
                if(existingAddress.QS_Account__c == newAddress.QS_Account__c) {
                    
                    if(existingAddress.QS_Ship_To__c == true && newAddress.QS_Ship_To__c == true){
                        existingAddress.QS_Primary__c = false;
                    }
                    else if (existingAddress.QS_Bill_To__c == true && newAddress.QS_Bill_To__c == true){
                        existingAddress.QS_Primary__c = false;
                    }
                }
            }
        }
        
        update existingPrimaries;
    }
    
    private static Boolean HasPrimaryAddressChange(QS_Bill_To_Ship_To__c newRecord, Map<Id, QS_Bill_To_Ship_To__c> oldRecords){
        /****************************************************************************
            Returns true if any potential change of primary exists.
        ****************************************************************************/
        Boolean hasChange = false; 
        
        if(
            (oldRecords.isEmpty() == true || (oldRecords.get(newRecord.Id) != null && oldRecords.get(newRecord.Id).QS_Primary__c == false)) ||
            (oldRecords.isEmpty() == false && newRecord.QS_Ship_To__c != oldRecords.get(newRecord.Id).QS_Ship_To__c) || 
            (oldRecords.isEmpty() == false && newRecord.QS_Bill_To__c != oldRecords.get(newRecord.Id).QS_Bill_To__c)
        ){hasChange = true;}
        
        return hasChange;
    }
    
    private static void SplitAddressRecords(List<QS_Bill_To_Ship_To__c> newRecords){
        List<QS_Bill_To_Ship_To__c> clonedAddresses = new List<QS_Bill_To_Ship_To__c>();
        
        for(QS_Bill_To_Ship_To__c address : newRecords){
            
            if(address.QS_Bill_To__c && address.QS_Ship_To__c) {
                
                //Create a cloned copy.
                QS_Bill_To_Ship_To__c addressCloned = address.clone(false,true);
                address.QS_Ship_To__c = false;
                addressCloned.QS_Bill_To__c = false;
                clonedAddresses.add(addressCloned);
            }
        }
        if(!clonedAddresses.isEmpty()) insert clonedAddresses;
    }
    
    private static void updateAccountBillToShipTo(List<QS_Bill_To_Ship_To__c> newRecords)
    {
        // If Billing or Shipping is set to primary, update account.
        List<QS_Bill_To_Ship_To__c> primaryAddresses = new List<QS_Bill_To_Ship_To__c>();
        Set<Id> accountIds = new Set<Id>();
        
        for(QS_Bill_To_Ship_To__c address : newRecords)
        {
            if(address.QS_Primary__c) {
                primaryAddresses.add(address);
                accountIds.add(address.QS_Account__c);
            }
        }
        if(primaryAddresses.isEmpty()) return;
        Map<Id, Account> accounts = new Map<Id, Account> ([SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, QS_Primary_Bill_To__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, QS_Primary_Ship_To__c from Account where Id =: accountIds]);
        for(QS_Bill_To_Ship_To__c address : primaryAddresses)
        {
            // Populate Account Address
            Account account = accounts.get(address.QS_Account__c);
            
            String s1 = address.QS_Street_1__c !=null ? address.QS_Street_1__c : '';
            String s2 = address.QS_Street_2__c !=null ? address.QS_Street_2__c : '';
            
            if(address.QS_Bill_To__c) {
                account.BillingStreet = s1 + '\n' + s2;
                account.BillingCity = address.QS_City__c != null ? address.QS_City__c : '';
                account.BillingState = address.QS_State_Picklist__c != null ? address.QS_State_Picklist__c : '';
                account.BillingPostalCode = address.QS_Zip_Postal_Code__c != null ? address.QS_Zip_Postal_Code__c : '';
                account.BillingCountry = address.QS_Country_Picklist__c != null ? address.QS_Country_Picklist__c : '';
                account.QS_Primary_Bill_To__c = address.Id;
            }
            else if (address.QS_Ship_To__c) {
                account.ShippingStreet = s1 + '\n' + s2;
                account.ShippingCity = address.QS_City__c != null ? address.QS_City__c : '';
                account.ShippingState = address.QS_State_Picklist__c != null ? address.QS_State_Picklist__c : '';
                account.ShippingPostalCode = address.QS_Zip_Postal_Code__c != null ? address.QS_Zip_Postal_Code__c : '';
                account.ShippingCountry = address.QS_Country_Picklist__c != null ? address.QS_Country_Picklist__c : '';
                account.QS_Primary_Ship_To__c = address.Id;
            }
        }
        
        update accounts.values();
    }
    
    
}