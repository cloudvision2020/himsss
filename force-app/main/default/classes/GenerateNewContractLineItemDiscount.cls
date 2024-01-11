public class GenerateNewContractLineItemDiscount {
    
    @InvocableMethod(label='UpdateOrRefreshDiscountCLIs')
    public static void flowSubscriberContract(List<id> inputId){
        //On CLI still refreshing all clis discounts - to fix
        List<Contract> contractList = [SELECT ID,Opportunity__c FROM Contract WHERE ID = :inputId[0]];
        List<Contract_Line_Item__c> cliList = [SELECT ID,Contract__c,Product_Name__c FROM Contract_Line_Item__c WHERE ID = :inputId[0]];
        Map<Id, OpportunityLineItem> newItems = new Map<Id, OpportunityLineItem>();
        
        if(!contractList.isEmpty()){
            system.debug('On Contract');
            Contract c = contractList[0];
            for(OpportunityLineItem o : [SELECT id FROM OpportunityLineItem WHERE OpportunityId = :c.Opportunity__c AND (End_Date__c > TODAY OR End_Date__c = null)]){
                newItems.put(o.id,o);	
            }        
            recreateDiscountLines(newItems,c);
        }else if(!cliList.isEmpty()){
            system.debug('On CLI');
            Contract_Line_Item__c cli = cliList[0];
            Contract c = [SELECT ID,Opportunity__c FROM Contract WHERE ID = :cli.Contract__c];
            for(OpportunityLineItem o : [SELECT id FROM OpportunityLineItem WHERE OpportunityId = :c.Opportunity__c AND Contract_Line_Item__c = :cli.id AND (End_Date__c > TODAY OR End_Date__c = null)]){
                newItems.put(o.id,o);
                system.debug('Opp Line item ID: '+o.id);
            }
            recreateDiscountLines(newItems,c);
        }else{
            system.debug('Failed to recreate discount clis');
        }
    }
    
    public static void recreateDiscountLines(Map<Id, OpportunityLineItem> newItems, Contract contractRecord){
        Set<Id> newItemIds = new Set<Id>();
        newItemIds = newItems.keyset();
        //Trigger:When edit is made on any of the OLIs
        
        //Get all Discount Line Items
        List<Contract_Line_Item__c> relatedDiscountCLIs = [SELECT ID 
                                                           FROM Contract_Line_Item__c 
                                                           WHERE is_Discount_Record__c = TRUE 
                                                           AND Contract__c = :contractRecord.Id AND Opportunity_Line_Item_Id__c in :newItemIds]; //needs to filter
        
        //Delete them
        delete relatedDiscountCLIs;
        
        //Get all non discount line items in map with their Ids
        List<Contract_Line_Item__c> relatedCLI = [SELECT ID,Opportunity_Line_Item_Id__c,Discounted_Contract_Line_Item__c,Sales_Price__c,
                                                  Quantity__c,Rate_Type__c,Contract__c,Start_Date__c,End_Date__c,Product_Name__c,Line_Description__c,
                                                  Product_Family__c,Ad_Size__c,Region__c,Discount__c  
                                                  FROM Contract_Line_Item__c 
                                                  WHERE is_Discount_Record__c = FALSE
                                                  AND Contract__c = :contractRecord.Id AND Opportunity_Line_Item_Id__c in :newItemIds];
                                                  //AND (Start_Date__c > TODAY OR Start_Date__c = null)]; //needs to filter
        
        Map<Id, Contract_Line_Item__c> CliIDtosOBJ = new Map<Id, Contract_Line_Item__c>();
        for(Contract_Line_Item__c cli : relatedCLI){
            CliIDtosOBJ.put(cli.id, cli);
        }
        
        //Then Run below method again to 'recreate'
        checkIfItemIsDiscounted(CliIDtosOBJ);
    }
    
    public static void checkIfItemIsDiscounted(Map<Id, Contract_Line_Item__c> newItems){
        system.debug('Inside checkIfItemIsDiscounted');
        //setup
        //Get list of new records
        List<Contract_Line_Item__c> contractLineItems = new List<Contract_Line_Item__c>();
        for(Contract_Line_Item__c c : newItems.values()){
            contractLineItems.add(c);
        }
        List<ID> OpportunityLineItemIds = new List<ID>();
        List<ID> discountedOLIs = new List<ID>();
        List<Contract_Line_Item__c> discountedContractLineItems = new List<Contract_Line_Item__c>();
        
        //get opportunity line item ID's
        for(Contract_Line_Item__c cli : contractLineItems){
            OpportunityLineItemIds.add(cli.Opportunity_Line_Item_Id__c);
        }
        
        //get opportunity line Item sObjects
        List<OpportunityLineItem> OLIs = [SELECT Id,Discount_Percent__c,OpportunityId,ProductCode,ListPrice 
                                          FROM OpportunityLineItem WHERE ID IN :OpportunityLineItemIds];
        
        //traverse opportunity line item and identify the discounted records
        for(OpportunityLineItem o : OLIs){
            if(o.Discount_Percent__c != null){discountedOLIs.add(o.id);}
        }
        
        //identify discounted contract line items
        for(Contract_Line_Item__c cli : contractLineItems){
            if(discountedOLIs.contains(cli.Opportunity_Line_Item_Id__c)){
                discountedContractLineItems.add(cli);
            }
        }
        
        checkForExistingDiscountRecord(discountedContractLineItems);
    }
    
    public static void checkForExistingDiscountRecord(List<Contract_Line_Item__c> newContractLineItems){
        system.debug('Inside checkForExistingDiscountRecord');
        List<Contract_Line_Item__c> toUpdate = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> toCreate = new List<Contract_Line_Item__c>();
        
        for(Contract_Line_Item__c c : newContractLineItems){
            if(c.Discounted_Contract_Line_Item__c != null){
                toUpdate.add(c);
            }else{
                toCreate.add(c);
            }
        }
        
        createDiscountRecord(toCreate);
        
    }
    
    
    public static void createDiscountRecord(List<Contract_Line_Item__c> CLIWithoutDiscount){
        system.debug('Inside createDiscountRecord');
        //Setup
        List<Contract_Line_Item__c> newCLIDiscounts = new List<Contract_Line_Item__c>();
        List<Id> OLIIds = new List<Id>();
        List<Id> OppIds = new List<Id>();
        Map<Contract_Line_Item__c,OpportunityLineItem> ContractLineItemToOpportunityLineItem = new Map<Contract_Line_Item__c,OpportunityLineItem>();
        Map<OpportunityLineItem,Opportunity> OpportunityLineItemToOpportunity = new Map<OpportunityLineItem,Opportunity>();
        Map<String,String> ProductCodeToDiscountCode = new Map<String,String>();
        List<Discount_Product__c> discountProducts = [SELECT id, Discount_Product_Code__c, Product_Code__c
                                                      FROM Discount_Product__c];
        
        //Isolate Opportunity Line Item Ids
        for(Contract_Line_Item__c  clI : CLIWithoutDiscount){
            OLIIds.add(clI.Opportunity_Line_Item_Id__c);
        }
        List<OpportunityLineItem> OLIs = [SELECT ID,Discount_Percent__c,OpportunityId,ProductCode,ListPrice
                                          FROM OpportunityLineItem WHERE Id IN :OLIIds];
        
        //Isolate Opportunity Ids
        for(OpportunityLineItem OLI : OLIs){
            OppIds.add(OLI.OpportunityId); 
        }
        List<Opportunity> Opps = [SELECT ID FROM Opportunity WHERE Id IN :OppIds];
        
        //Build Map for Contract Line Item To Opportunity Line Item
        for(Contract_Line_Item__c  clI : CLIWithoutDiscount){
            for(OpportunityLineItem o : OLIs){
                if(o.id == clI.Opportunity_Line_Item_Id__c){
                    ContractLineItemToOpportunityLineItem.put(cLI,o);
                }
            }
        }
        
        //Build Map for Opportunity Line Item To Opportunity
        for(OpportunityLineItem OLI : OLIs){
            for(Opportunity o : Opps){
                if(OLI.OpportunityId == o.Id){
                    OpportunityLineItemToOpportunity.put(OLI,o);
                }
            }
        }
        
        //Build Map for Product Code To Discount Product Code
        for(OpportunityLineItem OLI : OLIs){
            for(Discount_Product__c d : discountProducts){
                if(OLI.ProductCode == d.Product_Code__c){
                    ProductCodeToDiscountCode.put(OLI.ProductCode,d.Discount_Product_Code__c);
                }
            }
        }
        
        //Inserts (discount record) and Updates (non-discount contract line item to tag)
        List<Contract_Line_Item__c> insertDiscountContractLineItems = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> updateExistingContractLineItem = new List<Contract_Line_Item__c>();
        
        //Build Discount Contract line Item
        for(Contract_Line_Item__c  clI : CLIWithoutDiscount){
            //calculate discount amount
            OpportunityLineItem oli = ContractLineItemToOpportunityLineItem.get(clI);
            Opportunity o = OpportunityLineItemToOpportunity.get(oli);
            double discountPercent = oli.Discount_Percent__c;
            double discountAmount = (discountPercent / 100) * (cli.Sales_Price__c*cli.Quantity__c);
            //CPM requires a further /1000
            if(clI.Rate_Type__c == 'CPM'){
                discountAmount /= 1000;
            }
            //set contract line item fields
            Contract_Line_Item__c newDiscountCLI = new Contract_Line_Item__c();
            newDiscountCLI.Contract__c = clI.Contract__c;
            newDiscountCLI.Start_Date__c = clI.Start_Date__c;
            newDiscountCLI.End_Date__c = clI.End_Date__c;
            newDiscountCLI.Total_Price__c = 0 - discountAmount;
            newDiscountCLI.Sales_Price__c = 0 - discountAmount;
            newDiscountCLI.Opportunity_Line_Item_Id__c = cLI.Opportunity_Line_Item_Id__c;
            newDiscountCLI.Product_Name__c = clI.Product_Name__c + ' - ' + 'DISCOUNT';
            newDiscountCLI.Product_Code__c = ProductCodeToDiscountCode.get(oli.ProductCode);
            newDiscountCLI.Discounted_Contract_Line_Item__c = clI.Id; 
            newDiscountCLI.Line_Description__c = clI.Line_Description__c;
            newDiscountCLI.is_Discount_Record__c = TRUE;
            newDiscountCLI.Quantity__c = clI.Quantity__c;
            newDiscountCLI.Rate_Type__c = clI.Rate_Type__c;
            newDiscountCLI.Product_Family__c = CLI.Product_Family__c;
            newDiscountCLI.Ad_Size__c = CLI.Ad_Size__c;
            newDiscountCLI.Region__c = CLI.Region__c;
            newDiscountCLI.Discount__c = cli.Discount__c;
            system.debug('discountPercent == ' + discountPercent);
            insertDiscountContractLineItems.add(newDiscountCLI);
            
        }
        
        
        system.debug('No of records inserted = ' + insertDiscountContractLineItems.size());
        if(!insertDiscountContractLineItems.isEmpty()){
            insert insertDiscountContractLineItems;
            updateExistingContractLineItemSchedule(insertDiscountContractLineItems);
        }
    }
    
    public static void updateExistingContractLineItemSchedule(List<Contract_Line_Item__c> discountContractLineItems){
        system.debug('Inside updateExistingContractLineItemSchedule');

        //data setup
        List<Contract_Line_Item_Schedule__c> updateCLISchedules = new List<Contract_Line_Item_Schedule__c>();      
        List<Contract_Line_Item_Schedule__c> discountContractLineItemSchedules = [SELECT Id,Quantity__c, Contract_Line_Item__c,Discount__c,Extended_Amount__c,Contract_Line_Item__r.Discounted_Contract_Line_Item__r.Id
                                                                                  FROM Contract_Line_Item_Schedule__c 
                                                                                  WHERE Contract_Line_Item__c IN :discountContractLineItems];
        
        Map<Contract_Line_Item_Schedule__c,Contract_Line_Item__c> discountCLIScheduleTOnonDiscountRelatedCLI = new Map<Contract_Line_Item_Schedule__c,Contract_Line_Item__c>();
        
        List<Id> nonDiscountRelatedCliIds = new List<Id>();               
        for(Contract_Line_Item_Schedule__c discountclis : discountContractLineItemSchedules){
            nonDiscountRelatedCliIds.add(discountclis.Contract_Line_Item__r.Discounted_Contract_Line_Item__r.Id);
        }
        
        List<Contract_Line_Item__c> nonDiscountRelatedCLI = [SELECT Id FROM Contract_Line_Item__c WHERE ID IN :nonDiscountRelatedCliIds];
        //create map of discountCLISchedule TO nonDiscountRelatedCLI
        for(Contract_Line_Item_Schedule__c clis : discountContractLineItemSchedules){
            for(Contract_Line_Item__c nonDiscountCliRelated : nonDiscountRelatedCLI){
                if(clis.Contract_Line_Item__r.Discounted_Contract_Line_Item__r.Id == nonDiscountCliRelated.id){
                    discountCLIScheduleTOnonDiscountRelatedCLI.put(clis,nonDiscountCliRelated);
                }
            }
        }
        
        Map<Contract_Line_Item_Schedule__c,Contract_Line_Item__c> clisTocli = new Map<Contract_Line_Item_Schedule__c,Contract_Line_Item__c>();
        for(Contract_Line_Item__c cli : discountContractLineItems){
            for(Contract_Line_Item_Schedule__c clis : discountContractLineItemSchedules){
                if(clis.Contract_Line_Item__r.Id == cli.id){
                    clisTocli.put(clis,cli);
                }
            }
        }
        
        //update contract line item schedules
        for(Contract_Line_Item_Schedule__c c : discountContractLineItemSchedules){
            //get discount rate of parent cli
            Contract_Line_Item__c cli = clisTocli.get(c);
            double parentCliDiscount = cli.Discount__c;
            //increase schedule amount by the rate from parent cli
            //then do caluculations based on CPL CPM etc.
            double newDiscount = c.discount__c / 100;
            double discountnegative = c.Extended_Amount__c * newDiscount;
            double newAmount = 0 - discountnegative;
            double discountRemainder = 100-parentCliDiscount;
            double finalAmount = (newAmount / discountRemainder) *100;
            if(cli.Rate_Type__c == 'CPM'){
                //c.Amount__c = finalAmount * 1000; // quanitity added to each below
                c.Amount__c = (finalAmount*1000)/c.Quantity__c;
            }else if(cli.Rate_Type__c == 'CPL'){
                c.Amount__c = finalAmount/c.Quantity__c;
            }else{
                c.Amount__c = finalAmount/c.Quantity__c;
            }
            updateCLISchedules.add(c);
        }
        
        
        //performs update
        update updateCLISchedules;
    }
}