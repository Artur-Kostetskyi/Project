/**************************************************************************************
 * @Name         : AccountPrimaryContactController
 * @Description  : This class queries related contacts to Account and ensures the proper functioning of the AccountAndContacts page
 * @Created By   : Artur Kostetskyi
 * @Created Date : Aug 19, 2022
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
public with sharing class AccountPrimaryContactController {
    public List<Contact> contactsList { get; set; }
    public Account acc { get; set; }
    public Boolean isDisabledPrevBttn { get; set; }
    public Boolean isDisabledNextBttn { get; set; }
    public Integer totalPagesCount { get; set; }
    public Integer currentPage { get; set; }
    private Integer recordsPerPage = 50;
    public String nameFilter { get; set; }
    private final String CONTACT_FIELDS = 'Id, Name, Title, Phone, Is_Primary_Contact__c';

    public AccountPrimaryContactController(ApexPages.StandardController stdController) {
        currentPage = 1;
        try {
            acc = [Select Id, Name, AccountNumber, Type, Active__c, Phone, Fax 
            FROM Account
            WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        calculatePagesCount();
        getRelatedContacts();
    }

/**************************************************************************************
 * @Name          : getRelatedContacts
 * @Description   :
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 * @Return    List<Contact> list with related contacts to account
 
*************************************************************************************/ 
    public List<Contact> getRelatedContacts() {
        String contactQuery = buildQuery(false);
        contactsList = Database.query(contactQuery);
        isDisabledPrevBttn = currentPage == 1 ? true : false;
        isDisabledNextBttn =  totalPagesCount > currentPage ? false : true;
        return contactsList;
    }

/**************************************************************************************
 * @Name          : buildQuery
 * @Description   : Builds query using search filter if initialized  
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 * @Param     Boolean countAllEntries, if true, limitation and offset of the query will be disabled
 * @Return    String
 
*************************************************************************************/ 
    private String buildQuery(Boolean countAllEntries) {
        try {
            String contactQuery = 'SELECT ' + CONTACT_FIELDS + ' FROM Contact WHERE AccountId = \'' + acc.Id +'\'';
            if (String.isNotBlank(nameFilter)) {
                contactQuery += ' AND Name LIKE \'%' + String.escapeSingleQuotes(nameFilter) + '%\'';
            }
            if (!countAllEntries) { 
                contactQuery += ' LIMIT '+ recordsPerPage + ' OFFSET ' + ((currentPage - 1) * recordsPerPage);
            }
            return contactQuery;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return '';
        }
    }

/**************************************************************************************
 * @Name          : setPrimaryContact
 * @Description   : Sets selected contact as primary and all the other contacts will be secondary   
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 
*************************************************************************************/ 
    public void setPrimaryContact() {
        String selectedContactId = ApexPages.currentPage().getParameters().get('selectedContactId');
        List<Contact> contactsForUpdate = new List<Contact>(); 
        for (Contact primaryContact : [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE (Is_Primary_Contact__c = true AND AccountId = :acc.Id) OR Id = :selectedContactId]) {
            if (primaryContact.Id.equals(selectedContactId)) {
                primaryContact.Is_Primary_Contact__c = true;
            } else {
                primaryContact.Is_Primary_Contact__c = false;
            }
            contactsForUpdate.add(primaryContact);
        }
        if(!contactsForUpdate.isEmpty()) {
            update contactsForUpdate;
        }
        getRelatedContacts();
    }

/**************************************************************************************
 * @Name          : doSearch
 * @Description   : Search by Contact Name    
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 
*************************************************************************************/ 
    public void doSearch() {
        currentPage = 1;
        calculatePagesCount();
        getRelatedContacts();
    }

/**************************************************************************************
 * @Name          : moveToPage
 * @Description   : Goes to the specified page    
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 
*************************************************************************************/ 
    public void moveToPage() {        
        if (currentPage < 1) {
            currentPage = 1;
            getRelatedContacts();
        } else if (totalPagesCount >= currentPage) {
            getRelatedContacts();
        } else if (currentPage > totalPagesCount) {
            currentPage = totalPagesCount;
            getRelatedContacts();
        }
    }

/**************************************************************************************
 * @Name          : moveToNextPage
 * @Description   : Goes to the next page    
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 
 *************************************************************************************/ 
    public void moveToNextPage() {
        currentPage++;
        getRelatedContacts();
    }

/**************************************************************************************
 * @Name          : moveToPrevPage
 * @Description   : Goes to the previous page    
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 
*************************************************************************************/ 
    public void moveToPrevPage() {
        currentPage--;
        getRelatedContacts();
    }

/**************************************************************************************
 * @Name          : calculatePagesCount
 * @Description   : Calculates the number of pages
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 
 *************************************************************************************/ 
    public void calculatePagesCount() {
        Boolean countAllEntries = String.isBlank(nameFilter) ? true : false;
        Integer totalContactsSize = Database.countQuery(buildQuery(countAllEntries).replaceFirst(CONTACT_FIELDS, 'COUNT()'));
        totalPagesCount = Math.Mod(totalContactsSize, recordsPerPage) == 0 ? totalContactsSize / recordsPerPage : (totalContactsSize / recordsPerPage) + 1;
    }

}