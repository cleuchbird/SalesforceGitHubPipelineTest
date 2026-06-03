public class ShipmentService {                               // SF-0018: class does DML but declares no sharing
    private String defaultOwnerId = '001000000000001AAA';     // SF-0035: hardcoded Salesforce record ID

    // SF-0008: too many parameters · SF-0047/SF-0048: missing ApexDoc on a public method
    public void processShipments(String name, String type, String phone, String website, String rating, String ownerId, Integer count, Boolean active) {
        List<Account> toUpdate = new List<Account>();

        for (Integer i = 0; i < count; i++)                   // SF-0006: 'for' without braces
            toUpdate.add(new Account(Name = name + i));

        for (Integer i = 0; i < count; i++) {
            List<Account> existing = [SELECT Id, Name FROM Account WHERE Name = :name LIMIT 1];  // SF-0016: SOQL in loop
            Account a = new Account(Name = name + '-' + i);
            insert a;                                          // SF-0017: DML in loop
            System.debug('Created ' + a.Id + ' owner ' + defaultOwnerId);  // SF-0025: System.debug
        }

        if (active)                                           // SF-0003: 'if' without braces
            toUpdate.clear();

        try {
            update toUpdate;
        } catch (Exception e) {                               // SF-0039: empty catch swallows the exception
        }
    }
}
