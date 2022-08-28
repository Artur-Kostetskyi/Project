/**************************************************************************************
 * @Name         : SummarizeOpportunityAmountsBatch
 * @Description  : Batch class summarizes all Opportunity Amounts for each Account and sends an email to the primary
 *  contact of all Accounts, containing a table with the Closed Won/Open/Closed Lost summarized Opportunity Amounts.
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
public with sharing class SummarizeOpportunityAmountsBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<Account> accountsWithPrimaryContact = new List<Account>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, Name, Primary_Contact_Email__c, Closed_Won_Opportunities_Amount__c, 
             Closed_Lost_Opportunities_Amount__c, Open_Opportunities_Amount__c, 
             (SELECT ID, Amount, StageName 
              FROM Opportunities 
              WHERE (CreatedDate = THIS_MONTH OR LastModifiedDate = THIS_MONTH) AND Amount != NULL),
             (SELECT Id, Email, Phone 
              FROM Contacts 
              WHERE Is_Primary_Contact__c = true) 
             FROM Account]
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> records) {
        for (Account currentAccount : records) {
            currentAccount.Closed_Won_Opportunities_Amount__c = 0;
            currentAccount.Closed_Lost_Opportunities_Amount__c = 0;
            currentAccount.Open_Opportunities_Amount__c = 0;
            for (Contact currentPrimaryContact : currentAccount.Contacts) {
                currentAccount.Primary_Contact_Email__c	= currentPrimaryContact.Email;
                for (Opportunity opp : currentAccount.opportunities) {
                    if (opp.StageName.equals('Closed Won')) {
                        currentAccount.Closed_Won_Opportunities_Amount__c += opp.Amount;
                    } else if (opp.StageName.equals('Closed Lost')) {
                        currentAccount.Closed_Lost_Opportunities_Amount__c += opp.Amount;
                    } else {
                        currentAccount.Open_Opportunities_Amount__c += opp.Amount;
                    }
                }
                accountsWithPrimaryContact.add(currentAccount);
            }
        }
        update records;
    }

    public void finish(Database.BatchableContext bc) {
        Id emailTemplateId = [select Id from EmailTemplate where DeveloperName = 'Summarized_all_Opportunities_Amounts' LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Contact primaryContact;
        for (Account acc : accountsWithPrimaryContact) {
            primaryContact = acc.Contacts.get(0);
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage ();
            semail.setTargetObjectId(primaryContact.Id);
            semail.setToAddresses(new List<String> {primaryContact.Email});
            semail.setTemplateId(emailTemplateId);
            semail.setWhatId(acc.Id);
            emails.add(semail);
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);   
        }
    }
}