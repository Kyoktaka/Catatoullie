// Supplied ingredient PNGs retain their alpha and illustrated depth.
PImage[] foodArt=new PImage[0];
int foodMission=-1;
final float ITEM_SIZE=174;
void ensureFoodArt(int mission){
  if(mission<0||mission>=GameModel.RECIPES.length||mission==foodMission)return;
  foodMission=mission;foodArt=new PImage[GameModel.RECIPES[mission].length];
  try{
    JSONArray paths=loadJSONArray(dataPath("ingredient-assets.json")).getJSONArray(mission);
    for(int i=0;i<min(foodArt.length,paths.size());i++){
      PImage art=sprite(paths.getString(i));
      if(art!=null&&max(art.width,art.height)>320){float scale=320.0/max(art.width,art.height);art.resize(max(1,round(art.width*scale)),max(1,round(art.height*scale)));}
      foodArt[i]=art;
    }
  }catch(Exception unavailable){println("Ingredient art unavailable: "+unavailable.getMessage());notifyPlayer("Ingredient art unavailable. Check the data folder.");}
}
void ingredientArt(GameModel.Item item,float cx,float cy,float size){
  if(item==null)return;
  PImage art=null;
  if(item.required){
    ensureFoodArt(model.missionIndex);int index=item.id-model.missionIndex*100;
    if(index>=0&&index<foodArt.length)art=foodArt[index];
  }else art=item.name.equals("Banana Peel")?bananaImg:item.name.equals("Fish Bones")?bonesImg:bottleImg;
  pushStyle();noStroke();fill(0,50);ellipse(cx+3,cy+size*.36,size*.78,size*.19);
  containImage(art,cx-size/2,cy-size/2,size,size);popStyle();
}
