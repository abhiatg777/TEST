public without sharing class SCG_Utils {
	public class ApplicationException extends Exception { }
	private static integer DebugInt;
	private Set<string> ObjectNames;
    public static Boolean enableIsRunningTest = true;
    private static Map<string, Map<String, Schema.RecordTypeInfo>> mObjectsToRecordTypeNames;
    private static Map<string, Map<Id, Schema.RecordTypeInfo>> mObjectsToRecordTypeIds;

	public static string GetErrorMessage(Exception CaughtException, boolean forHTML)
	{
		String messageDelim = '\n--------------------------------------------------------------------------\n';
		String theMessage = '' +
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
		if (forHTML)
		{
			theMessage = theMessage.replace('\n', '<br/>');
		}
		//system.debug(theMessage);
		return theMessage;
	}

	public static List<sObject> GetObjectByFields(String typeName, Set<String> fields, String whereClause, String orderByField) {
		Set<String> selectFieldSet = new Set<String> { 'id' };
		selectFieldSet.addAll(fields);

		String selectFields = '';

		for (String thisField : selectFieldSet) {
			selectFields = selectFields + ', ' + thisField;
		}

		selectFields = selectFields.substring(2);
		String theQuery = 'SELECT ' + selectFields + ' '
		+ 'FROM ' + typeName + ' ';
		if (whereClause != null)
		{
			theQuery = theQuery + 'WHERE ' + whereClause;

		}
		if (orderByField != null) {
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
	public static boolean isAlreadyExecuted(String name)
	{
		if (alreadyDone == null) alreadyDone = new Map<String, Boolean> ();
		Boolean done = alreadyDone.get(name);
		if (done == null) done = false;

		return done;

	}

	/* Indicates that a section of code has been executed with the indicated name.
	 */
	public static void setExecuted(String name) {
		if (alreadyDone == null) alreadyDone = new Map<String, Boolean> ();
		alreadyDone.put(name, true);
	}

	/* Used in testing routines to allow the flag to be rest if the data setup would trigger this.
	 */
	public static void resetExecuted(String name) {
		if (alreadyDone == null) alreadyDone = new Map<String, Boolean> ();
		alreadyDone.put(name, false);
	}

	/* This function is provided for test methods to be able to reset all flags that may have been
	 * setup during the data initialization.
	 */
	public static void resetAllExecuted() {
		if (alreadyDone == null) {
			alreadyDone = new Map<String, Boolean> ();
			return;
		}
		alreadyDone.clear();
	}

	public static List<sObject> GetObject(String typeName, String whereClause) {
		return GetObject(typeName, null, whereClause);
	}
	public static List<sObject> GetObject(String typeName, Set<string> ExtraFields, String whereClause) {
		Set<string> theFields = new Set<string> ();
		theFields.addAll(Schema.getGlobalDescribe().get(typeName).getDescribe().fields.getMap().keySet());
		if (ExtraFields != null && !ExtraFields.isEmpty())
		{
			theFields.addAll(ExtraFields);
		}
		return GetObjectByFields(typeName, theFields, whereClause, null);
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
    
	public static void ScheduleJob(Database.Batchable<sObject> batch, String name) {
		List<SCG_Job__mdt> lObjects = SCG_Utils.getObject('SCG_Job__mdt', 'Label=\'' + name + '\'');
		if (lObjects.isEmpty()) {
			return;
		}
		SCG_Job__mdt metaRecord = lObjects[0];
		string jobName = metaRecord.Job_Name__c;

		List<CronJobDetail> jobs=[select Id from CronJobDetail WHERE Name=:jobName];
        //for tests we want to force the run so we change some items
        boolean testing=Test.isRunningTest();
        if(testing)
        {
            jobs=new List<CronJobDetail>();
            
            jobName=Guid();
        }
		if (!testing && (metaRecord.Automatic_Reschedule__c == false || metaRecord.Abort__c == true || !jobs.isEmpty())) {
			return;
		}
		else {
			system.scheduleBatch(batch, jobName, Integer.valueOf(metaRecord.Schedule_Frequency__c), Integer.valueOf(metaRecord.Job_Size__c));
		}
	}
	public static void RunJob(Database.Batchable<sObject> batch, string Name) {
		List<SCG_Job__mdt> lObjects = SCG_Utils.getObject('SCG_Job__mdt', 'Label=\'' + name + '\'');
		if (lObjects.isEmpty()) {
			return;
		}
		SCG_Job__mdt metaRecord = lObjects[0];

		if (metaRecord.Abort__c == false) {
			Database.executeBatch(batch, Integer.valueOf(metaRecord.Job_Size__c));
		}
	}
    
    public static Id GetRecordTypeId(string objectname, string recordtypename)
    {
        try
        {
            return GetRecordTypeNamesMap(objectName).get(recordtypename).getRecordTypeId();
        }
        catch(Exception ex)
        {
            throw new ApplicationException('Error-> Object :"' + objectname + '" or Record Type Name: "' + recordtypename + '" cannot be accessed or is not Found/Configured ');
        }
    }
    public static Map<String, Schema.RecordTypeInfo> GetRecordTypeNamesMap(string objectname)
    {
        if (mObjectsToRecordTypeNames == null)
        {
            mObjectsToRecordTypeNames = new Map<string, Map<String, Schema.RecordTypeInfo>> ();
        }
        if (!mObjectsToRecordTypeNames.containsKey(objectName))
        {
            mObjectsToRecordTypeNames.put(objectName, Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName());
        }
        return mObjectsToRecordTypeNames.get(objectname);
    }
    public static Map<Id, Schema.RecordTypeInfo> GetRecordTypeIdsMap(string objectname)
    {
        if (mObjectsToRecordTypeIds == null)
        {
            mObjectsToRecordTypeIds = new Map<string, Map<Id, Schema.RecordTypeInfo>> ();
        }
        if (!mObjectsToRecordTypeIds.containsKey(objectName))
        {
            mObjectsToRecordTypeIds.put(objectName, Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById());
        }
        return mObjectsToRecordTypeIds.get(objectname);
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
    
    public static string GetInClause(Set<Id> theValues, boolean isString)
    {
        string strSeparator = '\'';
        if (!isString)
        {
            strSeparator = '';
        }
        return '(' + strSeparator + String.join(new List<Id> (theValues), + strSeparator + ',' + + strSeparator) + strSeparator + ')';
    }
    
    public static Boolean isRunningTest()
    {
        return Test.isRunningTest() && enableIsRunningTest;
    }
    
    public static string Guid()
    {
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }
    
    public static SCG_Setting__mdt getSetting(string settingName)
    {
        
        List<SCG_Setting__mdt> theSettings = SCG_Utils.getObject('SCG_Setting__mdt','Label=\'' + settingName + '\'');
        SCG_Setting__mdt toReturn;
		if(theSettings.isEmpty())
        {
            toReturn = new SCG_Setting__mdt();
        }
        else
        {
            toReturn = theSettings[0];
        }
        
        return toReturn;
    }

    /**********************
     START USER METHODS 
    **********************/
    public static boolean IsLoggedIn()
    {
        return UserInfo.getUserType().toLowerCase() != 'guest';
    }
    public static boolean IsStandardUser()
    {
        return UserInfo.getUserType() == 'Standard';
    }
    public static boolean IsPartnerUser()
    {
        return UserInfo.getUserType() == 'PowerPartner';
    }
    public static boolean IsPortalUser()
    {
        return (UserInfo.getUserType() == 'CSPLitePortal' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess');
    }
    /**********************
     END USER METHODS 
    **********************/

}