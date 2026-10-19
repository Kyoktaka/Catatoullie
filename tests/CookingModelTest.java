import java.util.*;
public class CookingModelTest {
  static int checks;
  static PreparedLayout layout=new PreparedLayout();
  static void check(boolean condition,String message){checks++;if(!condition)throw new AssertionError(message);}
  static void action(CookingModel m){
    CookingModel.CookingStep front=m.front();CookingModel.Action a=m.action();
    int size=m.cookingQueue.size(),done=m.dequeued.size(),progress=a.progress;
    check(!m.perform("wrong",a.target,true),"Wrong source cannot complete an action");
    check(!m.perform(a.source,"wrong",true),"Wrong destination rejected");
    check(m.front()==front&&m.cookingQueue.size()==size&&a.progress==progress,"Failed actions leave FIFO intact");
    if(a.mode==CookingModel.Mode.HEAT){
      check(!m.perform(a.source,a.target,true),"Cooking requires burner control");
      check(m.startHeat(),"Start active cooking action");check(!m.startHeat(),"Repeated burner click cannot restart cooking");
      m.tick(a.duration-1,false);check(m.action()==a&&!a.done(),"Cooking waits for its duration");
      int heat=m.heatElapsed,time=m.remainingMs;m.tick(10000,true);check(m.heatElapsed==heat&&m.remainingMs==time,"Pause freezes heat and dish timer");
      m.tick(1,false);
    }else{
      if(a.mode==CookingModel.Mode.GESTURE)check(!m.perform(a.source,a.target,false),"Tool action requires a drag gesture");
      check(m.available(a.source),"Dependencies preserved for "+a.source);
      check(m.perform(a.source,a.target,true),"Valid interaction accepted");
      if(a.mode==CookingModel.Mode.GESTURE){
        check(m.gesturing&&!a.done()&&m.action()==a,"One utensil drag starts animation without advancing recipe");
        check(!m.perform(a.source,a.target,true)&&!m.startHeat(),"Busy action cannot be restarted or skipped");
        int time=m.remainingMs;m.tick(10000,true);
        check(m.gestureElapsed==0&&m.remainingMs==time,"Pause freezes utensil animation and timer");
        m.tick(a.duration-1,false);check(!a.done()&&m.action()==a,"Output waits until utensil animation ends");
        m.tick(1,false);check(a.done()&&!m.gesturing,"Animation completes action exactly once");
      }
    }
    if(CookingModel.isContainer(a.target)&&!CookingModel.TOOLS.contains(a.source)&&m.front()==front){
      check(!m.work.containsKey(a.target),"Ingredient packaging disappears inside cookware");
    }
    check(m.dequeued.size()-done<=1,"An action polls at most one major stage");
    check(m.cookingQueue.size()+m.dequeued.size()==5,"Queue conservation");
    Map<String,float[]> previous=new HashMap<String,float[]>();
    for(String id:m.prepared){float[] b=layout.bounds(id);if(b!=null)previous.put(id,b);}
    layout.sync(m.prepared);
    for(String id:m.prepared){
      float[] b=layout.bounds(id);check(b!=null&&b[0]>=298&&b[0]+b[2]<=948&&b[1]+b[3]<620,"Prepared tray stays clear of board and cookware");
      if(previous.containsKey(id))check(Arrays.equals(b,previous.get(id)),"Unconsumed ingredient keeps its tray position");
      for(String other:m.prepared)if(!other.equals(id)){
        float[] c=layout.bounds(other);check(b[0]+b[2]<=c[0]||c[0]+c[2]<=b[0],"Prepared ingredients never overlap");
      }
    }
    if(m.front()!=front){
      check(m.dequeued.size()==done+1&&m.lastDequeued.equals(front.name),"Only the completed front stage leaves");
      check(m.equipment.isEmpty()&&m.work.isEmpty(),"Temporary equipment resets at each stage");
    }
  }
  public static void main(String[] args){
    WardrobeInventory wardrobe=new WardrobeInventory();
    for(int i=0;i<5;i++)wardrobe.restoreReward(i,4+i,4+i);
    Set<Integer> awardedHats=new HashSet<Integer>(),awardedAccessories=new HashSet<Integer>();
    Random random=new Random(42);
    CookingModel m=new CookingModel();check(!m.startDish(1)&&!m.startDish(-1)&&!m.startDish(5),"Locked and invalid dishes rejected");
    for(int dish=0;dish<5;dish++){
      layout.clear();check(m.startDish(dish),"Sequential dish available");check(m.cookingQueue instanceof ArrayDeque,"Actual ArrayDeque implementation");
      check(m.cookingQueue.size()==5&&m.remainingMs==300000,"Five stages and five minutes");
      if(dish==2){long wrappers=m.recipe.get(2).actions.stream().filter(a->a.source.equals("wrapper")).count();check(wrappers==3,"Wrap exactly three lumpia");}
      m.tick(999999,false);check(m.remainingMs==300000,"Tutorial time not counted");
      CookingModel.Action first=m.action();check(!m.perform(first.source,first.target,true),"Preparation cannot advance queue");
      m.begin();int guard=0;
      while(!m.complete()){check(++guard<300,"Every recipe terminates");action(m);}
      check(m.cookingQueue.isEmpty()&&m.dequeued.size()==5&&m.equipmentResets==5,"Exactly five FIFO polls and resets");
      for(int i=0;i<5;i++)check(m.dequeued.get(i).equals(m.recipe.get(i).name),"Offer order equals poll order");
      check(m.completed[dish]&&m.bestStars[dish]==3&&!m.searching,"Success unlocks next dish and stops timer");
      check(m.prepared.contains(new String[]{"dish_spaghetti","dish_chicken","dish_lumpia","dish_pie","dish_burger"}[dish]),"Completed artwork state exists");
      check(wardrobe.awardCooking(m,random),"New completed dish grants a reward");
      int hat=wardrobe.cookingRewardHats[dish],accessory=wardrobe.cookingRewardAccessories[dish];
      check(hat>=9&&accessory>=9,"Cooking avoids previously owned Level 1 rewards");
      check(awardedHats.add(hat)&&awardedAccessories.add(accessory),"Cooking rewards are distinct");
      check(!wardrobe.awardCooking(m,random),"Dish replays cannot farm duplicate rewards");
      int remaining=m.remainingMs;m.tick(Integer.MAX_VALUE,false);check(m.remainingMs==remaining,"Victory timer frozen");
      check(!m.perform("plate","serve",true)&&!m.startHeat(),"Repeated completion cannot poll again");
    }
    check(m.progressMask()==31,"All five dishes completed");
    m.startDish(0);m.begin();action(m);m.tick(300000,false);check(m.failed&&!m.searching&&m.remainingMs==0,"Exact timeout");
    check(!m.perform(m.action().source,m.action().target,true),"Cannot act after timeout");
    check(m.startDish(0)&&m.cookingQueue.size()==5&&m.prepared.isEmpty()&&m.foodStates.isEmpty()&&m.equipment.isEmpty(),"Retry resets attempt");
    check(m.progressMask()==31,"Retry preserves earned progression");
    WardrobeInventory restored=new WardrobeInventory();
    for(int i=0;i<5;i++)restored.restoreReward(i,4+i,4+i);
    for(int i=0;i<5;i++){
      restored.restoreCookingReward(i,wardrobe.cookingRewardHats[i],wardrobe.cookingRewardAccessories[i]);
      check(restored.cookingClaimed[i]&&restored.hats[wardrobe.cookingRewardHats[i]]&&restored.accessories[wardrobe.cookingRewardAccessories[i]],"Cooking rewards restore independently of level completion");
    }
    CookingModel fresh=new CookingModel();check(!wardrobe.awardCooking(fresh,random),"Unfinished dish grants no reward");fresh.startDish(0);fresh.begin();fresh.tick(Integer.MAX_VALUE,false);check(!fresh.completed[0]&&!fresh.unlocked(1),"Failure grants no unlock");
    CookingModel expiry=new CookingModel();expiry.startDish(0);expiry.begin();
    while(expiry.action().mode!=CookingModel.Mode.GESTURE)action(expiry);
    expiry.perform(expiry.action().source,expiry.action().target,true);expiry.remainingMs=1;
    expiry.tick(1,false);check(expiry.failed&&!expiry.gesturing&&!expiry.prepared.contains("chopped_onion"),"Timeout cancels animation before producing food");
    expiry.startDish(0);check(!expiry.gesturing&&expiry.gestureElapsed==0,"Retry clears animation state");
    CookingModel persistence=new CookingModel();persistence.restore(31);check(persistence.progressMask()==31,"Restores all unlocked dishes");persistence.restore(10);check(persistence.progressMask()==0,"Rejects noncontiguous progress");
    System.out.println("CookingModelTest passed: "+checks+" checks.");
  }
}
