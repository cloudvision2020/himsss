/*
 *  Automatically generated and deployed by Hooked (aptk_hooked)
 *  DO NOT REMOVE THIS CLASS MANUALLY
 *  USE THE WEBHOOK BUILDER TO DELETE THIS CLASS
 */
@IsTest
public class APTKHookedContactTriggerTest {
  @IsTest
  public static void testTrigger() {
    try { insert new Contact(); } catch(Exception e) { System.debug(e); }
  }
}