({
	doInit : function(cmp, event, helper) {
        var action = cmp.get("c.callApex");
        action.setParams({ ItemId : cmp.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("5% of subscription are Audit successfull...");
               $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})