/**
 * @description Unit tests for ShipmentService.
 */
@isTest
private class ShipmentServiceTest {

    @isTest
    static void createsRequestedNumberOfAccounts() {
        System.runAs(currentUser()) {
            Test.startTest();
            new ShipmentService().processShipments('Acme', 3);
            Test.stopTest();
        }

        Integer created = [SELECT COUNT() FROM Account WHERE Name LIKE 'Acme-%'];
        System.assertEquals(3, created, 'processShipments should create one Account per requested count');
    }

    @isTest
    static void ignoresNonPositiveCount() {
        System.runAs(currentUser()) {
            Test.startTest();
            new ShipmentService().processShipments('Acme', 0);
            Test.stopTest();
        }

        Integer created = [SELECT COUNT() FROM Account WHERE Name LIKE 'Acme-%'];
        System.assertEquals(0, created, 'No Accounts should be created when count is not positive');
    }

    /**
     * @description Returns a handle to the running user so tests can demonstrate
     * execution in a specific user context via System.runAs.
     *
     * @return the running user
     */
    private static User currentUser() {
        return new User(Id = UserInfo.getUserId());
    }
}
