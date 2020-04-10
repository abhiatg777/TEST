({
    updateHealth: function(component) {
        //call apex class method
        var action = component.get('c.UpdateHealth');
        action.setParams({  "accountId" : component.get("v.recordId")  });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            console.log('state: ' + state);
            if (state === "SUCCESS") {
            	component.set("v.Spinner", false);
                console.log('JSON: ' + response.getReturnValue());
                this.showResult(component, response.getReturnValue());
            }
        });
        console.log('test');
        
        $A.enqueueAction(action);
    }
    ,showResult: function(component, json) {
        let title = '';
        let parsed = JSON.parse(json);
        let type = parsed.type;
        let message = parsed.message;
        console.log('type: ' + type + ' message: ' + message);
        
        if (type == 'success') {
            title = 'Success!';
            component.set("v.success", true);
        } else if (type == 'error') {
            title = 'Error';
            component.set("v.error", true);
			component.set("v.errorMessage", message);
        }
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: 'dismissable'
        });
        //toastEvent.fire();
    }
})