@IsTest
private class CaseRetentionSchedulableTest {

	@IsTest
	private static void test_schedulable() {
		SchedulableContext schedulableContext = null;
		CaseRetentionSchedulable testSchedulable = new CaseRetentionSchedulable();
		testSchedulable.execute(schedulableContext);
	}
}