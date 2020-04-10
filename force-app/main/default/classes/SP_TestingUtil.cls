public with sharing class SP_TestingUtil {
  public String opId;
  public String scsId;
  public String scsecId;
  public String scsecItemId;
  public String actId;

  public SP_TestingUtil(){
  	opId = makeTestableOp();
  	scsId = makeSalesCoachStage();
  	scsecId = makeSalesCoachSections();
  	scsecItemId = makeSecItem();
  	actId = makeActivities();
  	ApexPages.currentPage().getParameters().put('id', this.opId);
  }

  private String makeTestableOp(){
  	Opportunity op = new Opportunity();
  	op.Name='testOpName';
  	op.CloseDate = Date.today();
  	op.StageName='testStage';
  	insert op;
    return op.Id;
  }
  
  private String makeSalesCoachStage(){
  	QS_Sales_Coach_Stage__c scs = new QS_Sales_Coach_Stage__c();
  	scs.Name='testStage';
    scs.QS_Buyer_Stage__c='testBuyStage';
    scs.QS_active__c=true;
  	insert scs;
  	return scs.Id;
  }
  
  private String makeSalesCoachSections(){
  	QS_Sales_Coach_Section__c scsec =  new QS_Sales_Coach_Section__c();
  	scsec.QS_Section_Ordering__c =1.0;
  	scsec.QS_Section_Name__c='testSection';
  	scsec.QS_Sales_Coach_Stage__c=scsId;
  	scsec.QS_Section_Width__c=33.0;
  	insert scsec;
  	return scsec.Id;
  }
  
 private String makeSecItem(){
 	QS_Sales_Coach_Section_Item__c secItem = new QS_Sales_Coach_Section_Item__c();
 	secItem.QS_Section_Ordering__c=1.0;
 	secItem.QS_Sales_Coach_Section__c=scsecId;
 	secItem.QS_Link_to_Content__c='http://www.google.com';
 	secItem.QS_Item_Name__c='testItem';
 	secItem.QS_Display__c=true;
 	secItem.QS_Products__c ='';
 	insert secItem;
 	return secItem.Id;
 }
 
 private String makeActivities(){
  QS_Sales_Coach_Activity__c sca = new QS_Sales_Coach_Activity__c();
  sca.QS_Sales_Coach_Stage__c=scsId;
  sca.QS_Ordering_Number__c=1.0;
  sca.QS_Activity_Details__c='testActivity';
  insert sca;
  return sca.Id;
 }

}