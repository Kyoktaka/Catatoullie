// Each trash can: loading -> folder -> open-folder transition -> two papers -> search.
float[] canCenters={237,451,643,833,1007};
boolean[] paperRead={false,false};
final float[] PAW_BASE_X={330,950},PAW_BASE_Y={750,750};
final float[] PAW_REST_X={435,845},PAW_REST_Y={515,515};
float[] pawX={435,845},pawY={515,515};
PImage[] pawCaps=new PImage[2],pawForearms=new PImage[2];
float[] asideX=new float[8],asideY=new float[8];
float[] stagedX=new float[16],stagedY=new float[16];
int activePaw=-1,holdingPaw=-1;
GameModel.Item heldItem=null;
float pawOffsetX=0,pawOffsetY=0;
final float PILE_X=640,PILE_Y=357;
ArrayList<GameModel.Item> placedOrder=new ArrayList<GameModel.Item>();
float grabX,grabY;
float heldOffsetX=0,heldOffsetY=0;
boolean heldTravelled=false;

void resetPaws(){activePaw=-1;holdingPaw=-1;heldItem=null;heldOffsetX=0;heldOffsetY=0;for(int i=0;i<2;i++){pawX[i]=PAW_REST_X[i];pawY[i]=PAW_REST_Y[i];}}
void beginMission(int index){
  if(!model.startMission(index)){notifyPlayer(model.feedback);return;}
  ensureFoodArt(index);placedOrder.clear();particles.clear();newReward=false;
  resetPaws();java.util.Arrays.fill(asideX,0);java.util.Arrays.fill(asideY,0);
  java.util.Arrays.fill(stagedX,0);java.util.Arrays.fill(stagedY,0);
  paused=false;showHelp=false;paperRead[0]=false;paperRead[1]=false;toastUntil=0;
  screen=LOADING;transitionStarted=millis();
}
void drawLevelSelect(){
  sceneBackground(selectionBg,0);
  menuPill("LEVEL 1  /  FIND THE PURFECT MEAL",367,26,546,46);
  label(model.completedCount()+" / 5 ingredient sets collected",640,99,18,CREAM);
  for(int i=0;i<5;i++){
    float x=canCenters[i];boolean unlocked=model.unlocked(i),hover=hit(x-64,440,128,194);
    pushStyle();noStroke();fill(INK,95);ellipse(x,617,128,22);
    if(!unlocked)tint(145,151,146);image(trashIcon,x-63,442,126,170);noTint();
    if(!unlocked)containImage(lockImg,x-18,502,36,49);
    if(model.completed[i])for(int s=0;s<model.bestStars[i];s++)containImage(starImg,x-35+s*25,623,22,22);
    if(hover&&vfxAmount>0){
      float pulse=1+sin(millis()*.009)*.09*vfxAmount;
      tint(255,255*vfxAmount);
      containImage(sparkleImg,x-98,432,64*pulse,64*pulse);
      containImage(sparkleImg,x+38,484,42*pulse,42*pulse);
      noTint();
    }
    popStyle();
  }
  button("LEVELS",28,662,173,39,true);
  label("Choose a can under the lights. Each search lasts two minutes.",736,684,15,CREAM);
}
void drawLoading(){
  sceneBackground(bg,115);catPreview(640,405,184);
  title("MEOW MEOW MEOW...",640,465,24,CREAM);
  float progress=constrain((millis()-transitionStarted)/1500.0,0,1);
  noStroke();fill(CREAM,70);rect(420,518,440,14,7);fill(GOLD);rect(420,518,440*progress,14,7);
  label("Jumping into the next trash can",640,565,17,CREAM);
  if(progress>=1){screen=FOLDER;transitionStarted=millis();}
}
void trashInterior(float shade){sceneBackground(trashBg,shade);drawRestingPaws();}
void drawRestingPaws(){drawPaw(0,PAW_REST_X[0],PAW_REST_Y[0],false);drawPaw(1,PAW_REST_X[1],PAW_REST_Y[1],false);}
void preparePawSprite(int which){
  if(pawCaps[which]!=null)return;
  PImage src=which==0?leftHandImg:rightHandImg;if(src==null)return;
  // Straighten the supplied diagonal sprite once. Keep the paw rigid while only
  // the forearm strip stretches between its wrist and fixed offscreen base.
  float bx=src.width*(which==0?.17:.83),by=src.height*.93;
  float tx=src.width*(which==0?.76:.24),ty=src.height*.17;
  float len=dist(bx,by,tx,ty),ux=(tx-bx)/len,uy=(ty-by)/len;
  float crossScale=132/(src.width*.43),lengthScale=345/len;
  float a=-uy*crossScale,b=ux*crossScale,c=-ux*lengthScale,d=-uy*lengthScale;
  PGraphics strip=createGraphics(260,440);strip.beginDraw();strip.clear();
  strip.applyMatrix(a,b,130-a*bx-b*by,c,d,410-c*bx-d*by);
  strip.image(src,0,0);strip.endDraw();
  pawCaps[which]=strip.get(0,0,260,147);pawForearms[which]=strip.get(0,145,260,265);
  strip.dispose();
}
void drawPaw(int which,float x,float y,boolean carrying){
  preparePawSprite(which);if(pawCaps[which]==null)return;
  float dx=x-PAW_BASE_X[which],dy=y-PAW_BASE_Y[which],len=max(110,sqrt(dx*dx+dy*dy));
  pushMatrix();translate(PAW_BASE_X[which],PAW_BASE_Y[which]);rotate(atan2(dy,dx)+HALF_PI);
  image(pawForearms[which],-130,-len+80,260,len-80);
  image(pawCaps[which],-130,-len-65,260,147);popMatrix();
  if(carrying&&heldItem!=null)ingredientArt(heldItem,x+heldOffsetX,y+heldOffsetY,ITEM_SIZE);
}
void drawFolder(){
  trashInterior(30);title("YOU FOUND A RECIPE!",640,96,32,CREAM);
  float bob=sin(millis()*.003)*4*vfxAmount;
  containImage(folderImg,473,200+bob,334,263);
  menuPill(GameModel.MISSION_NAMES[model.missionIndex],460,463,360,46);
  button("OPEN FOLDER",499,560,282,50,true);button("BACK",28,662,128,39,true);
}
void drawOpenFolder(){
  trashInterior(30);float t=constrain((millis()-transitionStarted)/850.0,0,1);
  containImage(openedFolderImg,450-t*15,208-t*12,380+t*30,290+t*24);
  label("Opening your recipe folder...",640,554,20,CREAM);
  if(t>=1)screen=PAPERS;
}
void drawPapers(){
  trashInterior(46);title("TWO NOTES TO READ",640,74,29,CREAM);
  label("Click each paper to reveal its contents.",640,112,17,CREAM);
  for(int i=0;i<2;i++){
    float x=303+i*367;
    image(paperImg,x,157,307,390);
    if(paperRead[i])drawPaperContents(i,x,157,307,390);
    else {title(i==0?"RECIPE":"COLLECTION",x+153,300,23,INK);label("CLICK TO READ",x+153,353,16,INK);}
    if(hit(x,157,307,390)){noFill();stroke(GOLD);strokeWeight(3);rect(x+8,165,291,374,6);}
  }
  button("START SEARCH - 2:00",462,588,356,51,paperRead[0]&&paperRead[1]);
  label("The timer starts when you begin searching.",640,658,15,CREAM);
}
void drawPaperContents(int paper,float x,float y,float w,float h){
  pushStyle();textFont(paperFonts[language]);
  pushStyle();textFont(paperFonts[language]);fittedLabel(paper==0?"FIND THESE":"COLLECTION NOTES",x+w/2,y+70,18,w-40,INK);popStyle();
  if(paper==0){
    String[] recipe=GameModel.RECIPES[model.missionIndex];
    for(int i=0;i<recipe.length;i++){pushStyle();textAlign(LEFT,CENTER);fill(INK);textSize(14);String line="[ ]  "+tr(recipe[i]);float wText=textWidth(line);if(wText>w-60)textSize(14*(w-60)/wText);text(line,x+33,y+108+i*21);popStyle();}
  }else{
    String[] notes={"Drag either paw into the pile.","Take only the TOP item.","Follow FIND from top to bottom.","Set later ingredients aside.","Collect them when their turn comes.","Last in, first out: LIFO.","", "You have TWO MINUTES.","Ingredients stay uncooked.","Cooking is for Level 2."};
    for(int i=0;i<notes.length;i++)fittedLabel(notes[i],x+w/2,y+108+i*23,14,w-42,INK);
  }
  popStyle();
}
void drawBriefing(){drawPapers();}
void drawGame(){
  sceneBackground(trashBg,24);drawHealth();drawFindList();drawCollectionBag();drawPile();drawPlacedItems();
  for(int i=0;i<2;i++){
    if(activePaw!=i&&holdingPaw!=i){pawX[i]=lerp(pawX[i],PAW_REST_X[i],pawReturnBlend);pawY[i]=lerp(pawY[i],PAW_REST_Y[i],pawReturnBlend);}
    drawPaw(i,pawX[i],pawY[i],holdingPaw==i);
  }
  label(heldItem==null?"Follow FIND in order. Set later ingredients aside to reach the next one.":"Collect the next FIND item, or set it aside to reach the next ingredient.",640,646,15,CREAM);
  button("?",1152,25,43,38,true);button("II",1205,25,43,38,true);
}
void drawHealth(){
  // Keep the supplied heart and frame; replace only its interior with countdown fill.
  float x=411,y=21,w=458,h=83;
  image(healthImg,x,y,w,h);
  noStroke();fill(0xffa897b0);rect(x+92,y+21,w-115,40);
  float fraction=model.remainingMs/(float)GameModel.LIMIT_MS;
  fill(fraction>.33?0xff75a248:0xffda6555);rect(x+92,y+21,(w-115)*fraction,40);
  int seconds=(int)Math.ceil(model.remainingMs/1000.0);
  title(nf(seconds/60,1)+":"+nf(seconds%60,2),650,61,25,INK);
  label("LEVEL 1  /  "+GameModel.MISSION_NAMES[model.missionIndex],640,117,18,CREAM);
}
void drawFindList(){
  image(paperImg,22,115,264,467);title("FIND",154,181,24,INK);
  String[] recipe=GameModel.RECIPES[model.missionIndex];
  for(int i=0;i<recipe.length;i++){
    boolean found=false;for(GameModel.Item item:model.collected)if(item.name.equals(recipe[i]))found=true;
    float y=218+i*25;
    if(!found&&i==model.collected.size()){noStroke();fill(GOLD,155);rect(35,y-11,239,22,4);}
    noFill();stroke(INK);strokeWeight(1.3);rect(46,y-7,12,12);
    if(found){stroke(0xff417c4d);strokeWeight(3);line(47,y,51,y+4);line(51,y+4,60,y-7);}
    pushStyle();fill(found?0xff417c4d:INK);textAlign(LEFT,CENTER);
    textSize(10);float nameWidth=(!found&&i==model.collected.size())?min(151,186-textWidth(tr("NEXT"))):194;
    textSize(14);String name=tr(recipe[i]);float tw=textWidth(name);if(tw>nameWidth)textSize(14*nameWidth/tw);text(name,69,y);
    if(!found&&i==model.collected.size()){textAlign(RIGHT,CENTER);fill(0xff805500);textSize(10);text(tr("NEXT"),263,y);}
    popStyle();
  }
  label(model.collectedCount()+" / "+recipe.length+" collected",154,539,14,INK);
  label("Still uncooked",154,563,12,INK);
}
void drawCollectionBag(){
  boolean hover=heldItem!=null&&hit(1010,150,243,422);
  panel(1010,150,243,422);title("COLLECT",1131,185,24,INK);
  String bagHint=heldItem==null?"Follow the order on FIND":model.isNextIngredient(heldItem)?"Correct next ingredient":"Drop the highlighted FIND item";
  fittedLabel(bagHint,1131,216,14,220,INK);
  if(hover){noFill();stroke(model.isNextIngredient(heldItem)?GOLD:0xffcf6f67);strokeWeight(5);rect(1012,152,239,418,8);}
  for(int i=0;i<model.collected.size();i++)ingredientArt(model.collected.get(i),1052+(i%3)*76,272+(i/3)*68,45);
  if(model.collected.isEmpty()){containImage(folderImg,1064,331,136,112);label("Your finds go in this bag",1131,480,13,INK);}
  label("Collected for later",1131,538,14,INK);
}
void drawPile(){
  int count=model.pile.size();int start=max(0,count-10);
  pushStyle();noStroke();fill(INK,65);ellipse(PILE_X,PILE_Y+94,315,92);popStyle();
  for(int i=start;i<count;i++){
    GameModel.Item item=model.pile.get(i);int depth=count-1-i;
    if(item==heldItem)continue;
    float spread=depth==0?0:((item.id*47)%145-72);
    float x=PILE_X+spread,y=PILE_Y+depth*9+(depth==0?0:(item.id*13)%23);
    pushMatrix();translate(x,y);rotate(((item.id*19)%41-20)*PI/180);
    ingredientArt(item,0,0,ITEM_SIZE);popMatrix();
  }
}
void drawPlacedItems(){
  for(GameModel.Item item:placedOrder){
    if(item==heldItem||item.state==GameModel.COLLECTED)continue;
    int slot=item.id-model.missionIndex*100;
    ingredientArt(item,stagedX[slot],stagedY[slot],ITEM_SIZE);
  }
}
// Keep compatibility with earlier drawing callers; both types now share free placement.
void drawAsideItems(){drawPlacedItems();}
void drawStagedItems(){}
boolean insideTrash(float x,float y){
  float dx=(x-640)/365,dy=(y-377)/255;
  // Keep the full-size art within the interior, clear of the FIND and COLLECT panels.
  // Placement uses the paw center so the visible rim is reachable without an inset dead zone.
  return x>=298&&x<=982&&y>=145&&y<=613&&dx*dx+dy*dy<=1;
}
void drawCongrats(){
  drawGame();
  pushStyle();noStroke();fill(255,170);rect(0,0,width,height);popStyle();
  victorySign("INGREDIENTS COLLECTED!",phrase("Stage {0} - Level {1}",model.missionIndex+1,1));
  for(int i=0;i<3;i++){pushStyle();if(i>=model.lastStars)tint(100);containImage(starImg,437+i*140,336,120,120);popStyle();}
  victoryButton(model.missionIndex<4?"NEXT TRASH":"NEXT LEVEL",500,475,280,55,model.missionIndex<4||level2Unlocked());
  victoryButton("MAIN MENU",500,562,280,55,true);
  int hat=wardrobe.rewardHats[model.missionIndex],accessory=wardrobe.rewardAccessories[model.missionIndex];
  if(hat>=0&&accessory>=0){
    pushStyle();noStroke();fill(0xffe8dcc7);rect(995,440,275,206,24);popStyle();
    fittedLabel(newReward?"NEW WARDROBE FINDS":"STAGE REWARDS",1100,465,18,285,INK);
    containImage(hats[hat],1005,493,90,85);containImage(accessoryImages[accessory],1110,493,90,85);
    fittedLabel(wardrobeHatNames[hat],1050,598,13,140,INK);fittedLabel(wardrobeAccessoryNames[accessory],1160,622,13,190,INK);
  }
}
void drawTimeUp(){
  trashInterior(155);panel(392,167,496,355);title("TIME'S UP!",640,226,40,INK);
  label("Your paws need another try.",640,286,21,INK);
  label("A fresh search gives you two full minutes.",640,329,16,INK);
  button("RETRY TRASH",474,383,332,48,true);button("TRASH CANS",474,451,332,48,true);
}
void drawPause(){
  noStroke();fill(INK,205);rect(0,0,width,height);title("TAKE A PAWS",640,180,42,CREAM);
  pauseTextButton("RESUME",466,252,348,49,true);pauseTextButton("RESTART TRASH",466,321,348,49,true);pauseTextButton("TRASH CANS",466,390,348,49,true);pauseTextButton("MAIN MENU",466,459,348,49,true);
  label("The countdown is paused.",640,548,18,CREAM);
}
void drawHelp(){
  noStroke();fill(INK,210);rect(0,0,width,height);panel(289,120,702,470);title("A PAW-SOME SEARCH",640,165,30,INK);
  String[] lines={"1. Follow FIND from the first item down the list.","2. Only its next unchecked item can go in COLLECT.","3. Set later ingredients and junk to the side to reach it.","4. Collect a staged ingredient when it becomes NEXT.","5. Finish the list before the two minutes run out."};
  for(int i=0;i<lines.length;i++)label(lines[i],640,227+i*47,17,INK);
  label("You can release your paw after grabbing, then drag it again.",640,483,15,INK);button("LET'S SEARCH",470,521,340,47,true);
}
void mousePressed(){
  if(mouseButton!=LEFT)return;
  applyFocusPause();
  int origin=screen;settleInputClock();if(screen!=origin)return;
  playUiSound();
  if(kitchenMousePressed())return;
  if(showHelp){if(hit(470,521,340,47))showHelp=false;return;}
  if(paused){if(hit(466,252,348,49))paused=false;else if(hit(466,321,348,49))beginMission(model.missionIndex);else if(hit(466,390,348,49)){paused=false;resetPaws();screen=LEVEL_SELECT;}else if(hit(466,459,348,49))goMenu();return;}
  if(menuMousePressed())return;
  if(screen==CUTSCENE){if(hit(1020,660,220,43))finishCutscene();return;}
  if(screen==LEVEL_SELECT){if(hit(28,662,173,39)){openWorldSelection();return;}for(int i=0;i<5;i++)if(hit(canCenters[i]-64,440,128,194)){beginMission(i);return;}}
  else if(screen==FOLDER){if(hit(473,200,334,309)||hit(499,560,282,50)){screen=OPEN_FOLDER;transitionStarted=millis();playUiSound();}else if(hit(28,662,128,39))screen=LEVEL_SELECT;}
  else if(screen==PAPERS||screen==BRIEFING){
    for(int i=0;i<2;i++)if(hit(303+i*367,157,307,390)){paperRead[i]=true;playUiSound();return;}
    if(paperRead[0]&&paperRead[1]&&hit(462,588,356,51)){model.beginSearch();lastTick=millis();screen=GAME;resetPaws();}
  }else if(screen==GAME)gameMousePressed();
  else if(screen==CONGRATS){if(hit(500,475,280,55)){if(model.missionIndex<4)beginMission(model.missionIndex+1);else if(level2Unlocked())startEndingMovie(1);}else if(hit(500,562,280,55))goMenu();}
  else if(screen==TIME_UP){if(hit(474,383,332,48))beginMission(model.missionIndex);else if(hit(474,451,332,48))screen=LEVEL_SELECT;}
}
boolean pawHit(int i){float dx=(mouseX-pawX[i])/64,dy=(mouseY-pawY[i])/59;return dx*dx+dy*dy<=1;}
void gameMousePressed(){
  if(hit(1152,25,43,38)){activePaw=-1;showHelp=true;return;}if(hit(1205,25,43,38)){activePaw=-1;paused=true;return;}
  // A held object belongs to its paw until deposited; the other paw cannot steal it.
  for(int i=1;i>=0;i--)if(pawHit(i)&&(holdingPaw<0||holdingPaw==i)){
    activePaw=i;pawOffsetX=pawX[i]-mouseX;pawOffsetY=pawY[i]-mouseY;return;
  }
  if(hit(520,266,240,231))notifyPlayer("Use your paw to grab the top item of the stack.");
}
void movePaw(){
  if(activePaw<0)return;
  pawX[activePaw]=constrain(mouseX+pawOffsetX,45,1230);pawY[activePaw]=constrain(mouseY+pawOffsetY,132,634);
  float x=pawX[activePaw],y=pawY[activePaw];
  // Collision is checked against the grabbing tip, never a lower stack layer.
  if(heldItem==null){
    for(int i=placedOrder.size()-1;i>=0;i--){
      GameModel.Item item=placedOrder.get(i);int slot=item.id-model.missionIndex*100;
      if(abs(x-stagedX[slot])<ITEM_SIZE*.43&&abs(y-stagedY[slot])<ITEM_SIZE*.43){heldItem=item;break;}
    }
    if(heldItem==null&&model.top()!=null&&abs(x-PILE_X)<(75+16*sensitivity)&&abs(y-PILE_Y)<(67+16*sensitivity))heldItem=model.top();
    if(heldItem!=null){
      int slot=heldItem.id-model.missionIndex*100;boolean placed=placedOrder.contains(heldItem);
      heldOffsetX=(placed?stagedX[slot]:PILE_X)-x;heldOffsetY=(placed?stagedY[slot]:PILE_Y)-y;
      holdingPaw=activePaw;grabX=x;grabY=y;heldTravelled=false;burst(x,y,8,GOLD);playUiSound();
    }
  }else if(dist(x,y,grabX,grabY)>28)heldTravelled=true;
}
void mouseDragged(){applyFocusPause();kitchenMouseDragged();menuMouseDragged();if(screen==GAME&&!paused&&!showHelp)movePaw();}
void mouseReleased(){
  if(mouseButton!=LEFT)return;
  applyFocusPause();
  if(screen==LEVEL3_ENTRY){mealMouseReleased();return;}
  if(screen>=COOK_SELECT){kitchenMouseReleased();return;}
  menuMouseReleased();if(screen!=GAME||paused||showHelp||activePaw<0)return;
  int now=millis();model.tick(max(0,now-lastTick));lastTick=now;
  if(model.failed){resetPaws();screen=TIME_UP;return;}
  movePaw();int which=activePaw;activePaw=-1;
  if(heldItem==null)return;
  float x=pawX[which],y=pawY[which];boolean accepted=false;
  if(x>=1010&&x<=1253&&y>=150&&y<=590){
    if(!heldItem.required)model.feedback="Leave that in the can. Set it beside the pile.";
    else accepted=model.isStaged(heldItem)?model.collectStaged(heldItem):model.collectTop(heldItem);
    if(accepted){placedOrder.remove(heldItem);burst(x,y,28,GOLD);}
  }else if(insideTrash(x,y)&&heldTravelled){
    accepted=model.isStaged(heldItem)||model.aside.contains(heldItem)||model.setAsideTop(heldItem);
    if(accepted){
      int slot=heldItem.id-model.missionIndex*100;
      stagedX[slot]=x;stagedY[slot]=y;
      placedOrder.remove(heldItem);placedOrder.add(heldItem);
      model.feedback=heldItem.required?"Ingredient set aside. Follow FIND in order.":"Junk stays inside the can.";
      burst(x,y,10,MUTED);
    }
  }else return;
  notifyPlayer(model.feedback);
  if(accepted){heldItem=null;holdingPaw=-1;playUiSound();}
  if(model.missionComplete()){grantMissionReward();playMeow();resetPaws();screen=CONGRATS;toastUntil=0;saveProgress();}
}
void keyPressed(){
  applyFocusPause();
  if(keyEvent!=null&&keyEvent.isAutoRepeat()){if(key==ESC)key=0;return;}
  int origin=screen;settleInputClock();if(screen!=origin){if(key==ESC)key=0;return;}
  if(mealKeyPressed())return;
  if(optionsKeyPressed())return;
  if(screen>=COOK_SELECT){
    if(key==ESC){key=0;if(screen==COOK_GAME){if(kitchenStorage>=0||kitchenNote||kitchenStove){kitchenStorage=-1;kitchenNote=false;kitchenStove=false;return;}kitchenPaused=!kitchenPaused;kitchenHeld="";lastTick=millis();}else if(screen==ENDING_MOVIE)finishEndingMovie();else if(screen==COOK_TUTORIAL)finishKitchenTutorial();else if(screen==COOK_LOADING)openCookingSelection();else if(screen==COOK_SELECT||screen==LEVEL3_ENTRY)openWorldSelection();else goMenu();return;}
    if(screen==ENDING_MOVIE&&(key==' '||key==ENTER)){finishEndingMovie();return;}
    if(screen==COOK_GAME&&key==CODED&&keyCode==java.awt.event.KeyEvent.VK_F3){fifoDebug=!fifoDebug;return;}
    if(screen==COOK_GAME&&!kitchenPaused&&(key=='h'||key=='H'||key=='?')){clearKitchenInput();tutorialPage=0;tutorialPractice=false;tutorialReplay=true;screen=COOK_TUTORIAL;return;}
    return;
  }
  if(key==ESC){key=0;if(showHelp)showHelp=false;else if(screen==GAME){paused=!paused;activePaw=-1;}else if(screen==CUTSCENE)finishCutscene();else if(screen==LEVEL_SELECT)openWorldSelection();else if(screen==LOADING||screen==FOLDER||screen==OPEN_FOLDER||screen==PAPERS||screen==BRIEFING){resetPaws();screen=LEVEL_SELECT;}else goMenu();return;}
  if(screen==CUTSCENE&&(key==' '||key==ENTER))finishCutscene();
  if(screen==GAME&&!paused&&(key=='?'||key=='h'||key=='H')){showHelp=!showHelp;activePaw=-1;}
}
