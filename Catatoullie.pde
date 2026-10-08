// Catatoullie - Level 1: collect ingredients from a LIFO pile. No cooking yet.
import java.util.*;

final int MENU=0,CUTSCENE=1,LEVEL_SELECT=2,GAME=3,CONGRATS=4;
final int CUSTOMIZE=5,OPTIONS=6,ACHIEVEMENTS=7,BRIEFING=8,FOLDER=9;
final int LOADING=10,OPEN_FOLDER=11,PAPERS=12,TIME_UP=13;
final int INK=0xff17252c,CREAM=0xfffff3d4,GOLD=0xffffcf53,MUTED=0xff9aacae;
int screen=MENU,selectedCat=0,selectedHat=0,selectedAccessory=0,catAngle=0;
float musicVolume=.35,vfxAmount=.7,sensitivity=1;
PImage bg,trashBg,selectionBg,playBtn,customBtn,optionsBtn,exitBtn,achievementsBtn,backBtn;
PImage lockImg,trashIcon,folderImg,openedFolderImg,paperImg,achievementIcon,catsIcon,mapsIcon;
PImage sparkleImg,starImg,congratsImg,healthImg,leftHandImg,rightHandImg;
PImage bananaImg,fishImg,bonesImg,bottleImg;
PImage[][] catViews=new PImage[5][4];
PImage[] hats=new PImage[4],accessoryImages=new PImage[4];
GameModel model=new GameModel();
PFont uiFont,headingFont;
boolean paused=false,showHelp=false;
int introStarted=0,transitionStarted=0,lastTick=0,toastUntil=0;
String toast="";
String[] mealShort={"Spaghetti","Fried chicken","Lumpia","Peach mango pie","Burgis"};

void setup(){
  size(1280,720);surface.setTitle("Catatoullie - Level 1");frameRate(60);noSmooth();
  uiFont=createFont("Arial",18,true);headingFont=createFont("Arial Bold",28,true);textFont(uiFont);
  loadAssets();loadProgress();setAvatarView(catAngle);initMedia();lastTick=millis();
}
void loadAssets(){
  bg=asset("IMAGE/Background.png");trashBg=asset("IMAGE/background-trashcan.png");selectionBg=asset("IMAGE/selectionbg.png");
  playBtn=sprite("BUTTONS/buttons/play-button.png");customBtn=sprite("BUTTONS/buttons/customization-button.png");
  optionsBtn=sprite("BUTTONS/buttons/options-button.png");exitBtn=sprite("BUTTONS/buttons/exit-button.png");
  achievementsBtn=sprite("BUTTONS/buttons/achievements-button.png");backBtn=sprite("BUTTONS/buttons/back-to-menu-button.png");
  lockImg=sprite("XTRAS/lock.png");trashIcon=sprite("XTRAS/trashcan.png");folderImg=sprite("XTRAS/file.png");
  openedFolderImg=sprite("XTRAS/opened-file.png");paperImg=sprite("XTRAS/paper.png");
  leftHandImg=sprite("XTRAS/cat-left-hand.png");rightHandImg=sprite("XTRAS/cat-right-hand.png");
  achievementIcon=sprite("XTRAS/Achivements.png");catsIcon=sprite("XTRAS/cats.png");mapsIcon=sprite("XTRAS/Mapsbutton.png");
  sparkleImg=sprite("XTRAS/sparkle.png");starImg=sprite("XTRAS/star.png");congratsImg=sprite("XTRAS/congrats.png");healthImg=sprite("XTRAS/health-bar.png");
  bananaImg=sprite("INGREDIENTS/banana.png");fishImg=sprite("INGREDIENTS/fish.png");bonesImg=sprite("INGREDIENTS/bones.png");bottleImg=sprite("INGREDIENTS/bottle.png");
  String[] colors={"orange","blue","white","black","vox"};
  String[] angles={"front","right","back","left"};
  for(int c=0;c<5;c++)for(int a=0;a<4;a++){
    String name="cat-menu-"+angles[a]+"-"+colors[c]+".jpg";
    if(c==3&&a==0)name="cat-menu-front.-black.jpg";
    if(c==1&&a==1)name="cat-menu-right-blue9.jpg";
    catViews[c][a]=catSprite("CAT/Cat-Cuztomize-Character/"+name,c,a);
  }
  hats[1]=sprite("ACCESSORIES/Luffy_hat.png");hats[2]=sprite("ACCESSORIES/Brown_hat.png");hats[3]=sprite("ACCESSORIES/Chefs_hat.png");
  accessoryImages[1]=sprite("ACCESSORIES/headphone.png");accessoryImages[2]=sprite("ACCESSORIES/tag.png");accessoryImages[3]=sprite("ACCESSORIES/eyewear.png");
}
PImage asset(String path){if(!new java.io.File(dataPath(path)).isFile()){println("Missing image: "+path);return null;}return loadImage(path);}
void draw(){
  int now=millis(),delta=max(0,now-lastTick);lastTick=now;
  advanceAvatarRotation(delta);
  if(screen==GAME&&!paused&&!showHelp){model.tick(delta);if(model.failed){resetPaws();screen=TIME_UP;}}
  background(INK);textFont(uiFont);imageMode(CORNER);rectMode(CORNER);ellipseMode(CENTER);textAlign(CENTER,CENTER);noTint();
  updateMusic();
  if(screen==MENU)drawMenu();else if(screen==CUTSCENE)drawCutscene();else if(screen==LEVEL_SELECT)drawLevelSelect();
  else if(screen==CUSTOMIZE)drawCustomize();else if(screen==OPTIONS)drawOptions();else if(screen==ACHIEVEMENTS)drawAchievements();
  else if(screen==LOADING)drawLoading();else if(screen==FOLDER)drawFolder();else if(screen==OPEN_FOLDER)drawOpenFolder();
  else if(screen==PAPERS)drawPapers();else if(screen==BRIEFING)drawBriefing();else if(screen==GAME)drawGame();
  else if(screen==CONGRATS)drawCongrats();else if(screen==TIME_UP)drawTimeUp();
  if(paused)drawPause();if(showHelp)drawHelp();
  if(millis()<toastUntil&&!paused&&!showHelp){noStroke();fill(INK,245);rect(293,675,694,34,5);label(toast,640,692,14,CREAM);}
}
void startCutscene(){finishAvatarDrag();paused=false;showHelp=false;screen=CUTSCENE;introStarted=millis();startIntroMedia();}
void drawCutscene(){drawIntroMedia();noStroke();fill(INK,225);rect(0,645,width,75);label("A hungry cat. A tiny dream. One purfect meal.",490,681,18,CREAM);button("SKIP [SPACE]",1020,660,220,43,true);updateIntroMedia();}
void finishCutscene(){stopIntroMedia();screen=LEVEL_SELECT;}
void goMenu(){finishAvatarDrag();stopIntroMedia();screen=MENU;paused=false;showHelp=false;resetPaws();saveProgress();}
void notifyPlayer(String message){toast=message;toastUntil=millis()+3000;}
void loadProgress(){
  java.io.File file=new java.io.File(dataPath("savegame.json"));if(!file.isFile())return;
  try{
    JSONObject s=loadJSONObject(file);
    // Preserve wardrobe/settings, but old FIFO cooking progress is a different game mode.
    if(s.getInt("version",1)>=2){model.restoreProgress(s.getInt("completed",0));JSONArray stars=s.getJSONArray("stars");if(stars!=null)for(int i=0;i<min(5,stars.size());i++)model.bestStars[i]=model.completed[i]?constrain(stars.getInt(i),1,3):0;}
    selectedCat=constrain(s.getInt("cat",0),0,4);selectedHat=constrain(s.getInt("hat",0),0,3);selectedAccessory=constrain(s.getInt("accessory",0),0,3);catAngle=constrain(s.getInt("angle",0),0,3);
    musicVolume=constrain(s.getFloat("music",.35),0,1);vfxAmount=constrain(s.getFloat("vfx",.7),0,1);sensitivity=constrain(s.getFloat("sensitivity",1),.5,2);
  }catch(Exception e){println("Save unavailable: "+e.getMessage());}
}
void saveProgress(){
  try{
    JSONObject s=new JSONObject();s.setInt("version",2);s.setInt("completed",model.progressMask());JSONArray stars=new JSONArray();for(int i=0;i<5;i++)stars.setInt(i,model.bestStars[i]);s.setJSONArray("stars",stars);
    s.setInt("cat",selectedCat);s.setInt("hat",selectedHat);s.setInt("accessory",selectedAccessory);s.setInt("angle",catAngle);
    s.setFloat("music",musicVolume);s.setFloat("vfx",vfxAmount);s.setFloat("sensitivity",sensitivity);saveJSONObject(s,dataPath("savegame.json"));
  }catch(Exception e){notifyPlayer("Could not save progress. Check the data folder is writable.");}
}
