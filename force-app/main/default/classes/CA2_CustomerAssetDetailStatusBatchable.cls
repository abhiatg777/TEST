/**
 * @author Advanced Technology Group (www.atginfo.com)
 */
global class CA2_CustomerAssetDetailStatusBatchable implements Database.Batchable<sObject> {
    
     Date staticdate = System.Today();
     Boolean isRenewalClosedWon = false;
     Boolean isRenewalClosed = false;
     Boolean isRenewalGenerated = false;
     Boolean isLastSegment = false;
     Boolean isRenewalPastDue = false;
     Boolean isDecommRecordCreated = false;
    //after days of the End Date 
    QS_customer_asset_settings__c AfterDays = QS_customer_asset_settings__c.getInstance();  
    String query = 'SELECT Id,QS_Terminated_Date__c, QS_Asset_Status__c,QS_Booking_Date__c, QS_Customer_Asset__c,QS_Currently_Active__c, QS_End_Date__c,QS_Start_Date__c, QS_Product__r.QS_Auto_Activate__c, QS_Product__r.QS_Auto_Deactivate__c,QS_Contract__r.SBQQ__RenewalOpportunity__r.IsWon,QS_Contract__r.SBQQ__RenewalOpportunity__r.IsClosed,QS_Contract__r.SBQQ__RenewalOpportunity__r.CloseDate,QS_Contract__r.EndDate,QS_Contract__r.SBQQ__Opportunity__r.CloseDate,QS_Contract__r.SBQQ__Opportunity__c FROM QS_Customer_Asset_Detail__c where QS_Asset_Status__c in (\'Active\',\'Reduced\',\'Pending Activation\',\'Pending Renewal\',\'Pending Reduction\',\'Pending Decommission\')';    
  //   String query = 'SELECT Id, QS_Asset_Status__c, QS_Customer_Asset__c,QS_Currently_Active__c, QS_End_Date__c,QS_Start_Date__c, QS_Product__r.QS_Auto_Activate__c, QS_Product__r.QS_Auto_Deactivate__c,QS_Contract__r.SBQQ__RenewalOpportunity__r.IsWon,QS_Contract__r.SBQQ__RenewalOpportunity__r.IsClosed,QS_Contract__r.SBQQ__RenewalOpportunity__r.CloseDate,QS_Contract__r.EndDate,QS_Contract__r.SBQQ__Opportunity__r.CloseDate,QS_Contract__r.SBQQ__Opportunity__c FROM QS_Customer_Asset_Detail__c where QS_Customer_Asset__r.Id =\'a0C55000003WCiuEAG\'';    
    
    /**
     * Batachable start method implementation.
     * @param BC The BatchableContext object provided by runtime.
     * @return List of Customer Assets to be updated.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /**
     * Batchable execute method implementation.
     * This method applies expiration logic and updates on Customer Asset's Detail status.
     */
    global void execute(Database.BatchableContext BC, List<QS_Customer_Asset_Detail__c> scope) {
        
        executeBatchJob(scope,staticdate);
    }
    
    global void executeBatchJob(List<QS_Customer_Asset_Detail__c> scope,Date dt)
    {
        try{
                List<QS_Customer_Asset_Detail__c> cadforUpdate = new List<QS_Customer_Asset_Detail__c>();  
                Date effective_end_Date;      
                System.debug('In Batch Execute --->' + scope.size());
                for(QS_Customer_Asset_Detail__c cad: scope) {
                    System.debug('TEST Start loop');
                    
                    isRenewalClosedWon = isRenewalWon(cad);
                    isRenewalClosed = isRenewalClosed(cad);
                    isRenewalGenerated = isRenewalGenerated(cad);
                    isLastSegment = isLastSegmentInContract(cad);
                    isRenewalPastDue = isRenewalPastDue(cad,dt);
                    Date effective_terminated_Date;
                    System.debug('Current DT' + dt );
                                      
                    //Effective End Date for Expired Status
                    if(cad.QS_End_Date__c == NULL) {
                        effective_end_Date = dt + 2;
                    } else {
                        effective_end_Date = cad.QS_End_Date__c + Integer.valueOf(AfterDays.QS_Expiration_Days__c);
                    }
                    if(cad.QS_Terminated_Date__c != null)
                    {
                        System.debug('CAD Terminated Date' + cad.QS_Terminated_Date__c);
                        effective_terminated_Date = Date.valueOf(cad.QS_Terminated_Date__c.addDays(1));
                        
                        if(dt > effective_terminated_Date 
                       //   && cad.QS_Asset_Status__c <> 'Reduced' 
                        && cad.QS_Asset_Status__c <> 'Expired')
                        {
                            SYstem.debug('In Decom Logic');
                            cad.QS_Asset_Status__c = 'Decommissioned';
                            cadforUpdate.add(cad);
                        }
                        
                        if(dt <= effective_terminated_Date 
                     //     && cad.QS_Asset_Status__c <> 'Reduced' 
                        && cad.QS_Asset_Status__c <> 'Expired')
                        {
                            SYstem.debug('In Pending Decommission Logic');
                            cad.QS_Asset_Status__c = 'Pending Decommission';
                            cadforUpdate.add(cad);
                        }
                        
                        
                    }  
                    else{ 
                    
                    if((cad.QS_Asset_Status__c == 'Pending Activation' || cad.QS_Asset_Status__c == 'Active')  
                       && effective_end_Date <= dt) {
                            if(isLastSegment)
                            {
                                
                                if((isRenewalGenerated && !isRenewalClosed && isRenewalPastDue 
                                   || !isRenewalGenerated))
                                {
                                  
                                    cad.QS_Asset_Status__c = 'Pending Renewal';
                                    cadforUpdate.add(cad);
                                }else if (isRenewalClosed && !isRenewalClosedWon)
                                {
                               
                                    
                                    cad.QS_Asset_Status__c = 'Expired';
                                    cadforUpdate.add(cad);
                                    createDecommissionedRecord(cad);
                                }
                                else if (isRenewalClosed && isRenewalClosedWon)
                                {
                                    System.debug('Expired');
                                    cad.QS_Asset_Status__c = 'Expired';
                                    cadforUpdate.add(cad);
                                }
                            }else
                            {
                                if(cad.QS_Start_Date__c < dt )
                                {
                                    System.debug('Not last segment of Contract');
                                    cad.QS_Asset_Status__c = 'Expired';
                                    cadforUpdate.add(cad);
                                    
                                }
                            }
                        } 
                        else if(cad.QS_Asset_Status__c == 'Pending Renewal' 
                              && cad.QS_Product__r.QS_Auto_Activate__c == true) { 
                               if(isRenewalGenerated && isRenewalClosed)
                               {
                                   cad.QS_Asset_Status__c = 'Expired';
                                   cadforUpdate.add(cad);
                                   if(!isRenewalClosedWon)
                                   {
                                       createDecommissionedRecord(cad);
                                    }
                                    if(isRenewalClosedWon)
                                    {
                                        cad.QS_Asset_Status__c = 'Expired';
                                        
                                    }
                                   cadforUpdate.add(cad);
                               }
                               else if(cad.QS_Product__r.QS_Auto_Deactivate__c == True 
                                     && cad.QS_Start_Date__c <= dt 
                                    && effective_end_Date <= dt)
                                  {
                                      cad.QS_Asset_Status__c = 'Expired';
                                      cadforUpdate.add(cad);
                                  }
                                
                       
                        }   
                        else if(cad.QS_Asset_Status__c == 'Pending Activation' && cad.QS_Start_Date__c > dt) {
                            cad.QS_Currently_Active__c = False;
                            cadforUpdate.add(cad);

                        }
                        else if((cad.QS_Asset_Status__c == 'Pending Activation'||cad.QS_Asset_Status__c == 'Active') 
                                && cad.QS_Product__r.QS_Auto_Activate__c == True 
                                && cad.QS_Start_Date__c <= dt
                                && effective_end_Date >= dt
                               ) {
                                
                                cad.QS_Asset_Status__c = 'Active';
                                cadforUpdate.add(cad);   
        
                        } 
                        else if(cad.QS_Asset_Status__c == 'Pending Decommission' 
                                  && cad.QS_Product__r.QS_Auto_Deactivate__c == True && 
                                  cad.QS_Start_Date__c <= dt) {
                            cad.QS_Asset_Status__c = 'Decommissioned';
                            cadforUpdate.add(cad);
                        
                        } 
                        else if(cad.QS_Asset_Status__c == 'Pending Reduction' 
                                  && cad.QS_Product__r.QS_Auto_Deactivate__c == True 
                                  && cad.QS_Start_Date__c <= dt
                                  && effective_end_Date >= dt
                                 ) { 
                                    cad.QS_Asset_Status__c = 'Reduced';
                                    cadforUpdate.add(cad);
                        
                                } 
                        else if(cad.QS_Asset_Status__c == 'Reduced' 
                              && cad.QS_Start_Date__c <= dt 
                              && cad.QS_End_Date__c >= dt 
                              && cad.QS_Product__r.QS_Auto_Deactivate__c == true) { 
                                cad.QS_Asset_Status__c = 'Reduced';
                                cadforUpdate.add(cad);
                       
                        }    
                        else if(cad.QS_Asset_Status__c == 'Reduced' 
                                  && cad.QS_Start_Date__c <= dt 
                                  && cad.QS_End_Date__c < dt 
                                  && cad.QS_Product__r.QS_Auto_Deactivate__c == true) { 
                                    cad.QS_Asset_Status__c = 'Reduced';
                                    cadforUpdate.add(cad);
                                  
                        } 
                    }
                    
                    if(cad.QS_Asset_Status__c == 'Expired')
                    {
                        cad.QS_Currently_Active__c = false;
                    }
                    else if(cad.QS_End_Date__c < dt)
                    {
                        cad.QS_Currently_Active__c = false;
                    }    
                    else if(cad.QS_End_Date__c >= dt && cad.QS_Start_Date__c <= dt)
                    {
                        cad.QS_Currently_Active__c = true;
                    }
                    else if(cad.QS_End_Date__c > dt && cad.QS_Start_Date__c > dt)
                    {
                        cad.QS_Currently_Active__c = false;
                    }

                    //This is to ensure the CADs generated from Assets are always currently Active
                    if(cad.QS_End_Date__c ==null){
                    
                        cad.QS_Currently_Active__c = true;
                    }

                }
        
                //update statues
                if(cadforUpdate.size() > 0){
                    update cadforUpdate;            
                }
        }
        catch(Exception ex)
        {
                System.debug(' Error Occurred at line number ' + ex.getLineNumber() + '  Message -->' + ex.getMessage());
            }
    }
    
        
    public Boolean isRenewalGenerated(QS_Customer_Asset_Detail__c cad)
    {
        if(cad.QS_Contract__r.SBQQ__RenewalOpportunity__r == null)
        {
            return false;
        }return true;
    }
    
    public Boolean isRenewalClosed(QS_Customer_Asset_Detail__c cad)
    {
        if(cad.QS_Contract__r.SBQQ__RenewalOpportunity__r == null)
        {
            return false;
        }
        return cad.QS_Contract__r.SBQQ__RenewalOpportunity__r.IsClosed;
        
    }
    
    public Boolean isRenewalWon(QS_Customer_Asset_Detail__c cad)
    {
        if(cad.QS_Contract__r.SBQQ__RenewalOpportunity__r == null)
        {
            return false;
        }
        return cad.QS_Contract__r.SBQQ__RenewalOpportunity__r.IsWon;
        
    }
       
    public Boolean isRenewalPastDue(QS_Customer_Asset_Detail__c cad,Date dynamicdate)
    {
        if(cad.QS_Contract__r.EndDate == null)
        {
            return false;
        }
        return (cad.QS_Contract__r.EndDate < dynamicdate);
    }
    public Boolean isLastSegmentInContract(QS_Customer_Asset_Detail__c cad)
    {
        return (cad.QS_End_Date__c == cad.QS_Contract__r.EndDate);
    }
    
    public Boolean createDecommissionedRecord(QS_Customer_Asset_Detail__c cad)
    {
        try
        {
            
            
            QS_Customer_Asset_Detail__c decommRecordToBeCreated = new QS_Customer_Asset_Detail__c();
            decommRecordToBeCreated = cad.clone(false,true,false,false);
            insert decommRecordToBeCreated; 
            decommRecordToBeCreated.QS_Start_Date__c = cad.QS_Contract__r.EndDate.addDays(1);
            decommRecordToBeCreated.QS_End_Date__c = cad.QS_Contract__r.EndDate.addDays(1);
            decommRecordToBeCreated.QS_Asset_Status__c = 'Decommissioned';
            decommRecordToBeCreated.QS_CA_Quantity__c = 0;
            decommRecordToBeCreated.QS_Quantity__c = 0;
            decommRecordToBeCreated.QS_Booking_Date__c = cad.QS_Booking_Date__c;
            decommRecordToBeCreated.QS_Previous_Contract__c = cad.QS_Contract__c;
            decommRecordToBeCreated.QS_Apex_Created_Decommission_Record__c = true;
            update decommRecordToBeCreated;
            return true;
            
        }
        Catch(Exception ex)
        {
            System.debug('Exception Occurred' + ex.getMessage() + ' at LINE Number' + ex.getLineNumber());
            
            return false;    
        }
            
    }
    
    /**
     * Batchable finish method implementation.
     * @param BC The BatchableContext object provided by runtime.
     */
    global void finish(Database.BatchableContext BC) {
    }

}