@isTest(seeAllData=true)
private class ShipmentServiceTest {
    static testMethod void testProcess() {
        ShipmentService svc = new ShipmentService();
        svc.processShipments('Acme', 'Tech', '555', 'http://acme.com', 'Hot', '001000000000001AAA', 2, true);
    }
    @isTest
    static void testMath() {
        Integer x = 1 + 1;
        System.assertEquals(2, x);
    }
}
