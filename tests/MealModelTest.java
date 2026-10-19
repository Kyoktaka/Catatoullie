import java.util.*;
public class MealModelTest {
 static int checks;
 static void check(boolean ok,String why){checks++;if(!ok)throw new AssertionError(why);}
 static void permutations(List<MealModel.Dish> order,List<MealModel.Dish> rest){
  if(!rest.isEmpty()){for(MealModel.Dish dish:rest){List<MealModel.Dish> next=new ArrayList<>(rest);next.remove(dish);order.add(dish);permutations(order,next);order.remove(order.size()-1);}return;}
  MealModel m=new MealModel();m.begin();
  for(MealModel.Dish dish:order){int before=m.size(),hearts=m.hearts;boolean allowed=m.active()&&dish.ordinal()==before;
   check(m.place(dish,true)==allowed,"Only chronological placement accepted");check(m.size()==before+(allowed?1:0),"Rejected push preserves stack");check(m.hearts==(hearts==0?0:allowed?hearts:hearts-1),"One penalty per wrong placement");}
 }
 public static void main(String[] args){
  permutations(new ArrayList<>(),new ArrayList<>(Arrays.asList(MealModel.Dish.values())));
  MealModel m=new MealModel();check(m.remainingMs==30000&&m.hearts==3,"Initial values");m.tick(99999);check(m.remainingMs==30000,"Intro does not tick");m.begin();m.tick(1234);
  check(!m.place(MealModel.Dish.PIE,false)&&m.hearts==3,"Empty space cancels freely");m.place(MealModel.Dish.BURGER,true);check(m.remainingMs==28766,"Push does not reset timer");
  check(!m.place(MealModel.Dish.BURGER,true)&&m.size()==1&&m.hearts==3,"No duplicates");m.paused=true;m.tick(50000);check(m.remainingMs==28766&&!m.place(MealModel.Dish.PIE,true),"Pause freezes input and timer");m.paused=false;
  for(int i=1;i<5;i++)m.place(MealModel.Dish.values()[i],true);
  check(m.phase==MealModel.Phase.EATING&&m.top()==MealModel.Dish.SPAGHETTI,"Top is last pushed");m.tick(90000);check(m.remainingMs==28766,"No eating timer");
  check(!m.place(MealModel.Dish.BURGER,true)&&m.size()==5,"Cannot stack during eating");
  check(!m.feed(MealModel.Dish.BURGER,true)&&m.size()==5&&m.hearts==2,"Cannot eat underneath top");
  for(int i=4;i>=0;i--){MealModel.Dish expected=MealModel.Dish.values()[i];check(m.top()==expected,"Peek returns LIFO top");check(m.feed(expected,true),"Top fed");check(m.size()==i,"One pop only");check(!m.feed(m.top(),true),"Animation locks repeated feeding");m.paused=true;int animation=m.animationMs;m.tick(9999);check(m.animationMs==animation,"Pause freezes animation");m.paused=false;m.tick(i==0?2200:800);}
  check(m.completed&&m.phase==MealModel.Phase.COMPLETED&&m.bestStars==2,"Ending completes with earned stars");m.restart();check(m.completed&&m.size()==0&&m.eaten==0&&m.hearts==3&&m.remainingMs==30000,"Retry resets attempt only");
  m.begin();for(int i=0;i<3;i++)m.place(MealModel.Dish.PIE,true);check(m.phase==MealModel.Phase.FAILED&&m.hearts==0&&m.size()==0,"Zero hearts fails");m.tick(99999);check(m.hearts==0,"Hearts nonnegative");
  m.restart();m.begin();m.tick(30001);check(m.remainingMs==0&&m.phase==MealModel.Phase.FAILED,"Timeout clamped");check(!m.place(MealModel.Dish.BURGER,true),"No push after timeout");
  System.out.println("MealModelTest passed: "+checks+" checks");
 }
}
