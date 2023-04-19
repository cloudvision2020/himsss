@IsTest
public with sharing class DataMigrationTest {
    @IsTest
    public static void DataMigrationTest() {
        List<String> objList = new List<String>();
        List<String> removeFields = new List<String>();
        String res = DataMigration.Dispatcher(objList,removeFields,null,false);
        
        objList.add('Account');
        String nothing = DataMigration.Dispatcher(objList,removeFields,res,false);
        
        removeFields.add('wmxid__c');
        DataMigration.Dispatcher(objList,removeFields,res,false);

    }
}