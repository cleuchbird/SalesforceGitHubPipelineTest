public class AccountService {

    // SF-0035: hardcoded Salesforce record ID
    private String defaultOwnerId = '001000000000001AAA';

    // SF-0008: method with an excessive number of parameters (8)
    // SF-0018: class uses DML but declares no sharing mode
    // SF-0047 / SF-0048: missing ApexDoc on a public method
    public void processAccounts(String name, String industry, String phone, String website, String rating, String ownerId, Integer employees, Boolean active) {
        List<Account> accountsToUpdate = new List<Account>();

        // SF-0006: 'for' loop without surrounding braces (single-statement body)
        for (Integer i = 0; i < employees; i++)
            accountsToUpdate.add(new Account(Name = name + i));

        // SF-0016: SOQL inside a loop  +  SF-0017: DML inside a loop
        for (Integer i = 0; i < employees; i++) {
            List<Account> existing = [SELECT Id, Name FROM Account WHERE Name = :name LIMIT 1];
            Account a = new Account(Name = name + '-' + i);
            insert a;
            // SF-0025 / SF-SYS-DEBUG: System.debug can expose data and impacts limits
            System.debug('Created account ' + a.Id + ' owner ' + defaultOwnerId);
        }

        // SF-0003: 'if' statement without braces
        if (active)
            accountsToUpdate.clear();

        // SF-0039: empty catch block silently swallows the exception
        try {
            update accountsToUpdate;
        } catch (Exception e) {
        }
    }
}
