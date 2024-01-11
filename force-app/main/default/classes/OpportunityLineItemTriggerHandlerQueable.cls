public class OpportunityLineItemTriggerHandlerQueable implements Queueable
{
    public List<OpportunityLineItemSchedule> OppScheduleList{get;set;}
    
    public void execute(QueueableContext context) {
        List<OpportunityLineItemSchedule> ListLineItems=new List<OpportunityLineItemSchedule>();
      for(OpportunityLineItemSchedule   lineItem:OppScheduleList)
      {
          OpportunityLineItemSchedule tempRecord= new OpportunityLineItemSchedule();
          tempRecord=lineItem;
          ListLineItems.add(tempRecord);
      }
        
        update ListLineItems;
    }
}