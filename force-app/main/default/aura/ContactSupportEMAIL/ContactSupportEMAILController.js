({
    doInit : function(component, event, helper) {
        
        // recaptcha settings
        //let vfOrigin = "https://eos1-mindbody.cs27.force.com";			// EOS FULL
        //let vfOrigin = "https://mindbodysupport.force.com";				// PRODUCTION
        let vfOrigin = "https://eosdev-mindbodysupport.cs124.force.com"	//EOS DEV
        window.addEventListener("message",function(event) {
            //console.log('event.data = ' + event.data);
            //console.log('event.origin = ' + event.origin);
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
        
        /////////////////////////////////////////////////////
        //	TEST CODE BELOW
        ////////////////////////////////////////////////////
/*                
        var count = 0;
        var interval = setInterval(function(e) {
            console.log(window.Inbenta);
            if (window.Inbenta !== undefined) {
                window.setTimeout(
                    $A.getCallback( function() {                        
                        console.log(window.Inbenta);
                        console.log("Running window.Inbenta.Assistant.StartInbenta();");
                        window.Inbenta.Assistant.StartInbenta();
                    })
                );
                clearInterval(interval);
            } else {
                count++;
            }
            if (count > 5) clearInterval(interval);
        }, 1000);
*/        
    },
    
    //TEMP
    scriptsLoaded : function(component, event, helper) { 
        console.log('Scripts Loaded!');         
        if (typeof jQuery !== "undefined" && typeof j$ === "undefined") {
            var j$ = jQuery.noConflict(true);
        }      
        console.log('j$(.webForm .inbenta .slds-input) = ' + j$(".webForm .inbenta .slds-input").value);
    },
    
    testJQuery : function(component, event, helper) {
        console.log('in testJQuery');
        console.log('typeof jQuery = ' + typeof jQuery);
        console.log('typeof j$ = ' + typeof j$);
        if (typeof jQuery !== "undefined" && typeof j$ === "undefined") {
            var j$ = jQuery.noConflict(true);
        }
		console.log('j$(.webForm .inbenta .slds-input) = ' + j$(".webForm .inbenta .slds-input").val());
	},
    
    handleUploadFinished: function (component, event) {
        
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        if(uploadedFiles.length>1)
        {
            component.set("v.showFilesUploaded",true);
        }
        
        var fileList = component.get("v.caseFiles");
        for(var i = 0;i < uploadedFiles.length;i++) {
            
            fileList.push({
                key: uploadedFiles[i].documentId,
                value: uploadedFiles[i].name
            });             
        }
        component.set("v.caseFiles",fileList);
        component.set("v.fileUploaded", true);      
    },
    
    handlePillRemoval: function (component, event,helper) {
        
        var selectedFileId = event.getSource().get("v.name");
        
        helper.deleteFile(component,selectedFileId);
    },
    
    ProductSelected : function(component, event, helper) {
        
        var product = component.find("caseProduct").get("v.value");
        //console.log('product = ' + product);
        
        if(product !== "")
        {
            component.set("v.selectedProduct",product);
            component.set("v.fieldDisabled",false);
        }
        else
        {
            component.set("v.selectedProduct",null);
            component.set("v.fieldDisabled",true);
        }
    },
    
    submitCreateCase : function(component, event, helper) {
        component.set("v.errorMessages", []);
        var hasErrors = false; 
        component.set("v.showSubmitCase", false);
        var theCase = component.get("v.theCase"); 
        var product = component.find("caseProduct").get("v.value");
        
        if(helper.checkError(component,"caseName","Name","SuppliedName",theCase))
        {
            hasErrors=true;
        }        
        if(helper.checkError(component,"caseEmail","Email","SuppliedEmail",theCase))
        {
            hasErrors=true;
        } 
        if(helper.checkError(component,"casePhone","Phone","SuppliedPhone",theCase))
        {
            hasErrors=true;
        } 
        if(helper.checkError(component,"caseProduct","Product","Product__c",theCase))
        {
            hasErrors=true;
        }
        if(product === "MINDBODY" && helper.checkError(component,"caseSiteId","Site Id","Site_ID__c",theCase))
        {
            hasErrors=true;
        } 
        if(product === "Booker" && helper.checkError(component,"caseLocationId","Location Id","Location_ID__c",theCase))
        {
            hasErrors=true;
        } 
        if(product === "FitMetrix" && helper.checkError(component,"caseLocationName","Location Name","Location_name__c",theCase))
        {
            hasErrors=true;
        } 
        if(helper.checkError(component,"caseNeedHelpWith","I Need Help With","I_need_help_with__c",theCase))
        {
            hasErrors=true;
        } 
        if(helper.checkError(component,"caseSeverity","Severity","Severity__c",theCase))
        {
            hasErrors=true;
        } 
        if(helper.checkError(component,"caseSubject","Subject","Subject",theCase))
        {
            hasErrors=true;
        }        
        if(helper.checkError(component,"caseDescription","Description","Description",theCase))
        {
            hasErrors=true;
        }                    
        
        if (!hasErrors) {
            component.set("v.theCase", theCase); 
            
            try
            {
                helper.submitCase(component);
            }
            catch (exp)
            {
                errorMessages.push(exp.getMessage());
                component.set("v.showSubmitCase", true);
                component.set("v.errorMessages", errorMessages);
            }
        }
        else {
            component.set("v.showSubmitCase",true);
        }
    },
})