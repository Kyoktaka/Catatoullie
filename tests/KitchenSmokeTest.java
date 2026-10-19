import processing.awt.PGraphicsJava2D;
import processing.core.PApplet;
import processing.video.Movie;
import java.nio.file.*;
import java.util.*;

/** Real sketch handlers, offscreen graphics, isolated save, deterministic video failure. */
public class KitchenSmokeTest {
  static class KitchenSketch extends Catatoullie {
    int movieStarts=0,introStarts=0;
    @Override public void startIntroMedia(){introStarts++;}
    @Override public String progressPath(){return Paths.get("tmp/qa-kitchen/save.json").toAbsolutePath().toString();}
    @Override public Movie createEndingMovie(String source){movieStarts++;return null;}
    @Override public void updateKitchenMusic(){}
  }
  static KitchenSketch app;
  static int checks;
  static Path out=Paths.get("tmp/qa-kitchen");
  static void check(boolean result,String message){checks++;if(!result)throw new AssertionError(message);}
  static void press(int x,int y){app.lastTick=app.millis();app.mouseX=x;app.mouseY=y;app.mouseButton=PApplet.LEFT;app.mousePressed();}
  static void drag(int x,int y){app.mouseX=x;app.mouseY=y;app.mouseDragged();}
  static void release(int x,int y){app.lastTick=app.millis();app.mouseX=x;app.mouseY=y;app.mouseReleased();}
  static void click(int x,int y){press(x,y);release(x,y);}
  static void capture(String name){
    app.g.beginDraw();app.textFont(app.uiFont);app.imageMode(PApplet.CORNER);app.rectMode(PApplet.CORNER);app.ellipseMode(PApplet.CENTER);app.noTint();app.drawKitchenScreen();app.g.endDraw();app.g.save(out.resolve(name+".png").toString());
  }
  static void finishKitchenLoad(){
    check(app.screen==app.COOK_LOADING,"Stage enters loading screen");
    app.kitchenLoadingStarted=app.millis();int timer=app.cooking.remainingMs;
    CookingModel.Action action=app.cooking.action();click(1021,195);
    check(app.screen==app.COOK_LOADING&&app.cooking.action()==action&&app.kitchenHeld.isEmpty(),"Loading rejects gameplay input");
    app.g.beginDraw();app.lastTick=app.millis()-5000;app.draw();app.g.endDraw();
    check(app.cooking.remainingMs==timer,"Loading does not consume countdown time");
    app.advanceKitchenLoading(app.KITCHEN_LOADING_MS-1);check(app.screen==app.COOK_LOADING,"Loading respects minimum duration");
    capture("loading-dish-"+app.cooking.dish+"-stage-"+app.cooking.dequeued.size());
    app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);
    check(app.screen==app.COOK_GAME||app.screen==app.COOK_TUTORIAL,"Loading reaches intended stage screen");
    check(app.cooking.remainingMs==timer,"Stage starts with countdown intact");
  }
  static void checkLevelBorders(){
    GameModel originalModel=app.model;CookingModel originalCooking=app.cooking;
    app.model=new GameModel();app.cooking=new CookingModel();
    check(!app.levelPerfect(0)&&!app.levelPerfect(1)&&!app.levelPerfect(2),"New and unavailable levels are not perfect");
    app.model.restoreProgress(31);app.cooking.restore(31);
    Arrays.fill(app.model.bestStars,3);Arrays.fill(app.cooking.bestStars,3);
    for(int level=0;level<2;level++){
      check(app.levelPerfect(level),"All 15 stars earn perfect border for level "+level);
      int[] stars=level==0?app.model.bestStars:app.cooking.bestStars;
      stars[4]=2;check(!app.levelPerfect(level),"Fourteen stars do not earn gold border");stars[4]=3;
    }
    app.g.beginDraw();app.textFont(app.uiFont);app.drawWardrobeMaps();app.g.endDraw();app.g.save(out.resolve("maps-perfect.png").toString());
    check((app.g.get(350,210)&0xffffff)==(app.GOLD&0xffffff)&& (app.g.get(680,210)&0xffffff)==(app.GOLD&0xffffff),"Maps renders both perfect level borders in gold");
    app.model.bestStars[0]=2;app.cooking.bestStars[0]=2;
    app.g.beginDraw();app.drawWardrobeMaps();app.g.endDraw();app.g.save(out.resolve("maps-partial.png").toString());
    check((app.g.get(350,210)&0xffffff)!=(app.GOLD&0xffffff)&&(app.g.get(680,210)&0xffffff)!=(app.GOLD&0xffffff),"Maps removes gold when stars are incomplete");
    app.g.beginDraw();app.sceneBackground(app.bg,160);int backdrop=app.g.get(100,200);app.drawWorldSelect();app.g.endDraw();
    check(app.g.get(100,200)==backdrop,"World selection has no card background or border");
    app.g.save(out.resolve("world-selection.png").toString());
    app.model=originalModel;app.cooking=originalCooking;
  }
  static void grabSource(String source){
    if(app.cooking.equipment.containsKey(source)&&!source.equals("board")){
      float[] b=app.kitchenEquipmentBounds(source);press(Math.round(b[0]+b[2]/2),Math.round(b[1]+b[3]/2));
      check(app.kitchenHeld.equals(source),"Placed tool can be reused: "+source);return;
    }
    if(app.cooking.prepared.contains(source)){
      float[] b=app.preparedBounds(source);press(Math.round(b[0]+b[2]/2),Math.round(b[1]+b[3]/2));
      check(app.kitchenHeld.equals(source),"Prepared ingredient comes from its own tray: "+source);return;
    }
    int station=app.kitchenStorageFor(source);float[] stationBounds=app.kitchenStationBounds(station);
    click(Math.round(stationBounds[0]+stationBounds[2]/2),Math.round(stationBounds[1]+stationBounds[3]/2));
    check(app.kitchenStorage==station,"Kitchen hotspot opens correct storage");
    ArrayList<String> ids=app.kitchenStorageItems();int index=ids.indexOf(source);check(index>=0,"Visible source exists: "+source);
    app.kitchenPage=index/6;float[] b=app.kitchenStorageCard(index%6);
    press(Math.round(b[0]+b[2]/2),Math.round(b[1]+b[3]/2));
    check(app.kitchenHeld.equals(source)&&app.kitchenStorage==-1,"Source leaves storage for world-space dragging: "+source);
  }
  static void completeDish(){
    int guard=0,lastStage=-1,stageLoads=0;
    while(!app.cooking.complete()){
      if(app.screen==app.COOK_LOADING){stageLoads++;finishKitchenLoad();}
      check(++guard<350,"UI recipe terminates");app.syncKitchenSource();
      CookingModel.Action action=app.cooking.action();int before=app.cooking.dequeued.size();
      if(lastStage!=before){capture("dish-"+app.cooking.dish+"-stage-"+before);lastStage=before;}
      if(action.mode==CookingModel.Mode.HEAT){
        capture("heat-ready-"+app.cooking.dish);click(390,430);check(app.kitchenStove,"Stove opens closeup");capture("stove-closeup");click(640,537);check(app.cooking.heating,"Burner click starts timed cooking");
        app.cooking.tick(1000,false);capture("heat-active-"+app.cooking.dish);
        app.cooking.tick(action.duration-1000,false);app.updateCookingState();
      }else{
        for(int repetition=action.progress;repetition<action.repetitions;repetition++){
          grabSource(action.source);float[] t=app.kitchenTarget(action.target);int x=Math.round(t[0]+t[2]/2),y=Math.round(t[1]+t[3]/2);

          drag(x,y);release(x,y);check(app.kitchenHeld.isEmpty(),"Release clears dragging state");
          if(action.mode==CookingModel.Mode.GESTURE){
            check(app.cooking.gesturing&&!action.done(),"One direct drag starts utensil animation");
            app.grabKitchenObject(action.source);check(app.kitchenHeld.isEmpty(),"No second pickup during animation");
            click(45,570);int elapsed=app.cooking.gestureElapsed,timer=app.cooking.remainingMs;
            app.cooking.tick(10000,app.kitchenPaused);check(app.kitchenPaused&&elapsed==app.cooking.gestureElapsed&&timer==app.cooking.remainingMs,"Pause freezes utensil motion");
            click(640,282);app.cooking.tick(action.duration/2,false);
            capture("gesture-"+app.cooking.dish+"-"+action.source+"-"+action.target);
            app.cooking.tick(action.duration-action.duration/2,false);app.updateCookingState();
          }
        }
      }
      check(action.done(),"Required interaction completes active action");
      if(CookingModel.RAW.contains(action.source)&&action.target.equals("board")){
        check(!app.cooking.storedIngredients().contains(action.source),"Placed raw ingredient disappears from storage");
        app.grabKitchenObject(action.source);check(app.kitchenHeld.isEmpty(),"Placed raw ingredient cannot be duplicated");
      }
      if(app.cooking.dish==4&&app.cooking.prepared.size()>=6)capture("burger-prepared-trays");
      check(app.cooking.dequeued.size()-before<=1,"One interaction never skips FIFO stages");
    }
    check(stageLoads==4,"All four recipe-stage boundaries show loading");
    check(app.screen==app.COOK_SUCCESS,"Success screen follows final action");
    check(app.wardrobe.cookingClaimed[app.cooking.dish],"Completed dish awards a wardrobe reward");
    int hat=app.wardrobe.cookingRewardHats[app.cooking.dish];app.updateCookingState();
    check(app.newCookingReward&&app.wardrobe.cookingRewardHats[app.cooking.dish]==hat,"Repeated state checks preserve the original reward presentation");
    capture("dish-"+app.cooking.dish+"-success");
  }
  static void checkAudio()throws Exception{
    Catatoullie.GentleAudio audio=app.new GentleAudio();audio.gain=0;
    long silent=0,clickEnergy=0;for(int i=0;i<2000;i++)silent+=Math.abs(audio.renderSample(i));
    check(silent==0,"Music zero produces silence without effects");
    app.gentleAudio=audio;press(45,570);
    for(int i=0;i<2000;i++)clickEnergy+=Math.abs(audio.renderSample(i));
    check(clickEnergy>0,"Mouse feedback remains audible at Music zero");
    app.screen=app.OPTIONS;click(600,238);check(app.sfxVolume==0,"Effects slider reaches zero");
    audio.clickRemaining=1400;long muted=0;for(int i=0;i<2000;i++)muted+=Math.abs(audio.renderSample(i));
    check(muted==0,"Effects zero mutes button feedback");
    click(760,238);check(app.sfxVolume>.45&&app.sfxVolume<.55,"Effects slider has independent intermediate volume");
    app.sfxVolume=0;app.loadProgress();check(app.sfxVolume>.45&&app.sfxVolume<.55,"Effects setting persists in save");
    app.sfxVolume=.7f;audio.effectsGain=.7f;audio.clickRemaining=0;app.gentleAudio=null;app.screen=app.MENU;
    audio.gain=.35f;audio.scavenging=true;byte[] pcm=new byte[22050*10*2];long different=0;
    Catatoullie.GentleAudio menu=app.new GentleAudio();menu.gain=.35f;
    for(int i=0;i<pcm.length/2;i++){int sample=audio.renderSample(i);different+=Math.abs(sample-menu.renderSample(i));pcm[i*2]=(byte)sample;pcm[i*2+1]=(byte)(sample>>8);}
    check(different>0,"Level 1 has a distinct original soundtrack");
    javax.sound.sampled.AudioFormat format=new javax.sound.sampled.AudioFormat(22050,16,1,true,false);
    try(javax.sound.sampled.AudioInputStream stream=new javax.sound.sampled.AudioInputStream(new java.io.ByteArrayInputStream(pcm),format,pcm.length/2)){
      javax.sound.sampled.AudioSystem.write(stream,javax.sound.sampled.AudioFileFormat.Type.WAVE,out.resolve("level1-music-preview.wav").toFile());
    }
  }
  static void checkGeometry(){
    int originalWidth=app.width,originalHeight=app.height;
    for(int[] viewport:new int[][]{{1280,720},{1600,900},{1280,900}}){
      app.width=viewport[0];app.height=viewport[1];app.updateKitchenSceneGeometry();
      float scale=Math.max(viewport[0]/2012f,viewport[1]/1258f),ox=(viewport[0]-2012*scale)/2,oy=(viewport[1]-1258*scale)/2;
      check(Math.abs(app.kitchenStationBounds(2)[1]-(oy+411*scale))<.01,"Fridge outline follows cover crop");
      float[][] landmarks={{935,890},{130,315},{1640,530}};
      for(int station=0;station<3;station++)check(app.kitchenStationHit(station,ox+landmarks[station][0]*scale,oy+landmarks[station][1]*scale),"Physical storage landmark is clickable at each viewport");
      check(!app.kitchenStationHit(2,ox+1510*scale,oy+797*scale),"Fridge click region excludes the foreground counter");
      check(!app.kitchenStationHit(1,ox+250*scale,oy+140*scale),"Cupboard excludes wall above sloping door edge");
    }
    app.width=originalWidth;app.height=originalHeight;app.updateKitchenSceneGeometry();
  }
  static void checkLanguageDropdown(){
    app.screen=app.OPTIONS;int original=app.language;
    click(780,471);check(app.languageDropdownOpen,"Language selector opens dropdown");
    app.g.beginDraw();app.drawOptions();app.g.endDraw();app.g.save(out.resolve("options-language-dropdown.png").toString());
    app.key=PApplet.CODED;app.keyCode=PApplet.DOWN;app.keyPressed();
    check(app.languageDropdownIndex==(original+1)%7,"Arrow keys navigate language options");
    app.key=PApplet.ENTER;app.keyPressed();check(!app.languageDropdownOpen&&app.language==(original+1)%7,"Enter selects a language");
    click(780,471);app.key=PApplet.ESC;app.keyPressed();check(!app.languageDropdownOpen&&app.screen==app.OPTIONS,"Escape dismisses dropdown without leaving Options");
    click(780,471);float volume=app.musicVolume;click(921,166);
    check(!app.languageDropdownOpen&&app.musicVolume==volume,"Dropdown consumes outside click without changing an underlying slider");
    app.setLanguage(original,false);app.screen=app.MENU;
  }
  public static void main(String[] args)throws Exception {
    Files.createDirectories(out);app=new KitchenSketch();
    java.lang.reflect.Field path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
    app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);
    app.g.beginDraw();app.uiFont=app.createFont("Arial",18,true);app.headingFont=app.createFont("Arial Bold",28,true);app.initLanguages();app.g.endDraw();
    app.loadAssets();app.initKitchenAssets();
    for(String key:app.kitchenPaths.keySet())check(app.kitchenImage(key)!=null,"Mapped sprite loads: "+key);
    processing.core.PImage egg=app.kitchenImage("egg");egg.loadPixels();
    check((egg.pixels[0]>>>24)==0&&(egg.pixels[egg.width-1]>>>24)==0,"Egg gray border removed from cached sprite");
    checkAudio();checkLevelBorders();checkGeometry();checkLanguageDropdown();
    app.startCooking(0);check(app.cooking.dish==-1,"Level 2 locked before Level 1 completion");
    app.model.restoreProgress(31);app.model.missionIndex=4;app.screen=app.CONGRATS;
    click(640,500);check(app.screen==app.ENDING_MOVIE&&app.movieStarts==1,"Level 1 ending only starts from NEXT LEVEL");
    app.startEndingMovie(1);check(app.movieStarts==1,"Repeated ending starts suppressed");capture("ending-error");
    app.advanceEndingPlayback(10,10,true);check(app.screen==app.COOK_SELECT,"Video completion opens dish selection");capture("selection-initial");
    click(635,235);check(app.cooking.dish==-1,"Locked dish cannot start");click(300,235);
    finishKitchenLoad();
    check(app.screen==app.COOK_TUTORIAL&&!app.cooking.searching,"First dish opens untimed tutorial");
    for(int page=0;page<5;page++){
      check(app.tutorialPage==page,"Tutorial pages follow order");capture("tutorial-"+page);
      if(page==1){int count=app.cooking.cookingQueue.size();click(1120,678);check(app.tutorialPage==1,"Practice waits for a real drag");click(85,180);check(app.kitchenStorage==1,"Practice opens the real cupboard hotspot");capture("tutorial-cupboard");press(425,260);drag(600,650);release(600,650);check(app.tutorialPractice&&app.cooking.cookingQueue.size()==count,"Practice cannot mutate real cooking queue");}
      click(1120,678);
    }
    check(app.screen==app.COOK_GAME&&app.cooking.searching&&app.cooking.remainingMs==300000,"Timer starts after tutorial");
    click(1200,150);check(app.kitchenNote,"Recipe paper opens checklist");capture("recipe-note");
    CookingModel.Action noteAction=app.cooking.action();click(640,230);check(app.cooking.action()==noteAction,"Checklist never skips FIFO steps");
    click(1000,120);check(!app.kitchenNote,"Checklist closes");
    int[][] stationLandmarks={{590,560},{85,180},{1040,260}};
    for(int station=0;station<3;station++){
      app.mouseX=stationLandmarks[station][0];app.mouseY=stationLandmarks[station][1];capture("station-hover-"+station);
      click(stationLandmarks[station][0],stationLandmarks[station][1]);
      check(app.kitchenStorage==station,"Storage hotspot opens");capture("storage-"+station);
      app.key=PApplet.ESC;app.keyPressed();check(app.kitchenStorage==-1&&!app.kitchenPaused,"Escape closes storage without pausing");
    }
    click(965,470);check(app.kitchenStorage==-1,"Counter in front of fridge does not open storage");
    int size=app.cooking.cookingQueue.size();CookingModel.Action first=app.cooking.action();
    click(40,165);check(app.cooking.action()==first&&app.cooking.cookingQueue.size()==size,"Checklist click cannot advance cooking");
    grabSource("board");drag(500,200);release(500,200);check(app.kitchenHeld.isEmpty()&&app.cooking.action()==first,"Wrong drop returns source without progress");
    grabSource("knife");float[] prep=app.kitchenTarget("prep");drag(600,580);release(600,580);check(app.cooking.action()==first,"Later action cannot be completed early");
    grabSource("board");click(45,570);check(app.kitchenPaused&&app.kitchenHeld.isEmpty(),"Pausing safely cancels held object");
    int timer=app.cooking.remainingMs;app.cooking.tick(99999,app.kitchenPaused);check(app.cooking.remainingMs==timer,"Paused timer frozen");capture("paused");click(640,282);
    app.key='h';app.keyPressed();check(app.screen==app.COOK_TUTORIAL,"Help replays tutorial during a dish");
    app.g.beginDraw();app.lastTick=app.millis()-5000;app.draw();app.g.endDraw();check(app.cooking.remainingMs==timer,"Replayed tutorial freezes the real game clock");
    click(100,678);check(app.screen==app.COOK_GAME&&app.cooking.action()==first&&app.cooking.remainingMs==timer,"Tutorial replay preserves attempt state and timer");
    app.key=PApplet.CODED;app.keyCode=java.awt.event.KeyEvent.VK_F3;app.keyPressed();check(app.fifoDebug,"F3 exposes FIFO debug overlay");capture("fifo-debug");app.keyPressed();
    completeDish();int finishedTimer=app.cooking.remainingMs;
    check(app.movieStarts==1,"No cutscene after an individual dish");click(640,545);finishKitchenLoad();check(app.cooking.dish==1&&app.screen==app.COOK_GAME,"Next dish bypasses completed tutorial");
    app.cooking.tick(300000,false);app.updateCookingState();check(app.screen==app.COOK_TIMEOUT&&!app.cooking.completed[1],"Timeout does not unlock dish");capture("timeout");
    click(640,383);finishKitchenLoad();check(app.cooking.remainingMs==300000&&app.cooking.cookingQueue.size()==5&&app.cooking.completed[0],"Retry restores queue and preserves earned progress");
    for(int dish=1;dish<5;dish++){
      check(app.cooking.dish==dish,"Sequential cooking progression");completeDish();
      if(dish<4){click(640,545);finishKitchenLoad();}
    }
    check(app.cooking.progressMask()==31&&app.movieStarts==1,"All dishes finish before ending video");
    capture("level2-complete");click(640,545);check(app.endingLevel==2&&app.movieStarts==2&&app.endingSource.equals("LEVEL2/level2-cutscene-after.mp4"),"Final NEXT LEVEL starts correct MP4");
    click(1130,681);check(app.screen==app.LEVEL3_ENTRY&&app.cooking.progressMask()==31,"Skip enters Level 3 intro with progress intact");capture("level3-entry");
    app.cooking.tutorialSeen=true;app.saveProgress();app.cooking=new CookingModel();app.model=new GameModel();app.loadProgress();
    check(app.model.completedCount()==5&&app.cooking.progressMask()==31&&app.cooking.tutorialSeen,"Save restores both levels and tutorial state");
    Files.writeString(Paths.get(app.progressPath()),"{\"version\":3,\"completed\":31,\"cat\":4,\"hat\":3,\"music\":0.4}");
    app.cooking=new CookingModel();app.model=new GameModel();app.loadProgress();check(app.level2Unlocked()&&app.cooking.progressMask()==0&&app.selectedCat==4&&app.selectedHat==3,"Version 3 migration unlocks Level 2 without inventing progress");
    app.cooking.tutorialSeen=true;app.startCooking(0);finishKitchenLoad();
    for(int language=0;language<7;language++){
      app.setLanguage(language,false);app.screen=app.COOK_SELECT;capture("selection-language-"+language);
      app.screen=app.COOK_GAME;capture("cooking-language-"+language);
      for(CookingModel.CookingStep stage:app.cooking.recipe)check(app.translations.hasKey(stage.name),"Cooking stage has translations");
      if(language>0)check(!app.kitchenActionText(app.cooking.action()).equals("Drag Chopping board to Work area."),"Dynamic cooking guidance translates");
    }
    // Entry cutscenes and a progress-only reset use actual button handlers.
    app.model.restoreProgress(31);app.screen=app.MENU;click(1100,465);
    check(app.screen==app.CUTSCENE&&app.introDestination==app.WORLD_SELECT,"PLAY always opens intro before world selection");
    app.finishCutscene();click(220,300);check(app.screen==app.CUTSCENE&&app.introDestination==app.LEVEL_SELECT,"Level 1 replay opens intro");
    app.finishCutscene();app.screen=app.WORLD_SELECT;click(620,300);
    check(app.screen==app.ENDING_MOVIE&&app.endingLevel==1,"Level 2 entry plays Level 1 ending first");app.finishEndingMovie();
    app.screen=app.CUSTOMIZE;app.wardrobeTab=1;click(350,300);check(app.screen==app.CUTSCENE,"Maps Level 1 opens intro");app.finishCutscene();
    app.screen=app.CUSTOMIZE;click(650,300);check(app.screen==app.ENDING_MOVIE,"Maps Level 2 opens previous ending");app.finishEndingMovie();
    for(int selector:new int[]{app.LEVEL_SELECT,app.COOK_SELECT,app.LEVEL3_ENTRY}){
      app.screen=selector;int x=selector==app.LEVEL3_ENTRY?640:100,y=selector==app.LEVEL3_ENTRY?657:677;
      click(x,y);check(app.screen==app.WORLD_SELECT,"Back returns to levels from selector "+selector);
      app.screen=selector;app.key=PApplet.ESC;app.keyPressed();check(app.screen==app.WORLD_SELECT,"Escape returns to levels from selector "+selector);
    }
    int rewardHat=app.wardrobe.cookingRewardHats[0],rewardAccessory=app.wardrobe.cookingRewardAccessories[0];
    app.selectedHat=rewardHat;app.selectedAccessory=rewardAccessory;app.cooking.restore(31);
    app.screen=app.OPTIONS;click(780,605);check(app.confirmProgressReset,"Reset requires explicit confirmation");
    click(500,430);check(app.model.completedCount()==5,"Cancel preserves progress");click(780,605);click(760,430);
    check(app.model.completedCount()==0&&app.cooking.progressMask()==0&&!app.level2Unlocked(),"Reset relocks levels and clears completion");
    check(app.wardrobe.hats[rewardHat]&&app.wardrobe.accessories[rewardAccessory]&&app.selectedHat==rewardHat&&app.selectedAccessory==rewardAccessory,"Reset preserves wearable rewards");
    app.wardrobe=new WardrobeInventory();app.loadProgress();check(app.wardrobe.hats[rewardHat]&&app.wardrobe.accessories[rewardAccessory]&&app.model.completedCount()==0&&app.wardrobe.cookingClaimed[0],"Rewards survive reset and save reload");
    check(app.insideTrash(310,377)&&app.insideTrash(970,377)&&!app.insideTrash(1015,377),"Placement reaches bin edges but excludes collection bag");
    app.g.beginDraw();app.screen=app.OPTIONS;app.drawOptions();app.g.endDraw();app.g.save(out.resolve("reset-options.png").toString());
    System.out.println("KitchenSmokeTest passed: "+checks+" checks; screenshots in "+out);
  }
}
