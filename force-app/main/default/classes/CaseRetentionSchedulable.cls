/* Name:  CaseRetentionSchedulable
Created By:  Neha Agrawal
Created Date:  2020-03-20
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class CaseRetentionSchedulable implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		CaseRetentionBatchable batch = new CaseRetentionBatchable();
		String batchId = Database.executeBatch(batch);
	}
}