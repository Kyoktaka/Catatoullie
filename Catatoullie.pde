import java.util.*;

final int MENU=0,CUTSCENE=1,LEVEL_SELECT=2,GAME=3,CONGRATS=4;
final int CUSTOMIZE=5,OPTIONS=6,ACHIEVEMENTS=7,BRIEFING=8,FOLDER=9;
final int LOADING=10,OPEN_FOLDER=11,PAPERS=12,TIME_UP=13;
final int INK=0xff17252c,CREAM=0xfffff3d4,GOLD=0xffffcf53,MUTED=0xff9aacae;
int screen=MENU,selectedCat=0,selectedHat=0,selectedAccessory=0,catAngle=0;
float musicVolume=.35,sfxVolume=.7,vfxAmount=.7,sensitivity=1;
PImage bg,trashBg,selectionBg,playBtn,customBtn,optionsBtn,exitBtn,achievementsBtn,backBtn;
PImage lockImg,trashIcon,folderImg,openedFolderImg,paperImg,achievementIcon,catsIcon,mapsIcon;
PImage sparkleImg,starImg,congratsImg,healthImg,leftHandImg,rightHandImg;
PImage bananaImg,fishImg,bonesImg,bottleImg;
PImage[][] catViews=new PImage[5][4];
PImage[] hats=new PImage[15],accessoryImages=new PImage[19];
GameModel model=new GameModel();
PFont uiFont,headingFont;
boolean paused=false,showHelp=false;
int introDestination=LEVEL_SELECT;
int introStarted=0,transitionStarted=0,lastTick=0,toastUntil=0;
String toast="";
float pawReturnBlend=.22;

void setup(){
  size(1280,720);surface.setTitle("Catatoullie");frameRate(60);noSmooth();
  uiFont=createFont("Arial",18,true);headingFont=createFont("Arial Bold",28,true);textFont(uiFont);
  loadAssets();loadProgress();initLanguages();setAvatarView(catAngle);initMedia();lastTick=millis();
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
  loadWardrobe();
}
PImage asset(String path){if(!new java.io.File(dataPath(path)).isFile()){println("Missing image: "+path);return null;}return loadImage(path);}
void draw(){
  applyFocusPause();
  int now=millis(),delta=max(0,now-lastTick);lastTick=now;
  pawReturnBlend=1-pow(.78,delta*60/1000.0);
  advanceAvatarRotation(delta);
  if(screen==GAME&&!paused&&!showHelp){model.tick(delta);if(model.failed){resetPaws();screen=TIME_UP;}}
  if(screen==LEVEL3_ENTRY)updateMeal(delta);
  if(screen==COOK_GAME){cooking.tick(delta,kitchenPaused);updateCookingState();}
  background(INK);textFont(uiFont);imageMode(CORNER);rectMode(CORNER);ellipseMode(CENTER);textAlign(CENTER,CENTER);noTint();
  updateMusic();
  if(screen==MENU)drawMenu();else if(screen==CUTSCENE)drawCutscene();else if(screen==LEVEL_SELECT)drawLevelSelect();
  else if(screen==CUSTOMIZE)drawCustomize();else if(screen==OPTIONS)drawOptions();else if(screen==ACHIEVEMENTS)drawAchievements();
  else if(screen==LOADING)drawLoading();else if(screen==FOLDER)drawFolder();else if(screen==OPEN_FOLDER)drawOpenFolder();
  else if(screen==PAPERS)drawPapers();else if(screen==BRIEFING)drawBriefing();else if(screen==GAME)drawGame();
  else if(screen==CONGRATS)drawCongrats();else if(screen==TIME_UP)drawTimeUp();
  else drawKitchenScreen();
  drawEffects(delta);
  if(paused)drawPause();if(showHelp)drawHelp();
  if(millis()<toastUntil&&!paused&&!showHelp){noStroke();fill(INK,245);rect(293,675,694,34,5);label(toast,640,692,14,CREAM);}
}
void startCutscene(){startCutscene(LEVEL_SELECT);}
void startCutscene(int destination){introDestination=destination;finishAvatarDrag();paused=false;showHelp=false;screen=CUTSCENE;introStarted=millis();startIntroMedia();}
void drawCutscene(){
  drawIntroMedia();drawIntroSubtitles();
  button("SKIP [SPACE]",1020,660,220,43,true);updateIntroMedia();
}
void finishCutscene(){stopIntroMedia();screen=introDestination;}
void goMenu(){confirmProgressReset=false;languageDropdownOpen=false;finishAvatarDrag();stopIntroMedia();stopEndingMovie();clearKitchenInput();particles.clear();kitchenPops.clear();kitchenPaused=false;screen=MENU;paused=false;showHelp=false;resetPaws();saveProgress();}
void notifyPlayer(String message){toast=message;toastUntil=millis()+3000;}
String progressPath(){return dataPath("savegame.json");}
void loadProgress(){
  java.io.File file=new java.io.File(progressPath());if(!file.isFile())return;
  try{
    JSONObject s=loadJSONObject(file);if(s==null)return;meal.restore(false,0);
    // Preserve wardrobe/settings, but old FIFO cooking progress is a different game mode.
    if(savedInt(s,"version",1)>=2){model.restoreProgress(savedInt(s,"completed",0));JSONArray stars=savedArray(s,"stars");for(int i=0;i<5;i++)model.bestStars[i]=model.completed[i]?savedRating(stars,i):0;}
    selectedCat=constrain(savedInt(s,"cat",0),0,4);selectedHat=constrain(savedInt(s,"hat",0),0,hats.length-1);selectedAccessory=constrain(savedInt(s,"accessory",0),0,accessoryImages.length-1);catAngle=constrain(savedInt(s,"angle",0),0,3);
    language=constrain(savedInt(s,"language",0),0,6);
    JSONArray rewards=savedArray(s,"rewards");
    if(rewards!=null)for(int i=0;i<min(5,rewards.size());i++){
      JSONObject reward=savedObject(rewards,i);if(reward==null)continue;
      wardrobe.restoreReward(i,savedInt(reward,"hat",-1),savedInt(reward,"accessory",-1));
    }
    JSONArray cookingRewards=savedArray(s,"cookingRewards");
    if(cookingRewards!=null)for(int i=0;i<min(5,cookingRewards.size());i++){
      JSONObject reward=savedObject(cookingRewards,i);if(reward==null)continue;
      wardrobe.restoreCookingReward(i,savedInt(reward,"hat",-1),savedInt(reward,"accessory",-1));
    }
    if(!wardrobe.hats[selectedHat])selectedHat=0;
    if(!wardrobe.accessories[selectedAccessory])selectedAccessory=0;
    musicVolume=savedSetting(s,"music",.35,0,1);sfxVolume=savedSetting(s,"sfx",.7,0,1);vfxAmount=savedSetting(s,"vfx",.7,0,1);sensitivity=savedSetting(s,"sensitivity",1,.5,2);
    if(level2Unlocked()){
      cooking.restore(savedInt(s,"cookingCompleted",0));cooking.tutorialSeen=savedBoolean(s,"cookingTutorial",false);
      if(cooking.progressMask()==31)meal.restore(savedBoolean(s,"mealCompleted",false),savedInt(s,"mealStars",0));
      JSONArray ratings=savedArray(s,"cookingStars");for(int i=0;i<5;i++)cooking.bestStars[i]=cooking.completed[i]?savedRating(ratings,i):0;
    }
  }catch(Exception e){println("Save unavailable: "+e.getMessage());}
}
void saveProgress(){
  try{
    JSONObject s=new JSONObject();s.setInt("version",6);s.setInt("completed",model.progressMask());JSONArray stars=new JSONArray();for(int i=0;i<5;i++)stars.setInt(i,model.bestStars[i]);s.setJSONArray("stars",stars);
    s.setInt("cookingCompleted",level2Unlocked()?cooking.progressMask():0);s.setBoolean("cookingTutorial",cooking.tutorialSeen);
    JSONArray cookingRatings=new JSONArray();for(int i=0;i<5;i++)cookingRatings.setInt(i,cooking.bestStars[i]);s.setJSONArray("cookingStars",cookingRatings);
    s.setBoolean("mealCompleted",meal.completed);s.setInt("mealStars",meal.bestStars);
    s.setInt("language",language);JSONArray rewards=new JSONArray();
    for(int i=0;i<5;i++){JSONObject r=new JSONObject();r.setInt("hat",wardrobe.rewardHats[i]);r.setInt("accessory",wardrobe.rewardAccessories[i]);rewards.setJSONObject(i,r);}s.setJSONArray("rewards",rewards);
    JSONArray cookingRewards=new JSONArray();
    for(int i=0;i<5;i++){JSONObject r=new JSONObject();r.setInt("hat",wardrobe.cookingRewardHats[i]);r.setInt("accessory",wardrobe.cookingRewardAccessories[i]);cookingRewards.setJSONObject(i,r);}s.setJSONArray("cookingRewards",cookingRewards);
    s.setInt("cat",selectedCat);s.setInt("hat",selectedHat);s.setInt("accessory",selectedAccessory);s.setInt("angle",catAngle);
    s.setFloat("music",finiteSetting(musicVolume,.35,0,1));s.setFloat("sfx",finiteSetting(sfxVolume,.7,0,1));s.setFloat("vfx",finiteSetting(vfxAmount,.7,0,1));s.setFloat("sensitivity",finiteSetting(sensitivity,1,.5,2));writeProgressAtomically(s);
  }catch(Exception e){notifyPlayer("Could not save progress. Check the data folder is writable.");}
}
