/**
 * @description Handles Invoice trigger logic for Account records, keeping the
 * trigger body free of business logic and running in the caller's sharing context.
 */
public with sharing class InvoiceTriggerHandler {

    /**
     * @description Applies default field values to Account records before they
     * are saved. Operates on the in-memory trigger records, so it performs no
     * SOQL or DML.
     *
     * @param accounts the Account records supplied by the trigger context
     */
    public void applyDefaults(List<Account> accounts) {
        if (accounts == null) {
            return;
        }

        for (Account account : accounts) {
            if (String.isBlank(account.Description)) {
                account.Description = 'Processed by InvoiceTriggerHandler';
            }
        }
    }
}
