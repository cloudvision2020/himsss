global class ScheduleCEHoursUpdateOnContact implements Schedulable {
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new BatchCEHoursUpdateOnSubscription());
   }
}