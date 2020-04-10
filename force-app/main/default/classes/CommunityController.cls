global without sharing class CommunityController {
    
    //Customer Support Case Record Type ID
    static string supportRecordTypeId 
    {
        get{
            if(supportRecordTypeId == null)
            {
                supportRecordTypeId = SCG_Utils.GetRecordTypeId('Case', 'Customer Support');
            }
            return supportRecordTypeId;
        }
        set;
    }
    
    static List<BusinessHours> listBusinessHours
    {
        get{
            if(listBusinessHours == null)
            {
                listBusinessHours= [SELECT id, Name, IsActive FROM BusinessHours WHERE IsActive = true];
            }
            return listBusinessHours;
        }
        set;
    }
    
    ///////////////////////////////////////////////////////////////
    //Aura Enabled Methods
    //
    //////////////////////////////////////////////////////////////
    @AuraEnabled
    public static String getUserId() 
    {    
        return UserInfo.getUserId();
    }
    
    @AuraEnabled
    public static string getRecordTypeId() 
    {
        return supportRecordTypeId;
    }
    
    @AuraEnabled
    public static List<Support_Phone_Number__mdt> getSupportNumbers() 
    {
        List<Support_Phone_Number__mdt> toReturn = [SELECT MasterLabel, Support_Number__c
                                                    FROM Support_Phone_Number__mdt 
                                                    ORDER BY MasterLabel];
        if(!toReturn.isEmpty())
            return toReturn;
        else
            return new List<Support_Phone_Number__mdt>();
        
    }
    
    @AuraEnabled
    public static boolean checkBusinessHours(String productName) 
    {
        boolean duringBusinessHours = false;
        BusinessHours productHours;
        
        Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();        
        for(BusinessHours bh : listBusinessHours)
            mapBusinessHours.put(bh.Name, bh);
        
        productHours = mapBusinessHours.get(productName);        
        if(productHours != null)
            duringBusinessHours = BusinessHours.isWithin(productHours.Id, datetime.now());
        
        return duringBusinessHours;
    }
    
    @AuraEnabled
    public static Id insertGuestCase(Case theCase, String theFiles) 
    {         
        //TODO: set defined values for the global action
        theCase.Origin = 'Customer Community Guest';
        theCase.RecordTypeId = supportRecordTypeId;
        theCase.Customer_Email__c = theCase.SuppliedEmail;
        //string theEmail=SCG_Utils.GetCleanString(theCase.SuppliedEmail, 80);
        /*
List<Contact> contacts = [select id,accountid from contact where email=:theEmail];
if(!contacts.isEmpty() && contacts.size()==1)
{
theCase.ContactId = contacts[0].Id;
theCase.AccountId=contacts[0].AccountId;
}
*/
        if(theFiles != '' && theFiles != null)
            theCase.Has_Attachment__c = true;
        
        insert theCase;
        
        if(theFiles != '' && theFiles != null) {
            attachFiles(theCase, theFiles, true);
        }    
        
        return theCase.Id;
    }
    
    @AuraEnabled
    public static void attachFiles(Case theCase, String theFiles, Boolean isGuestUser)
    {
        String[] fileIds = theFiles.split(',');
        
        List<ContentVersion> cvs = [
            SELECT                 
            Id
            ,ContentDocumentId
            ,ContentDocument.OwnerId
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIds
        ];
        if (cvs.size()>0) 
        {
            List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
            List<FeedAttachment> postAttachments = new List<FeedAttachment>();
            for (ContentVersion cv : cvs) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = theCase.Id;
                cdl.ShareType = 'V';
                
                cdls.add(cdl);
                
            }
            insert cdls;
            
            //now make the owner of the contentdocument be an internal user as otherwise 
            //any guest user could see the file. Update the contentversion as well
            //even though that shouldn't matter but it's to future proof any 
            //changes from SF security. Load into two different lists to prevent 
            //System.TypeException: Cannot have more than 10 chunks in a single operation. Please rearrange the data to reduce chunking
            
            if(isGuestUser)
            {
                Map<Id,ContentDocument> mToUpdate = new Map<Id,ContentDocument>();
                SCG_Setting__mdt metaRecord = SCG_Utils.getSetting('Support');
                for (ContentVersion cv : cvs) 
                {
                    ContentDocument cd = cv.ContentDocument;
                    cd.OwnerId=metaRecord.Default_Guest_File_Owner_ID__c;
                    mToUpdate.put(cv.ContentDocumentId,cd);                    
                    cv.OwnerId=metaRecord.Default_Guest_File_Owner_ID__c;                                    
                }
                update mToUpdate.values();
                update cvs;
            }
            
            //createFeedItem(theCase.Id, cvs);
        }
    }
    
    public static void createFeedItem(string theCaseId, List<ContentVersion> listContentVersion) 
    {     
        List<FeedItem> toInsert = new List<FeedItem>();
        
        for(ContentVersion cv : listContentVersion) {
            FeedItem item = new FeedItem(Body = 'This case has an attached file.',
                                         ParentId = theCaseId,
                                         RelatedRecordId = cv.Id,
                                         Visibility = 'AllUsers'
                                        );
            toInsert.add(item);
        }
        try{
        if(!toInsert.isEmpty())
            insert toInsert;
        }
        catch(Exception e) {
            system.debug(SCG_Utils.getErrorMessage(e,false));
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////
    // reCaptcha Remote Action
    //
    /////////////////////////////////////////////////////////////////////////////////////
    public class CaptchaResponse    
    {
        public boolean success;
    }
    
    @RemoteAction
    global static boolean verifyCaptcha(String captchaResponse) {
        boolean toReturn=true;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        SCG_Setting__mdt metaRecord = SCG_Utils.getSetting('Support');
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify?secret=' + metaRecord.reCaptcha_Secret_Key__c + '&response=' + captchaResponse);
        request.setMethod('POST');
        
        //String clientid = app.reCaptcha_Site_Key__c;
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Accept','application/json');
        request.setHeader('Content-Length','0');
        HttpResponse response = http.send(request); 
        //VCG_Utils.showDebug(response.getBody());
        if (response.getStatusCode() == 200) 
        {
            CaptchaResponse cr = (CaptchaResponse)JSON.deserialize(response.getBody(), CaptchaResponse.class);
            toReturn=cr.success;
        }
        
        return toReturn;
    }
    
}