package motivation;

import java.lang.*;
import static org.junit.*;
import MyFarm;

public class MyFarmTest {
  private static String FARMNAME = "MyFarm";
  private static int CHICKENS = 5;
  private static int COWS = 8;
  private static int EGGCOUNT = 5;
  private static int MILKCOUNT = 10;

  private MyFarm farm;

  @Before public void setUp() {
    farm = new MyFarm(FARMNAME, CHICKENS, COWS);
  }
  @Test public void testFarmName() {
    assertEquals(FARMNAME, farm.getFarmName());
  }
  @Test public void testChickens() {
    assertEquals(CHICKENS, farm.getChickens());
  }
  @Test public void testCows() {
    assertEquals(COWS, farm.getCows());
  }
  @Test public void testEggCount() {
    assertEquals(EGGCOUNT, farm.getEggCount());
  }
  @Test public void testMilkCount() {
    assertEquals(MILKCOUNT, farm.getMilkCount());
  }
  @Test public void testIsEggEmpty() {
    assertFalse(farm.isEggEmpty());
  }
  @Test public void testIsMilkEmpty() {
    assertFalse(farm.isMilkEmpty());
  }
}
