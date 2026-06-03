trigger ShipmentTrigger on Account (before insert, before update) {
    new ShipmentTriggerHandler().applyDefaults(Trigger.new);
}
