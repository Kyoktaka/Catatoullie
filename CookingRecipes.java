/** Shared action vocabulary; every dish supplies five FIFO stages. */
public class CookingRecipes {
  static CookingModel.CookingStep step(CookingModel m,String name){CookingModel.CookingStep s=new CookingModel.CookingStep(name);m.recipe.add(s);return s;}
  static void drop(CookingModel.CookingStep s,String item,String target){drop(s,item,target,"",false);}
  static void drop(CookingModel.CookingStep s,String item,String target,String result,boolean consume){s.actions.add(new CookingModel.Action(item,target,result,CookingModel.Mode.DROP,1,0,consume));}
  static void gesture(CookingModel.CookingStep s,String tool,String target,String result){
    int duration=tool.equals("spoon")?1250:tool.equals("knife")?900:1000;
    s.actions.add(new CookingModel.Action(tool,target,result,CookingModel.Mode.GESTURE,1,duration,false));
  }
  static void heat(CookingModel.CookingStep s,String result){s.actions.add(new CookingModel.Action("heat","stove",result,CookingModel.Mode.HEAT,1,2500,false));}
  static void chop(CookingModel.CookingStep s,String raw,String result){drop(s,raw,"board");gesture(s,"knife","board",result);}
  static void setup(CookingModel.CookingStep s){drop(s,"board","prep");drop(s,"knife","prep");}
  static void pan(CookingModel.CookingStep s){drop(s,"pan","stove");drop(s,"oil","pan");}
  static void serve(CookingModel.CookingStep s,String food,String dish){drop(s,"plate","serve");drop(s,food,"plate",dish,true);}
  public static void build(CookingModel m,int dish){
    CookingModel.CookingStep s;
    if(dish==0){
      s=step(m,"Prepare aromatics and meats");setup(s);chop(s,"onion","chopped_onion");chop(s,"garlic","chopped_garlic");chop(s,"hotdogs","sliced_hotdogs");
      s=step(m,"Prepare the sauce");pan(s);drop(s,"chopped_onion","pan","",true);drop(s,"chopped_garlic","pan","",true);drop(s,"sliced_hotdogs","pan","",true);drop(s,"meatballs","pan");drop(s,"tomato_can","pan");drop(s,"milk","pan");gesture(s,"spoon","pan","");heat(s,"cooked_sauce");
      s=step(m,"Cook the pasta");drop(s,"pot","sink");drop(s,"water","pot");drop(s,"pot","stove");drop(s,"pasta","pot");heat(s,"boiled_pasta");drop(s,"strainer","pot","drained_pasta",false);
      s=step(m,"Combine pasta and sauce");drop(s,"bowl","prep");drop(s,"drained_pasta","bowl","",true);drop(s,"cooked_sauce","bowl","",true);gesture(s,"spoon","bowl","mixed_spaghetti");
      s=step(m,"Plate and serve");serve(s,"mixed_spaghetti","dish_spaghetti");
    }else if(dish==1){
      s=step(m,"Marinate the chicken");drop(s,"bowl","prep");drop(s,"buttermilk","bowl");drop(s,"chicken","bowl","marinated_chicken",false);
      s=step(m,"Bread the chicken");drop(s,"bowl","prep");for(String id:new String[]{"flour","cornstarch","salt","garlic_powder","pepper"})drop(s,id,"bowl");gesture(s,"spoon","bowl","seasoned_flour");drop(s,"tray","prep");drop(s,"seasoned_flour","tray","",true);drop(s,"marinated_chicken","tray","coated_chicken",true);
      s=step(m,"Heat the oil");pan(s);heat(s,"hot_oil");
      s=step(m,"Fry the chicken");drop(s,"pan","stove");drop(s,"hot_oil","pan","",true);drop(s,"coated_chicken","pan","frying_chicken",true);heat(s,"fried_chicken");
      s=step(m,"Plate and serve");drop(s,"strainer","prep");drop(s,"fried_chicken","strainer","drained_chicken",true);serve(s,"drained_chicken","dish_chicken");
    }else if(dish==2){
      s=step(m,"Prepare the vegetables");setup(s);chop(s,"white_onion","diced_white_onion");chop(s,"carrot","diced_carrot");chop(s,"garlic","chopped_garlic");chop(s,"scallions","chopped_scallions");
      s=step(m,"Mix the filling");drop(s,"bowl","prep");for(String id:new String[]{"pork","diced_white_onion","diced_carrot","chopped_garlic","chopped_scallions","egg"})drop(s,id,"bowl","",!CookingModel.RAW.contains(id));gesture(s,"spoon","bowl","lumpia_filling");
      s=step(m,"Wrap and seal");drop(s,"tray","prep");drop(s,"bowl","prep");drop(s,"water","bowl");
      for(int roll=0;roll<3;roll++){drop(s,"wrapper","tray");drop(s,"lumpia_filling","wrapper","filled_wrapper",false);drop(s,"filled_wrapper","prep","rolled_lumpia",true);gesture(s,"brush","wrapper",roll==2?"sealed_lumpia":"");}
      s=step(m,"Fry the lumpia");pan(s);drop(s,"sealed_lumpia","pan","frying_lumpia",true);heat(s,"fried_lumpia");
      s=step(m,"Plate and serve");drop(s,"strainer","prep");drop(s,"fried_lumpia","strainer","drained_lumpia",true);serve(s,"drained_lumpia","dish_lumpia");
    }else if(dish==3){
      s=step(m,"Prepare fruit filling");setup(s);chop(s,"mango","diced_mango");chop(s,"peach","diced_peach");pan(s);drop(s,"diced_mango","pan","",true);drop(s,"diced_peach","pan","",true);for(String id:new String[]{"syrup","sugar","lemon","cinnamon","salt","cornstarch","water"})drop(s,id,"pan");gesture(s,"spoon","pan","");heat(s,"fruit_filling");
      s=step(m,"Prepare the pastry");setup(s);drop(s,"pastry","board");gesture(s,"knife","board","cut_pastry");drop(s,"bowl","prep");drop(s,"egg","bowl");gesture(s,"fork","bowl","egg_wash");
      s=step(m,"Assemble and seal");drop(s,"tray","prep");drop(s,"cut_pastry","tray","",true);drop(s,"fruit_filling","pastry","filled_pastry",true);drop(s,"egg_wash","pastry","",true);gesture(s,"brush","pastry","");gesture(s,"fork","pastry","sealed_pie");
      s=step(m,"Cook the pies");pan(s);drop(s,"sealed_pie","pan","frying_pie",true);heat(s,"fried_pie");
      s=step(m,"Plate and serve");drop(s,"strainer","prep");drop(s,"fried_pie","strainer","drained_pie",true);serve(s,"drained_pie","dish_pie");
    }else if(dish==4){
      s=step(m,"Prepare the vegetables");setup(s);chop(s,"tomato","sliced_tomato");chop(s,"onion","sliced_onion");chop(s,"pickles","sliced_pickles");drop(s,"lettuce","sink","washed_lettuce",false);
      s=step(m,"Prepare the patty");drop(s,"bowl","prep");for(String id:new String[]{"pork","egg","salt","pepper"})drop(s,id,"bowl");gesture(s,"spoon","bowl","patty_mix");drop(s,"tray","prep");drop(s,"patty_mix","tray","raw_patty",true);
      s=step(m,"Cook the patty");pan(s);drop(s,"raw_patty","pan","",true);heat(s,"cooked_patty");
      s=step(m,"Prepare buns and sauce");drop(s,"pan","stove");drop(s,"buns","pan");heat(s,"toasted_buns");drop(s,"bowl","prep");drop(s,"mayo","bowl");drop(s,"ketchup","bowl");drop(s,"mustard","bowl");gesture(s,"spoon","bowl","burger_sauce");
      s=step(m,"Assemble and serve");drop(s,"plate","serve");drop(s,"toasted_buns","plate","bottom_bun",true);drop(s,"burger_sauce","plate","",true);for(String id:new String[]{"cooked_patty","washed_lettuce","sliced_tomato","sliced_onion","sliced_pickles"})drop(s,id,"plate","",true);drop(s,"bottom_bun","plate","dish_burger",true);
    }
  }
}
