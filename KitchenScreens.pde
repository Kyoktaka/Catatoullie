final int COOK_SELECT=14,COOK_TUTORIAL=15,COOK_GAME=16,COOK_SUCCESS=17,COOK_TIMEOUT=18,ENDING_MOVIE=19,LEVEL3_ENTRY=20,WORLD_SELECT=21;
CookingModel cooking=new CookingModel();
PreparedLayout preparedLayout=new PreparedLayout();
boolean kitchenPaused=false,fifoDebug=false;
int kitchenPage=0,tutorialPage=0;
boolean tutorialPractice=false,tutorialDragging=false,tutorialReplay=false;
String kitchenHeld="";
float kitchenGrabX,kitchenGrabY,kitchenTravel=0;
float kitchenOffsetX=-56,kitchenOffsetY=-61,kitchenHeldWidth=112,kitchenHeldHeight=112;
String expectedKitchenSource="";
final String[] kitchenTools={"board","knife","pan","pot","bowl","plate","spoon","fork","strainer","brush","tray"};
final float[] kitchenServingArea={803,625,145,79},kitchenBowlArea={717,625,89,80},kitchenStrainerArea={802,625,145,79},kitchenTrayArea={502,625,210,79},kitchenPrepArea={485,620,235,84};
boolean level2Unlocked(){return model.completedCount()==5;}
void openCookingSelection(){if(!level2Unlocked())return;kitchenHeld="";kitchenPaused=false;screen=COOK_SELECT;}
void startCooking(int dish){
  if(!level2Unlocked()||!cooking.startDish(dish))return;
  clearKitchenInput();particles.clear();kitchenPops.clear();
  kitchenHeld="";kitchenPaused=false;kitchenPage=0;expectedKitchenSource="";preparedLayout.clear();newCookingReward=false;kitchenVisibleStage=0;kitchenStorage=-1;kitchenNote=false;kitchenStove=false;
  initKitchenAssets();
  if(!cooking.tutorialSeen){tutorialPage=0;tutorialPractice=false;tutorialReplay=false;beginKitchenLoading(COOK_TUTORIAL);}
  else beginKitchenLoading(COOK_GAME);
  syncKitchenSource();lastTick=millis();
}
void finishKitchenTutorial(){
  cooking.tutorialSeen=true;tutorialDragging=false;kitchenHeld="";kitchenStorage=-1;kitchenNote=false;kitchenStove=false;screen=COOK_GAME;
  cooking.begin();lastTick=millis();saveProgress();
}
void syncKitchenSource(){
  CookingModel.Action a=cooking.action();String current=a==null?"":a.source;
  if(current.equals(expectedKitchenSource))return;
  expectedKitchenSource=current;
}
float[] kitchenTarget(String id){
  updateKitchenSceneGeometry();
  if((id.equals("pot")||id.equals("pan"))&&"sink".equals(cooking.equipment.get(id)))return kitchenSinkRect;
  if(id.equals("sink"))return kitchenSinkRect;
  if(id.equals("stove")||id.equals("pan")||id.equals("pot"))return kitchenStoveRect;
  if(id.equals("serve")||id.equals("plate"))return kitchenServingArea;
  if(id.equals("bowl"))return kitchenBowlArea;
  if(id.equals("strainer"))return kitchenStrainerArea;
  if(id.equals("tray")||id.equals("wrapper")||id.equals("pastry"))return kitchenTrayArea;
  return kitchenPrepArea;
}
void drawKitchenScreen(){
  if(screen==COOK_LOADING)drawKitchenLoading();else if(screen==WORLD_SELECT)drawWorldSelect();else if(screen==COOK_SELECT)drawCookingSelect();
  else if(screen==COOK_TUTORIAL)drawKitchenTutorial();else if(screen==COOK_GAME)drawKitchenGame();
  else if(screen==COOK_SUCCESS)drawCookingSuccess();else if(screen==COOK_TIMEOUT)drawCookingTimeout();
  else if(screen==ENDING_MOVIE)drawEndingMovie();else if(screen==LEVEL3_ENTRY)drawLevel3Entry();
}
void drawWorldSelect(){
  sceneBackground(bg,160);title("YOUR NEIGHBORHOOD",640,85,32,CREAM);
  for(int i=0;i<3;i++){
    float x=85+i*400;
    if(i==0)containImage(trashIcon,x+90,213,130,172);
    else if(i==1)containImage(kitchenImage("dish_spaghetti"),x+48,230,215,145);
    else if(cooking.progressMask()==31){initMealAssets();containImage(mealFood[0],x+48,230,215,145);}else containImage(lockImg,x+122,250,65,85);
    title("LEVEL "+(i+1),x+155,414,25,CREAM);
    fittedLabel(i==0?"Find the ingredients":i==1?"Cooking Time":"Full Course Meal",x+155,456,18,280,CREAM);
    drawLevelRating(i,x+155,554);
    button("PLAY",x+40,480,230,39,i==0||i==1&&level2Unlocked()||i==2&&cooking.progressMask()==31);
  }
  button("MAIN MENU",35,652,220,44,true);
}
void drawCookingSelect(){
  kitchenBackdrop(0);pushStyle();noStroke();fill(255,155);rect(0,0,width,height);
  stroke(INK);strokeWeight(4);fill(0xfffbd522);rect(410,24,460,65);popStyle();
  title("LEVEL 2: COOKING TIME",640,57,30,INK);
  for(int i=0;i<5;i++){
    float x=i<3?155+i*340:325+(i-3)*340,y=i<3?155:395;
    boolean unlocked=cooking.unlocked(i);
    pushStyle();if(!unlocked)tint(140);containImage(kitchenImage(dishArtIds[i]),x+30,y+4,230,140);noTint();popStyle();
    fittedLabel(CookingModel.DISHES[i],x+145,y+156,21,270,INK);
    if(unlocked){if(hit(x,y,290,210)||!cooking.completed[i])drawDishPlay(x+111,y+50,68);if(cooking.completed[i])for(int s=0;s<cooking.bestStars[i];s++)containImage(starImg,x+93+s*36,y+180,32,30);}
    else containImage(lockImg,x+121,y+49,48,61);
  }
  button("LEVELS",32,658,200,42,true);
}
void drawKitchenObject(String id,float x,float y,float w,float h){
  if(id.equals("bowl")){
    pushStyle();stroke(INK);strokeWeight(3);fill(0xffc8c3a8);arc(x+w/2,y+h*.32,w,h*1.2,0,PI,CHORD);fill(CREAM);ellipse(x+w/2,y+h*.32,w,h*.35);popStyle();
  }else containImage(kitchenImage(id),x,y,w,h);
}
String kitchenActionText(CookingModel.Action a){
  if(a==null)return "";
  if(a.mode==CookingModel.Mode.HEAT)return tr("Click HEAT, then wait for cooking to finish.");
  String item=preparedName(a.source),target=kitchenName(a.target);
  return phrase(a.mode==CookingModel.Mode.GESTURE?"Drag {0} to {1} once, then wait.":"Drag {0} to {1}.",item,target);
}
void drawKitchenGame(){
  kitchenBackdrop(12);syncKitchenSource();drawKitchenCounter();
  pushStyle();noStroke();fill(0xffe8dcc7,240);rect(465,18,545,66,24);popStyle();
  title("LEVEL 2  /  "+CookingModel.DISHES[max(0,cooking.dish)],737,39,23,INK);
  fittedLabel(cooking.front()==null?"":cooking.front().name,737,65,16,510,0xff606c38);
  int seconds=(cooking.remainingMs+999)/1000;menuPanel(1054,18,206,66);
  title(nf(seconds/60,2)+":"+nf(seconds%60,2),1157,48,30,cooking.remainingMs<60000?0xffff8070:CREAM);
  drawKitchenStations();
  button("II",20,551,58,41,true);button("?",88,551,58,41,true);button("MAIN MENU",20,605,256,39,true);
  drawKitchenWork();drawKitchenGesture();
  CookingModel.Action a=cooking.action();
  if(a!=null){
    float[] target=kitchenTarget(a.target);pushStyle();noFill();stroke(GOLD);strokeWeight(3);rect(target[0],target[1],target[2],target[3],7);popStyle();
    pushStyle();noStroke();fill(0xffe8dcc7,240);rect(465,93,545,71,24);popStyle();
    fittedLabel(kitchenActionText(a),737,114,16,510,INK);
    fittedLabel(kitchenName(a.target),target[0]+target[2]/2,target[1]-14,14,target[2]+60,CREAM);
    fittedLabel(a.mode==CookingModel.Mode.GESTURE?(cooking.gesturing?kitchenGestureLabel(a):"Drag once, then wait."):a.mode==CookingModel.Mode.HEAT?(cooking.heating?"COOKING...":"HEAT"):"Click and hold. Drag to the gold outline.",737,145,14,510,0xff606c38);
    if(a.mode==CookingModel.Mode.HEAT){
      button(cooking.heating?"COOKING...":"HEAT",309,494,167,39,!cooking.heating);
      if(cooking.heating){noStroke();fill(GOLD);rect(309,537,167*cooking.heatElapsed/(float)a.duration,7,3);
        for(int i=0;i<5;i++){fill(CREAM,110*vfxAmount);float y=425-(millis()*.03+i*22)%80;ellipse(341+i*23,y,6,13);}
      }
    }
  }
  if(cooking.gesturing){
    CookingModel.Action active=cooking.action();pushStyle();noStroke();fill(0xff8b9d83);
    rect(477,156,510*cooking.gestureElapsed/(float)active.duration,4,2);popStyle();
  }
  drawPreparedShelf();
  if(!kitchenHeld.isEmpty())drawKitchenHeld();else drawKitchenRightHand(922,590);
  if(fifoDebug)drawFifoDebug();
  if(kitchenNote)drawKitchenNote();
  if(kitchenStorage>=0){drawKitchenStorage();drawKitchenRightHand(constrain(mouseX,330,980),constrain(mouseY,185,605));}
  if(kitchenStove)drawKitchenStove();
  if(kitchenPaused)drawKitchenPause();
}
float[] kitchenEquipmentBounds(String id){
  String location=cooking.equipment.get(id);float[] t=kitchenTarget(location==null?"prep":location.equals("prep")?id:location);
  if(id.equals("board"))return new float[]{t[0],t[1]+17,t[2],67};
  if(id.equals("knife"))return new float[]{t[0]+t[2]-45,t[1]-4,45,80};
  if(id.equals("brush")||id.equals("fork"))return new float[]{t[0]+t[2]-43,t[1]-6,36,73};
  return new float[]{t[0]+8,t[1]-10,min(t[2]-12,145),min(t[3]+15,108)};
}
void drawKitchenWork(){
  // All coordinates use the same window space as the aspect-preserving backdrop.
  for(Map.Entry<String,String> e:cooking.equipment.entrySet()){
    if(e.getKey().equals("tray")&&kitchenGestureFood().equals("rolled_lumpia"))continue;
    if(e.getKey().equals(kitchenHeld)||(cooking.gesturing&&e.getKey().equals(expectedKitchenSource)))continue;
    float[] b=kitchenEquipmentBounds(e.getKey());
    pushStyle();noStroke();fill(INK,55);ellipse(b[0]+b[2]/2,b[1]+b[3]-4,b[2]*.85,12);popStyle();
    drawKitchenObject(e.getKey(),b[0],b[1],b[2],b[3]);
    if(e.getKey().equals(expectedKitchenSource)){pushStyle();noFill();stroke(GOLD);strokeWeight(2);rect(b[0]-3,b[1]-3,b[2]+6,b[3]+6,6);popStyle();}
    if(cooking.contents.containsKey(e.getKey()))drawCookwareContents(e.getKey(),b);
  }
  for(Map.Entry<String,String> e:cooking.work.entrySet()){
    if(e.getValue().equals(kitchenHeld)||CookingModel.isContainer(e.getKey()))continue;
    if(!kitchenGestureFood().isEmpty()&&e.getKey().equals(cooking.action().target))continue;
    float[] t=kitchenTarget(e.getKey());drawKitchenObject(e.getValue(),t[0]+t[2]/2-51,t[1]-4,102,85);
  }
}
float[] preparedBounds(String id){preparedLayout.sync(cooking.prepared);return preparedLayout.bounds(id);}
void drawPreparedShelf(){
  preparedLayout.sync(cooking.prepared);if(cooking.prepared.isEmpty())return;
  pushStyle();noStroke();fill(0xff606c38,100);rect(294,607,654,10,4);
  fill(0xffb08b6e);rect(294,555,654,55,18);popStyle();
  for(String id:cooking.prepared){
    if(id.equals(kitchenGestureFood()))continue;
    float[] b=preparedLayout.bounds(id);boolean active=id.equals(expectedKitchenSource),hover=hit(b[0],b[1],b[2],b[3]);
    pushStyle();noStroke();fill(0xffe8dcc7);rect(b[0]+1,b[1]+7,b[2]-2,b[3]-5,16);
    if(active||hover){noFill();stroke(active?0xffc08e3a:0xff8b9d83);strokeWeight(2);rect(b[0]+1,b[1]+7,b[2]-2,b[3]-5,16);}
    if(!id.equals(kitchenHeld)){fill(0xff606c38,40);noStroke();ellipse(b[0]+38,b[1]+53,60,8);drawKitchenObject(id,b[0]+3,b[1]+1,b[2]-6,b[3]-3);}
    popStyle();
    if(hover||active){pushStyle();textFont(paperFonts[language]);fittedLabel(preparedName(id),b[0]+38,539,13,115,0xffe8dcc7);popStyle();}
  }
}
void drawCookwareContents(String id,float[] b){
  // Contained food is represented by the surface of a mixture, never by a bottle or can.
  pushStyle();noStroke();fill(0xffb77735,220);
  float surface=id.equals("pot")?.12:id.equals("bowl")?.32:.38;
  float depth=id.equals("pot")?.06:.14;
  ellipse(b[0]+b[2]*.5,b[1]+b[3]*surface,b[2]*.48,b[3]*depth);
  int count=min(8,cooking.contents.get(id));
  for(int i=0;i<count;i++){fill(i%2==0?0xffc66b3d:0xff8b9d83);ellipse(b[0]+b[2]*(.36+(i%4)*.09),b[1]+b[3]*(surface-.01+(i/4)*depth*.2),5,3);}
  popStyle();
}
void drawKitchenHeld(){
  CookingModel.Action a=cooking.action();boolean over=false;
  if(a!=null){float[] b=kitchenTarget(a.target);over=a.source.equals(kitchenHeld)&&hit(b[0],b[1],b[2],b[3]);}
  float x=mouseX+kitchenOffsetX,y=mouseY+kitchenOffsetY;
  pushStyle();noStroke();fill(INK,55);ellipse(x+kitchenHeldWidth/2,y+kitchenHeldHeight-4,kitchenHeldWidth*.75,14);popStyle();
  drawKitchenRightHand(mouseX,mouseY);
  drawKitchenObject(kitchenHeld,x,y,kitchenHeldWidth,kitchenHeldHeight);
}
void drawKitchenCounter(){
  // Extend the foreground worktop under the preparation trays, with a perspective edge.
  pushStyle();noStroke();fill(0xff606c38,70);quad(277,617,965,617,1005,720,237,720);
  fill(0xffb08b6e);quad(286,615,954,615,994,712,246,712);
  stroke(0xffd4b895,100);strokeWeight(1);
  for(int i=0;i<7;i++){float y=626+i*12;line(286-(y-615)*.4,y,954+(y-615)*.4,y);}
  noStroke();fill(0xff806047);quad(246,712,994,712,994,720,246,720);popStyle();
}
void drawFifoDebug(){
  menuPanel(300,176,646,195);fittedLabel("FIFO DEBUG — Queue.offer / peek / poll",623,195,18,620,GOLD);
  fittedLabel(CookingModel.DISHES[cooking.dish]+" | remaining: "+cooking.cookingQueue.size(),623,225,15,620,CREAM);
  int row=0;for(CookingModel.CookingStep step:cooking.cookingQueue)fittedLabel((row==0?"FRONT: ":"")+step.name,623,249+row++*18,12,620,CREAM);
  fittedLabel("Last poll: "+cooking.lastDequeued,623,357,12,620,GOLD);
}
void drawKitchenPause(){
  noStroke();fill(INK,210);rect(0,0,width,height);title("TAKE A PAWS",640,210,42,CREAM);
  pauseTextButton("RESUME",475,264,330,47,true);pauseTextButton("RETRY DISH",475,333,330,47,true);pauseTextButton("MAIN MENU",475,402,330,47,true);
  label("The countdown is paused.",640,500,18,CREAM);
}
String[] tutorialTitles={"Welcome to your kitchen","Click and drag","Follow the recipe","First step, then the next","Five minutes per dish"};
String[] tutorialBodies={"Open the cupboard, drawers, or fridge to take an item.","Open the cupboard. Drag the chopping board to the gold work area.","Click the paper to read your recipe. Follow the highlighted action.","Finish the first cooking stage before the next one becomes available.","The timer begins after this tutorial. Pause whenever you need a break."};
void drawKitchenTutorial(){
  kitchenBackdrop(35);drawKitchenCounter();drawKitchenStations();
  if(tutorialPage==1&&kitchenStorage>=0)drawKitchenStorage();
  if(tutorialPage==2||tutorialPage==3)drawKitchenNote();
  if(tutorialPage==4){menuPanel(1054,110,206,66);title("05:00",1157,140,30,CREAM);}
  float[] focus=tutorialPage==0?kitchenStationBounds(0):tutorialPage==1?(kitchenStorage==1?kitchenStorageCard(0):kitchenStationBounds(1)):tutorialPage==4?new float[]{1054,110,206,66}:new float[]{1150,99,100,126};
  pushStyle();noFill();stroke(GOLD);strokeWeight(3);
  if(tutorialPage==0)drawKitchenStationOutline(0);else if(tutorialPage==1&&kitchenStorage<0)drawKitchenStationOutline(1);
  else rect(focus[0],focus[1],focus[2],focus[3],16);popStyle();
  pushStyle();noStroke();fill(0xffe8dcc7);rect(15,5,1250,88,24);popStyle();
  title(tutorialTitles[tutorialPage],640,27,25,INK);fittedLabel(tutorialBodies[tutorialPage],640,64,18,1200,INK);
  if(tutorialPage==1){
    float[] target=kitchenTarget("prep");pushStyle();noFill();stroke(GOLD);strokeWeight(3);rect(target[0],target[1],target[2],target[3],12);popStyle();
    if(tutorialDragging){drawKitchenRightHand(mouseX,mouseY);drawKitchenObject("board",mouseX-90,mouseY-28,180,58);}
    else drawKitchenRightHand(kitchenStorage>=0?constrain(mouseX,330,980):922,kitchenStorage>=0?constrain(mouseY,185,605):590);
    if(tutorialPractice){drawKitchenObject("board",target[0],target[1],target[2],target[3]);fittedLabel("Well done!",640,590,22,360,CREAM);}
  }else drawKitchenRightHand(922,590);
  button("SKIP",36,656,200,44,true);button(tutorialPage==4?"START COOKING":"NEXT",1020,656,224,44,tutorialPage!=1||tutorialPractice);
  label((tutorialPage+1)+" / 5",640,680,18,CREAM);

}
void drawCookingSuccess(){
  kitchenBackdrop(0);pushStyle();noStroke();fill(255,170);rect(0,0,width,height);popStyle();boolean all=cooking.progressMask()==31;
  victorySign(all?"LEVEL 2 COMPLETE!":"DISH COMPLETE!",CookingModel.DISHES[cooking.dish]);
  containImage(kitchenImage(dishArtIds[cooking.dish]),75,267,280,210);
  for(int i=0;i<3;i++){pushStyle();if(i>=cooking.lastStars)tint(100);containImage(starImg,487+i*105,317,96,85);popStyle();}
  drawCookingRewards();
  victoryButton(all?"NEXT LEVEL":"NEXT DISH",458,521,364,48,true);victoryButton("DISHES",458,584,170,42,true);victoryButton("MAIN MENU",647,584,175,42,true);
}

void drawCookingTimeout(){
  kitchenBackdrop(155);panel(375,171,530,362);title("TIME'S UP!",640,229,38,INK);
  label("A fresh attempt gives you five minutes.",640,303,18,INK);
  button("RETRY DISH",467,359,346,48,true);button("MAIN MENU",467,433,346,48,true);
}
boolean kitchenMousePressed(){
  if(screen==COOK_LOADING){if(hit(32,658,200,42))openWorldSelection();return true;}
  if(screen==ENDING_MOVIE){if(hit(1020,660,220,43))finishEndingMovie();return true;}
  if(screen==WORLD_SELECT){for(int i=0;i<3;i++)if(hit(85+i*400,175,310,360)){if(i==0)startCutscene();else startEndingMovie(i);return true;}if(hit(35,652,220,44))goMenu();return true;}
  if(screen==LEVEL3_ENTRY)return mealMousePressed();
  if(screen==COOK_SELECT){
    if(hit(32,658,200,42)){openWorldSelection();return true;}
    for(int i=0;i<5;i++){float x=i<3?155+i*340:325+(i-3)*340,y=i<3?155:395;if(hit(x,y,290,210))startCooking(i);}return true;
  }
  if(screen==COOK_TUTORIAL){
    if(hit(36,656,200,44)){finishKitchenTutorial();kitchenStorage=-1;return true;}
    if(hit(1020,656,224,44)&&(tutorialPage!=1||tutorialPractice)){kitchenStorage=-1;if(tutorialPage==4)finishKitchenTutorial();else tutorialPage++;return true;}
    if(tutorialPage==1&&!tutorialPractice){
      if(kitchenStorage==1){
        float[] b=kitchenStorageCard(0);
        if(hit(b[0],b[1],b[2],b[3])){tutorialDragging=true;kitchenStorage=-1;kitchenGrabX=mouseX;kitchenGrabY=mouseY;}
        else if(hit(1005,116,155,44))kitchenStorage=-1;
      }else{float[] b=kitchenStationBounds(1);if(kitchenStationHit(1,mouseX,mouseY))openKitchenStorage(1);}
    }
    return true;
  }
  if(screen==COOK_SUCCESS){
    if(hit(458,521,364,48)){if(cooking.progressMask()==31)startEndingMovie(2);else startCooking(cooking.dish+1);}
    else if(hit(458,584,170,42))openCookingSelection();else if(hit(647,584,175,42))goMenu();return true;
  }
  if(screen==COOK_TIMEOUT){if(hit(467,359,346,48))startCooking(cooking.dish);else if(hit(467,433,346,48))goMenu();return true;}
  if(screen!=COOK_GAME)return false;
  if(kitchenPaused){if(hit(475,264,330,47)){kitchenPaused=false;lastTick=millis();}else if(hit(475,333,330,47))startCooking(cooking.dish);else if(hit(475,402,330,47))goMenu();return true;}
  if((kitchenStorage>=0||kitchenNote||kitchenStove)&&kitchenSpatialMouse())return true;
  if(hit(20,551,58,41)){kitchenHeld="";kitchenPaused=true;return true;}
  if(hit(88,551,58,41)){kitchenHeld="";tutorialReplay=true;tutorialPage=0;tutorialPractice=false;screen=COOK_TUTORIAL;return true;}
  if(hit(20,605,256,39)){goMenu();return true;}
  if(hit(309,494,167,39)&&cooking.action()!=null&&cooking.action().mode==CookingModel.Mode.HEAT){cooking.startHeat();return true;}
  CookingModel.Action active=cooking.action();
  if(active!=null&&active.mode==CookingModel.Mode.HEAT){
    float[] stove=kitchenTarget("stove");if(hit(stove[0],stove[1],stove[2],stove[3])){kitchenStove=true;return true;}
  }
  if(cooking.gesturing)return true;
  // Prepared trays are above the tool surfaces and take pointer priority.
  preparedLayout.sync(cooking.prepared);
  for(String id:cooking.prepared){if(id.equals(kitchenGestureFood()))continue;float[] b=preparedLayout.bounds(id);if(hit(b[0],b[1],b[2],b[3])){grabKitchenObject(id);return true;}}
  // Pick tools up where they were placed; no trip back to storage for each chop.
  CookingModel.Action expected=cooking.action();
  if(expected!=null&&cooking.equipment.containsKey(expected.source)){
    float[] b=kitchenEquipmentBounds(expected.source);
    if(hit(b[0],b[1],b[2],b[3])){grabKitchenObject(expected.source);return true;}
  }
  for(String tool:cooking.equipment.keySet()){
    float[] b=kitchenEquipmentBounds(tool);
    if(hit(b[0],b[1],b[2],b[3])&&!tool.equals("board")){grabKitchenObject(tool);return true;}
  }

  kitchenSpatialMouse();
  return true;
}
void grabKitchenObject(String id){
  if(cooking.gesturing||!cooking.available(id)||!kitchenHeld.isEmpty())return;
  float[] origin=null;
  if(kitchenStorage>=0){
    ArrayList<String> items=kitchenStorageItems();int index=items.indexOf(id);
    if(index>=0){float[] b=kitchenStorageCard(index%6);origin=new float[]{b[0]+22,b[1]+15,b[2]-44,111};}
  }else if(cooking.prepared.contains(id)){
    float[] b=preparedBounds(id);origin=new float[]{b[0]+3,b[1]+1,b[2]-6,b[3]-3};
  }else if(cooking.equipment.containsKey(id))origin=kitchenEquipmentBounds(id);
  if(origin==null)origin=new float[]{mouseX-56,mouseY-61,112,112};
  kitchenOffsetX=origin[0]-mouseX;kitchenOffsetY=origin[1]-mouseY;kitchenHeldWidth=origin[2];kitchenHeldHeight=origin[3];
  kitchenStorage=-1;kitchenHeld=id;kitchenGrabX=mouseX;kitchenGrabY=mouseY;kitchenTravel=0;
}
void kitchenMouseDragged(){
  if(screen==COOK_GAME&&!kitchenPaused&&!kitchenHeld.isEmpty())kitchenTravel=max(kitchenTravel,dist(mouseX,mouseY,kitchenGrabX,kitchenGrabY));
}
void kitchenMouseReleased(){
  if(screen==COOK_TUTORIAL&&tutorialDragging){
    tutorialDragging=false;float[] t=kitchenTarget("prep");if(hit(t[0],t[1],t[2],t[3])&&dist(mouseX,mouseY,kitchenGrabX,kitchenGrabY)>30)tutorialPractice=true;return;
  }
  if(screen!=COOK_GAME||kitchenPaused||kitchenHeld.isEmpty())return;
  kitchenTravel=max(kitchenTravel,dist(mouseX,mouseY,kitchenGrabX,kitchenGrabY));
  int now=millis();cooking.tick(max(0,now-lastTick),false);lastTick=now;
  CookingModel.Action a=cooking.action();boolean accepted=false;
  if(a!=null&&!cooking.failed){float[] t=kitchenTarget(a.target);
    if(kitchenTravel>12&&hit(t[0],t[1],t[2],t[3]))accepted=cooking.perform(kitchenHeld,a.target,kitchenTravel>12);
  }
  if(accepted){if(a.mode!=CookingModel.Mode.GESTURE)kitchenDropPop(kitchenHeld,mouseX,mouseY);burst(mouseX,mouseY,12,GOLD);playCookingSound(a.mode==CookingModel.Mode.GESTURE);syncKitchenSource();}
  else notifyPlayer("Follow the highlighted cooking action.");
  kitchenHeld="";updateCookingState();
}
void updateCookingState(){
  if(cooking.failed){kitchenHeld="";screen=COOK_TIMEOUT;}
  else if(cooking.complete()&&screen!=COOK_SUCCESS){kitchenHeld="";screen=COOK_SUCCESS;grantCookingReward();playMeow();burst(640,360,70,GOLD);saveProgress();}
  else if(screen==COOK_GAME&&cooking.dequeued.size()>kitchenVisibleStage){
    kitchenVisibleStage=cooking.dequeued.size();beginKitchenLoading(COOK_GAME);
  }
}
