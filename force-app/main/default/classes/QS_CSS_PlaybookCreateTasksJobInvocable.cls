public class QS_CSS_PlaybookCreateTasksJobInvocable {
    //Invocable method to create playbook batch job
    @InvocableMethod(label='Batch Create Tasks' description='Schedule a job to create tasks for Customer Alerts based on Playbook Template.')
    public static void CreateTasks(List<QS_CSS_Customer_Alert__c> CustomerAlerts) {
        (new QS_CSS_PlaybookUtils()).CreateTasksJob(CustomerAlerts);
    }
}