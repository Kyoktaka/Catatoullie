import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.Stack;

/** Level 1 only: timed LIFO scavenging. Ingredients remain uncooked. */
public class GameModel {
  public static final int AVAILABLE=0, COLLECTED=1, SET_ASIDE=2, STAGED=3;
  public static final int LIMIT_MS=120000;
  public static final String[] MISSION_NAMES={"Spaghetti Recipe","Fried-Chicken Recipe","Lompia Recipe","Peach Mango Pie Recipe","Burger Recipe"};
  public static final String[][] RECIPES={
    {"Pasta","Meatballs","Hot Dogs","Tomato Can","Milk","Onion","Garlic","Oil","Cheese"},
    {"Chicken","Buttermilk","All-Purpose Flour","Cornstarch","Salt","Garlic Powder","Pepper","Oil"},
    {"Ground Pork","White Onion","Carrots","Garlic","Scallions","Egg","Lumpia Wrapper","Water Bottle","Oil"},
    {"Mangoes","Canned Peach","Peach Syrup","Sugar","Lemon Juice","Ground Cinnamon","Salt","Cornstarch","Water Bottle","Puff Pastry","Egg","Oil"},
    {"Ground Pork","Salt","Black Pepper","Egg","Lettuce","Tomato","Onion","Pickles","Mayo","Ketchup","Mustard","Buns"}
  };
  public static class Item {
    public final int id;
    public final String name;
    public final boolean required;
    public int state=AVAILABLE;
    public Item(int id,String name,boolean required){this.id=id;this.name=name;this.required=required;}
  }
  public int missionIndex=-1, remainingMs=LIMIT_MS, lastStars=0;
  public boolean searching=false, failed=false;
  public final boolean[] completed=new boolean[5];
  public final int[] bestStars=new int[5];
  public final List<Item> items=new ArrayList<Item>();
  public final List<Item> collected=new ArrayList<Item>();
  public final List<Item> aside=new ArrayList<Item>();
  public final List<Item> staged=new ArrayList<Item>();
  public final Stack<Item> pile=new Stack<Item>();
  public String feedback="Choose a trash can to find ingredients.";

  public boolean unlocked(int index){return index>=0&&index<5&&(index==0||completed[index-1]);}
  public boolean startMission(int index){
    if(!unlocked(index)){feedback="Finish the previous trash can first.";return false;}
    missionIndex=index;remainingMs=LIMIT_MS;lastStars=0;searching=false;failed=false;
    items.clear();collected.clear();aside.clear();staged.clear();pile.clear();
    int id=index*100;
    for(String name:RECIPES[index])items.add(new Item(id++,name,true));
    items.add(new Item(id++,"Banana Peel",false));
    items.add(new Item(id++,"Fish Bones",false));
    items.add(new Item(id++,"Empty Bottle",false));
    Collections.shuffle(items,new Random(7301L+index));
    for(Item item:items)pile.push(item);
    feedback="Read both papers, then start your two-minute search.";
    return true;
  }
  public void beginSearch(){if(missionIndex>=0&&!failed&&!missionComplete())searching=true;}
  public void tick(int elapsedMs){
    if(!searching||failed||missionComplete()||elapsedMs<=0)return;
    remainingMs=(int)Math.max(0L,(long)remainingMs-elapsedMs);
    if(remainingMs==0){failed=true;searching=false;feedback="Time is up! Retry this trash can.";}
  }
  public Item top(){return pile.empty()?null:pile.peek();}
  public boolean collectTop(Item expected){
    if(!validTop(expected))return false;
    if(!expected.required){feedback="Leave that in the can. Set it beside the pile.";return false;}
    if(!isNextIngredient(expected)){
      feedback="Find "+nextIngredientName()+" first. Set "+expected.name+" aside for later.";
      return false;
    }
    pile.pop();return collectIngredient(expected);
  }
  public boolean setAsideTop(Item expected){
    if(!validTop(expected))return false;
    pile.pop();
    if(expected.required){
      boolean next=isNextIngredient(expected);
      expected.state=STAGED;staged.add(expected);
      feedback=next?expected.name+" is next. Pick it up from the side to collect."
        :expected.name+" set aside. Find "+nextIngredientName()+" next.";
    }else{
      expected.state=SET_ASIDE;aside.add(expected);
      feedback=expected.name+" set beside the pile.";
    }
    return true;
  }
  public boolean collectStaged(Item expected){
    if(!validStaged(expected))return false;
    if(!isNextIngredient(expected)){
      feedback="Find "+nextIngredientName()+" first.";
      return false;
    }
    staged.remove(expected);return collectIngredient(expected);
  }
  public boolean isNextIngredient(Item item){
    if(item==null||!item.required||missionIndex<0||collected.size()>=RECIPES[missionIndex].length)return false;
    return RECIPES[missionIndex][collected.size()].equals(item.name);
  }
  public String nextIngredientName(){
    return missionIndex>=0&&collected.size()<RECIPES[missionIndex].length
      ?RECIPES[missionIndex][collected.size()] : "the next ingredient";
  }
  public boolean isStaged(Item item){return item!=null&&staged.contains(item);}
  private boolean collectIngredient(Item expected){
    expected.state=COLLECTED;collected.add(expected);
    feedback=expected.name+" collected - still uncooked.";
    if(missionComplete()){
      searching=false;completed[missionIndex]=true;
      lastStars=remainingMs>=80000?3:remainingMs>=40000?2:1;
      bestStars[missionIndex]=Math.max(bestStars[missionIndex],lastStars);
      feedback="All ingredients collected!";
    }
    return true;
  }
  private boolean validTop(Item item){
    if(!searching||failed||remainingMs<=0){feedback=failed?"Time is up. Retry to search again.":"Start the search first.";return false;}
    if(item==null||item!=top()){feedback="LIFO: only the top item can leave the pile.";return false;}
    return true;
  }
  private boolean validStaged(Item item){
    if(!searching||failed||remainingMs<=0){feedback=failed?"Time is up. Retry this trash can.":"Start the search first.";return false;}
    if(item==null||!staged.contains(item)){feedback="That ingredient is not set aside.";return false;}
    return true;
  }
  public int collectedCount(){return collected.size();}
  public boolean missionComplete(){return missionIndex>=0&&collected.size()==RECIPES[missionIndex].length;}
  public int completedCount(){int count=0;for(boolean b:completed)if(b)count++;return count;}
  public int progressMask(){int mask=0;for(int i=0;i<5;i++)if(completed[i])mask|=1<<i;return mask;}
  public void restoreProgress(int mask){
    boolean previous=mask>=0;
    for(int i=0;i<5;i++){completed[i]=previous&&(mask&(1<<i))!=0;previous=completed[i];bestStars[i]=completed[i]?Math.max(1,bestStars[i]):0;}
  }
}
