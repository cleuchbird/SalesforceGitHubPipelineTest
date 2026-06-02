// SF-0002: @isTest(seeAllData=true) exposes org data to the test
@isTest(seeAllData=true)
private class AccountServiceTest {

    // SF-IS-TEST: deprecated 'testMethod' keyword (should use @isTest)
    // SF-0001: unit test contains no assertion
    // SF-APEX-RUNAS: no System.runAs used anywhere in the test class
    static testMethod void testProcessAccounts() {
        AccountService svc = new AccountService();
        svc.processAccounts('Acme', 'Tech', '555', 'http://acme.com', 'Hot', '001000000000001AAA', 2, true);
    }

    @isTest
    static void testAssertNoMessage() {
        Integer x = 1 + 1;
        // SF-ASSERT-MSG: assertion is missing an explanatory message
        System.assertEquals(2, x);
    }
}
