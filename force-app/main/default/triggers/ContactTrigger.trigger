trigger ContactTrigger on Contact (before insert, before update) {
    if (!System.isFuture() && Trigger.isBefore && Trigger.isUpdate) {
        if (Trigger.New.size() == 1 || Trigger.isInsert) {
            PrimaryContactHandler.updatePrimaryContact(Trigger.New);
        } else if (Trigger.New.size() == 2) {
            PrimaryContactHandler.updatePrimaryContactFromTable(Trigger.New);
        }
    }
}