@isTest
public class QS_CSS_TestAccountHealth {       
	private static Id NPSId = QS_VCG_Utils.GetRecordTypeId('QS_Survey_Feedback__c', 'NPS');
    @testSetup static void setup()
	{

		Account a = new Account(
		                        Name = 'Test'
            					,QS_CSM__c = UserInfo.getUserId()
		);
		insert a;

		QS_Survey_Feedback__c sf = new QS_Survey_Feedback__c(
		                                               QS_Account__c = a.id,
		                                               QS_NPS__c = 6,
		                                               RecordTypeId = NPSId
		);
		insert sf;

	}
    private static QS_CSS_Account_Health__c getAccountHealth()
    {
        return [
            SELECT 
            Id
            , QS_Account_Survey_Score__c 
            ,QS_Start_Date__c
            ,QS_End_Date__c
            FROM QS_CSS_Account_Health__c 
            ];
    }
    // PASSING
    @isTest
	static void testNPS()
	{
		Test.startTest();
		Account acct = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

		QS_CSS_AccountHealthUtils a = new QS_CSS_AccountHealthUtils(); //creates a new instance of the class QS_CSS_AccountHealthUtils();
//		a.PicklistFirstDay='Last';
		a.UpdateHealth(acct.Id); //runs update health with the account we created
		QS_CSS_Account_Health__c acctHealth = [SELECT Id, QS_Account_Survey_Score__c FROM QS_CSS_Account_Health__c WHERE QS_Account__c = :acct.Id];

		System.AssertEquals(6, acctHealth.QS_Account_Survey_Score__c, 'NPS not updated correctly');

		QS_Survey_Feedback__c sf2 = new QS_Survey_Feedback__c(
		                                                QS_Account__c = acct.id,
		                                                QS_NPS__c = 1,
		                                                RecordTypeId = NPSId
            											//QS_VCG_Utils getRecordType
		);
		insert sf2;
		a.UpdateHealth(acct.Id); //runs update health with this ^ account
		acctHealth = [SELECT Id, QS_Account_Survey_Score__c FROM QS_CSS_Account_Health__c WHERE QS_Account__c = :acct.Id];
		System.AssertEquals(3.5, acctHealth.QS_Account_Survey_Score__c, 'NPS not updated correctly');

		Test.stopTest();
	}
    
    //PASSING
    @isTest
    static void testQSSettingsPicklistFirst()
    {
        Test.startTest();
        
		QS_CSS_AccountHealthUtils a = new QS_CSS_AccountHealthUtils(); //creates a new instance of the class QS_CSS_AccountHealthUtils();
		a.PicklistFirstDay='First';

        //Test start of year
        a.DtToday = date.newinstance(2019, 1, 1);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 01, 01), a.StartDate);
        system.assertEquals(date.newInstance(2019, 01, 31), a.EndDate);
        
        //Test end of year
        a.DtToday = date.newinstance(2019, 12, 31);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 12, 01), a.StartDate);
        system.assertEquals(date.newInstance(2019, 12, 31), a.EndDate);

        //Test month of 30
        a.DtToday = date.newinstance(2019, 04, 15);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 04, 01), a.StartDate);
        system.assertEquals(date.newInstance(2019, 04, 30), a.EndDate);
        
		//Test leap year
        a.DtToday = date.newinstance(2020, 2, 29);
        a.setDates();
        system.assertEquals(date.newInstance(2020, 02, 01), a.StartDate);
        system.assertEquals(date.newInstance(2020, 02, 29), a.EndDate);
        
		Test.stopTest();
    }
        
    
    //PASSING
    @isTest
    static void testQSSettingsPicklistOther()
    {
        Test.startTest();
        
		QS_CSS_AccountHealthUtils a = new QS_CSS_AccountHealthUtils(); //creates a new instance of the class QS_CSS_AccountHealthUtils();
		a.NumberFirstDay = 8;
        a.PicklistFirstDay='Other';

        //Test start of year
        a.DtToday = date.newinstance(2019, 1, 1);
        a.setDates();
        system.assertEquals(date.newInstance(2018, 12, 08), a.StartDate);
        system.assertEquals(date.newInstance(2019, 01, 07), a.EndDate);
        
        //Test end of year
        a.DtToday = date.newinstance(2019, 12, 31);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 12, 08), a.StartDate);
        system.assertEquals(date.newInstance(2020, 01, 07), a.EndDate);
        
		//Test leap year
        a.DtToday = date.newinstance(2020, 02, 29);
        a.setDates();
        system.assertEquals(date.newInstance(2020, 02, 08), a.StartDate);
        system.assertEquals(date.newInstance(2020, 03, 07), a.EndDate);
        
        //Test month of 30
        a.DtToday = date.newinstance(2019, 4, 15);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 04, 08), a.StartDate);
        system.assertEquals(date.newInstance(2019, 05, 07), a.EndDate);
        
        
        //Test same day (should not be new month yet)
        a.DtToday = date.newinstance(2019, 4, 7);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 03, 08), a.StartDate);
        system.assertEquals(date.newInstance(2019, 04, 07), a.EndDate);
        
        //Test same month (should not be new month yet)
        a.DtToday = date.newinstance(2019, 4, 5);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 03, 08), a.StartDate);
        system.assertEquals(date.newInstance(2019, 04, 07), a.EndDate);
       
		Test.stopTest();

    }
    
    
    //PASSING
    @isTest
    static void testQSSettingsPicklistThird()
    {
        Test.startTest();
        
        QS_CSS_AccountHealthUtils a = new QS_CSS_AccountHealthUtils(); //creates a new instance of the class QS_CSS_AccountHealthUtils();
        a.PicklistFirstDay='Third';
        
        //Test start of year
        a.DtToday = date.newinstance(2019, 01, 01);
        a.setDates();
        system.assertEquals(date.newInstance(2018, 12, 29), a.StartDate);
        system.assertEquals(date.newInstance(2019, 01, 28), a.EndDate);
        
        //Test end of year
        a.DtToday = date.newinstance(2019, 12, 31);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 12, 29), a.StartDate);
        system.assertEquals(date.newInstance(2020, 01, 28), a.EndDate);
        
		//Test leap year
        a.DtToday = date.newinstance(2020, 2, 29);
        a.setDates();
        system.assertEquals(date.newInstance(2020, 02, 27), a.StartDate);
        system.assertEquals(date.newInstance(2020, 03, 28), a.EndDate);
        
        //Test month of 30
        a.DtToday = date.newinstance(2019, 4, 15);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 03, 29), a.StartDate);
        system.assertEquals(date.newInstance(2019, 04, 27), a.EndDate);
        
		Test.stopTest();
        
    }
    
    
    //PASSING
    @isTest
    static void testQSSettingsPicklistSecond()
    {
        Test.startTest();
        
        QS_CSS_AccountHealthUtils a = new QS_CSS_AccountHealthUtils(); //creates a new instance of the class QS_CSS_AccountHealthUtils();
        a.PicklistFirstDay='Second';
        
        //Test start of year
        a.DtToday = date.newinstance(2019, 01, 01);
        a.setDates();
        system.assertEquals(date.newInstance(2018, 12, 30), a.StartDate);
        system.assertEquals(date.newInstance(2019, 01, 29), a.EndDate);
        
        //Test end of year
        a.DtToday = date.newinstance(2019, 12, 31);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 12, 30), a.StartDate);
        system.assertEquals(date.newInstance(2020, 01, 29), a.EndDate);
        
		//Test leap year
        a.DtToday = date.newinstance(2020, 2, 29);
        a.setDates();
        system.assertEquals(date.newInstance(2020, 02, 28), a.StartDate);
        system.assertEquals(date.newInstance(2020, 03, 29), a.EndDate);
        
        //Test month of 30
        a.DtToday = date.newinstance(2019, 4, 15);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 03, 30), a.StartDate);
        system.assertEquals(date.newInstance(2019, 04, 28), a.EndDate);
        
		Test.stopTest();
    }
    
    
    //PASSING
    @isTest
    static void testQSSettingsPicklistLast()
    {
        Test.startTest();
        
        QS_CSS_AccountHealthUtils a = new QS_CSS_AccountHealthUtils(); //creates a new instance of the class QS_CSS_AccountHealthUtils();
        a.PicklistFirstDay='Last';
        
        //Test start of year
        a.DtToday = date.newinstance(2019, 01, 01);
        a.setDates();
        system.assertEquals(date.newInstance(2018, 12, 31), a.StartDate);
        system.assertEquals(date.newInstance(2019, 01, 30), a.EndDate);
        
        //Test end of year
        a.DtToday = date.newinstance(2019, 12, 31);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 12, 31), a.StartDate);
        system.assertEquals(date.newInstance(2020, 01, 30), a.EndDate);
        
		//Test leap year
        a.DtToday = date.newinstance(2020, 2, 29);
        a.setDates();
        system.assertEquals(date.newInstance(2020, 02, 29), a.StartDate);
        system.assertEquals(date.newInstance(2020, 03, 30), a.EndDate);
        
        //Test month of 30
        a.DtToday = date.newinstance(2019, 4, 15);
        a.setDates();
        system.assertEquals(date.newInstance(2019, 03, 31), a.StartDate);
        system.assertEquals(date.newInstance(2019, 04, 29), a.EndDate);
        
		Test.stopTest();
    }
    

    
    
    // PASSING
	@isTest
	static void testSetPriorMonthSameMonth()
	{
		QS_CSS_AccountHealthUtils ahu = new QS_CSS_AccountHealthUtils();
        ahu.DtToday = date.newinstance(2019, 2, 7);
        ahu.NumberFirstDay = 8;
        ahu.PicklistFirstDay='Other';
		Account acct = [SELECT Id, Name FROM Account];
        
		Test.startTest();
        
        ahu.setDates();
        
		Date startDate=ahu.startDates[1];
		Date endDate=ahu.mStartDateToEndDate.get(startDate);
		QS_CSS_Account_Health__c ah2 = new QS_CSS_Account_Health__c(
		                                              QS_Account__c = acct.Id,
		                                              QS_Start_Date__c = startDate,
		                                              QS_End_Date__c = endDate
		);
		startDate=ahu.startDates[0];
		endDate=ahu.mStartDateToEndDate.get(startDate);
		QS_CSS_Account_Health__c ah3 = new QS_CSS_Account_Health__c(
		                                              QS_Account__c = acct.Id,
		                                              QS_Start_Date__c = startDate,
		                                              QS_End_Date__c = endDate
		);
        
		insert ah2;
		insert ah3;

		ahu.UpdateHealth(acct.Id);

		ahu.theAccountHealth=null;
		QS_CSS_Account_Health__c ah1 = [select QS_Last_Months_Health__c,QS_Two_Months_Prior_Health__c, QS_Start_Date__c from QS_CSS_Account_Health__c  where Id=:ahu.theAccountHealth.Id order by QS_Start_Date__c desc ];
        System.assertEquals(ah1.QS_Start_Date__c, date.newInstance(2019, 01, 08));
        System.assertEquals(ah2.QS_Start_Date__c, date.newInstance(2018, 12, 08));
        System.assertEquals(ah3.QS_Start_Date__c, date.newInstance(2018, 11, 08));
		System.assertEquals(ah2.Id, ah1.QS_Last_Months_Health__c);
		System.assertEquals(ah3.Id, ah1.QS_Two_Months_Prior_Health__c);

		Test.stopTest();
	}
    
        // PASSING
	@isTest
	static void testSetPriorMonthNextMonth()
	{
		QS_CSS_AccountHealthUtils ahu = new QS_CSS_AccountHealthUtils();
        ahu.DtToday = date.newinstance(2019, 2, 16);
        ahu.NumberFirstDay = 8;
        ahu.PicklistFirstDay='Other';
		Account acct = [SELECT Id, Name FROM Account];
        
		Test.startTest();
        
        ahu.setDates();
        
		Date startDate=ahu.startDates[1];
		Date endDate=ahu.mStartDateToEndDate.get(startDate);
		QS_CSS_Account_Health__c ah2 = new QS_CSS_Account_Health__c(
		                                              QS_Account__c = acct.Id,
		                                              QS_Start_Date__c = startDate,
		                                              QS_End_Date__c = endDate
		);
		startDate=ahu.startDates[0];
		endDate=ahu.mStartDateToEndDate.get(startDate);
		QS_CSS_Account_Health__c ah3 = new QS_CSS_Account_Health__c(
		                                              QS_Account__c = acct.Id,
		                                              QS_Start_Date__c = startDate,
		                                              QS_End_Date__c = endDate
		);
        
		insert ah2;
		insert ah3;

		ahu.UpdateHealth(acct.Id);

		ahu.theAccountHealth=null;
		QS_CSS_Account_Health__c ah1 = [select QS_Last_Months_Health__c,QS_Two_Months_Prior_Health__c, QS_Start_Date__c from QS_CSS_Account_Health__c  where Id=:ahu.theAccountHealth.Id order by QS_Start_Date__c desc ];
        System.debug('this months health' + ah1.QS_Start_Date__c);
        System.debug('last months health' + ah2.QS_Start_Date__c);
        System.debug('2 months health' + ah3.QS_Start_Date__c);
        System.assertEquals(ah1.QS_Start_Date__c, date.newInstance(2019, 02, 08));
        System.assertEquals(ah2.QS_Start_Date__c, date.newInstance(2019, 01, 08));
        System.assertEquals(ah3.QS_Start_Date__c, date.newInstance(2018, 12, 08));
		System.assertEquals(ah2.Id, ah1.QS_Last_Months_Health__c);
		System.assertEquals(ah3.Id, ah1.QS_Two_Months_Prior_Health__c);

		Test.stopTest();
	}
    
    // PASSING
	@isTest
	static void testSetPriorMonthSameDay()
	{
		QS_CSS_AccountHealthUtils ahu = new QS_CSS_AccountHealthUtils();
        ahu.DtToday = date.newinstance(2019, 2, 8);
        ahu.NumberFirstDay = 8;
        ahu.PicklistFirstDay='Other';
		Account acct = [SELECT Id, Name FROM Account];
        
		Test.startTest();
        
        ahu.setDates();
        
		Date startDate=ahu.startDates[1];
		Date endDate=ahu.mStartDateToEndDate.get(startDate);
		QS_CSS_Account_Health__c ah2 = new QS_CSS_Account_Health__c(
		                                              QS_Account__c = acct.Id,
		                                              QS_Start_Date__c = startDate,
		                                              QS_End_Date__c = endDate
		);
		startDate=ahu.startDates[0];
		endDate=ahu.mStartDateToEndDate.get(startDate);
		QS_CSS_Account_Health__c ah3 = new QS_CSS_Account_Health__c(
		                                              QS_Account__c = acct.Id,
		                                              QS_Start_Date__c = startDate,
		                                              QS_End_Date__c = endDate
		);
        
		insert ah2;
		insert ah3;

		ahu.UpdateHealth(acct.Id);

		ahu.theAccountHealth=null;
		QS_CSS_Account_Health__c ah1 = [select QS_Last_Months_Health__c,QS_Two_Months_Prior_Health__c, QS_Start_Date__c from QS_CSS_Account_Health__c  where Id=:ahu.theAccountHealth.Id order by QS_Start_Date__c desc ];
        System.debug('this months health' + ah1.QS_Start_Date__c);
        System.debug('last months health' + ah2.QS_Start_Date__c);
        System.debug('2 months health' + ah3.QS_Start_Date__c);
        System.assertEquals(ah1.QS_Start_Date__c, date.newInstance(2019, 02, 08));
        System.assertEquals(ah2.QS_Start_Date__c, date.newInstance(2019, 01, 08));
        System.assertEquals(ah3.QS_Start_Date__c, date.newInstance(2018, 12, 08));
		System.assertEquals(ah2.Id, ah1.QS_Last_Months_Health__c);
		System.assertEquals(ah3.Id, ah1.QS_Two_Months_Prior_Health__c);

		Test.stopTest();
	}
    
    // PASSING
	@isTest
	static void testBatchAccountHealth() {
		Test.startTest();
		QS_CSS_BatchAccountHealth b = new QS_CSS_BatchAccountHealth();
		QS_VCG_Utils.RunJob(b, QS_CSS_BatchAccountHealth.JobName);
		String CRON_EXP = '0 0 13 * * ?';
		System.schedule(QS_VCG_Utils.Guid(), CRON_EXP, b);
		Test.stopTest();
	}
    
    //PASSING
	@isTest
	static void testAccountHealthController() {
		Account acct = [SELECT Id, Name FROM Account WHERE Name = 'Test'];
		String acctId = acct.Id;
		QS_CSS_AccountHealthController.UpdateHealth(acctId);
		delete acct;
		QS_CSS_AccountHealthController.UpdateHealth(acctId); //check throwing exception
	}

}