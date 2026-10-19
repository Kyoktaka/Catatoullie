HashMap<String,PImage> kitchenArt=new HashMap<String,PImage>();
HashMap<String,String> kitchenPaths=new HashMap<String,String>();
PImage kitchenBackground;
boolean kitchenAssetsInitialized=false;
String[] dishArtIds={"dish_spaghetti","dish_chicken","dish_lumpia","dish_pie","dish_burger"};
void initKitchenAssets(){
  if(kitchenAssetsInitialized)return;
  kitchenAssetsInitialized=true;
  kitchenBackground=asset("LEVEL2/level-2-background.png");
  try{
    JSONObject map=loadJSONObject(dataPath("LEVEL2/asset-map.json"));
    if(map!=null)for(Object raw:map.keys()){String key=(String)raw;kitchenPaths.put(key,map.getString(key));}
  }catch(Exception unavailable){println("Kitchen asset map unavailable: "+unavailable.getMessage());}
}
PImage kitchenImage(String id){
  initKitchenAssets();if(kitchenArt.containsKey(id))return kitchenArt.get(id);
  String path=kitchenPaths.get(id);PImage art=path==null?null:asset(path);
  if(art!=null){
    art.loadPixels();int corner=art.pixels[0];
    if((corner>>>24)>16){
      // Some supplied sprites have a gray matte. Flood its connected border only.
      // Include partially transparent mattes (the supplied egg uses alpha 200).
      int w=art.width,h=art.height;boolean[] seen=new boolean[w*h];int[] q=new int[w*h];int tail=0;
      for(int x=0;x<w;x++){tail=kitchenMattePixel(x,art,corner,seen,q,tail);tail=kitchenMattePixel((h-1)*w+x,art,corner,seen,q,tail);}
      for(int y=1;y<h-1;y++){tail=kitchenMattePixel(y*w,art,corner,seen,q,tail);tail=kitchenMattePixel(y*w+w-1,art,corner,seen,q,tail);}
      for(int head=0;head<tail;head++){int i=q[head],x=i%w;if(x>0)tail=kitchenMattePixel(i-1,art,corner,seen,q,tail);if(x<w-1)tail=kitchenMattePixel(i+1,art,corner,seen,q,tail);if(i>=w)tail=kitchenMattePixel(i-w,art,corner,seen,q,tail);if(i<w*(h-1))tail=kitchenMattePixel(i+w,art,corner,seen,q,tail);}
      art.format=ARGB;for(int i=0;i<seen.length;i++)if(seen[i])art.pixels[i]=0;art.updatePixels();
    }
    art=trimSprite(art);
    if(max(art.width,art.height)>400){float scale=400.0/max(art.width,art.height);art.resize(max(1,round(art.width*scale)),max(1,round(art.height*scale)));}
  }
  kitchenArt.put(id,art);return art;
}
int kitchenMattePixel(int i,PImage art,int matte,boolean[] seen,int[] q,int tail){
  int c=art.pixels[i];
  if(!seen[i]&&((c>>>24)<16||(abs((c>>16&255)-(matte>>16&255))<=18&&abs((c>>8&255)-(matte>>8&255))<=18&&abs((c&255)-(matte&255))<=18))){seen[i]=true;q[tail++]=i;}
  return tail;
}
void kitchenBackdrop(float shade){
  initKitchenAssets();updateKitchenSceneGeometry();
  cachedBackdrop(kitchenBackground,kitchenSceneX,kitchenSceneY,2012*kitchenSceneScale,1258*kitchenSceneScale,shade);
  noStroke();fill(INK,shade);
}
HashMap<String,String> kitchenLabels=new HashMap<String,String>(),preparedLabels=new HashMap<String,String>();
String kitchenName(String id){
  if(kitchenLabels.isEmpty()){
  String[] keys={"board","knife","pan","pot","bowl","plate","spoon","fork","strainer","brush","tray","prep","serve","sink","stove","onion","garlic","hotdogs","meatballs","tomato_can","milk","oil","pasta","water","chicken","buttermilk","flour","cornstarch","salt","garlic_powder","pepper","pork","white_onion","carrot","scallions","egg","wrapper","mango","peach","syrup","sugar","lemon","cinnamon","pastry","lettuce","tomato","pickles","mayo","ketchup","mustard","buns"};
  String[] names={"Chopping board","Knife","Pan","Pot","Bowl","Plate","Spoon","Fork","Strainer","Brush","Tray","Work area","Serving area","Sink","Stove","Onion","Garlic","Hot Dogs","Meatballs","Tomato Can","Milk","Oil","Pasta","Water Bottle","Chicken","Buttermilk","All-Purpose Flour","Cornstarch","Salt","Garlic Powder","Pepper","Ground Pork","White Onion","Carrots","Scallions","Egg","Lumpia Wrapper","Mangoes","Canned Peach","Peach Syrup","Sugar","Lemon Juice","Ground Cinnamon","Puff Pastry","Lettuce","Tomato","Pickles","Mayo","Ketchup","Mustard","Buns"};
    for(int i=0;i<keys.length;i++)kitchenLabels.put(keys[i],names[i]);
  }
  String name=kitchenLabels.get(id);return tr(name==null?"Prepared food":name);
}
String preparedName(String id){
  if(preparedLabels.isEmpty()){
  String[] keys={"chopped_onion","chopped_garlic","sliced_hotdogs","cooked_sauce","boiled_pasta","drained_pasta","mixed_spaghetti","marinated_chicken","seasoned_flour","coated_chicken","hot_oil","frying_chicken","fried_chicken","drained_chicken","diced_white_onion","diced_carrot","chopped_scallions","lumpia_filling","filled_wrapper","rolled_lumpia","sealed_lumpia","frying_lumpia","fried_lumpia","drained_lumpia","diced_mango","diced_peach","fruit_filling","cut_pastry","egg_wash","filled_pastry","sealed_pie","frying_pie","fried_pie","drained_pie","sliced_tomato","sliced_onion","sliced_pickles","washed_lettuce","patty_mix","raw_patty","cooked_patty","toasted_buns","bottom_bun","burger_sauce"};
  String[] names={"Chopped onion","Chopped garlic","Sliced hot dogs","Cooked sauce","Boiled pasta","Drained pasta","Mixed spaghetti","Marinated chicken","Seasoned flour","Coated chicken","Hot oil","Frying chicken","Fried Chicken","Drained chicken","Diced white onion","Diced carrots","Chopped scallions","Lumpia filling","Filled wrapper","Rolled lumpia","Sealed lumpia","Frying lumpia","Lumpia","Drained lumpia","Diced mango","Diced peach","Fruit filling","Cut pastry","Egg wash","Filled pastry","Sealed pie","Frying pie","Peach Mango Pie","Drained pie","Sliced tomato","Sliced onion","Sliced pickles","Washed lettuce","Patty mixture","Raw patty","Cooked patty","Toasted buns","Bottom bun","Burger sauce"};
    for(int i=0;i<keys.length;i++)preparedLabels.put(keys[i],names[i]);
  }
  if(preparedLabels.containsKey(id))return tr(preparedLabels.get(id));
  for(int i=0;i<dishArtIds.length;i++)if(dishArtIds[i].equals(id))return tr(CookingModel.DISHES[i]);
  return kitchenName(id);
}
