boolean confirmProgressReset=false;
void openWorldSelection(){
  finishAvatarDrag();stopIntroMedia();stopEndingMovie();clearKitchenInput();particles.clear();kitchenPops.clear();
  kitchenPaused=false;paused=false;showHelp=false;resetPaws();
  screen=WORLD_SELECT;saveProgress();
}
int totalStars(int[] ratings){int total=0;for(int value:ratings)total+=value;return total;}
boolean levelPerfect(int level){
  if(level==2)return meal.completed&&meal.bestStars==3;
  if(level==0&&model.completedCount()!=5||level==1&&cooking.progressMask()!=31||level<0||level>1)return false;
  int[] ratings=level==0?model.bestStars:cooking.bestStars;
  for(int rating:ratings)if(rating!=3)return false;
  return true;
}
void drawLevelBorder(int level,float x,float y,float w,float h){
  pushStyle();noFill();boolean perfect=levelPerfect(level);
  stroke(perfect?GOLD:0xff4d5966);strokeWeight(perfect?3:1);rect(x,y,w,h,7);popStyle();
}
void drawLevelRating(int level,float x,float y){
  if(level==2){containImage(starImg,x-103,y-10,20,20);fittedLabel(meal.bestStars+" / 3  ·  "+tr(meal.completed?"COMPLETED":"IN PROGRESS"),x+12,y,13,245,GOLD);return;}
  if(level>2)return;
  int stars=totalStars(level==0?model.bestStars:cooking.bestStars);
  boolean done=level==0?model.completedCount()==5:cooking.progressMask()==31;
  containImage(starImg,x-103,y-10,20,20);
  fittedLabel(stars+" / 15  ·  "+tr(done?"COMPLETED":"IN PROGRESS"),x+12,y,13,245,GOLD);
}
void drawResetConfirmation(){
  pushStyle();noStroke();fill(INK,225);rect(0,0,width,height);
  panel(310,220,660,280);title("RESET PROGRESS",640,265,28,INK);
  fittedLabel("Restart all levels. Keep all wardrobe rewards.",640,326,18,600,INK);
  button("CANCEL",400,408,220,46,true);button("RESET PROGRESS",660,408,220,46,true);popStyle();
}
void resetLevelProgress(){
  stopIntroMedia();stopEndingMovie();model=new GameModel();cooking=new CookingModel();meal=new MealModel();mealHeld=null;
  kitchenHeld="";kitchenPaused=false;paused=false;showHelp=false;resetPaws();
  placedOrder.clear();particles.clear();kitchenPops.clear();newReward=false;toastUntil=0;
  // Wardrobe inventory, reward records, equipped cosmetics and preferences survive.
  saveProgress();playUiSound();
}
