public class QS_CSS_AccountHealthController {
    class JSONResult {
        public String type = 'success';
        public String message = 'Successfully updated Account Health';
    }
        
    //Used for Account Health Update button
    @auraEnabled
    public static String UpdateHealth (Id accountId) {
        try {
            QS_CSS_AccountHealthUtils ahh = new QS_CSS_AccountHealthUtils();
            ahh.UpdateHealth(accountId);
            //String s;					//for testing returning errors
            //s.capitalize();
            JSONResult result = new JSONResult();
            return JSON.serialize(result);
        }
        catch (Exception e) {
            JSONResult error = new JSONResult();
            error.type = 'error';
            string msg=QS_VCG_Utils.GetErrorMessage(e, true);
            error.message = msg;
            QS_VCG_Utils.showDebug(msg);
            return JSON.serialize(error);
        }
    }
}