({
	getUserId : function(component) {
        var action = component.get("c.getUserId");        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            var errors = response.getError();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.userId", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecordTypeId : function(component) {
        var action = component.get("c.getRecordTypeId");        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            var errors = response.getError();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.recordTypeId", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getSupportNumbers : function(component) {
        var action = component.get("c.getSupportNumbers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            if(component.isValid() && state === "SUCCESS") {
                //console.log('returnValue = ' + response.getReturnValue()[0].MasterLabel);
				component.set("v.supportNumbers", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    checkBusinessHours : function(component, selectedProduct) {
        var action = component.get("c.checkBusinessHours");
        action.setParams ({
            productName : selectedProduct
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            if(component.isValid() && state === "SUCCESS") {
				component.set("v.businessOpen", response.getReturnValue());
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    displaySupportNumber : function(component, isOpen) {
        if(isOpen)
        {
            var displayPhone = component.find("displayPhoneOpen");
        	var number = component.find("listSupportNumbersOpen").get("v.value");
        	displayPhone.set("v.value",number);
        }
        else
        {
            var displayPhone = component.find("displayPhoneClosed");
        	var number = component.find("listSupportNumbersClosed").get("v.value");
        	displayPhone.set("v.value",number);
        }
        
    },
    
})