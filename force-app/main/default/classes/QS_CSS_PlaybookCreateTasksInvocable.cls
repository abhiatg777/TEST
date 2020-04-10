public class QS_CSS_PlaybookCreateTasksInvocable {	
    //Invocable method to create plyaybook without scheduling a job
    @InvocableMethod(label='Create Tasks' description='Create the tasks for Customer Alerts based on Playbook Template.')
    public static void CreateTasks(List<QS_CSS_Customer_Alert__c> CustomerAlerts) {
        (new QS_CSS_PlaybookUtils()).CreateTasks(CustomerAlerts);                
    }
}