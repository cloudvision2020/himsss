@RestResource(urlMapping='/DataMigration/*')
global without sharing class DataMigration {

    @HttpPost
    global static String Dispatcher(List<String> objList, List<String> removeFieldList, String sourceObjString, Boolean diffOrg){
        String retVal = '';
        if(!removeFieldList.isEmpty()){
            retVal = getTargetObjectFields(objList, removeFieldList, sourceObjString, diffOrg);
        }
        else if(!objList.isEmpty()){
            retVal = getSourceObjectFields(objList);
        }
        else{
            retVal = getObjects();
        }
        return retVal;
    }
    
    global static String getSourceObjectFields(List<String> objList) {
        Map<String,Set<String>> objMap = new Map<String,Set<String>>();
        
        for(String objName : objList){
            objMap.put(objName, new Set<String>());
            system.debug(objName);
            Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            
            for(String field : fields.keySet()){
                objMap.get(objName).add(fields.get(field).getDescribe().getName());
            }
        }
        return JSON.serialize(objMap);
    }
    
    global static String getObjects() {
        Map<String,Set<String>> objMap = new Map<String,Set<String>>();
        Set<String> ignoreList = new Set<String>{'Organization','Group'};
        for(Schema.SObjectType obj : Schema.getGlobalDescribe().values()){
            if(obj.getDescribe().isCreateable() && !ignoreList.contains(obj.getDescribe().getName())){
                objMap.put(obj.getDescribe().getName(), new Set<String>());
                Map<String, Schema.SObjectField> fields = obj.getDescribe().fields.getMap();
                
                for(String field : fields.keySet()){
                    String req = fields.get(field).getDescribe().isNillable() ? '' : '*';
                    System.debug(req + ' ' + field);
                    if(String.valueOf(fields.get(field).getDescribe().getType()) == 'REFERENCE'){
                        for(Schema.SObjectType reference : fields.get(field).getDescribe().getReferenceTo()){
                            if(!ignoreList.contains(reference.getDescribe().getName())){
                            	objMap.get(obj.getDescribe().getName()).add(req + reference.getDescribe().getName());
                            }
                        }
                    }
                }
            }
        }
        return JSON.serialize(objMap);
    }
    
    global static String getTargetObjectFields(List<String> objList, List<String> removeFieldList, String sourceObjString, Boolean diffOrg) {
        Set<String> objSet = new Set<String>(objList);
        Map<String,Map<String,String>> objMap = new Map<String,Map<String,String>>();
        Set<String> removeFields = new Set<String>(removeFieldList);
        system.debug(sourceObjString);
        Map<String,Object> sourceObjects = (Map<String,Object>)JSON.deserializeUntyped(sourceObjString);
        Map<String,Set<String>> sourceObjMap = new Map<String,Set<String>>();
        Set<String> completedObj = new Set<String>();
        List<String> objToInclude = new List<String>{'RecordType','User'};
        List<String> objToIncludeId = new List<String>{'RecordTypeId','Product2Id','Pricebook2Id','PricebookEntryId','UserId'};
        if(!diffOrg){
            objToInclude.addAll(new List<String>{'Product2','User','Pricebook2','PricebookEntry'});
        }
        for(String objName : sourceObjects.keySet()){
            sourceObjMap.put(objName,new Set<String>());
            for(Object o : (List<Object>)sourceObjects.get(objName)){
                sourceObjMap.get(objName).add(String.valueOf(o));
            }
        }
        System.debug(sourceObjMap);
        
        for(String objName : objList){
            Map<String, Schema.SObjectField> fields= Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            Map<String,String> fieldMap = new Map<String,String>();
            
            for(String field : fields.keySet()){
                String fieldName = fields.get(field).getDescribe().getName();
                System.debug(fieldName + ' : ' + ObjName);
                System.debug((fields.get(field).getDescribe().isUpdateable()) + ' : ' + (fields.get(field).getDescribe().getRelationshipOrder() != null) + ' : ' + (!fields.get(field).getDescribe().isNillable()) + ' : ' + (fieldName == 'Product2Id'));
                Boolean addToList = true;
                if(!removeFields.contains(field) && sourceObjMap.get(objName).contains(fieldName) && (fields.get(field).getDescribe().isUpdateable() || fields.get(field).getDescribe().getRelationshipOrder() != null || /*!fields.get(field).getDescribe().isNillable() ||*/ objToIncludeId.contains(fieldName) || (fieldName == 'OpportunityId' && objName =='OpportunityLineItem'))){
                    //Boolean isLookup = String.valueOf(fields.get(field).getDescribe().getType()) == 'REFERENCE' ;
                    String isLookup = null;
                    for(Schema.SObjectType reference : fields.get(field).getDescribe().getReferenceTo()) {
                        if(objToInclude.contains(reference.getDescribe().getName())){
                            isLookup = null;
                        }
                        else{
                            isLookup = reference.getDescribe().getName();
                        }
                        if(!(completedObj.contains(reference.getDescribe().getName()) || reference.getDescribe().getName() == objName || objToInclude.contains(reference.getDescribe().getName()))){
                            //System.debug(objList.contains(reference.getDescribe().getName()) + reference.getDescribe().getName());
                            addToList = false;
                        }
                    }
                    if(addToList){
                        
                        fieldMap.put(fieldName,isLookup); 
                    }            
                }
            }
            completedObj.add(objName);
            objMap.put(objName, fieldMap);
        }
        return JSON.serialize(objMap);
    }
}