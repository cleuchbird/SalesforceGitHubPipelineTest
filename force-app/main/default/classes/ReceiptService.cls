/**
 * @description Service for creating Account records in bulk. Declared
 * `with sharing` so all DML runs in the calling user's sharing context.
 */
public with sharing class ReceiptService {

    /**
     * @description Creates `count` Account records, each named from `baseName`.
     * Records are collected into a list and inserted with a single DML statement,
     * keeping the method bulk-safe and within governor limits. Object create
     * permission is checked before the insert.
     *
     * @param baseName base text used to build each Account's Name
     * @param count    number of Account records to create; ignored when not positive
     */
    public void processReceipts(String baseName, Integer count) {
        if (String.isBlank(baseName) || count == null || count <= 0) {
            return;
        }

        if (!Schema.sObjectType.Account.isCreateable()) {
            return;
        }

        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accountsToInsert.add(new Account(Name = baseName + '-' + i));
        }

        insert accountsToInsert;
    }
}
