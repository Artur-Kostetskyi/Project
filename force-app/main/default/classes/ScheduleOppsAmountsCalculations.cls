/**************************************************************************************
 * @Name         : ScheduleOppsAmountsCalculations
 * @Description  : Schedulable class calls the batch class SummarizeOpportunityAmountsBatch
 * @Created By   : Artur Kostetskyi
 * @Created Date : Aug 25, 2022
 * @Modification Log:
 * ************************************************************************************
 * Version          Developer                    Date               Description
 * ------------------------------------------------------------------------------------
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 **************************************************************************************/
public class ScheduleOppsAmountsCalculations implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new SummarizeOpportunityAmountsBatch(), 100);
    }
}