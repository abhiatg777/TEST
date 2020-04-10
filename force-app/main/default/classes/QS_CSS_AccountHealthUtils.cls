public class QS_CSS_AccountHealthUtils {   
    public Date DtToday=date.today();
    public Date StartDate, EndDate;
    public Map<Date,Date> mStartDateToEndDate = new Map<Date,Date>();
    public List<Date> startDates = new List<Date>();
    public String PicklistFirstDay = String.valueOf(QS_CSS_Statics.QS_Settings.QS_Account_Health_Starting_Day__c);
    public Integer NumberFirstDay = Integer.valueOf(QS_CSS_Statics.QS_Settings.QS_Account_Health_Starting_Day_Number__c) == null ? 1 : Integer.valueOf(QS_CSS_Statics.QS_Settings.QS_Account_Health_Starting_Day_Number__c);
    private Id AccountId;
    
    public QS_CSS_AccountHealthUtils()
    {
        
    }
    
    
    
    private Account theAccount
    {
        get {
            Account toReturn;
            if (theAccount == null)
            {
                
                toReturn = [SELECT Id, QS_Annual_Recurring_Revenue__c,Name, QS_CSS_Account_Health__c
                            FROM Account
                            WHERE Id = :AccountId];
                theAccount = toReturn;
            }
            return theAccount;
        }
        set;
        
    }
    
    
    
    public QS_CSS_Account_Health__c theAccountHealth
    {
        get {
            QS_CSS_Account_Health__c toReturn;
            if (theAccountHealth == null)
            {
                List<QS_CSS_Account_Health__c> ahs = [
                    select
                    Id
                    , Name
                    , QS_Account_Survey_Score__c
                    FROM QS_CSS_Account_Health__c
                    WHERE QS_Account__c = :AccountId 
                    AND QS_Is_Editable__c = true 
                ];
                if (ahs.isEmpty())
                {
                    toReturn = createAccountHealth();
                }
                else
                {
                    toReturn = ahs[0];
                }
                theAccountHealth = toReturn;
            }
            return theAccountHealth;
        }
        set;
    }
    
    
    
    public void setDates() {
        StartDate = DtToday.toStartOfMonth(); //will get changed
        EndDate = DtToday.toStartOfMonth().addMonths(1).addDays(- 1); //will get changed
        mStartDateToEndDate = new Map<Date,Date>();
        startDates = new List<Date>();
        
        if(PicklistFirstDay=='First' || PicklistFirstDay=='Other')
        {            
            //the StartDate is already set to the first of the current month
            //so for Other, set it to the value entered in.
            if(PicklistFirstDay=='Other')
            {
                StartDate=StartDate.addDays(NumberFirstDay-1);
            }
            //now find where today falls into. 
            //Start 2 months prior for the later method of setmonthsprior
            //subtractMonth and forLimit are determined by which month we are in and if we are still 
            //in that month, more months need to be subtracted.
            integer subtractMonth = -2;
            integer forLimit = 1;
            if(NumberFirstDay > DtToday.day()){
            	subtractMonth--;
                forLimit--; 
            }

            for(integer i=subtractMonth;i<forLimit;i++)
            {
                Date possibleStartDate=StartDate.addMonths(i);
                Date possibleEndDate=StartDate.addMonths(i+1).addDays(-1);
                startDates.add(possibleStartDate);
                mStartDateToEndDate.put(possibleStartDate,possibleEndDate);
                if(DtToday>=possibleStartDate && DtToday<=possibleEndDate)
                {
                    StartDate=possibleStartDate;
                    EndDate=possibleEndDate;
                    break;
                }
            }
        }
        else 
        {
            switch on PicklistFirstDay            
            { 
                when 'Last'
                {
                    NumberFirstDay=-1;
                }
                when 'Second'
                {
                    NumberFirstDay=-2;
                }
                when else
                {
                    NumberFirstDay=-3;
                }
            }            
            //now find where today falls into
            //Start 2 months prior for the later method of setmonthsprior
            for(integer i=-1;i<2;i++)
            {
                //the StartDate is already set to the first of the current month
                //set it to the value entered in.
                Date possibleStartDate=StartDate.addMonths(i).addDays(NumberFirstDay);
                Date possibleEndDate=StartDate.addMonths(i+1).addDays(NumberFirstDay).addDays(-1);
                startDates.add(possibleStartDate);
                mStartDateToEndDate.put(possibleStartDate,possibleEndDate);
                if(DtToday>=possibleStartDate && DtToday<=possibleEndDate)
                {
                    StartDate=possibleStartDate;
                    EndDate=possibleEndDate;
                    break;
                }
            }
        }
    }
    
    
    
    public QS_CSS_Account_Health__c createAccountHealth() {
        
        setDates();
               
        theAccountHealth = new QS_CSS_Account_Health__c(
            QS_Account__c = AccountId
            , QS_Start_Date__c = StartDate
            , QS_End_Date__c = EndDate 
        );
        theAccountHealth.QS_Annual_Recurring_Revenue__c=theAccount.QS_Annual_Recurring_Revenue__c;
        setPriorMonths(theAccountHealth, 1);
        setPriorMonths(theAccountHealth, 2);
        insert theAccountHealth;
        theAccount.QS_CSS_Account_Health__c = theAccountHealth.Id;
        QS_VCG_Utils.setExecuted('AccountTrigger');
        update theAccount;
        QS_VCG_Utils.resetExecuted('AccountTrigger');
        
        return theAccountHealth;
    }
    
    
    
    public void setPriorMonths(QS_CSS_Account_Health__c theAccountHealth, integer monthsAgo)
    {        
        //System.debug('setPriorMonths');
		//System.debug('Account Health: ' + theAccountHealth);
        //System.debug('Months Ago: ' + monthsAgo);
        Date startFilter = startDates[2-monthsAgo];
        Date endFilter = mStartDateToEndDate.get(startFilter);
        
        List<QS_CSS_Account_Health__c> toFind = [
            select id from QS_CSS_Account_Health__c
            where
            QS_Start_Date__c = :startFilter
            AND QS_End_Date__c = :endFilter
            AND QS_Account__c = :theAccount.Id
        ];
        //System.debug(toFind);
        if (!toFind.isEmpty())
        {
            switch on monthsAgo
            {
                when 1
                {
                    theAccountHealth.QS_Last_Months_Health__c = toFind[0].Id;
                }
                when 2
                {
                    theAccountHealth.QS_Two_Months_Prior_Health__c = toFind[0].Id;
                }
            }
        }else{
            //System.debug('else');
        }
    }
    
    
    
    public void UpdateHealth(Id theAccountId)
    {
        accountId = theAccountId;
        Integer previousYears = (Integer.valueOf(QS_CSS_Statics.QS_Settings.QS_NPS_Survey_Years__c)) * -1;
        DateTime dtFilter = datetime.now().addYears(previousYears);
        theAccountHealth.QS_Account_Survey_Score__c = getRollupValue([
            SELECT AVG(QS_NPS__c) theAvg
            FROM QS_Survey_Feedback__c
            WHERE
            QS_Account__c = :theAccount.Id
            AND QS_Is_Account_Health_Eligible__c = true
            AND CreatedDate>=:dtFilter
        ], 'theAvg', false);
        System.debug(theAccountHealth);
        theAccountHealth.QS_Annual_Recurring_Revenue__c=theAccount.QS_Annual_Recurring_Revenue__c;
        update theAccountHealth;
    }
    
    private decimal getRollupValue(SObject[] ars, string columnName, boolean round)
    {
        decimal toReturn = - 1;
        object theVal = ars[0].get(columnName);
        if (ars != null && !ars.isEmpty() && theVal != null)
        {
            toReturn = (Decimal) theVal;
            if (round)
            {
                toReturn = toReturn.round();
            }
        }
        if (toReturn == - 1)
        {
            toReturn = null;
        }
        return toReturn;
    }

}