import java.lang.*;
public class MyFarm {

  private String farmName;
  private int chickens;
  private int cows;
  private int eggCount;
  private int milkCount;

  public MyFarm (String farmName, int chickens, int cows) {
    this.farmName = farmName;
    this.chickens = chickens; this.cows = cows;
    this.eggCount = 5;        this.milkCount = 10;
  }
  public String getFarmName() {  return this.farmName;  }
  public int getChickens()    {  return this.chickens;  }
  public int getCows()        {  return this.cows;      }
  public int getEggCount()    {  return this.eggCount;  }
  public int getMilkCount()   {  return this.milkCount; }
  public boolean isEggEmpty() { 
    if (eggCount > 0) { return false; }
    else {  return true; }
  }
  public boolean isMilkEmpty() {
    if (milkCount > 0) {  return false; }
    else {  return true;  }
  }
}
