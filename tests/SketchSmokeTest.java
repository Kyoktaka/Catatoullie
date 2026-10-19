import processing.awt.PGraphicsJava2D;
import processing.core.PApplet;
import java.nio.file.*;
import java.util.Arrays;

/** Offscreen renderer and real input-handler checks. Never mutates saved progress. */
public class SketchSmokeTest {
  static class TestSketch extends Catatoullie {
    boolean persist=false;
    @Override public void saveProgress() {if(persist)super.saveProgress();}
    @Override public String progressPath(){return Paths.get("tmp/qa/test-save.json").toAbsolutePath().toString();}
    @Override public processing.video.Movie createEndingMovie(String source){return null;}
    @Override public void updateKitchenMusic(){}
  }
  static Catatoullie app;
  static Path out;
  static int checks=0;
  static boolean checkedFoodDrop=false,checkedJunkDrop=false,checkedOldDrop=false,checkedOtherPaw=false;
  static void check(boolean b,String m){checks++;if(!b)throw new AssertionError(m);}
  static void beginPaint(){
    app.g.beginDraw();app.g.background(app.INK);app.textFont(app.uiFont);
    app.imageMode(PApplet.CORNER);app.rectMode(PApplet.CORNER);app.ellipseMode(PApplet.CENTER);
    app.textAlign(PApplet.CENTER,PApplet.CENTER);app.noTint();
  }
  static void capture(String name,Runnable paint){
    beginPaint();paint.run();app.g.endDraw();app.g.save(out.resolve(name+".png").toString());
  }
  static int[] avatarPixels(int view,int accessory){
    app.setAvatarView(view);app.selectedAccessory=accessory;
    beginPaint();app.catPreview(640,630,420);app.g.endDraw();app.g.loadPixels();
    return app.g.pixels.clone();
  }
  static void press(int x,int y){app.mouseX=x;app.mouseY=y;app.mouseButton=PApplet.LEFT;app.mousePressed();}
  static void drag(int x,int y){app.mouseX=x;app.mouseY=y;app.mouseDragged();}
  static void release(int x,int y){app.lastTick=app.millis();app.mouseX=x;app.mouseY=y;app.mouseReleased();}
  static void click(int x,int y){press(x,y);release(x,y);}
  static void settleAvatar(){for(int i=0;i<20;i++)app.advanceAvatarRotation(16);}
  static boolean sameYaw(float a,float b){float difference=a-b;return Math.abs(difference-4*Math.round(difference/4))<.001f;}
  static void rotateAvatar(int x,int y,int distance,int expected){
    float initial=app.avatarYaw;
    press(x,y);check(app.avatarDragging,"Pressing the avatar captures mouse rotation");
    drag(x+distance,y);float target=app.avatarTargetYaw;
    check(Math.abs(target-initial)>.001f,"Horizontal drag changes the desired angle");
    app.advanceAvatarRotation(16);
    check(Math.abs(app.avatarYaw-initial)>.001f&&Math.abs(app.avatarYaw-target)>.001f,"Avatar eases toward the drag instead of snapping");
    release(x+distance,y);check(!app.avatarDragging,"Release ends avatar dragging");
    settleAvatar();check(app.catAngle==expected,"Drag settles on the expected view "+expected);
  }
  static void checkAvatarInputs(){
    app.screen=app.MENU;app.setAvatarView(0);
    click(300,600);click(74,600);settleAvatar();check(app.catAngle==0,"Former menu arrow locations cannot rotate the cat");
    rotateAvatar(187,400,100,1);rotateAvatar(187,400,-100,0);rotateAvatar(187,400,-100,3);
    float before=app.avatarTargetYaw;
    press(510,400);drag(610,400);release(610,400);settleAvatar();
    check(sameYaw(app.avatarTargetYaw,before)&&!app.avatarDragging,"Dragging outside the menu avatar does nothing");
    app.screen=app.CUSTOMIZE;app.wardrobeTab=0;app.setAvatarView(0);
    click(1167,599);click(902,599);settleAvatar();check(app.catAngle==0,"Former wardrobe arrows cannot rotate the cat");
    click(1162,535);check(app.selectedCat==4,"Silver Vox color selectable");
    rotateAvatar(1050,360,100,1);check(app.selectedCat==4,"Rotating preserves the selected coat");
    click(1106,535);check(app.selectedCat==3&&app.catAngle==1,"Changing color preserves the view");
    rotateAvatar(1050,360,-100,0);rotateAvatar(1050,360,-100,3);
    before=app.avatarTargetYaw;
    press(860,640);drag(1060,360);release(1060,360);settleAvatar();
    check(sameYaw(app.avatarTargetYaw,before)&&!app.avatarDragging,"A drag beginning outside the wardrobe preview cannot rotate it");
    app.selectedCat=0;app.setAvatarView(0);
  }
  static void checkAccessoryVisibility(){
    app.selectedHat=2;
    for(int coat=0;coat<5;coat++){
      app.selectedCat=coat;
      for(int view=0;view<4;view++){
        int[] bare=avatarPixels(view,0);
        for(int accessory=1;accessory<app.accessoryImages.length;accessory++){
          boolean same=Arrays.equals(bare,avatarPixels(view,accessory));
          check(view==0?!same:same,"Face accessory "+accessory+" is front-only for coat "+coat+", view "+view);
        }
      }
    }
    app.selectedCat=0;app.setAvatarView(0);
  }
  static void dragPawTo(int paw,int x,int y){
    press(Math.round(app.pawX[paw]),Math.round(app.pawY[paw]));
    check(app.activePaw==paw,"The selected paw starts dragging from its actual position");
    float[] baseX=app.PAW_BASE_X.clone(),baseY=app.PAW_BASE_Y.clone();
    drag(x,y);
    check(Arrays.equals(baseX,app.PAW_BASE_X)&&Arrays.equals(baseY,app.PAW_BASE_Y),"Reaching leaves both arm bases anchored");
    release(x,y);
  }
  static void completeMission(int paw,int junkSide){
    for(processing.core.PImage food:app.foodArt)check(food!=null,"Every recipe PNG loads");
    int interactions=0,placements=0;
    int[][] positions={{370,240},{500,240},{780,240},{910,240},{370,380},{500,380},{780,380},{910,380},{370,520},{500,520},{780,520},{910,520},{580,550},{710,550}};
    while(!app.model.missionComplete()){
      check(++interactions<40,"Ordered search makes bounded progress");
      GameModel.Item item=null;
      for(GameModel.Item candidate:app.model.staged)if(app.model.isNextIngredient(candidate))item=candidate;
      boolean fromSide=item!=null;if(item==null)item=app.model.top();
      check(item!=null,"Next item remains reachable");
      int slot=item.id-app.model.missionIndex*100;
      dragPawTo(paw,fromSide?Math.round(app.stagedX[slot]):640,fromSide?Math.round(app.stagedY[slot]):357);
      check(app.heldItem==item,"Paw picks selected top or staged item");
      if(!checkedOtherPaw){
        int other=1-paw;press(Math.round(app.pawX[other]),Math.round(app.pawY[other]));
        check(app.activePaw<0&&app.holdingPaw==paw,"Other paw cannot steal held item");
        release(Math.round(app.pawX[other]),Math.round(app.pawY[other]));checkedOtherPaw=true;
      }
      if(!checkedOldDrop){dragPawTo(paw,640,630);check(app.heldItem==item,"Outside-can placement rejected");checkedOldDrop=true;}
      int count=app.model.collectedCount();
      if(app.model.isNextIngredient(item)){
        dragPawTo(paw,1120,355);check(app.model.collectedCount()==count+1,"Next ingredient collected");
        check(item.name.equals(GameModel.RECIPES[app.model.missionIndex][count]),"Collection follows exact FIND order");
      }else{
        dragPawTo(paw,1120,355);check(app.heldItem==item&&app.model.collectedCount()==count,"Wrong food or junk rejected by bag");
        if(item.required)checkedFoodDrop=true;else checkedJunkDrop=true;
        int[] position=positions[placements++];
        check(app.insideTrash(position[0],position[1]),"Test placement is inside can");
        dragPawTo(paw,position[0],position[1]);
        check(Math.abs(app.stagedX[slot]-position[0])<1&&Math.abs(app.stagedY[slot]-position[1])<1,"Placement preserves chosen coordinates within mouse rounding");
        check(app.placedOrder.contains(item),"Placed item remains visible in can");
        if(placements==3)capture("free-placement-"+app.model.missionIndex,()->app.drawGame());
      }
      check(app.heldItem==null,"Valid placement releases paw");
    }
    check(app.screen==app.CONGRATS,"Every ingredient set opens congratulations");
    check(app.wardrobe.claimed[app.model.missionIndex],"Successful can grants wardrobe rewards");
  }
  public static void main(String[] args)throws Exception{
    app=new TestSketch();out=Paths.get("tmp/qa");Files.createDirectories(out);
    java.lang.reflect.Field path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
    app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);
    app.g.beginDraw();app.uiFont=app.createFont("Arial",18,true);app.headingFont=app.createFont("Arial Bold",28,true);app.g.endDraw();
    app.loadAssets();app.g.beginDraw();app.initLanguages();app.g.endDraw();
    for(int c=0;c<5;c++)for(int a=0;a<4;a++)check(app.catViews[c][a]!=null,"Every coat/view exists");
    checkAvatarInputs();checkAccessoryVisibility();
    app.screen=app.MENU;capture("menu",()->app.drawMenu());
    app.selectedHat=2;app.selectedAccessory=3;app.screen=app.CUSTOMIZE;
    capture("wardrobe-ginger",()->app.drawCustomize());
    app.selectedHat=3;app.selectedAccessory=0;
    for(int c=0;c<5;c++)for(int a=0;a<4;a++){
      final int coat=c,angle=a;app.selectedCat=c;app.setAvatarView(a);
      capture("cat-"+c+"-"+a,()->{app.sceneBackground(app.bg,120);app.catPreview(640,630,420);app.label("COAT "+coat+" / "+angle,640,50,24,app.CREAM);});
    }
    for(int hat=1;hat<app.hats.length;hat++)for(int acc=0;acc<=0;acc++){
      app.selectedCat=0;app.setAvatarView(0);app.selectedHat=hat;app.selectedAccessory=acc;
      capture("fit-"+hat+"-"+acc,()->app.drawCustomize());
    }
    for(int acc=1;acc<app.accessoryImages.length;acc++){
      app.selectedHat=0;app.selectedAccessory=acc;capture("accessory-"+acc,()->app.drawCustomize());
    }
    app.selectedHat=2;app.selectedAccessory=2;app.setAvatarView(0);
    press(1050,360);drag(1100,360);settleAvatar();
    capture("wardrobe-turning",()->app.drawCustomize());release(1100,360);app.setAvatarView(0);
    app.selectedHat=2;app.selectedAccessory=3;
    app.selectedCat=4;app.setAvatarView(0);capture("wardrobe-silver",()->app.drawCustomize());
    app.screen=app.LEVEL_SELECT;app.mouseX=237;app.mouseY=505;capture("selection",()->app.drawLevelSelect());
    click(237,505);check(app.screen==app.LOADING,"Every can enters loading");
    capture("loading",()->app.drawLoading());
    app.screen=app.FOLDER;capture("folder",()->app.drawFolder());click(640,585);check(app.screen==app.OPEN_FOLDER,"Folder animation");
    capture("opened-folder",()->app.drawOpenFolder());
    app.screen=app.PAPERS;capture("papers-closed",()->app.drawPapers());
    click(640,615);check(app.screen==app.PAPERS,"Cannot bypass unread papers");
    click(450,330);click(815,330);capture("papers-read",()->app.drawPapers());
    click(640,615);check(app.screen==app.GAME&&app.model.searching,"Start starts timer");
    capture("game",()->app.drawGame());
    int beforePause=app.model.remainingMs;app.paused=true;app.lastTick=app.millis()-5000;
    capture("paused",()->app.draw());check(app.model.remainingMs==beforePause,"Pause stops timer");
    app.paused=false;app.showHelp=true;app.lastTick=app.millis()-5000;
    capture("help",()->app.draw());check(app.model.remainingMs==beforePause,"Instructions stop timer");
    app.showHelp=false;app.lastTick=app.millis()-2000;capture("game-running",()->app.draw());
    check(app.model.remainingMs<=beforePause-2000,"Active time counts down");
    completeMission(0,390);
    capture("congrats",()->app.drawCongrats());
    click(640,500);check(app.screen==app.LOADING&&app.model.missionIndex==1,"Next trash also loads");
    app.model.beginSearch();app.model.tick(GameModel.LIMIT_MS);app.screen=app.TIME_UP;capture("timeout",()->app.drawTimeUp());
    click(640,408);check(app.screen==app.LOADING&&app.model.remainingMs==120000,"Retry resets timer");
    for(int mission=1;mission<5;mission++){
      check(app.model.missionIndex==mission,"Next sequential can");
      app.screen=app.FOLDER;click(640,585);check(app.screen==app.OPEN_FOLDER,"Every can opens folder");
      app.screen=app.PAPERS;click(450,330);click(815,330);click(640,615);
      completeMission(1,mission%2==0?390:885);
      if(mission<4){click(640,500);check(app.screen==app.LOADING,"Next trash always loads");}
    }
    check(checkedFoodDrop&&checkedJunkDrop&&checkedOldDrop&&checkedOtherPaw,"Invalid placements and paw ownership were exercised");
    check(app.model.completedCount()==5,"Five ingredient sets finish Level 1");
    capture("level1-complete",()->app.drawCongrats());click(640,500);
    check(app.screen==app.ENDING_MOVIE&&app.endingSource.equals("LEVEL2/level1-cutscene-after.mp4"),"Final trash NEXT LEVEL starts the supplied ending");
    click(1130,680);check(app.screen==app.COOK_SELECT,"Ending skip opens Level 2 selection");
    app.screen=app.OPTIONS;capture("options",()->app.drawOptions());
    app.screen=app.ACHIEVEMENTS;capture("achievements",()->app.drawAchievements());
    app.beginMission(4);app.paperRead[0]=true;app.paperRead[1]=true;
    for(int lang=0;lang<7;lang++){
      final int selectedLanguage=lang;app.screen=app.OPTIONS;click(780,471);click(780,Math.round(app.languageOptionY(lang)+19));
      check(app.language==lang,"Language input selects requested locale");
      capture("options-language-"+lang,()->app.drawOptions());
      capture("menu-language-"+lang,()->app.drawMenu());
      capture("papers-language-"+lang,()->app.drawPapers());
      capture("game-language-"+lang,()->app.drawGame());
      capture("wardrobe-language-"+lang,()->app.drawCustomize());
      for(String[] recipe:GameModel.RECIPES)for(String ingredient:recipe)check(app.translations.hasKey(ingredient),"Ingredient translation exists");
      if(lang>0){
        check(!app.tr("Find Pasta first.").equals("Find Pasta first."),"Dynamic feedback translates");
        check(app.tr("Find Pasta first. Set Meatballs aside for later.").contains(app.tr("Meatballs")),"Embedded ingredient names translate");
        for(int key=0;key<8;key++)check(app.translatedButtons[lang][key]!=null,"Translated button art loads");
      }
      check(app.introSource().equals("cutscene1-english.mp4"),"Missing locale video falls back to English");
      check(app.introEnglishFallback==(lang!=0),"Fallback indication matches selected language");
    }
    app.screen=app.OPTIONS;app.particles.clear();click(600,310);app.burst(640,360,40,app.GOLD);
    check(app.vfxAmount==0&&app.particles.isEmpty(),"Zero VFX disables particles");
    click(760,310);app.burst(640,360,40,app.GOLD);int half=app.particles.size();
    app.particles.clear();click(921,310);app.burst(640,360,40,app.GOLD);
    check(half==20&&app.particles.size()==40,"Slider scales particle count proportionally");
    app.setLanguage(0,false);
    TestSketch saved=(TestSketch)app;saved.persist=true;
    app.language=6;app.selectedHat=app.wardrobe.rewardHats[0];app.selectedAccessory=app.wardrobe.rewardAccessories[0];
    int savedHat=app.selectedHat,savedAccessory=app.selectedAccessory;app.saveProgress();
    app.wardrobe=new WardrobeInventory();app.model=new GameModel();app.language=0;app.selectedHat=0;app.selectedAccessory=0;app.loadProgress();
    check(app.language==6&&app.selectedHat==savedHat&&app.selectedAccessory==savedAccessory,"Save restores locale and selected rewards");
    check(app.model.completedCount()==5&&app.wardrobe.claimed[4],"Save restores all progress and stage rewards");
    Files.writeString(Paths.get(app.progressPath()),"{\"version\":2,\"completed\":1,\"stars\":[3,0,0,0,0],\"hat\":3,\"accessory\":2,\"music\":0.2,\"vfx\":0.4}");
    app.wardrobe=new WardrobeInventory();app.model=new GameModel();app.loadProgress();
    check(app.language==0&&app.selectedHat==3&&app.selectedAccessory==2&&Math.abs(app.musicVolume-.2)<.001,"Old save retains wardrobe/settings and defaults to English");
    check(app.model.completed[0]&&!app.wardrobe.claimed[0],"Old completed stage can earn its first reward on replay");
    saved.persist=false;
    System.out.println("Sketch smoke tests passed: "+checks+" checks; screenshots in "+out);
  }
}
