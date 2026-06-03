@isTest(seeAllData=true)                                        // SF-0002: seeAllData=true exposes org data
private class ReceiptServiceTest {

    // testMethod keyword (deprecated) · SF-0001: no assertion · no System.runAs used
    static testMethod void testProcess() {
        ReceiptService svc = new ReceiptService();
        svc.processReceipts('Acme', 'Tech', '555', 'http://acme.com', 'Hot', '001000000000001AAA', 2, true);
    }

    @isTest
    static void testMath() {
        Integer x = 1 + 1;
        System.assertEquals(2, x);                              // SF-ASSERT-MSG: assertion missing a message
    }
}
