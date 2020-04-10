/*
 * This class is responsible for creation and execution of 
 * a batchable job (an instance of CA2_CustomerAssetDetailStatusBatchable) that 
 * updates the status of the Customer Assets Detail
 * depending on its expiration and decommission date.
 * Implements the Schedulable interface.
 *
 * @see Schedulable
 * @author Advanced Technology Group (www.atginfo.com)
 */
global class CA2_CustomerAssetDetailStatusSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    	CA2_CustomerAssetDetailStatusbatchable b = new CA2_CustomerAssetDetailStatusBatchable();
    	database.executeBatch(b);

	}
}