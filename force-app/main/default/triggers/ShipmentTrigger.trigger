trigger ShipmentTrigger on Account (before insert, before update) {
    String defaultOwnerId = '001000000000001AAA';
    for (Account a : Trigger.new) {
        List<Contact> existing = [SELECT Id FROM Contact WHERE AccountId = :a.Id];
        Contact c = new Contact(LastName = a.Name, AccountId = a.Id);
        insert c;
        System.debug('Processed ' + a.Id + ' owner ' + defaultOwnerId);
    }
}
