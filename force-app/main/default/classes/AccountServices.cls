public without sharing class AccountServices 
{
  /*  public static final String SObjectName = 'Account';
       
    public static Account populateAddressOnAccountFromAccountAddressObject(QS_Bill_To_Ship_To__c btst)
    {
        if(btst != null && !GenericServices.isNullOrEmpty(btst.QS_Account__c))
        {
            Boolean updatedAccount = false;
            Account a = new Account(id=btst.QS_Account__c);
            
            if(btst.QS_Bill_To__c == true && btst.QS_Primary__c == true)
            {
                if (btst.QS_Street_2__c != null) {
                    a.BillingStreet = btst.QS_Street_1__c + '\r\n' + btst.QS_Street_2__c;
                }
                else {
                    a.BillingStreet = btst.QS_Street_1__c;
                }
                a.QS_Primary_Bill_To__c = btst.Id;
                a.BillingCity = btst.QS_City__c;
                a.BillingState = btst.QS_State__c;
                a.BillingCountry = btst.QS_Country__c;
                a.BillingPostalCode = btst.QS_Zip_Postal_Code__c;
                        a.QS_Bill_To_Email__c = btst.QS_Email__c;
                        a.QS_Bill_To_Attention_To__c = btst.QS_Attention_To__c;
                
                updatedAccount = true;
            }
            
            if(btst.QS_Ship_To__c == true)
            {
                if (btst.QS_Street_2__c != null && btst.QS_Primary__c == true) {
                    a.ShippingStreet = btst.QS_Street_1__c + '\r\n' + btst.QS_Street_2__c;
                }
                else {
                    a.ShippingStreet = btst.QS_Street_1__c;
                }
                a.QS_Primary_Ship_To__c = btst.Id;
                a.ShippingCity = btst.QS_City__c;
                a.ShippingState = btst.QS_State__c;
                a.ShippingCountry = btst.QS_Country__c;
                a.ShippingPostalCode = btst.QS_Zip_Postal_Code__c;
                
                updatedAccount = true;
            }   
            
            if(updatedAccount)
                return a;
            
        }
        
        return null;
        
    } */
}