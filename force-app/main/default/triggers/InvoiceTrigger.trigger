trigger InvoiceTrigger on Account (before insert, before update) {
    new InvoiceTriggerHandler().applyDefaults(Trigger.new);
}
