@isTest
public with sharing class ContactTriggerTest {
    @TestSetup
    static void setup() {
        Account account = new Account(Name='Account');
        insert account;
        List <Contact> contacts = new List <Contact>();
        for (Integer i = 0; i < 2000; i++) {
            contacts.add(new Contact(LastName='Contact' + (i + 1), Phone='123' + i, AccountId=account.id));
        }
        insert contacts;
    }

    @isTest
    static void testSetContactAsPrimary() {
        Contact primaryContact = [SELECT Id, Phone, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact100'];
        primaryContact.Is_Primary_Contact__c = true;

        Test.startTest();
        update primaryContact;
        Test.stopTest();

        for(Contact currentContact : [SELECT Id, Primary_Contact_Phone__c FROM Contact]) {
            System.assertEquals(primaryContact.Phone, currentContact.Primary_Contact_Phone__c);
        }
    }

    @isTest
    static void testSetSecondPrimaryContact() {
        Contact primaryContact = [SELECT Id, Phone, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact100'];
        primaryContact.Is_Primary_Contact__c = true;
        Contact secondPrimaryContact = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact200'];
        secondPrimaryContact.Is_Primary_Contact__c = true;

        Test.startTest();
        update primaryContact;
        Test.stopTest();
        
        Database.SaveResult result;
        try {
            Database.update(secondPrimaryContact);
        } catch (Exception ex){
            System.assertEquals('System.DmlException', ex.getTypeName());
        }
    }

    @isTest
    static void testSetContactAsPrimaryFromTable() {
        Contact prevPrimaryContact = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact100'];
        prevPrimaryContact.Is_Primary_Contact__c = false;
        Contact newPrimaryContact = [SELECT Id, Phone, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact200'];
        newPrimaryContact.Is_Primary_Contact__c = true;
        List<Contact> contactsForUpdate = new List<Contact>();
        contactsForUpdate.Add(prevPrimaryContact);
        contactsForUpdate.Add(newPrimaryContact);

        Test.startTest();
        update contactsForUpdate;
        Test.stopTest();
        
        for(Contact currentContact : [SELECT Id, Primary_Contact_Phone__c FROM Contact]) {
            System.assertEquals(newPrimaryContact.Phone, currentContact.Primary_Contact_Phone__c);
        }
    }

    static void testFailUpdateContact() {
        Contact newPrimaryContact = [SELECT Id, Phone, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact200'];
        newPrimaryContact.Is_Primary_Contact__c = true;
        List<Contact> contactsForUpdate = new List<Contact>();
        contactsForUpdate.Add(newPrimaryContact);
        
        Contact wrongContact = [SELECT LastName FROM Contact WHERE LastName = 'Contact300'];

        Test.startTest();
        update contactsForUpdate;
        Test.stopTest();
        
        for(Contact currentContact : [SELECT Id, Primary_Contact_Phone__c FROM Contact]) {
            System.assertEquals(newPrimaryContact.Phone, currentContact.Primary_Contact_Phone__c);
        }
    }
}