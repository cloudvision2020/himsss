public class UpdateContactScheduleJob implements Schedulable  {
    public Set<Id> contactIds;
    public String jobName = '';
    public UpdateContactScheduleJob(Set<Id> conIds) {
        this.contactIds = conIds;
        jobName = 'UpdateContactScheduleJob';
    }
    public void execute(System.SchedulableContext context) {
        // Query the CronTrigger object to check if a job with the specified name is scheduled
        string searchJobName = jobName+'%';
        system.debug('jobName : '+jobName+'- searchJobName : '+searchJobName);
        List<CronTrigger> scheduledJobs = [SELECT Id,CronJobDetail.Name, State, EndTime FROM CronTrigger WHERE CronJobDetail.Name LIKE : searchJobName];
        system.debug('scheduledJobs : '+scheduledJobs);
        if (scheduledJobs.size() > 0) {
            // The job with the specified name is already scheduled
            System.debug('The job with the name Fon_MassPaymentSchedulableJob is already scheduled.');
            for(CronTrigger ct: scheduledJobs){
                System.abortJob(ct.Id);
            }
            List<Contact> conList = [SELECT Id, Name FROM contact where Id In: contactIds];
            system.debug('conList : '+conList);
            if(conList.size() > 0){
                update conList;
            }
            //string cronImmidiate = scheduleJobAfter1Mins();
            //jobName = jobName+String.valueOf(Datetime.now().addMinutes(1).minute());
            //system.debug('Execute jobName : '+jobName);
            //System.schedule(jobName,  cronImmidiate, new Fon_MassPaymentSchedulable(primarySalesOrderIds));
            
        } else {
            System.debug('No existing job with the name Fon_MassPaymentSchedulableJob. The new job has been scheduled.');
            List<Contact> conList = [SELECT Id, Name FROM contact where Id In: contactIds];
            system.debug('conList : '+conList);
            if(conList.size() > 0){
                update conList;
            }
        }
    }
}