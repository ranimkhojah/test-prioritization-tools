import java.lang.*;
public class MyFarm {

  private String farmName;
  private int chickens; private int eggNum;
  private int cows;     private int milkNum;

  public MyFarm (String farmName, int chickens, int cows) {
    this.farmName = farmName;
    this.chickens = chickens; this.cows = cows;
    this.eggNum = 5;        this.milkNum = 10;
  }
  public String getName() { return this.farmName;}
  public int getChickens(){ return this.chickens;}
  public int getCows()    { return this.cows;}
  public int getEggNum()  { return this.eggNum;}
  public int getMilkNum() { return this.milkNum;}
  public boolean isEggEmpty() { 
    if (eggNum > 0) { return false; }
    else            { return true; }
  }
  public boolean isMilkEmpty() {
    if (milkNum > 0) { return false; }
    else             { return true;  }
  }
}
