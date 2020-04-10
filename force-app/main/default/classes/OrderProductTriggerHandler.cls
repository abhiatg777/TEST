/*------------------------------------------------------------
Author: ATG
Description: OrderProduct trigger handler
History
05/27/2016    ATG Created
------------------------------------------------------------*/
public class OrderProductTriggerHandler extends TriggerHandler {
    protected override void afterInsert(){
        updateOrderWithBillTo((Map<Id,OrderItem>)Trigger.newMap);

    }

    protected override void afterUpdate(){
        //updateOrderWithBillTo((Map<Id,OrderItem>)Trigger.newMap);

    }

    public static void updateOrderWithBillTo (Map<Id,OrderItem> orderItemsMap){
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        for (OrderItem orderItem : orderItemsMap.values()) {
            if (orderItem.OrderId != null && orderItem.Order.Bill_To__c == null) {
                orderItemMap.put(orderItem.OrderId, orderItem);
                }
            }
        for (Order order : [SELECT Id, Bill_To__c  FROM Order WHERE Id IN: orderItemMap.keySet()]){
            order.Bill_To__c = orderItemMap.get(order.Id).Bill_To__c;
                OrderMap.put(order.Id, order);
            }
            update orderMap.values();
        }
        
    }