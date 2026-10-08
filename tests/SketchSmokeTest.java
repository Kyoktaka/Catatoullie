import processing.awt.PGraphicsJava2D;
import processing.core.PApplet;
import java.nio.file.*;
import java.util.Arrays;

/** Offscreen renderer and real input-handler checks. Never mutates saved progress. */
public class SketchSmokeTest {
  static class TestSketch extends Catatoullie { @Override public void saveProgress() {} }
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
        for(int accessory=1;accessory<=3;accessory++){
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
    int interactions=0;
    while(!app.model.missionComplete()){
      check(++interactions<=app.model.items.size(),"The stack makes bounded progress");
      GameModel.Item item=app.model.top();check(item!=null,"Top remains available");
      int pileCount=app.model.pile.size(),collectedCount=app.model.collectedCount(),asideCount=app.model.aside.size();
      dragPawTo(paw,640,357);
      check(app.heldItem==item&&app.holdingPaw==paw,"Either paw grabs only the top item");
      check(app.model.top()==item&&app.model.pile.size()==pileCount,"Holding keeps the item on the stack until a valid placement");
      if(!checkedOtherPaw){
        int other=1-paw;press(Math.round(app.pawX[other]),Math.round(app.pawY[other]));
        check(app.activePaw<0&&app.holdingPaw==paw,"The other paw cannot steal a held item");
        release(Math.round(app.pawX[other]),Math.round(app.pawY[other]));checkedOtherPaw=true;
      }
      if(!checkedOldDrop){
        dragPawTo(paw,640,630);
        check(app.heldItem==item&&app.model.top()==item&&item.state==GameModel.AVAILABLE,"The removed bottom discard area keeps the held item");
        checkedOldDrop=true;
      }
      if(item.required&&!checkedFoodDrop){
        dragPawTo(paw,390,360);
        check(app.heldItem==item&&app.model.aside.size()==asideCount&&app.model.collectedCount()==collectedCount,"Needed food cannot be set aside");
        capture("holding",()->app.drawGame());checkedFoodDrop=true;
      }else if(!item.required&&!checkedJunkDrop){
        dragPawTo(paw,1120,355);
        check(app.heldItem==item&&app.model.top()==item&&app.model.collectedCount()==collectedCount,"Junk cannot enter the collection bag");
        capture("holding-junk",()->app.drawGame());checkedJunkDrop=true;
      }
      if(item.required)dragPawTo(paw,1120,355);else dragPawTo(paw,junkSide,360);
      check(app.heldItem==null,"A valid placement releases the item");
      check(app.model.pile.size()==pileCount-1,"Only one top item leaves per placement");
      if(item.required){
        check(item.state==GameModel.COLLECTED&&app.model.collectedCount()==collectedCount+1,"Food is collected once");
      }else{
        check(item.state==GameModel.SET_ASIDE&&app.model.aside.size()==asideCount+1&&app.model.collectedCount()==collectedCount,"Junk remains aside inside the can, uncollected");
        check(junkSide<640?app.asideX[asideCount]<490:app.asideX[asideCount]>790,"Set-aside art follows the chosen side");
        capture(junkSide<640?"junk-aside-left":"junk-aside-right",()->{for(int frame=0;frame<16;frame++)app.drawGame();});
      }
    }
    check(app.screen==app.CONGRATS,"Every ingredient set opens congratulations");
  }
  public static void main(String[] args)throws Exception{
    app=new TestSketch();out=Paths.get("tmp/qa");Files.createDirectories(out);
    java.lang.reflect.Field path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
    app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);
    app.g.beginDraw();app.uiFont=app.createFont("Arial",18,true);app.headingFont=app.createFont("Arial Bold",28,true);app.g.endDraw();
    app.loadAssets();
    for(int c=0;c<5;c++)for(int a=0;a<4;a++)check(app.catViews[c][a]!=null,"Every coat/view exists");
    checkAvatarInputs();checkAccessoryVisibility();
    app.screen=app.MENU;capture("menu",()->app.drawMenu());
    app.selectedHat=2;app.selectedAccessory=3;app.screen=app.CUSTOMIZE;
    capture("wardrobe-ginger",()->app.drawCustomize());
    for(int c=0;c<5;c++)for(int a=0;a<4;a++){
      final int coat=c,angle=a;app.selectedCat=c;app.setAvatarView(a);
      capture("cat-"+c+"-"+a,()->{app.sceneBackground(app.bg,120);app.catPreview(640,630,420);app.label("COAT "+coat+" / "+angle,640,50,24,app.CREAM);});
    }
    for(int hat=1;hat<=3;hat++)for(int acc=1;acc<=3;acc++){
      app.selectedCat=0;app.setAvatarView(0);app.selectedHat=hat;app.selectedAccessory=acc;
      capture("fit-"+hat+"-"+acc,()->app.drawCustomize());
    }
    app.selectedHat=0;app.selectedAccessory=1;capture("fit-headphones-no-hat",()->app.drawCustomize());
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
    click(640,560);check(app.screen==app.LOADING&&app.model.missionIndex==1,"Next trash also loads");
    app.model.beginSearch();app.model.tick(GameModel.LIMIT_MS);app.screen=app.TIME_UP;capture("timeout",()->app.drawTimeUp());
    click(640,408);check(app.screen==app.LOADING&&app.model.remainingMs==120000,"Retry resets timer");
    for(int mission=1;mission<5;mission++){
      check(app.model.missionIndex==mission,"Next sequential can");
      app.screen=app.FOLDER;click(640,585);check(app.screen==app.OPEN_FOLDER,"Every can opens folder");
      app.screen=app.PAPERS;click(450,330);click(815,330);click(640,615);
      completeMission(1,mission%2==0?390:885);
      if(mission<4){click(640,560);check(app.screen==app.LOADING,"Next trash always loads");}
    }
    check(checkedFoodDrop&&checkedJunkDrop&&checkedOldDrop&&checkedOtherPaw,"Invalid placements and paw ownership were exercised");
    check(app.model.completedCount()==5,"Five ingredient sets finish Level 1");
    capture("level1-complete",()->app.drawCongrats());click(640,560);
    check(app.screen==app.CONGRATS&&app.model.missionIndex==4,"No unimplemented Level 2 navigation");
    app.screen=app.OPTIONS;capture("options",()->app.drawOptions());
    app.screen=app.ACHIEVEMENTS;capture("achievements",()->app.drawAchievements());
    System.out.println("Sketch smoke tests passed: "+checks+" checks; screenshots in "+out);
  }
}
