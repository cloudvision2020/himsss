public without sharing class Fon_SearchAccountWrapper {
    public String strAccountId{get;set;}
    public String strAccountName{get;set;}
    public String strAccAddress{get;set;}
    
    
    public Fon_SearchAccountWrapper(String strAccountId, String strAccountName, String strAccAddress){
        this.strAccountId = strAccountId;
        this.strAccountName = strAccountName;
        this.strAccAddress = strAccAddress;
    }
    
    public Fon_SearchAccountWrapper(Account objAccount){
        this.strAccountId = objAccount.Id;
        this.strAccountName = objAccount.Name;
        //this.strAccAddress = objAccount.BillingStreet + objAccount.BillingCity + objAccount.BillingCountry + objAccount.BillingPostalCode;
         this.strAccAddress = ' '+' ';
        if(String.isNotBlank(objAccount.BillingCity)){
            this.strAccAddress = this.strAccAddress + objAccount.BillingCity;
        }
        if(String.isNotBlank(objAccount.BillingState)){
            this.strAccAddress = this.strAccAddress +', '+ objAccount.BillingState ;
        }
        if(String.isNotBlank(objAccount.BillingCountry)){
            this.strAccAddress = this.strAccAddress + ', '+ objAccount.BillingCountry + ',';
        }
        this.strAccAddress = this.strAccAddress.subString(0,this.strAccAddress.Length()-1);
    }
    
    public static List<Fon_SearchAccountWrapper> fetchAccountWrapper(List<Account> lstAccount){
        List<Fon_SearchAccountWrapper> lstAccWrapper = new List<Fon_SearchAccountWrapper>();
        for(Account eachAcc : lstAccount){
            Fon_SearchAccountWrapper objWrapper = new Fon_SearchAccountWrapper(eachAcc);
            lstAccWrapper.add(objWrapper);
        }
        return lstAccWrapper;
    }
    
}