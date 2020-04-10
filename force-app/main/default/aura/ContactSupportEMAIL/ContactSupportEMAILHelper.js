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
    
    deleteFile : function(component,selectedFileId)
    {
        component.set("v.showSpinner",true);
        var fileList = component.get("v.caseFiles");
        
        var selectedIndex = 0;
        for(var i = 0;i < fileList.length;i++) {
            if(fileList[i].key == selectedFileId) {
                selectedIndex = i;
            }
        }
        
        fileList.splice(selectedIndex,1);        
        component.set("v.caseFiles",fileList);
        component.set("v.fileUploaded",false);
        component.set("v.showSpinner",false);
        
        
    },
/*    
	fetchPicklistValues : function(component, objectName, apiName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName' : objectName,
            'field_apiName' : apiName,
            'nullRequired' : true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.list" + apiName + "Values", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    fetchDependentValues : function(component, objectName, controllingApiName, dependentApiName, currentValue) {
        //component.set("v.showSpinner",true);
        var action = component.get("c.getDependentValues");
        action.setParams({
            'pObjName' : objectName,
            'pControllingFieldName' : controllingApiName,
            'pDependentFieldName' : dependentApiName,
            'selectedValue' : currentValue

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('return value = ' + response.getReturnValue());
            if(state === "SUCCESS") {
                component.set("v.list" + dependentApiName + "Values", response.getReturnValue());
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
	},
*/    
    checkError : function(component,fieldName,errorMessageName,objectFieldName,theCase)
    {
        //console.log('in checkError');
        let theValue = component.find(fieldName).get("v.value");
        //console.log(fieldName+': ' + theValue);
        let toReturn=false;
        if (theValue == '' || theValue == null || theValue == '--None--') 
        {
            toReturn = true;
            var errorMessages = component.get("v.errorMessages");
            errorMessages.push('Please provide your ' + errorMessageName + '.');      
            component.set("v.errorMessages", errorMessages);            
        } 
        else 
        {
            
            theCase[objectFieldName] = theValue;
        }    
        return toReturn;
    },
    
    submitCase : function(component) { 
        //alert('submitting Case');
        component.set("v.showSpinner",true);
        var theCase = component.get("v.theCase");
        var action = component.get("c.insertGuestCase"); 
        
        var fileList = component.get("v.caseFiles"); 
        var theFileIds = '';
        for(var i = 0;i < fileList.length;i++) {
            theFileIds += fileList[i].key + ',';
        }
        
        //console.log('fileids',theFileIds);
        action.setParams({
            theCase : theCase,
            theFiles : theFileIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "Case successfully created",
                    type: "success",
                    mode: "dismissible",
                    duration: 5000
                });
                component.set("v.showCase",false);
                component.set("v.showFiles",false);
                component.set("v.showSuccess",true);
                
                toastEvent.fire();
                
            } 
            else 
            {
                component.set("v.showSpinner", false);
                var errorMessages = component.get("v.errorMessages");
                errorMessages.push('We are sorry but an error occurred while trying to submit your case. Please try again.');
                component.set("v.errorMessages", errorMessages);
                component.set("v.showSubmitCase",true);
            }
        });
        $A.enqueueAction(action);
    },
})