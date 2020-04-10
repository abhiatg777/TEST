public without sharing class QS_VCG_Utils {
  public class ApplicationException extends Exception{}
  private static integer DebugInt;
  private Set<string> ObjectNames;
  public static Map<Id, User> DataLoadModeUsers
    {
        get
        {
            if (DataLoadModeUsers == null)
            {
                DataLoadModeUsers = new Map<Id, User> ([SELECT Id FROM User WHERE Bypass_Workflows__c = true]);
            }
            return DataLoadModeUsers;
        }
        set;
    }
    public static boolean IsDataLoadMode
    {
        get
        {
            return DataLoadModeUsers.containsKey(UserInfo.getUserId());
        }
 
    }
 
  public static Id GetRecordTypeId(string objectname,string recordtypename)
  {
    try
        {
            return GetRecordTypeNamesMap(objectName).get(recordtypename).getRecordTypeId();
        }
        catch(Exception ex)
        {
       throw new ApplicationException('Error-> Object :"'+objectname +'" or Record Type Name: "'+ recordtypename+'" cannot be accessed or is not Found/Configured ' );
    }
  }
    private static Map<string,Map<String,Schema.RecordTypeInfo>> mObjectsToRecordTypeNames;
  public static Map<String,Schema.RecordTypeInfo> GetRecordTypeNamesMap(string objectname)
  {
        if(mObjectsToRecordTypeNames==null)
        {
            mObjectsToRecordTypeNames=new Map<string,Map<String,Schema.RecordTypeInfo>>();
        }
        if(!mObjectsToRecordTypeNames.containsKey(objectName))
        {
            mObjectsToRecordTypeNames.put(objectName,Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName());
        }
        return   mObjectsToRecordTypeNames.get(objectname);
    }
    private static Map<string,Map<Id,Schema.RecordTypeInfo>> mObjectsToRecordTypeIds;
  public static Map<Id,Schema.RecordTypeInfo> GetRecordTypeIdsMap(string objectname)
  {
        if(mObjectsToRecordTypeIds==null)
        {
            mObjectsToRecordTypeIds=new Map<string,Map<Id,Schema.RecordTypeInfo>>();
        }
        if(!mObjectsToRecordTypeIds.containsKey(objectName))
        {
            mObjectsToRecordTypeIds.put(objectName,Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById());
        }
        return   mObjectsToRecordTypeIds.get(objectname);
    }

  public static string GetErrorMessage(Exception CaughtException,boolean forHTML)
  {
    String messageDelim='\n--------------------------------------------------------------------------\n';
    String theMessage='' +
        'An exception was caught @ ' + system.now() + '\nBelow is the exception information:' +
        messageDelim +
        'Exception Message:\n' +
        CaughtException.getMessage() +
        messageDelim +
        'Exception Cause:\n' +
        CaughtException.getCause() +
        messageDelim +
        'Exception Line:\n' +
        CaughtException.getLineNumber() +
        messageDelim +
        'Exception Stack Trace:\n' +
        CaughtException.getStackTraceString() +
        messageDelim;
    if(forHTML)
    {
      theMessage=theMessage.replace('\n','<br/>');
    }
    //system.debug(theMessage);
    return theMessage;
  }
  public static void showMsg(ApexPages.Severity sev, String message)
  {
    if(!System.isBatch() && ApexPages.currentPage()!=null)
    {
      ApexPages.Message msg =
          new ApexPages.Message(sev, message);
      ApexPages.addMessage(msg);
    }
  }

  public static boolean IsLoggedIn()
  {
    return UserInfo.getUserType().toLowerCase()!='guest';
  }
  public static boolean IsStandardUser()
  {
    return UserInfo.getUserType()=='Standard';
  }
  public static boolean IsPartnerUser()
  {
    return UserInfo.getUserType() == 'PowerPartner';
  }
  public static boolean IsPortalUser()
  {
    return (UserInfo.getUserType() == 'CSPLitePortal' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess');
  }
  public static void showInfo(String info)
  {
    showMsg(ApexPages.Severity.Info,info);
  }
  public static void showObject(object theObject)
  {
    showMsg(ApexPages.Severity.Info, String.valueOf(theObject));
  }
  public static void showDebug(object theObject)
  {
    if(DebugInt==null)
    {
      DebugInt=0;
    }
    string msg=String.valueOf(DebugInt) + '. - ' +String.valueOf(theObject);
    //if(UserInfo.getuserid()=='005W0000001Wg2NIAS')
    //{

    showMsg(ApexPages.Severity.Info, msg);
    system.debug(logginglevel.DEBUG,msg);
    //}
    DebugInt=DebugInt+1;
  }

  public static void showWarning(String warn)
  {
    showMsg(ApexPages.Severity.Warning,warn);
  }

  public static void showError(String err)
  {
    showMsg(ApexPages.Severity.Error,err);
  }
  public static string GetValueFromParam(string ParamKey)
  {
    string toReturn='';
    if(ApexPages.currentPage()!=null && ApexPages.currentPage().getParameters()!=null && ApexPages.currentPage().getParameters().containsKey(ParamKey))
    {
      toReturn=ApexPages.currentPage().getParameters().get(ParamKey);
      toReturn=GetCleanString(toReturn);
    }
    return toReturn;
  }
  public static string GetCleanString(string TheString)
  {
    return string.Escapesinglequotes(TheString);
  }
  public static string GetCleanString(string TheString, Integer maxLength)
  {
    String escaped = string.Escapesinglequotes(TheString);
    return escaped.substring(0, Math.min(escaped.length(), maxLength));
  }
  public static string GetObjectKeyPrefix(string ObjectName)
  {
    return Schema.getGlobalDescribe().get(ObjectName).getDescribe().getKeyPrefix();
  }
  public static string GetUserIPAddress()
  {
    //Map to hold current URL header parameters
    String toReturn;
    Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();
    //Proceed further only and only if map of header parameter have not null value with it
    if(mapHeaders != null) {
      toReturn = mapHeaders.get('True-Client-IP');
      if(toReturn == null)
      {
        toReturn = mapHeaders.get('X-Salesforce-SIP');
      }
    }
    return toReturn;
  }
  public static List<sObject> GetObjectByFields(String typeName, Set<String> fields, String whereClause, String orderByField) {
    Set<String> selectFieldSet = new Set<String>{'id'};
    selectFieldSet.addAll(fields);

    String selectFields = '';

    for(String thisField : selectFieldSet) {
      selectFields = selectFields + ', ' + thisField;
    }

    selectFields = selectFields.substring(2);
    String theQuery = 'SELECT ' + selectFields + ' '
        + 'FROM ' + typeName + ' ';
    if(whereClause!=null)
    {
      theQuery=theQuery + 'WHERE ' + whereClause;

    }
    if(orderByField != null) {
      theQuery += ' ORDER BY ' + orderByField;
    }
    //showObject('theQuery ' + theQuery);
    //showDebug(thequery);
    return Database.query(theQuery);
  }

  /*****************************************************************************************
   * This section of the code provides functions that should be used to ensure that code is
   * only executed once per batch process. Written by Marcus Harikan @ Navex
   */

  // Stores the distinct names that have previously executed.
  public static Map<String, Boolean> alreadyDone = null;

  /* Determines if a section of code has been previously executed with the indicated name.
   */
  public static boolean isAlreadyExecuted(String name,boolean showDebug)
    {
    if (alreadyDone == null) alreadyDone = new Map<String, Boolean>();
    Boolean done = alreadyDone.get(name);
    if (done == null) done = false;
        if(showDebug)
        {
          QS_VCG_Utils.showDebug('isAlreadyExecuted for=>' + name + '=>' + done);    
        }  
        return done;
    
    }
  public static boolean isAlreadyExecuted(String name)
    {
        return isAlreadyExecuted(name,false);
  }

  /* Indicates that a section of code has been executed with the indicated name.
   */
  public static void setExecuted(String name) {
    if (alreadyDone == null) alreadyDone = new Map<String, Boolean>();
    alreadyDone.put(name, true);
  }

  /* Used in testing routines to allow the flag to be rest if the data setup would trigger this.
   */
  public static void resetExecuted(String name) {
    if (alreadyDone == null) alreadyDone = new Map<String, Boolean>();
    alreadyDone.put(name, false);
  }

  /* This function is provided for test methods to be able to reset all flags that may have been
   * setup during the data initialization.
   */
  public static void resetAllExecuted() {
    if (alreadyDone == null) {
      alreadyDone = new Map<String, Boolean>();
      return;
    }
    alreadyDone.clear();
  }
  public static string GetInClause(Set<Id> theValues,boolean isString)
  {
    string strSeparator='\'';
    if(!isString)
    {
      strSeparator='';
    }
    return '(' + strSeparator + String.join(new List<Id>(theValues),+ strSeparator + ',' + + strSeparator) + strSeparator + ')';
  }
    public static string StringConcatenate(string currentValue,string newValue,string delimiter)
    {
        string toReturn='';
        if(String.isBlank(currentValue))
        {
            delimiter='';
        }
        else
        {
            toReturn=currentValue;
        }
        if(newValue!=null) toReturn+=delimiter + newValue;
        return toReturn;
    }
    public static void showConfirm(String conf)
    {
        showMsg(ApexPages.Severity.Confirm,conf);
    }

    public static List<sObject> GetObject(String typeName, String whereClause) {
        return GetObject(typeName, null, whereClause);
    }
    public static List<sObject> GetObject(String typeName,Set<string> ExtraFields, String whereClause) {
        Set<string> theFields=new Set<string>();
        theFields.addAll(Schema.getGlobalDescribe().get(typeName).getDescribe().fields.getMap().keySet());
        if(ExtraFields!=null && !ExtraFields.isEmpty())
        {
            theFields.addAll(ExtraFields);
        }
        return GetObjectByFields(typeName,theFields, whereClause, null);
    }

    public static List<sObject> GetObjectFromFieldSet(String typeName, String fieldSetName, Set<String> extraFields, String whereClause, String orderByField) {
        Set<String> selectFieldSet = new Set<String>{'id'};
            if(extraFields!=null)
        {
            selectFieldSet.addAll(extraFields);
        }

        for(Schema.FieldSetMember thisField : GetFieldsFromFieldSet(typeName,fieldSetName)) {
            selectFieldSet.add(thisField.getFieldPath());
        }

        return GetObjectByFields(typeName, selectFieldSet, whereClause, orderByField);
    }
    public static Map<string,Schema.SObjectField> GetFields(String typeName)
    {
        return Schema.getGlobalDescribe().get(typeName).getDescribe().fields.getMap();
    }

    public static List<Schema.FieldSetMember> GetFieldsFromFieldSet(String typeName,String fieldSetName)
    {
        return Schema.getGlobalDescribe().get(typeName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
    }
    public static Set<string> GetAllObjectNames()
    {
        Set<string> toReturn=new Set<string>();
        for(Schema.SObjectType f : Schema.getGlobalDescribe().values())
        {
            toReturn.add(f.getDescribe().getName());
        }
        //remove Milestone__c because that's old and causes false positives
        toReturn.remove('Milestone__c');
        return toReturn;
    }
    public object SObjectValueHelper(string fieldName,SObject parentObject,object newValue, boolean getField)
    {
        if(ObjectNames==null)
        {
            ObjectNames=QS_VCG_Utils.GetAllObjectNames();
        }
        Object toReturn=null;
        //now, if there are periods involved, it means there's relationships and we need to dig in.
        //otherwise, just get the field and return
        //vcg_cpq_utils.showdebug(fieldName);
        if(fieldName.contains('.'))
        {
            return SObjectValueHelper(fieldName.substringAfter('.'),(SObject)parentObject.getSObject(fieldName.substringBefore('.')),newValue,getField);
        }
        else
        {
            if(parentObject==null) return null;
            boolean isActualField=false;
            boolean checkSObject=ObjectNames.contains(fieldName) || fieldName.contains('__r');

            //if we are supposed to check the sobject because it "seems" like
            //the fieldname is an object name, we will test to see if it's true.
            //Some people name the fields the exact same as the object.  Ex: pse__Milestone__c which is both an object and a field on pse__Project_Task__c
            //In that case we must ensure that it's a field because otherwise we get an exception.
            //So do a try catch vs getfields as otherwise it'd be more resource intensive
            if(checkSObject)
            {
                try
                {
                    parentObject.getSObject(fieldName);
                }
                catch(Exception exc)
                {
                    isActualField=true;
                }
            }
            if(checkSObject && !isActualField)
            {
                if(getField)
                {
                    toReturn=parentObject.getSObject(fieldName);
                }
                else
                {
                    parentObject.putSObject(fieldName,(SObject)newValue);
                }
            }
            else
            {
                if(getField)
                {
                    toReturn=parentObject.get(fieldName);
                }
                else
                {
                    parentObject.put(fieldName,newValue);
                }
            }
        }
        return toReturn;
    }

    public List<SObject> CloneRecords(List<SObject> copyTo
                                     ,string objectName
                                     ,string fieldSetName
                                     ,string columns
                                     ,string whereClause)
    {
        Set<string> fieldsToQuery = new Set<string>();
        if(fieldSetName!=null)
        {
            for(Schema.FieldSetMember thisField : QS_VCG_Utils.GetFieldsFromFieldSet(objectName,fieldSetName))
            {
                fieldsToQuery.add(thisField.getFieldPath());
            }
        }
        if(columns!=null)
        {
          fieldsToQuery.addAll(columns.split(','));
        }

        if(fieldsToQuery.isEmpty())
        {
            return null;
        }

        List<Sobject> templates = QS_VCG_Utils.GetObjectByFields(objectName,fieldsToQuery,whereClause,null);
        if(templates==null)
        {
            return null;
        }

        for(SObject template : templates)
        {
            Type t = Type.forName(objectName);
            SObject newCopy = (SObject)t.newInstance();
            CloneRecord(newCopy,template,fieldsToQuery);
            copyTo.add(newCopy);
        }
        return templates;
    }
  public void CloneRecord(SObject copyTo,SObject copyFrom,Set<string> fieldsToCopy)
    {
        for(string fieldName : fieldsToCopy)
        {
            object valueToCopy=copyFrom.get(fieldName);
            if(valueToCopy==null) continue;
            copyTo.put(fieldName,valueToCopy);
        }
    }
    public static void SendEmail(
        List<User> userList,
        List<String> toList,
        String subject,
        String textBody,
        String htmlBody,
        Boolean allOrNone,
        Id orgWideEmail)
    {
      SendEmail(userList,toList,null,null,subject,textBody,htmlBody,null,allOrNone,orgWideEmail);
    }
    public static void SendEmail(
        List<User> userList,
        List<String> toList,
        List<String> ccList,
        List<String> bccList,
        String subject,
        String textBody,
        String htmlBody,
        Id templateId,
        Boolean allOrNone,
        Id orgWideEmail)
    {
        // Build up a list of the e-mail messages to send.
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        if (userList != null) {
            for (User u : userList) {
                System.debug('Sending to user ' + u);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(u.Id);
                mail.setSubject(subject);
                mail.setPlainTextBody(textBody);
                mail.setHtmlBody(htmlBody);
                mail.setTemplateId(templateId);
                mail.setSaveAsActivity(false);
                if(orgWideEmail != null){
                    mail.setOrgWideEmailAddressId(orgWideEmail);
                }
                emailMessageList.add(mail);
            }
        }
        if (toList != null && toList.size() > 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toList);
            mail.setCCAddresses(ccList);
            mail.setBCCAddresses(bccList);
            mail.setSubject(subject);
            mail.setPlainTextBody(textBody);
            mail.setHtmlBody(htmlBody);
            mail.setTemplateId(templateId);
            if(orgWideEmail != null){
                mail.setOrgWideEmailAddressId(orgWideEmail);
            }
            emailMessageList.add(mail);
        }
        showdebug(emailmessagelist);
        Messaging.sendEmail(emailMessageList, allOrNone);
    }
    
  private static Map<String, Set<Id>> mExecuted
  {
    get
    {
      if (mExecuted == null)
      {
        mExecuted = new Map<String, Set<Id>> ();
      }
      return mExecuted;
    }
    set;
  }

  public static boolean isAlreadyExecuted(String name, Id theId)
  {
    return mExecuted.containsKey(name) && (mExecuted.get(name)).contains(theId);
  }

  public static void setExecuted(String name, Id theId) {
    Set<Id> toReturn = mExecuted.get(name);
    if (toReturn == null)
    {
      toReturn = new Set<Id> ();
      mExecuted.put(name, toReturn);
    }
    if (!toReturn.contains(theId))
    {
      toReturn.add(theId);
    }
  }

  public static void resetExecuted(String name, Id theId) {
    Set<Id> toReturn = mExecuted.get(name);
    if (toReturn != null)
    {
      toReturn.remove(theId);
    }
  }
    
    public static Boolean enableIsRunningTest = true;
    
    public static Boolean isRunningTest()
    {
        return Test.isRunningTest() && enableIsRunningTest;
        
}
    public static Boolean SkipTrigger(string TriggerName)
    {
        if (
        (IsDataLoadMode && !isRunningTest())
            || isAlreadyExecuted(TriggerName)
        )
        {
            return true;
        }
        return false;
    }
    public static Decimal GetSObjectValue(SObject theObject, String fieldName)
    {
        Decimal toReturn = 0;
        if (theObject.get(fieldName) != null)
        {
            toReturn = Decimal.valueOf(String.valueOf(theObject.get(fieldName)));
        }
        return toReturn;
    }
    public static void ScheduleJob(Database.Batchable<sObject> batch, String name) {
        List<QS_Jobs__mdt> lObjects = QS_VCG_Utils.getObject('QS_Jobs__mdt', 'Label=\'' + name + '\'');
        if (lObjects.isEmpty()) {
            return;
        }
        QS_Jobs__mdt metaRecord = lObjects[0];
        string jobName = metaRecord.QS_Job_Name__c;
 
        List<CronJobDetail> jobs=[select Id from CronJobDetail WHERE Name=:jobName];
        //for tests we want to force the run so we change some items
        boolean testing=Test.isRunningTest();
        if(testing)
        {
            jobs=new List<CronJobDetail>();
            
            jobName=Guid();
        }
        if (!testing && (metaRecord.QS_Automatic_Reschedule__c == false || metaRecord.QS_Abort__c == true || !jobs.isEmpty())) {
            return;
        }
        else {
            if(metaRecord.QS_Automatic_Reschedule__c && metaRecord.QS_Schedule_Frequency__c!=null && metaRecord.QS_Job_Size__c!=null)
            {
            	system.scheduleBatch(batch, jobName, Integer.valueOf(metaRecord.QS_Schedule_Frequency__c), Integer.valueOf(metaRecord.QS_Job_Size__c));
            }
        }
    }
    public static void RunJob(Database.Batchable<sObject> batch, string Name) {
        List<QS_Jobs__mdt> lObjects = QS_VCG_Utils.getObject('QS_Jobs__mdt', 'Label=\'' + name + '\'');
        if (lObjects.isEmpty()) {
            return;
        }
        QS_Jobs__mdt metaRecord = lObjects[0];
 
        if (metaRecord.QS_Abort__c == false) {
            Database.executeBatch(batch, Integer.valueOf(metaRecord.QS_Job_Size__c));
        }
    }
    public static string Guid()
    {
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }
}