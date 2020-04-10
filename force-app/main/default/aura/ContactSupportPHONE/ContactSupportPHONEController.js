({
	doInit : function(component, event, helper) {
        // recaptcha settings
        //let vfOrigin="https://mindbodysupport.force.com";					//Production
        //let vfOrigin = "https://eos1-mindbody.cs27.force.com";			//Full Sandbox
        let vfOrigin = "https://eosdev-mindbodysupport.cs124.force.com"		//EOS Dev 
        window.addEventListener("message",function(event) {

            if(event.origin !== vfOrigin) {
                //not the expected origin - reject the message
                return;
            }
            if(event.data==="Unlock") {
                //console.log("unlock");
                component.set("v.showSubmitCase",true);
                component.set("v.showFiles",true);
                component.set("v.showRecaptcha",false);
            }
            else 
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: "An error occurred with your reCAPTCHA verification. Please refresh your browser and try again.",
                    type: "error"
                });
                toastEvent.fire();                
            }
        }, false);
        
        helper.getUserId(component);
        helper.getRecordTypeId(component);
        helper.getSupportNumbers(component);
	},
    
     ProductSelected : function(component, event, helper) {
        component.set("v.showSpinner", true);
         
         var product = component.find("caseProduct").get("v.value");
        //console.log('product = ' + product);
        
        if(product !== "")
        {
            helper.checkBusinessHours(component, product);
            component.set("v.selectedProduct",product);
        }
        else
        {
            component.set("v.selectedProduct",null);
            component.set("v.businessOpen", false);
            component.set("v.showSpinner", false);
        }
    },
    
    DisplaySupportNumber : function(component, event, helper) {
        var isOpen = component.get("v.businessOpen");
        helper.displaySupportNumber(component, isOpen);
    },
    
    formatPhoneNumber : function(component, event, helper) {
        helper.formatPhoneNumber(component, event);
    },
    doneRendering : function(component, event, helper) {
        helper.setPhoneService(component, event);
    }
})