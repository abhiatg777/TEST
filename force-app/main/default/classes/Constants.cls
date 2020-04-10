public with sharing class Constants
{
    public static final String SELECT_ONE = 'Select One';
    public static final String NONE = 'None';
    
    public static final Integer SCREEN_PRACTICE = 1;
    public static final Integer SCREEN_ASSIGN_SERVICE = 2;
    public static final Integer SCREEN_OPT_IN = 3;
    public static final Integer SCREEN_LOCATION = 4;
    public static final Integer SCREEN_STATEMENT = 5;
    public static final Integer SCREEN_SUMMARY = 6;
    public static final Integer SCREEN_PAYER = 7;
    public static final Integer SCREEN_ALL = -1;
    
    public static final String NO_CONTACTS_AVAILABLE = 'No Contacts Available';
    public static final String NO_PAYERS_AVAILABLE = 'No Payers Available';    
    public static final String NO_ENTITLEMENTS_AVAILABLE = 'No Entitlements Available';
    public static final String NO_PRODUCT_FAMILIES_AVAILABLE = 'No Product Families Available';
    public static final String NO_PRODUCT_LINES_AVAILABLE = 'No Product Lines Available';
    public static final String NO_PRACTICES_AVAILABLE = 'No Practices Available';
    public static final String NO_LICENSE_KEYS_AVAILABLE = 'No License Keys Available';
    public static final String NO_ASSETS_AVAILABLE = 'No Assets Available';
    public static final String NO_ASSET_VERSIONS_AVAILABLE = 'No Asset Versions Available';
    public static final String NO_COMPONENTS_AVAILABLE = 'No Components Available';
    public static final String NO_SUB_COMPONENTS_AVAILABLE = 'No Sub Components Available';
    
    public static final String QRY_STRING_ACCOUNT_ID = 'def_account_id';
    public static final String QRY_STRING_CONTACT_ID = 'def_contact_id';
    public static final String QRY_STRING_CHANGE_ASSET = 'isChangeAsset';
    public static final String QRY_STRING_CASE_ID = 'id';
    public static final String QRY_STRING_CONVERT_TO_TECH_FUNC_ISSUE = 'convertToTechFuncIssue';
    public static final String QRY_STRING_PRACTICE_ID = 'prc_id';
    public static final String QRY_STRING_COMPANY_ID = 'cmp_id';
    public static final String QRY_STRING_SCREEN = 'screen';
    public static final String QRY_STRING_PRODUCT_TYPE = 'prdType';
    public static final String QRY_STRING_ACCOUNT_ASSET_ID = 'aaID';
    public static final String QRY_STRING_EXPRESS_BILL_ID = 'ebID';
    public static final String QRY_STRING_REG_EVENT_TYPE = 'regType';
    
    public static final String PRACTICE = 'Practice';
    public static final String PAYERS = 'Payers';
    public static final String SERVICES = 'Services';
    public static final String PROVIDERS = 'Providers';
    
    public static final String MY_SERVICES = 'My Services';
    
    public static final String EVENT_TYPE_ADD_PRACTICE = 'Add '+PRACTICE;
    public static final String EVENT_TYPE_ADD_PAYERS = 'Add '+PAYERS;
    public static final String EVENT_TYPE_ADD_SERVICES = 'Add '+SERVICES;
    public static final String EVENT_TYPE_ADD_PROVIDERS = 'Add '+PROVIDERS;
    
    public static final String EDIT_MODE = 'edit';
    public static final String NEW_MODE = 'new';
    
    public static final String ACCOUNT_RECORD_TYPE_CHANNEL_PARTNER = 'Channel_Partner';
    public static final String ACCOUNT_RECORD_TYPE_CLIENT = 'Client';
    public static final String ACCOUNT_RECORD_TYPE_PRACTICE = 'Practice';
    
    public static final String CONTACT_RECORD_TYPE_PROVIDER = 'Provider';
    public static final String CONTACT_RECORD_TYPE_CONTACT = 'Contact';
    
    public static final String OPPORTUNITY_RECORD_TYPE_CHANGE_ORDER = 'Change_Order';
    
    public static final String ACCOUNT_ADDRESS_RECORD_TYPE_CLIENT = 'Client';
    public static final String ACCOUNT_ADDRESS_RECORD_TYPE_PRACTICE = 'Practice';
    public static final String ACCOUNT_ADDRESS_RECORD_TYPE_LOCATION = 'Location';
    
    public static final String DEFAULT_SEVERITY = '3 - Normal';
    public static final String DEFAULT_PRIORITY = '4';
    public static final String DEFAULT_ORIGIN = 'Phone';
    public static final String DEFAULT_ORIGIN_PORTAL = 'Web';
    public static final String DEFAULT_TYPE = 'Technical';
    public static final String ORIGIN_PHONE = 'Phone';
    
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_ESCALATED = 'Escalated to L3';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_FIXED = 'Fixed';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_ON_MAINTENANCE = 'Active';
    public static final String STATUS_OFF_MAINTENANCE = 'Expired';
    public static final String STATUS_DECOMMISSION = 'Decommission';
    public static final String STATUS_ESCALATED_TO_DEV = 'Escalated to Development';
    
    public static final String SEVERITY_ROUTINE = 'Routine';
    
    public static final String OPPORTUNITY_TYPE_NEW_CUSTOMER = 'Initial Opportunity';
    public static final String OPPORTUNITY_TYPE_EXISTING_CUSTOMER = 'Follow On Sales';
    
    public static final String PRODUCT_FAMILY_TRANSACTION_SERVICES = 'Transaction Services';
    public static final String PRODUCT_FAMILY_HARDWARE = 'Hardware';
    public static final String PRODUCT_FAMILY_ADMIN = 'Admin';
    
    public static final String ROLE_PROVIDER = 'Provider';
    
    public static final String ENTITLEMENT_STATUS_ACTIVE = 'Active';
    
    public static final String ORDER_TYPE_ADD_ON = 'AddOn';
    public static final String ORDER_TYPE_CHANGE_ORDER = 'Change Order';
    public static final String ORDER_TYPE_RENEWAL = 'Renewal';
    public static final String ORDER_TYPE_NEW_PRODUCT = 'New';
    public static final String ORDER_TYPE_MIGRATION = 'Migration';
    public static final String ORDER_TYPE_DECOMMISSION = 'Decommission';
    public static final String ORDER_TYPE_SERVICES_ONLY = 'Services Only';
	public static final String ORDER_TYPE_BILLING = 'Billing';
    
    public static final String LINE_TYPE_NEW = 'New';
    public static final String LINE_TYPE_RENEWAL = 'Renewal';
    public static final String LINE_TYPE_EXTENSION = 'Extension';
    public static final String LINE_TYPE_DECOMMISSION = 'Decommission';
    public static final String LINE_TYPE_MIGRATION = 'Migration';
    
    public static final String PRODUCT_TYPE_HARDWARE = 'Hardware';
    public static final String PRODUCT_TYPE_SOFTWARE = 'Software';
    
    public static final Integer LUHNS_DEFAULT_INITIAL_SUM = 24; //NPI numbers are always prefixed with '80480'. The LUHN sum for the NPI is 24
    public static final String FINANCE_REVIEW_APPROVED = 'Approved';
    
    public static final String REDIRECT_PARENT = 'parent';
    public static final String REDIRECT_ATTACH = 'attach';
    
    public static final String CUSTOMER_PORTAL_LICENSE_KEY = 'PID_Customer_Portal_Basic';
    public static final String CUSTOMER_PORTAL_LICENSE_KEY_STANDARD = 'PID_Customer_Portal_Standard';
    
    public static final String ENGINEERING_CASE_RECORD_TYPE = 'Engineering_Case';
    
    public static final String QUEUE_TYPE = 'Queue';
    public static final String DEVELOPMENT_QUEUE_NAME = 'L3';
}