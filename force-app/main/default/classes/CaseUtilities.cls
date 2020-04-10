/**
* @Author       Heidi Tang
* @Date         2016-04-28
* @Description  Compilation of methods for Case
* @Requirement  REQ-0518 Engineering parent type.
**/
public class CaseUtilities {
    
    private static Map<String, Map<String, Schema.SObjectField>> fieldDescribeCache = 
                new Map<String, Map<String, Schema.SObjectField>>();
    
    /* -----------------------------String Constants--------------------------*/    
    // Cases
    public static final String CASE_STATUS_ON_HOLD = 'On Hold';

    // Record Type Dev Names
    public static final String CASE_RECTYPE_ENGINEERING = 'Engineering_Case';
    
    /* -----------------------------Methods for Query Builder--------------------------*/

    /**
     * @author Heidi Tang
     * @date 2016-04-28
     * @description : dynamic SOQL
     * @param Schema.DescribeSObjectResult sdo
     * @return String 
    */ 
    public static String buildQuery(Schema.DescribeSObjectResult sdo) {
        String queryFields = buildQueryFields(sdo);
        
        queryFields = 'SELECT ' + queryFields +' FROM ' + sdo.getName() + ' ';
        return queryFields;
    }
    
     /**
     * @author Heidi Tang
     * @date 2016-04-28
     * @description : dynamic SOQL for fields
     * @param Schema.DescribeSObjectResult sdo
     * @return String 
    */ 
    public static String buildQueryFields(Schema.DescribeSObjectResult sdo) {
        
        Map<String, Schema.SObjectField> objectFields_map = getFieldDescribe(sdo);
        String queryFields = '';
        Boolean firstFlag = true;
        for (string c : objectFields_map.keySet()) {
            if (!firstFlag) {
                queryFields = queryFields + ', ';
            }
            queryFields = queryFields + c;
            firstFlag = false;
        }
        return queryFields;
    }
    
    /**
     * @author Heidi Tang
     * @date 2016-04-28
     * @description : get field based from describe method
     * @param Schema.DescribeSObjectResult sdo
     * @return Map<String, Schema.SObjectField> 
    */ 
    public static Map<String, Schema.SObjectField> getFieldDescribe(Schema.DescribeSObjectResult sdo) {
        if (!fieldDescribeCache.containsKey(sdo.getName())) {
            fieldDescribeCache.put(sdo.getName(), sdo.fields.getMap());
        }
        return fieldDescribeCache.get(sdo.getName());
    }
}