public with sharing class Constants {
    public static Id OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Label.OpportunityRecordType_HIMSS_Media).getRecordTypeId(); 
    public static String OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEDEVELOPERNAME  = Label.OpportunityRecordType_HIMSS_Media;
    public static Id CONTRACT_HIMSS_MEDIA_RECORDTYPEID = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(Label.ContractRecordType_HIMSS_Media).getRecordTypeId(); 
}