trigger OrderTrigger on Account (before insert, before update) {  // business logic in trigger body, no handler class
    String defaultOwnerId = '001000000000001AAA';            // SF-0035: hardcoded Salesforce record ID
    for (Account a : Trigger.new) {
        List<Contact> existing = [SELECT Id FROM Contact WHERE AccountId = :a.Id];  // SF-0016: SOQL in loop
        Contact c = new Contact(LastName = a.Name, AccountId = a.Id);
        insert c;                                             // SF-0017: DML in loop
        System.debug('Processed ' + a.Id + ' owner ' + defaultOwnerId);  // SF-0025: System.debug
    }
}
