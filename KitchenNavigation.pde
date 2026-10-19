// Spatial kitchen navigation follows the supplied Level 2 storyboard.
int kitchenStorage=-1;
boolean kitchenNote=false,kitchenStove=false;
PImage stoveCloseup;
PImage dishPlayImage,kitchenNoteImage,kitchenCheckmark;
boolean kitchenNavigationInitialized=false,dishPlayAttempted=false,stoveCloseupAttempted=false;
void initKitchenNavigationArt(){
  if(kitchenNavigationInitialized)return;
  kitchenNavigationInitialized=true;
  kitchenNoteImage=asset("LEVEL2/Other asset/PLAY__Animated__20261018_121239_0000-removebg-preview.png");
  kitchenCheckmark=asset("LEVEL2/Other asset/PLAY__Animated__20261018_121417_0000-removebg-preview.png");
}
void drawDishPlay(float x,float y,float size){
  if(!dishPlayAttempted){dishPlayAttempted=true;dishPlayImage=asset("LEVEL2/Other asset/PLAYbutton .png");}
  float grow=hit(x-6,y-6,size+12,size+12)?1.1:1;
  containImage(dishPlayImage,x-size*(grow-1)/2,y-size*(grow-1)/2,size*grow,size*grow);
}
void victorySign(String heading,String detail){
  pushStyle();
  // Reuse the supplied pixel-art sign, replacing only its dynamic second line.
  image(congratsImg,437,102,406,212);
  noStroke();fill(0xfffbd522);rect(467,222,345,67);
  if(language!=0){rect(467,140,345,70);fittedLabel(heading,640,172,30,337,0xff17140c);}
  fittedLabel(detail,640,251,25,337,0xff17140c);popStyle();
}
int kitchenStorageFor(String id){
  if(CookingModel.RAW.contains(id))return 2;
  return id.equals("knife")||id.equals("spoon")||id.equals("fork")||id.equals("brush")||id.equals("strainer")?0:1;
}
final float[][] kitchenCardRects={{330,190,190,168},{545,190,190,168},{760,190,190,168},{330,374,190,168},{545,374,190,168},{760,374,190,168}};
float[] kitchenStationBounds(int station){updateKitchenSceneGeometry();return kitchenStationRects[station];}
void openKitchenStorage(int station){kitchenStorage=station;kitchenPage=0;kitchenNote=false;}
ArrayList<String> kitchenStorageItems(){
  ArrayList<String> result=new ArrayList<String>();
  if(screen==COOK_TUTORIAL&&tutorialPage==1){result.add("board");return result;}
  if(kitchenStorage==2)result.addAll(cooking.storedIngredients());
  else for(String id:kitchenTools)if(kitchenStorageFor(id)==kitchenStorage&&cooking.inStorage(id))result.add(id);
  return result;
}
float[] kitchenStorageCard(int slot){return kitchenCardRects[slot];}
void drawKitchenStations(){
  initKitchenNavigationArt();
  CookingModel.Action action=cooking.action();
  boolean foreground=kitchenForegroundAtPointer();
  for(int i=0;i<3;i++){
    float[] b=kitchenStationBounds(i);
    boolean needed=action!=null&&cooking.inStorage(action.source)&&kitchenStorageFor(action.source)==i;
    boolean hovered=kitchenHeld.isEmpty()&&!foreground&&kitchenStationHit(i,mouseX,mouseY);
    pushStyle();stroke(needed?0xffc08e3a:0xffe8dcc7,hovered?255:needed?190:65);strokeWeight(hovered||needed?3:1);
    if(hovered)fill(0xffc08e3a,25);else noFill();
    drawKitchenStationOutline(i);
    if(needed||hovered){
      float labelY=i==1?b[1]+b[3]+18:b[1]-18;
      float labelX=b[0]+b[2]/2,labelWidth=min(180,b[2]);
      fill(0xff606c38);noStroke();rect(labelX-labelWidth/2,labelY-14,labelWidth,28,14);
      fittedLabel(i==2?"Ingredients":"Equipment",labelX,labelY,15,labelWidth-12,0xffe8dcc7);
    }popStyle();
  }
  pushStyle();image(kitchenNoteImage,1150,99,100,126);fittedLabel("RECIPE",1200,148,14,78,INK);popStyle();
}
void drawKitchenStorage(){
  initKitchenNavigationArt();
  kitchenBackdrop(55);pushStyle();
  boolean fridge=kitchenStorage==2;
  stroke(fridge?0xff606c38:0xff704c32);strokeWeight(12);fill(fridge?0xffd4d9bf:0xff473625);rect(292,110,696,514,16);
  // Open doors and drawer fronts frame the selectable objects on their shelves.
  noStroke();fill(fridge?0xff8b9d83:0xff886142);
  quad(292,120,200,158,200,601,292,624);quad(988,120,1080,158,1080,601,988,624);
  fill(fridge?0xffe8dcc7:0xffb08b6e);
  for(int row=0;row<2;row++){float sy=359+row*184;quad(310,sy-11,970,sy-11,988,sy+5,292,sy+5);rect(303,sy+5,675,13,4);}
  fill(0xff606c38);rect(310,126,660,46,20);
  fittedLabel(kitchenStorage==2?"Ingredients":"Equipment",640,149,24,580,0xffe8dcc7);
  button("CLOSE",1005,116,155,44,true);
  ArrayList<String> ids=kitchenStorageItems();int pages=max(1,(ids.size()+5)/6);kitchenPage=constrain(kitchenPage,0,pages-1);
  for(int slot=0;slot<6;slot++){
    int index=kitchenPage*6+slot;if(index>=ids.size())break;String id=ids.get(index);float[] b=kitchenStorageCard(slot);
    if(kitchenStorage==0){fill(0xffb08b6e,60);noStroke();rect(b[0],b[1],b[2],b[3],16);}
    if(id.equals(expectedKitchenSource)){noFill();stroke(0xffc08e3a);strokeWeight(3);rect(b[0]+8,b[1]+9,b[2]-16,b[3]-18,18);}
    drawKitchenObject(id,b[0]+22,b[1]+15,b[2]-44,111);fittedLabel(preparedName(id),b[0]+b[2]/2,b[1]+140,17,b[2]-26,kitchenStorage==2?INK:0xffe8dcc7);
  }
  if(ids.isEmpty())fittedLabel("Nothing else needed from storage.",640,330,23,610,INK);
  button("<",350,570,70,37,kitchenPage>0);button(">",860,570,70,37,kitchenPage+1<pages);
  fittedLabel((kitchenPage+1)+" / "+pages,640,590,18,200,INK);popStyle();
}
void drawKitchenNote(){
  initKitchenNavigationArt();
  pushStyle();noStroke();fill(INK,135);rect(0,0,width,height);image(kitchenNoteImage,370,90,540,542);
  textFont(paperFonts[language]);fittedLabel("RECIPE",640,161,29,450,INK);
  for(int i=0;i<cooking.recipe.size();i++){
    CookingModel.CookingStep step=cooking.recipe.get(i);boolean done=cooking.dequeued.contains(step.name);float y=249+i*81;
    if(done)containImage(kitchenCheckmark,401,y-26,47,45);
    fittedLabel(step.name,675,y-12,21,400,step==cooking.front()?0xff606c38:INK);
  }
  button("CLOSE",926,100,150,44,true);popStyle();
}
boolean kitchenSpatialMouse(){
  if(kitchenStove){
    if(hit(1005,116,155,44))kitchenStove=false;
    else if(hit(535,510,210,54)){cooking.startHeat();kitchenStove=false;}
    return true;
  }
  if(kitchenNote){if(hit(926,100,150,44))kitchenNote=false;return true;}
  if(kitchenStorage>=0){
    if(hit(1005,116,155,44)){kitchenStorage=-1;return true;}
    ArrayList<String> ids=kitchenStorageItems();
    if(hit(350,570,70,37)){kitchenPage=max(0,kitchenPage-1);return true;}
    if(hit(860,570,70,37)){kitchenPage=min(max(0,(ids.size()-1)/6),kitchenPage+1);return true;}
    for(int slot=0;slot<6;slot++){int index=kitchenPage*6+slot;if(index>=ids.size())break;float[] b=kitchenStorageCard(slot);if(hit(b[0],b[1],b[2],b[3])){grabKitchenObject(ids.get(index));return true;}}
    return true;
  }
  if(hit(1150,99,100,126)){kitchenNote=true;return true;}
  if(cooking.gesturing)return false;
  for(int i=0;i<3;i++){float[] b=kitchenStationBounds(i);if(kitchenStationHit(i,mouseX,mouseY)){openKitchenStorage(i);return true;}}
  return false;
}

void drawKitchenStove(){
  if(!stoveCloseupAttempted){stoveCloseupAttempted=true;stoveCloseup=asset("LEVEL2/Cook-ware/stove_clicked.jpg");}
  pushStyle();noStroke();fill(INK,190);rect(0,0,width,height);containImage(stoveCloseup,290,130,700,450);
  button("CLOSE",1005,116,155,44,true);button("HEAT",535,510,210,54,true);popStyle();drawKitchenRightHand(920,585);
}

void victoryButton(String text,float x,float y,float w,float h,boolean enabled){
  pushStyle();stroke(0xff17140c);strokeWeight(4);fill(hit(x,y,w,h)&&enabled?0xfffbd522:0xffc3c3c3);rect(x,y,w,h,28);
  stroke(0xfffaf6df);strokeWeight(3);line(x+25,y+5,x+w-25,y+5);
  fittedLabel(text,x+w/2,y+h/2,23,w-32,INK);popStyle();
}
void pauseTextButton(String text,float x,float y,float w,float h,boolean enabled){
  pushStyle();fittedLabel(text,x+w/2,y+h/2,25,w-12,hit(x,y,w,h)?GOLD:CREAM);
  if(hit(x,y,w,h)){stroke(GOLD);strokeWeight(2);line(x+w*.2,y+h-3,x+w*.8,y+h-3);}popStyle();
}

boolean kitchenForegroundAtPointer(){
  preparedLayout.sync(cooking.prepared);
  for(String id:cooking.prepared){float[] b=preparedLayout.bounds(id);if(hit(b[0],b[1],b[2],b[3]))return true;}
  for(String id:cooking.equipment.keySet()){float[] b=kitchenEquipmentBounds(id);if(hit(b[0],b[1],b[2],b[3]))return true;}
  return false;
}
