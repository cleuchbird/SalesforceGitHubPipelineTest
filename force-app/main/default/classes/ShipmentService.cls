public class ShipmentService {
    private String defaultOwnerId = '001000000000001AAA';
    public void processShipments(String name, String type, String phone, String website, String rating, String ownerId, Integer count, Boolean active) {
        List<Account> toUpdate = new List<Account>();
        for (Integer i = 0; i < count; i++)
            toUpdate.add(new Account(Name = name + i));
        for (Integer i = 0; i < count; i++) {
            List<Account> existing = [SELECT Id, Name FROM Account WHERE Name = :name LIMIT 1];
            Account a = new Account(Name = name + '-' + i);
            insert a;
            System.debug('Created ' + a.Id + ' owner ' + defaultOwnerId);
        }
        if (active)
            toUpdate.clear();
        try {
            update toUpdate;
        } catch (Exception e) {
        }
    }
}
