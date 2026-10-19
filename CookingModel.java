import java.util.*;

/** Level 2: the recipe's major stages are a real FIFO queue, independent of UI. */
public class CookingModel {
  public static final int LIMIT_MS=300000;
  public enum Mode { DROP, GESTURE, HEAT }
  public enum FoodState { RAW, PREPARED, COOKED }
  public static class Action {
    public final String source,target,output;
    public final Mode mode;
    public final int repetitions,duration;
    public final boolean consume;
    public int progress=0;
    public Action(String source,String target,String output,Mode mode,int repetitions,int duration,boolean consume){
      this.source=source;this.target=target;this.output=output;this.mode=mode;
      this.repetitions=repetitions;this.duration=duration;this.consume=consume;
    }
    public boolean done(){return progress>=repetitions;}
  }
  public static class CookingStep {
    public final String name;
    public final List<Action> actions=new ArrayList<Action>();
    public CookingStep(String name){this.name=name;}
    public Action nextAction(){for(Action a:actions)if(!a.done())return a;return null;}
  }
  public final Queue<CookingStep> cookingQueue=new ArrayDeque<CookingStep>();
  public final List<CookingStep> recipe=new ArrayList<CookingStep>();
  public final List<String> dequeued=new ArrayList<String>();
  public final Set<String> prepared=new LinkedHashSet<String>();
  public final Map<String,FoodState> foodStates=new LinkedHashMap<String,FoodState>();
  public final Map<String,String> equipment=new LinkedHashMap<String,String>();
  public final Map<String,String> work=new LinkedHashMap<String,String>();
  public final Map<String,Integer> contents=new LinkedHashMap<String,Integer>();
  public final boolean[] completed=new boolean[5];
  public final int[] bestStars=new int[5];
  public int dish=-1,remainingMs=LIMIT_MS,heatElapsed=0,gestureElapsed=0,lastStars=0,equipmentResets=0;
  public boolean searching=false,failed=false,heating=false,gesturing=false,tutorialSeen=false;
  public String lastDequeued="",feedback="";
  public static final String[] DISHES={"Spaghetti","Fried Chicken","Lumpia","Peach Mango Pie","Burger"};
  public static final Set<String> TOOLS=new HashSet<String>(Arrays.asList("board","knife","pan","pot","bowl","plate","spoon","fork","strainer","brush","tray"));
  public static final Set<String> RAW=new HashSet<String>(Arrays.asList("onion","garlic","hotdogs","meatballs","tomato_can","milk","oil","pasta","water","chicken","buttermilk","flour","cornstarch","salt","garlic_powder","pepper","pork","white_onion","carrot","scallions","egg","wrapper","mango","peach","syrup","sugar","lemon","cinnamon","pastry","lettuce","tomato","pickles","mayo","ketchup","mustard","buns"));
  public boolean unlocked(int index){return index>=0&&index<5&&(index==0||completed[index-1]);}
  public boolean startDish(int index){
    if(!unlocked(index))return false;
    dish=index;remainingMs=LIMIT_MS;heatElapsed=0;gestureElapsed=0;lastStars=0;failed=false;searching=false;heating=false;gesturing=false;
    cookingQueue.clear();recipe.clear();dequeued.clear();prepared.clear();foodStates.clear();equipment.clear();work.clear();contents.clear();
    equipmentResets=0;lastDequeued="";feedback="";
    CookingRecipes.build(this,index);
    for(CookingStep step:recipe)cookingQueue.offer(step);
    return true;
  }
  public CookingStep front(){return cookingQueue.peek();}
  public Action action(){return front()==null?null:front().nextAction();}
  public boolean available(String id){return TOOLS.contains(id)||rawInStorage(id)||prepared.contains(id);}
  public boolean rawInStorage(String id){
    if(!RAW.contains(id)||work.containsValue(id))return false;
    for(CookingStep step:cookingQueue)for(Action a:step.actions)
      if(!a.done()&&a.source.equals(id))return true;
    return false;
  }
  public boolean inStorage(String id){
    return TOOLS.contains(id)?!equipment.containsKey(id):rawInStorage(id);
  }
  public List<String> storedIngredients(){
    Set<String> remaining=new LinkedHashSet<String>();
    for(CookingStep step:cookingQueue)for(Action a:step.actions)
      if(!a.done()&&RAW.contains(a.source))remaining.add(a.source);
    remaining.removeAll(work.values());
    return new ArrayList<String>(remaining);
  }
  public void begin(){if(dish>=0&&!failed&&!complete())searching=true;}
  public boolean complete(){return dish>=0&&cookingQueue.isEmpty()&&dequeued.size()==5;}
  public boolean perform(String source,String target,boolean gesture){
    Action a=action();
    if(!searching||failed||heating||gesturing||a==null||a.mode==Mode.HEAT)return false;
    if(!a.source.equals(source)||!a.target.equals(target)||!available(source)||(a.mode==Mode.GESTURE&&!gesture)){
      feedback="Follow the highlighted cooking action.";return false;
    }
    if(a.mode==Mode.GESTURE){
      equipment.put(source,target);gesturing=true;gestureElapsed=0;return true;
    }
    a.progress++;
    if(TOOLS.contains(source))equipment.put(source,target);
    else if(isContainer(target)){contents.put(target,contents.getOrDefault(target,0)+1);work.remove(target);}
    else work.put(target,source);
    if(!a.done())return true;
    finishAction(a);return true;
  }
  public boolean startHeat(){
    Action a=action();if(!searching||failed||heating||gesturing||a==null||a.mode!=Mode.HEAT)return false;
    heating=true;heatElapsed=0;return true;
  }
  public void tick(int elapsed,boolean paused){
    if(paused||!searching||failed||complete()||elapsed<=0)return;
    remainingMs=(int)Math.max(0L,(long)remainingMs-elapsed);
    if(remainingMs==0){failed=true;searching=false;heating=false;gesturing=false;feedback="TIME'S UP!";return;}
    if(gesturing){
      Action a=action();gestureElapsed=(int)Math.min(a.duration,(long)gestureElapsed+elapsed);
      if(gestureElapsed>=a.duration){gesturing=false;a.progress=a.repetitions;finishAction(a);}
      return;
    }
    if(heating){
      Action a=action();heatElapsed=(int)Math.min(a.duration,(long)heatElapsed+elapsed);
      if(heatElapsed>=a.duration){heating=false;a.progress=a.repetitions;finishAction(a);}
    }
  }
  private void finishAction(Action a){
    if(a.consume&&!RAW.contains(a.source)&&!TOOLS.contains(a.source)){prepared.remove(a.source);foodStates.remove(a.source);}
    if(!a.output.isEmpty()){
      prepared.add(a.output);work.remove(a.target);
      // A filled wrapper replaces the wrapper already laid on the tray.
      if(RAW.contains(a.target))work.values().removeIf(value->value.equals(a.target));
      foodStates.put(a.output,a.mode==Mode.HEAT||a.output.startsWith("dish_")||a.output.startsWith("drained_")||a.output.equals("mixed_spaghetti")?FoodState.COOKED:FoodState.PREPARED);
    }
    CookingStep head=front();
    if(head!=null&&head.nextAction()==null){
      CookingStep removed=cookingQueue.poll();
      lastDequeued=removed.name;dequeued.add(removed.name);
      equipment.clear();work.clear();contents.clear();equipmentResets++;
      // Keep only prepared food referenced by a later action, plus the completed dish.
      Set<String> needed=new HashSet<String>();
      for(CookingStep future:cookingQueue)for(Action next:future.actions)needed.add(next.source);
      prepared.removeIf(id->!needed.contains(id)&&!id.startsWith("dish_"));
      foodStates.keySet().retainAll(prepared);
      if(complete()){
        searching=false;completed[dish]=true;lastStars=remainingMs>=180000?3:remainingMs>=60000?2:1;
        bestStars[dish]=Math.max(bestStars[dish],lastStars);
      }
    }
  }
  public static boolean isContainer(String target){return target.equals("pan")||target.equals("pot")||target.equals("bowl");}
  public int progressMask(){int mask=0;for(int i=0;i<5;i++)if(completed[i])mask|=1<<i;return mask;}
  public void restore(int mask){boolean previous=mask>=0;for(int i=0;i<5;i++){completed[i]=previous&&(mask&(1<<i))!=0;previous=completed[i];if(!completed[i])bestStars[i]=0;}}
}
