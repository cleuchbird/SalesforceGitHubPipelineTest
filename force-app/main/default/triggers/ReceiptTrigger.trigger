trigger ReceiptTrigger on Account (before insert, before update) {
    new ReceiptTriggerHandler().applyDefaults(Trigger.new);
}
