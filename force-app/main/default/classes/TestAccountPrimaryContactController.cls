@isTest
private class TestAccountPrimaryContactController {
    @testSetup static void setup() {
        Account acc = new Account(Name='Big Company', AccountNumber='515', Type='Prospect', Active__c='True', Phone='123456789', Fax='987654321');
        insert acc;
        List<Contact> contactsList = new List<Contact>();
        for (Integer i = 0; i < 2000; i++) {
            contactsList.Add(new Contact(LastName='Contact' + i, Title='Mr', Phone='12345' + i, Is_Primary_Contact__c=false, AccountId = acc.Id));
        }
        contactsList.get(1000).Is_Primary_Contact__c = true;
        insert contactsList;    
    }

    @isTest static void testSetPrimaryContact() {
        Account acc = [SELECT Id FROM Account];
        Contact firstContact = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE LastName = 'Contact0'];
        PageReference testPage = Page.AccountAndContacts; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        testPage.getParameters().put('selectedContactId', String.valueOf(firstContact.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);       
        AccountPrimaryContactController controller = new AccountPrimaryContactController(sc);
        
        Test.startTest();
        controller.setPrimaryContact();
        firstContact = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE Id = :firstContact.Id];
        List <Contact> contactsList = [SELECT Id FROM Contact WHERE Is_Primary_Contact__c = false];
        System.assertEquals(true, firstContact.Is_Primary_Contact__c);
        Test.stopTest();
        System.assertEquals(1999, contactsList.size());
    }

    @isTest static void testDoSearch() {
        Account acc = [SELECT Id FROM Account];
        PageReference testPage = Page.AccountAndContacts; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);       
        AccountPrimaryContactController controller = new AccountPrimaryContactController(sc);

        System.assertEquals(40, controller.totalPagesCount);
        System.assertEquals(1, controller.currentPage);
        System.assertEquals(false, controller.isDisabledNextBttn);
        System.assertEquals(true, controller.isDisabledPrevBttn);

        Test.startTest();
        controller.nameFilter = 'Contact1999';
        controller.doSearch();
        Test.stopTest();

        System.assertEquals(1, controller.totalPagesCount);
        System.assertEquals(1, controller.currentPage);
        System.assertEquals(true, controller.isDisabledNextBttn);
        System.assertEquals(true, controller.isDisabledPrevBttn);
        System.assertEquals('Contact1999', controller.nameFilter);
        System.assertEquals('Contact1999', controller.contactsList.get(0).Name);
    }

    @isTest static void testMoveToPage() {
        Account acc = [SELECT Id FROM Account];
        PageReference testPage = Page.AccountAndContacts; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);       
        AccountPrimaryContactController controller = new AccountPrimaryContactController(sc);

        Test.startTest();
        controller.currentPage = 5;
        controller.moveToPage();
        System.assertEquals(5, controller.currentPage);

        controller.currentPage = -100;
        controller.moveToPage();
        System.assertEquals(1, controller.currentPage);

        controller.currentPage = 0;
        controller.moveToPage();
        System.assertEquals(1, controller.currentPage);

        controller.currentPage = 1000;
        controller.moveToPage();
        System.assertEquals(40, controller.currentPage);
        Test.stopTest();
    }

    @isTest static void testMoveToNextPage() {
        Account acc = [SELECT Id FROM Account];
        PageReference testPage = Page.AccountAndContacts; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);       
        AccountPrimaryContactController controller = new AccountPrimaryContactController(sc);

        Test.startTest();
        controller.currentPage = 1;
        controller.getRelatedContacts();
        System.assertEquals(false, controller.isDisabledNextBttn);

        controller.currentPage = 40;
        controller.getRelatedContacts();
        System.assertEquals(true, controller.isDisabledNextBttn);

        controller.currentPage = 20;
        controller.moveToNextPage();
        System.assertEquals(false, controller.isDisabledNextBttn);
        Test.stopTest();
    }

    @isTest static void testMoveToPrevPage() {
        Account acc = [SELECT Id FROM Account];
        PageReference testPage = Page.AccountAndContacts; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);       
        AccountPrimaryContactController controller = new AccountPrimaryContactController(sc);

        Test.startTest();
        controller.currentPage = 1;
        controller.getRelatedContacts();
        System.assertEquals(true, controller.isDisabledPrevBttn);

        controller.currentPage = 40;
        controller.getRelatedContacts();
        System.assertEquals(false, controller.isDisabledPrevBttn);

        controller.currentPage = 20;
        controller.moveToPrevPage();
        System.assertEquals(false, controller.isDisabledPrevBttn);
        Test.stopTest();
    }

}