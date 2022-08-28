@isTest
public with sharing class SummarizeOpportunityAmountTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Contact> primaryContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i));
        }
        insert accounts;
        
        for (Account acc : accounts) {
            primaryContacts.add(new Contact(LastName = 'Primary', Phone= '999' , Is_Primary_Contact__c = true, AccountId = acc.Id, Email = 'artur.kostetskyi@gmail.com'));
            for (Integer i = 0; i < 10; i++) {
                opportunities.add(new Opportunity(Name = 'Opportunity ' + i, StageName = 'Closed Won', Amount = 100 ,CloseDate = Date.newInstance(2022, 08, 22), AccountId = acc.Id));
                opportunities.add(new Opportunity(Name = 'Opportunity ' + i, StageName = 'Closed Lost', Amount = 200 ,CloseDate = Date.newInstance(2022, 08, 22), AccountId = acc.Id));
                opportunities.add(new Opportunity(Name = 'Opportunity ' + i, StageName = 'Prospecting', Amount = 1000 ,CloseDate = Date.newInstance(2022, 08, 22), AccountId = acc.Id));
                
            }
        }
        insert primaryContacts;
        insert opportunities;
}

    @isTest static void testCalculations() {
        Test.startTest();
        Id batchId = Database.executeBatch(new SummarizeOpportunityAmountsBatch());
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name, Closed_Won_Opportunities_Amount__c, Closed_Lost_Opportunities_Amount__c, Open_Opportunities_Amount__c FROM Account];
        System.assertEquals(1000, accounts.get(0).Closed_Won_Opportunities_Amount__c);
        System.assertEquals(2000, accounts.get(3).Closed_Lost_Opportunities_Amount__c);
        System.assertEquals(10000, accounts.get(7).Open_Opportunities_Amount__c);

    }
}