/**************************************************************************************
 * @Name         : PrimaryContactPhoneUpdater
 * @Description  : 
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
public class PrimaryContactPhoneUpdater {

/**************************************************************************************
 * @Name          : updatePhone
 * @Description   : Updates primary contact phone field for all account contacts
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 * @Param     ID primaryContactId, id of the new primary contact
 * @Param     Id AccountId, id of the account to which the new primary contact belongs
 
*************************************************************************************/ 
    @future
    public static void updatePhone(Id primaryContactId, Id AccountId) {
        try {
            List<Id> contactsIdsForUpdate = new List<Id>();
            for (Contact entry : [SELECT Id FROM Contact WHERE AccountId = :AccountId]) {
                contactsIdsForUpdate.add(entry.Id);
            }
            List<Contact> contacts = [SELECT Id, Primary_Contact_Phone__c FROM Contact WHERE Id IN :contactsIdsForUpdate];
            Contact primaryContact = [SELECT Id, Phone FROM Contact WHERE Id = :primaryContactId];
            for (Contact entry : contacts) {
                entry.Primary_COntact_Phone__c = primaryContact.Phone;
            }
            Database.update(contacts, false);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}