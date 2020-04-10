/*------------------------------------------------------------
Author: ATG
Description: OrderProductCPQ Trigger
Test Class: 
History
05/27/16    ATG Created
------------------------------------------------------------*/
trigger OrderProductCPQTrigger on OrderItem (before insert, before update, before delete, after insert, after update, after delete) {
    new OrderProductTriggerHandler().run();    

}