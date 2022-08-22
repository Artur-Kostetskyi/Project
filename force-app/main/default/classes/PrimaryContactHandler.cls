/**************************************************************************************
 * @Name         : PrimaryContactHandler
 * @Description  : Checks whether there is a primary contact in the contactsList and if so, takes the necessary actions
 * @Created By   : Artur Kostetskyi
 * @Created Date : Aug 22, 2022
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
public class PrimaryContactHandler {

/**************************************************************************************
 * @Name          : updatePrimaryContact
 * @Description   : Checks whether there is no primary contact in the account and calls the function for updating primary contact phone field for all account contacts
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 19, 2022
 * @Param     List<Contact> contactsList
 
*************************************************************************************/ 
    public static void updatePrimaryContact(List<Contact> contactsList) {
        for (Contact currentContact : contactsList) {
            if (currentContact.Is_Primary_Contact__c) {
                try {
                    List <Contact> currentPrimaryContacts = [SELECT Id FROM Contact WHERE AccountId = :currentContact.AccountId AND Is_Primary_Contact__c = true];
                    if (currentPrimaryContacts.size() > 0 && currentPrimaryContacts.get(0).Id != currentContact.Id) {
                        currentContact.addError('Primary Contact already exists');
                    }
                    PrimaryContactPhoneUpdater.updatePhone(currentContact.Id, currentContact.AccountId);
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
    }

/**************************************************************************************
 * @Name          : updatePrimaryFromTable
 * @Description   : Calls the function for updating primary contact phone field for all account contacts
 * @Created By    : Artur Kostetskyi
 * @Created Date  : Aug 22, 2022
 * @Param     List<Contact> contactsList, accepts a list containing the old primary contact(Is_Primary_Contact__c = false) and the new primary contact.
 
*************************************************************************************/ 
    public static void updatePrimaryContactFromTable(List<Contact> contactsList) {
        for (Contact currentContact : contactsList) {
            if (currentContact.Is_Primary_Contact__c) {
                PrimaryContactPhoneUpdater.updatePhone(currentContact.Id, currentContact.AccountId);
            }
        }
    }
}