public class SP_OpportunityActionPlanExtension {
    
    public list<SP_OpportunityActionManager.Objective> stageObjectives{
        get{
            if (manager != null) {
                return manager.stageObjectives; 
            }
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.INFO,System.Label.No_Objectives));
            return null;
        }
    }
    
    public SP_OpportunityActionManager.Objective advancementCriteria{
        get{return manager.advancementCriteria;}
    }
    
    public list<SelectOption> viewOptions{
        get{
            return new list<SelectOption>{new SelectOption('all',System.Label.View_All_Actions), new SelectOption('commit',System.Label.View_Committed_Actions)};
        }
    }
    
    public boolean render{get;set;}
    
    public String curOppStage {get;set;}
    
    public String currentStage{get;set;}
    
    public String oppRecordType{get;set;}
    
    public String oppType{get;set;}
    
    public String oppOrderType{get;set;}
    
    public String oppOrderSubType{get;set;}
    
    private Id oppOwnerId{get;set;}
    
    public String selectedObjId{get;set;}
    
    public String mgrEmail{get;set;}
    
    private Id mgrId{get;set;}
    
    public boolean displayMgrDialog {get; set;}
    
    public boolean isMgr {get;private set;}
    
    public Integer defaultTabIndex {get; private set;}
    
    private String nextStepSig;
    
    public boolean allProductsExempt {get; private set;}
    
    public Map<String,String> objFieldValMap = new Map<String,String>();
    public void FSMapFunc() {
        string fld = Apexpages.currentPage().getParameters().get('fld');
        string val = system.CurrentPageReference().getParameters().get('val');
        objFieldValMap.put(fld,val);
        System.debug(objFieldValMap);
    }
    public void closeMgrDialog() {        
        displayMgrDialog = false;    
    }
    
    public void showMgrDialog() {        
        displayMgrDialog = true;
    }
    
    private list<SelectOption> mstages;
    public list<SelectOption> stages{
        get{
            if(mstages==null){
                mstages = new list<SelectOption>();
                //map<String,Schema.PicklistEntry> stageMap = new map<String,Schema.PicklistEntry>();
                map<String,String> stageMap = new map<String,String>();
                for(Schema.PicklistEntry ple:Opportunity.sObjectType.getDescribe().fields.getMap().get('StageName').getDescribe().getPicklistValues()){
                    //stageMap.put(ple.getValue(),ple); 
                    stageMap.put(ple.getValue(),ple.getLabel());
                    //stageMap.put('SPI', 'SPI');
                      
                }
                for(QS_Opportunity_Stage__c stage:[select Id, Name 
                        from QS_Opportunity_Stage__c
                        where Id in (select QS_Opportunity_Stage__c from QS_Stage_Objective__c)
                        order by QS_Stage_Number__c]){
                    mstages.add(new SelectOption(stage.name,stageMap.get(stage.name)));
                }
            }
            return mstages;
        }
    }
    
    public String currentView{get;
        set{
            manager.commitOnly = value=='commit';
            currentView = value;
        }
    }
    
    public String blockTitle{
        get{return showTitle ? opp.name + ' - ' + opp.StageName : '';}
    }
    
    public boolean showTitle{
        get{
            map<String,String> params = ApexPages.CurrentPage().getParameters();
            return params.containsKey('showOptions')&&params.get('showOptions')=='1';
        }
    }
    
    public Opportunity opp{get;
        set{
            if(currentStage==null){ currentStage = value.StageName; }
            //if(currentStage==null){ currentStage = 'SPI'; }
            init(value);
            opp = value;
        }
    }
    
    public User usrInfo {get; set;}

    private SP_OpportunityActionManager manager{
        get{return managermap.get(currentStage);}
    }
    
    private map<String,SP_OpportunityActionManager> managermap;

    public SP_OpportunityActionPlanExtension(ApexPages.StandardController std){
        // VF Page dynamically renders fields from field sets
        // We need to add these fields to the std record since they aren't added by default
        List<String> fsFields = new List<String>();
        if (!Test.isRunningTest()) {
            for (Schema.FieldSet fs : Schema.SObjectType.Opportunity.fieldSets.getMap().values()) {
                for (Schema.FieldSetMember fsm : fs.getFields()) {
                    fsFields.add(fsm.fieldPath);
                }
            }
            std.addFields(fsFields);
        }
        
        this.opp = (Opportunity) std.getRecord();
        
        this.defaultTabIndex = 0;
        
        //system.debug('@opp'+opp);
        render = false;
        for(SelectOption stage:stages){
            //render = render||stage.getValue()==opp.StageName;
            //render = render||stage.getValue()=='SPI';
            render = true;
        }
        if(!render){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.INFO,System.Label.No_Objectives));
        }
        this.currentStage = opp.StageName;
        //this.currentStage = 'SPI';
        this.oppRecordType = SP_RecordTypeManager.getNameById(opp.RecordTypeId, 'Opportunity');
        
        List<QS_Opportunity_Stage__c> relStages = [SELECT Id, (SELECT QS_Order__c FROM QS_Stage_Objective__r ORDER BY QS_Order__c) FROM QS_Opportunity_Stage__c WHERE Name =: this.currentStage];
        if (relStages.size() == 1 && relStages[0].QS_Stage_Objective__r.size() > 0) {
            this.defaultTabIndex = relStages[0].QS_Stage_Objective__r[0].QS_Order__c.intValue() - 1;
        }
        
        Opportunity qOpp = [SELECT OwnerId, Type, QS_Order_Type__c, QS_Order_Sub_Type__c, QS_SP_Products__c FROM Opportunity WHERE Id =: opp.id LIMIT 1];
        this.oppType = qOpp.Type;
        this.oppOrderType = qOpp.QS_Order_Type__c;
        this.oppOrderSubType = qOpp.QS_Order_Sub_Type__c;
        this.oppOwnerId = qOpp.OwnerId;
        this.allProductsExempt = checkExemptProducts(qOpp.QS_SP_Products__c);
        init(opp);
        
        this.nextStepSig = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year() + ' ' + UserInfo.getFirstName().substring(0,1) + UserInfo.getLastName().substring(0,1) + ': ';
    }

    public SP_OpportunityActionPlanExtension(){
        
    }

    private void init(Opportunity opp){     
        this.managermap = new map<String,SP_OpportunityActionManager>();
        map<String,list<QS_Stage_Objective__c>> so = queryStageObjectives(opp);
        map<String,list<Task>> oa = queryOppActions(opp);
        map<Id,QS_Objective_Action__c> objActions = queryObjectiveActions(opp);
        set<String> stagesSet = new set<String>();
        stagesSet.addAll(so.keySet());
        stagesSet.addAll(oa.keySet());
        for(String stage:stagesSet){
            managermap.put(stage,new SP_OpportunityActionManager(so.get(stage),oa.get(stage),objActions,opp.Id));
        }
        
        //determine manager / sales coach permissions
        usrInfo = [SELECT Id, Email, Name, Manager.Email, Manager.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        List<User> ownerInfo = [SELECT Id, ManagerId FROM User WHERE Id=:this.oppOwnerId];
        this.isMgr = false;
        for (User owner : ownerInfo) {
            this.mgrId = owner.ManagerId;
            if (usrInfo.Id == owner.ManagerId) {
                this.isMgr = true;
            }
        }
        
        //perform secondary check against custom setting list of profiles
        if (this.isMgr != true) {
            List<Sales_Coaching_Profiles__c> profs = Sales_Coaching_Profiles__c.getAll().values();
            List<String> profList = new List<String>();
            for (Sales_Coaching_Profiles__c prof : profs) {
                profList.add(prof.Profile_Name__c);
            }
        
            List<User> coaches = [SELECT Id FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name IN :profList)];
            for (User coach : coaches) {
                if (usrInfo.Id == coach.Id) {
                    this.isMgr = true;
                    break;
                }
            }
        }
    }

    private map<Id,QS_Objective_Action__c> queryObjectiveActions(Opportunity opp){
        return new map<Id,QS_Objective_Action__c>([select Id, name, QS_Stage_Objective__c, QS_Action_Type__c, QS_Order__c, QS_Stage_Name__c, QS_Opportunity_Type__c, QS_Opportunity_Order_Type__c, QS_Opportunity_Order_SubType__c, QS_Exempt_Products__c, QS_Description__c from QS_Objective_Action__c]);
    }

    private map<String,list<QS_Stage_Objective__c>> queryStageObjectives(Opportunity opp){
        map<String,list<QS_Stage_Objective__c>> result = new map<String,list<QS_Stage_Objective__c>>();
        set<Id> oaIds = SP_sCollection.IdSet([select QS_ObjectiveActionID__c from Task where WhatId = :opp.Id],Task.QS_ObjectiveActionID__c);
        list<QS_Stage_Objective__c> so;
        String stage;
        System.debug(oppRecordType);
            System.debug(oppType);
            System.debug(oppOrderType);
            System.debug(oppOrderSubType);
        for(QS_Stage_Objective__c obj:[select Id, name, QS_Advancement_Criteria__c, QS_Opportunity_Stage__r.name, QS_Order__c, QS_Description__c, QS_Field_Set__c,
                                    (select Id, name, QS_active__c, QS_Description__c, QS_Order__c, QS_Action_Type__c, QS_Stage_Objective__r.QS_Opportunity_Stage__r.name, QS_Stage_Objective__c, QS_Stage_Name__c, QS_Opportunity_Type__c, QS_Opportunity_Order_Type__c, QS_Opportunity_Order_SubType__c, QS_Exempt_Products__c, QS_Task_Type__c
                                    from QS_Objective_Action__r WHERE QS_Opportunity_Record_Type__c INCLUDES(:oppRecordType) AND QS_Opportunity_Type__c INCLUDES (:oppType) AND QS_Opportunity_Order_Type__c INCLUDES (:oppOrderType) AND QS_Opportunity_Order_SubType__c INCLUDES (:oppOrderSubType) and QS_active__c=true
                                    //where Id not in :oaIds
                                    order by QS_Order__c)
                                        from QS_Stage_Objective__c WHERE QS_Opportunity_Record_Type__c INCLUDES(:oppRecordType) AND QS_Opportunity_Type__c INCLUDES (:oppType) AND QS_Opportunity_Order_Type__c INCLUDES (:oppOrderType) AND QS_Opportunity_Order_SubType__c INCLUDES (:oppOrderSubType) order by QS_Order__c]){
          /*  System.debug(oppRecordType);
            System.debug(oppType);
            System.debug(oppOrderType);
            System.debug(oppOrderSubType);*/
                                            
                                            
            //stage = obj.QS_Opportunity_Stage__r.name;
            stage = currentStage;
            /*for (QS_Objective_Action__c act : obj.QS_Objective_Action__r) {
                System.debug(act.Name);
            }*/
            so = result.containsKey(stage) ? result.get(stage) : new list<QS_Stage_Objective__c>();
            so.add(obj);
            result.put(stage,so);
        }
        return result;
    }
    
    private map<String,list<Task>> queryOppActions(Opportunity opp){
        map<String,list<Task>> result = new map<String,list<Task>>();
        list<Task> actions;
        String stage;
        for(Task act:[select Id, Subject, ActivityDate, IsClosed, QS_ObjectiveActionID__c,
            QS_Key_Action__c, QS_StageObjectiveID__c, Description, QS_Related_Stage__c, WhatId, Status, QS_Coaching_Status__c, QS_Coached_By__c, QS_Date_of_Coaching__c
            from Task
            where whatId = :opp.Id
            and QS_StageObjectiveID__c != null
            and QS_ObjectiveActionID__c != null]){
            stage = act.QS_Related_Stage__c;
            //actions = result.containsKey(stage) ? result.get(stage) : new list<Task>();
            actions = result.containsKey(currentStage) ? result.get(currentStage) : new list<Task>();
            actions.add(act); 
            //result.put(stage,actions);
            result.put(currentStage,actions);
        }
        return result;
    }
    
    public PageReference saveActions(){
        list<Task> actions = new list<Task>();
        list<Task> actionsToUpdate = new list<Task>();
        String nextStep = '';
        Date nextStepDate = Date.today()+5000;
        Boolean foundNextStep = false;
        
        //system.debug('@managerMap'+managerMap);
      
        for(SP_OpportunityActionManager man:managerMap.values()){
            //system.debug('@man.oppActions'+man.oppActions);                   
            actions.addAll(man.oppActions);          
        }
        system.debug('@actions'+actions);
        for(Task act: actions){        
            //system.debug('@act'+act);
            if(act.subject=='Discovery?') {
                act.QS_Sales_Activity_Type__c = 'Discovery';
            }
            if(act.subject=='Discovery F2F?'){
                act.QS_Sales_Activity_Type__c = 'Discovery F2F';
            }
            if(act.subject=='Access to Power?'){
                act.QS_Sales_Activity_Type__c = 'Access to Power';
            }
            if(act.subject=='Sponsor Letter?') {
                act.QS_Sales_Activity_Type__c = 'Sponsor Letter';
            }
            if(act.subject=='Solution Presentation?') {
                act.QS_Sales_Activity_Type__c = 'Solution Presentation';
            }
            if(act.subject=='Solution Presentation F2F?') {
                act.QS_Sales_Activity_Type__c = 'Solution Presentation F2F';
            }
            if(act.subject=='Proposal?') {
                act.QS_Sales_Activity_Type__c = 'Proposal';
            }
            if(act.subject=='Contract Sent?') {
                act.QS_Sales_Activity_Type__c = 'Contract Sent'; 
            }             
            if(act.subject=='Vendor of Choice Confirmed?') {
                act.QS_Sales_Activity_Type__c = 'Vendor of Choice Confirmed';
            }
            act.QS_Sales_Plan_Task__c = true;
            actionsToUpdate.add(act); 
            
            if (act.ActivityDate < nextStepDate && act.ActivityDate >= Date.today() && act.status != 'Completed') {
                foundNextStep = true;
                nextStepDate = act.ActivityDate;
                if (act.Description != null) {
                    nextStep = this.nextStepSig + act.Subject + ' - ' + act.Description;
                }
                else {
                    nextStep = this.nextStepSig + act.Subject + ' - (no comment)';
                }
            }          
        }
        //system.debug('@actionsToUpdate'+actionsToUpdate);
        
        database.upsert(actionsToUpdate);
        
        // Populate Next Step and Next Step Date (if configured)
        if (SP_Settings__c.getInstance().QS_Auto_Next_Step__c && foundNextStep) {
            if (nextStep.length() > 255) {
                this.opp.NextStep = nextStep.substring(0,255);
            }
            else {
                this.opp.NextStep = nextStep;
            }
            this.opp.QS_Next_Steps_Date__c = nextStepDate;
        }
        
         string err = '';
        try { 
            Map<String, Schema.SobjectField> fields =  Schema.SobjectType.Opportunity.fields.getMap();  
            for(string fld :objFieldValMap.keySet()) {
               
               err =  'Fld :'+ Fld + ' '+ objFieldValMap.get(fld) + ' '+ 
                 ((Schema.Sobjectfield)fields.get(fld)).getDescribe().getType();              
              if( ''+ ((Schema.Sobjectfield)fields.get(fld)).getDescribe().getType()  == 'boolean' )
                this.opp.put(  fld,objFieldValMap.get(fld) == '1');
                  else  
                this.opp.put(fld,objFieldValMap.get(fld));
          } 
            
             
            update this.opp;
        }
       catch (DmlException e) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            //this.opp.addError(e.getMessage());
            return null;
        }
        
        //for(SP_OpportunityActionManager man:managerMap.values()){
        //    man.resetTasks(this.tasks);
        //}
        this.init(opp);
        return null;
    }
    
    public PageReference cancelActions(){
        for(SP_OpportunityActionManager man:managerMap.values()){
            man.clear();
        }
        return null;
    }
    
    
    public void requestCoaching() {
        for (SP_OpportunityActionManager.Objective obj : stageObjectives) {
            if (obj.objId == selectedObjId) {
                String toEmail = '';
                if (mgrEmail != '') {
                    toEmail = mgrEmail;
                }
                else if (usrInfo.Manager.Email != null) {
                    toEmail = usrInfo.Manager.Email;
                }
                else {
                    toEmail = '';
                }
                if (toEmail != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {toEmail};
                    String[] ccAddresses = new String[] {usrInfo.Email};
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccAddresses);
                    mail.setReplyTo(usrInfo.Email);
                    mail.setSenderDisplayName(usrInfo.Name);
                    mail.setSubject('Sales Plan Coaching Requested');
                    
                    String prefix = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
                    prefix = prefix.substring(0, prefix.indexOf('.'));
                    
                    mail.setPlainTextBody(usrInfo.Name + ' is requesting sales coaching for the SPI Objective ' + obj.Name + '. \r\n\r\nThis request is related to the Opportunity: ' + opp.Name + '\r\n\r\nLink to Opportunity: https://' + prefix + '.salesforce.com/' + opp.Id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    createCoachingTask(opp.Id, opp.StageName, mgrId);
                }
                break;
            }
        }
    }
    
    public void requestCoachingNoMgr() {
        System.debug('Selected Obj Id: ' + selectedObjId);
        System.debug('Email: ' + mgrEmail);
                String toEmail = '';
                if (mgrEmail != null && mgrEmail != '') {
                    toEmail = mgrEmail;
                }
                System.debug('Email: ' + toEmail);
                String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
                Pattern myPattern = Pattern.compile(emailRegex);
                Matcher myMatcher = MyPattern.matcher(toEmail);
                
                if (toEmail != null && myMatcher.matches()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {toEmail};
                    String[] ccAddresses = new String[] {usrInfo.Email};
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccAddresses);
                    mail.setReplyTo(usrInfo.Email);
                    mail.setSenderDisplayName(usrInfo.Name);
                    mail.setSubject('Sales Plan Coaching Requested');
                    
                    String prefix = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
                    System.debug('prefix '+prefix);
                    prefix = prefix.substring(0, prefix.indexOf('.'));
                    
                    mail.setPlainTextBody(usrInfo.Name + ' is requesting sales coaching. \r\n\r\nThis request is related to the Opportunity: ' + opp.Name + '\r\n\r\nLink to Opportunity: https://' + prefix + '.salesforce.com/' + opp.Id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    createCoachingTask(opp.Id, opp.StageName, mgrId);
                }
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid email address.'));
                    System.debug('INVALID EMAIL ADDRESS');
                }
    }
    
    public static void createCoachingTask(Id opptyId, String opptyStage, Id mgrId) {
        Task t = new Task();
        t.WhatId = opptyId;
        t.Subject = 'Request for Coaching - ' + opptyStage;
        RecordType reqCoaching;
        try {
            reqCoaching = [SELECT Id FROM RecordType WHERE DeveloperName = 'Request_for_Coaching' AND SobjectType = 'Task' LIMIT 1];
            t.RecordTypeId = reqCoaching.Id;
        }
        catch (Exception e) {
            reqCoaching = null;
        }
        //t.RecordTypeId = SystemIds__c.getInstance().RecordTypeId_Task_CoachingRequest__c;
        t.ActivityDate = Date.Today()+7;
        t.QS_Sales_Plan_Task__c = true;
        if (mgrId != null) {
            t.OwnerId = mgrId;
        }
        else {
            t.OwnerId = UserInfo.getUserId();
        }
        try {
            insert t;
        }
        catch (Exception e) {
            t.RecordTypeId = null;
            insert t;
        }
    }
    
    public PageReference coachingInfo() {
        return new PageReference('/apex/SP_SalesCoachV2?id=' + opp.Id);
    }
    
    public static boolean checkExemptProducts(String oppProds) {
        if (oppProds == null) {
            return true;
        }
        String[] oppProdArr = oppProds.split(';',0);
        Set<String> exemptProds = QS_SP_Exempt_Products__c.getAll().keySet();
        
        if (exemptProds.containsAll(oppProdArr)) {
            return true;
        }
        
        return false;
    }
   
}