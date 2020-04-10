global class QS_CSS_BatchAccountHealth implements Database.Batchable<SObject>, Schedulable
{
	public static final string JobName = 'QS_CSS_BatchAccountHealth';
	//constructors
	global QS_CSS_BatchAccountHealth() { }

	global void execute(SchedulableContext sc) {
		QS_VCG_Utils.RunJob(new QS_CSS_BatchAccountHealth(), JobName);
	}

	global database.querylocator start(Database.BatchableContext bc)
	{

		return Database.getQueryLocator(
		                                [
		                                SELECT
		                                Id, Name
		                                FROM Account 
                                        WHERE QS_Is_Account_Health_Eligible__c = TRUE
		                                ]
		);

	}

	global void execute(Database.BatchableContext bc, List<sObject> scope)
	{		
		List<Account> toUpdate = new List<Account> ();
		for (sObject s : scope)
		{
			Account a = (Account) s;
			QS_CSS_AccountHealthUtils healthHelper = new QS_CSS_AccountHealthUtils();
			healthHelper.UpdateHealth(a.Id);
		}

	}

	global void finish(Database.BatchableContext bc)
	{
        QS_VCG_Utils.ScheduleJob(new QS_CSS_BatchAccountHealth(), JobName);

	}


}