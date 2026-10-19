// Level 3 keeps the supplied storyboard composition in a 1280 x 720 canvas.
MealModel meal=new MealModel();
PImage mealRoom,mealPaper,mealQuest,mealTask,mealGame,mealDrool,mealEating,mealFat,mealWrong,mealTop;
PImage[] mealFood=new PImage[5],mealHearts=new PImage[3];
PFont mealFont;
boolean mealAssetsReady=false,mealLists=true,mealSaved=false;
MealModel.Dish mealHeld=null,mealAnimated=null;
float mealGrabX,mealGrabY,mealFeedX,mealFeedY;
float mealOffsetX,mealOffsetY,mealHeldWidth=166,mealHeldHeight=112;
int mealPlacementMs=0;
MealModel.Dish mealSettling=null;
final float[] mealMovingRect=new float[4];
final MealModel.Dish[] mealDishes=MealModel.Dish.values();
final float[][] mealStackRects={{620,645,166,112},{620,584,166,112},{620,523,166,112},{620,462,166,112},{620,401,166,112}};
final float[] mealWaitingCat={500,250,220,285},mealFeedingCat={720,295,215,240},mealFinishedCat={555,270,230,270};
final float[][] mealSources={{255,520,120,96},{1090,612,175,105},{100,550,142,100},{1170,500,164,126},{145,652,142,110}};
final String[] mealNames={"Burger","Peach mango pie","Lumpia","Fried Chicken","Spaghetti"};
void initMealAssets(){
  if(mealAssetsReady)return;
  mealRoom=asset("LEVEL3/eating-bg.png");mealPaper=asset("LEVEL3/paper-list.png");
  mealQuest=asset("LEVEL3/level-info.png");mealTask=sprite("LEVEL3/buttons/Paper-task-list-button.png");mealGame=sprite("LEVEL3/buttons/Game-button.png");
  mealDrool=sprite("LEVEL3/drool-cat.png");mealEating=mealCatSprite("LEVEL3/eating-cat.png");mealFat=mealCatSprite("LEVEL3/fat-cat.png");
  mealWrong=sprite("LEVEL3/wrong-stack-order-banner.png");mealTop=sprite("LEVEL3/top-plate-first-banner.png");
  String[] paths={"cooked-burger.png","cooked-peach-mango-pie.png","Lompia.png","Fried Tsiken.png","cooked-spaghetti.png"};
  for(int i=0;i<5;i++)mealFood[i]=sprite("LEVEL3/cooked-food/"+paths[i]);
  for(int i=0;i<3;i++)mealHearts[i]=asset("LEVEL3/hearts/PLAY (Animated) ("+(4-i)+").png");
  mealFont=createFont("Impact",24,false);mealAssetsReady=true;
}
void enterMeal(){
  if(!level2Unlocked()||cooking.progressMask()!=31)return;
  initMealAssets();clearKitchenInput();particles.clear();kitchenPops.clear();meal.restart();mealHeld=null;mealAnimated=null;mealSettling=null;mealPlacementMs=0;mealLists=true;mealSaved=false;
  screen=LEVEL3_ENTRY;lastTick=millis();
}
void updateMeal(int delta){
  if(!meal.paused)mealPlacementMs=max(0,mealPlacementMs-delta);
  meal.tick(delta);
  if(!meal.active())mealHeld=null;
  if(meal.phase==MealModel.Phase.COMPLETED&&!mealSaved){mealSaved=true;finaleStarted=millis();saveProgress();playMeow();}
}
float[] mealStackBounds(int index){return mealStackRects[index];}
float[] mealCatBounds(){
  boolean finalCat=meal.phase==MealModel.Phase.COMPLETED;
  boolean eating=meal.phase==MealModel.Phase.EATING||meal.phase==MealModel.Phase.ENDING;
  return finalCat?mealFinishedCat:eating?mealFeedingCat:mealWaitingCat;
}
void mealImage(PImage img,float[] b){containImage(img,b[0]-b[2]/2,b[1]-b[3]/2,b[2],b[3]);}
boolean mealSpriteHit(PImage img,float[] b,float x,float y){
  if(img==null)return false;
  float s=min(b[2]/img.width,b[3]/img.height),left=b[0]-img.width*s/2,top=b[1]-img.height*s/2;
  int px=floor((x-left)/s),py=floor((y-top)/s);
  if(px<0||py<0||px>=img.width||py>=img.height)return false;
  return (img.get(px,py)>>>24)>30;
}
void mealText(String value,float x,float y,float size,float maxWidth,int ink){
  pushStyle();textFont(language==3?uiFont:mealFont);fittedLabel(value,x,y,size,maxWidth,ink);popStyle();
}
void mealControl(String value,float x,float y,float w,float h){
  pushStyle();stroke(0xff211c14);strokeWeight(3);fill(hit(x,y,w,h)?0xffffdf55:0xffedcd5e);rect(x,y,w,h);
  mealText(value,x+w/2,y+h/2,22,w-14,0xff211c14);popStyle();
}
void drawMealPanel(boolean eating){
  float x=eating?890:40,y=75,w=330,h=330;
  pushStyle();if(eating&&meal.phase==MealModel.Phase.STACKING)tint(255,175);
  image(mealPaper,x,y,w,h);noTint();
  mealText(eating?"Eating order":"Stack order",x+174,y+25,20,270,INK);
  for(int row=0;row<5;row++){
    int dish=4-row;float cy=y+80+49*row;
    boolean done=eating?meal.eaten>row:meal.eaten>0||meal.size()>dish||meal.phase==MealModel.Phase.EATING||meal.phase==MealModel.Phase.ENDING||meal.phase==MealModel.Phase.COMPLETED;
    mealText(mealNames[dish],x+179,cy,28,240,INK);
    if(row==0||row==4)mealText((row==0)==eating?"start":"end",x+303,cy+15,12,42,INK);
    if(done){stroke(0xff398d35);strokeWeight(3);line(x+25,cy+14,x+32,cy+21);line(x+32,cy+21,x+46,cy+2);stroke(INK);strokeWeight(2);line(x+75,cy+2,x+277,cy+2);}
  }
  if(eating&&(meal.phase==MealModel.Phase.INTRO||meal.phase==MealModel.Phase.STACKING))containImage(lockImg,x+135,y+130,65,85);
  popStyle();
}
void drawLevel3Entry(){
  initMealAssets();if(meal.phase==MealModel.Phase.COMPLETED&&campaignComplete()){drawCampaignEnding();return;}
  pushStyle();imageMode(CORNER);rectMode(CORNER);noTint();image(mealRoom,0,0,width,height);
  image(mealTask,28,18,260,54);
  if(language>0){noStroke();fill(0xffc7c7c7);rect(39,22,232,43);mealText("Full Course Meal",156,43,23,220,INK);}
  if(mealLists){drawMealPanel(false);drawMealPanel(true);}
  if(meal.phase!=MealModel.Phase.INTRO){
    if(meal.hearts>0)image(mealHearts[meal.hearts-1],505,20,205,67);
    if(meal.phase==MealModel.Phase.STACKING)mealText(tr("Stack time")+": "+ceil(meal.remainingMs/1000.0)+"s",607,111,23,240,INK);
  }
  float[] cat=mealCatBounds();
  PImage expression=meal.phase==MealModel.Phase.COMPLETED?mealFat:meal.reactionMs>0||meal.animationMs>0?mealEating:mealDrool;
  containImage(expression,cat[0],cat[1],cat[2],cat[3]);
  if(meal.phase==MealModel.Phase.INTRO||meal.phase==MealModel.Phase.STACKING){
    for(MealModel.Dish dish:mealDishes)if(!meal.contains(dish)&&mealHeld!=dish)mealImage(mealFood[dish.ordinal()],mealSources[dish.ordinal()]);
  }
  for(int i=0;i<meal.size();i++){
    MealModel.Dish dish=meal.at(i);if(dish==mealHeld)continue;
    float[] b=mealStackBounds(i);
    if(dish==mealSettling&&mealPlacementMs>0){
      arrayCopy(b,mealMovingRect);mealMovingRect[1]-=sin(PI*mealPlacementMs/180.0)*7*vfxAmount;mealImage(mealFood[dish.ordinal()],mealMovingRect);
    }else mealImage(mealFood[dish.ordinal()],b);
  }
  if(mealHeld!=null){
    mealMovingRect[0]=mouseX+mealOffsetX;mealMovingRect[1]=mouseY+mealOffsetY;mealMovingRect[2]=mealHeldWidth;mealMovingRect[3]=mealHeldHeight;
    mealImage(mealFood[mealHeld.ordinal()],mealMovingRect);
  }
  if(mealAnimated!=null&&meal.animationMs>0){
    float t=constrain((800-meal.animationMs)/800.0,0,1);
    if(meal.phase==MealModel.Phase.ENDING)t=constrain((2200-meal.animationMs)/800.0,0,1);
    if(t<1){float eased=t*t*(3-2*t),size=1-eased*.8;mealMovingRect[0]=lerp(mealFeedX,cat[0]+cat[2]/2,eased);mealMovingRect[1]=lerp(mealFeedY,cat[1]+cat[3]*.4,eased);mealMovingRect[2]=166*size;mealMovingRect[3]=112*size;mealImage(mealFood[mealAnimated.ordinal()],mealMovingRect);}
  }
  if(meal.reactionMs>0){containImage(meal.phase==MealModel.Phase.STACKING?mealWrong:mealTop,390,150,500,88);if(language>0){noStroke();fill(0xffbd2726);rect(465,170,400,42);mealText(meal.phase==MealModel.Phase.STACKING?"Wrong stack order!":"Top plate first!",665,190,24,390,0xffffefc1);}}
  if(meal.phase==MealModel.Phase.INTRO){image(mealQuest,430,77,430,220);image(mealGame,490,547,235,72);if(language>0){noStroke();fill(0xffffd527);rect(458,98,375,184);mealText("Stack the meal, and then eat to your fill!",645,185,22,365,INK);fill(0xffc7c7c7);rect(508,558,200,51);mealText("PLAY",607,581,25,180,INK);}
    mealControl("LEVELS",475,632,330,50);}
  else if(meal.phase==MealModel.Phase.ENDING){
    float fade=sin(constrain((2200-meal.animationMs)/2200.0,0,1)*PI)*210;
    noStroke();fill(255,fade);rect(0,0,width,height);
  }else if(meal.phase==MealModel.Phase.COMPLETED){mealControl("LEVELS",475,643,330,50);}
  else if(meal.phase==MealModel.Phase.FAILED||meal.paused){
    noStroke();fill(0,135);rect(0,0,width,height);fill(0xffedcd5e);stroke(INK);strokeWeight(4);rect(410,230,460,275);
    mealText(meal.paused?"PAUSED":meal.hearts==0?"No hearts left":"Time is up",640,275,30,430,INK);
    mealControl(meal.paused?"RESUME":"TRY AGAIN",475,320,330,55);mealControl("LEVELS",475,405,330,55);
  }else mealControl("PAUSE",1080,18,170,46);
  popStyle();
}
boolean mealMousePressed(){
  if(screen!=LEVEL3_ENTRY)return false;
  if(meal.phase==MealModel.Phase.INTRO){
    if(hit(490,547,235,72)){meal.begin();lastTick=millis();}
    else if(hit(475,632,330,50))openWorldSelection();
    else if(hit(28,18,260,54))mealLists=!mealLists;
    return true;
  }
  if(meal.phase==MealModel.Phase.COMPLETED){if(campaignComplete()){if(hit(96,566,220,52))goMenu();else if(hit(336,566,220,52))openWorldSelection();}else if(hit(475,643,330,50))openWorldSelection();return true;}
  if(meal.paused||meal.phase==MealModel.Phase.FAILED){
    if(hit(475,320,330,55)){if(meal.paused){meal.paused=false;lastTick=millis();}else enterMeal();}
    else if(hit(475,405,330,55))openWorldSelection();return true;
  }
  if(meal.phase==MealModel.Phase.ENDING)return true;
  if(hit(1080,18,170,46)){meal.paused=true;mealHeld=null;return true;}
  if(hit(28,18,260,54)){mealLists=!mealLists;return true;}
  if(!meal.active())return true;
  mealGrabX=mouseX;mealGrabY=mouseY;
  if(meal.phase==MealModel.Phase.STACKING){
    for(MealModel.Dish dish:mealDishes)if(!meal.contains(dish)&&mealSpriteHit(mealFood[dish.ordinal()],mealSources[dish.ordinal()],mouseX,mouseY)){mealHeld=dish;break;}
  }else{
    for(int i=meal.size()-1;i>=0;i--){
      MealModel.Dish dish=meal.at(i);
      if(mealSpriteHit(mealFood[dish.ordinal()],mealStackBounds(i),mouseX,mouseY)){
        if(dish==meal.top())mealHeld=dish;else{meal.mistake();playMeow();}break;
      }
    }
  }
  if(mealHeld!=null){
    float[] origin=meal.phase==MealModel.Phase.STACKING?mealSources[mealHeld.ordinal()]:mealStackBounds(meal.size()-1);
    mealOffsetX=origin[0]-mouseX;mealOffsetY=origin[1]-mouseY;mealHeldWidth=origin[2];mealHeldHeight=origin[3];
  }
  return true;
}
void mealMouseReleased(){
  if(screen!=LEVEL3_ENTRY||mealHeld==null)return;
  MealModel.Dish selected=mealHeld;mealHeld=null;
  int delta=max(0,millis()-lastTick);lastTick=millis();updateMeal(delta);
  if(!meal.active()||dist(mouseX,mouseY,mealGrabX,mealGrabY)<18)return;
  boolean accepted=false;int hearts=meal.hearts;
  if(meal.phase==MealModel.Phase.STACKING){accepted=meal.place(selected,hit(465,330,310,380));if(accepted){mealSettling=selected;mealPlacementMs=180;}}
  else if(meal.phase==MealModel.Phase.EATING){float[] cat=mealCatBounds();accepted=meal.feed(selected,hit(cat[0],cat[1],cat[2],cat[3]));if(accepted){mealAnimated=selected;mealFeedX=mouseX+mealOffsetX;mealFeedY=mouseY+mealOffsetY;}}
  if(accepted){burst(mouseX,mouseY,18,0xffc08e3a);playUiSound();if(meal.phase!=MealModel.Phase.STACKING)playMeow();}
  else if(hearts!=meal.hearts)playMeow();
}
boolean mealKeyPressed(){
  if(screen!=LEVEL3_ENTRY)return false;
  if(key==ESC){key=0;mealHeld=null;
    if(meal.phase==MealModel.Phase.INTRO||meal.phase==MealModel.Phase.COMPLETED||meal.phase==MealModel.Phase.FAILED)openWorldSelection();
    else if(meal.phase!=MealModel.Phase.ENDING){meal.paused=!meal.paused;lastTick=millis();}
  }
  return true;
}
