({
    retry: function (component, event, helper) {
        component.set("v.error", false);
        update(component, event, helper);
    },
    refresh: function () {
        location.reload(true);
    },
    update: function (component, event, helper) {
        component.set("v.notPressed", false);
        helper.updateHealth(component);
    }
})