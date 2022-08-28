@isTest
public class ScheduleOppsAmountsCalculationsTest {
    public static String CRON_EXP = '0 0 0 15 10 ? 2022';

    @isTest static void testCalculateClosedWon() {
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new ScheduleOppsAmountsCalculations());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-10-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}