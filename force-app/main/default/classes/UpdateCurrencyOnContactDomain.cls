global inherited sharing class UpdateCurrencyOnContactDomain extends Framework.Domain {

    public UpdateCurrencyOnContactDomain(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new UpdateCurrencyOnContactDomain(sObjectList);
        }
    }

    public override void afterInsert() {
        Framework.Log.push(UpdateCurrencyOnContactDomain.class.getName(),'afterInsert');
        UpdateCurrencyOnContactService.UpdateCurrencyOnContact((Contact[]) records,null);
        Framework.Log.pop();
    }
    public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(UpdateCurrencyOnContactDomain.class.getName(),'afterUpdate');
        UpdateCurrencyOnContactService.UpdateCurrencyOnContact((Contact[]) records, (Map<Id,Contact>) oldMap);    
        Framework.Log.pop();
    }
}