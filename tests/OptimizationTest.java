import processing.awt.PGraphicsJava2D;
import processing.core.*;
import processing.data.*;
import java.nio.file.*;

/** Regression cases for interrupted input, missing assets and damaged saves. */
public class OptimizationTest {
  static class App extends Catatoullie {
    int clock=60000;
    boolean failWrites=false;
    @Override public int millis(){return clock;}
    @Override public String progressPath(){return Paths.get("tmp/qa-optimization/save.json").toAbsolutePath().toString();}
    @Override public void updateMusic(){}
    @Override public boolean saveJSONObject(JSONObject data,String filename){return !failWrites&&super.saveJSONObject(data,filename);}
  }
  static class MissingArt extends App {
    int requests;
    @Override public PImage asset(String path){requests++;return null;}
  }
  static class MissingFoodMap extends App {
    int requests;
    @Override public JSONArray loadJSONArray(String filename){requests++;return null;}
  }
  static App app;
  static int checks,failures;
  static void check(boolean ok,String message){checks++;if(!ok){failures++;System.out.println("FAIL: "+message);}}
  static void press(int x,int y){app.mouseX=x;app.mouseY=y;app.mouseButton=PApplet.LEFT;app.mousePressed();}
  static void release(int x,int y){app.mouseX=x;app.mouseY=y;app.mouseButton=PApplet.LEFT;app.mouseReleased();}
  static void paint(Runnable draw){app.g.beginDraw();app.textFont(app.uiFont);draw.run();app.g.endDraw();}
  static void initialize(App sketch)throws Exception{
    var path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(sketch,Paths.get("").toAbsolutePath().toString());
    sketch.width=1280;sketch.height=720;sketch.g=new PGraphicsJava2D();sketch.g.setParent(sketch);sketch.g.setPrimary(false);sketch.g.setSize(1280,720);
    sketch.g.beginDraw();sketch.uiFont=sketch.createFont("Arial",18,true);sketch.headingFont=sketch.createFont("Arial Bold",28,true);sketch.g.endDraw();
  }
  static void search(){app.beginMission(0);app.model.beginSearch();app.screen=app.GAME;app.lastTick=app.clock;}
  public static void main(String[] args)throws Exception{
    Files.createDirectories(Paths.get("tmp/qa-optimization"));app=new App();initialize(app);
    search();GameModel.Item top=app.model.top();app.heldItem=top;app.holdingPaw=0;app.activePaw=0;
    press(1220,40);check(app.paused&&app.activePaw<0,"Mouse pause cancels paw capture");
    check(app.model.top()==top&&app.model.pile.size()==12,"Pause preserves the logical stack");
    app.clock+=5000;press(600,275);check(!app.paused&&app.lastTick==app.clock,"Resume excludes paused wall time");
    search();app.activePaw=0;press(1170,40);check(app.showHelp&&app.activePaw<0,"Help cancels paw capture");
    app.clock+=3000;press(600,540);check(!app.showHelp&&app.lastTick==app.clock,"Closing help resets timer origin");
    app.model.restoreProgress(31);app.cooking.tutorialSeen=true;app.startCooking(0);app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);
    app.kitchenStorage=2;press(45,570);check(!app.kitchenPaused&&app.kitchenStorage==2,"Storage blocks clicks through to Pause");
    app.startCooking(0);app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);app.kitchenNote=true;press(100,625);check(app.screen==app.COOK_GAME&&app.kitchenNote,"Recipe modal blocks clicks through to Main Menu");
    app.kitchenNote=false;app.startCooking(0);app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);
    app.kitchenHeld="board";app.kitchenGrabX=400;app.kitchenGrabY=230;app.kitchenTravel=0;
    float[] target=app.kitchenTarget("prep");release(Math.round(target[0]+target[2]/2),Math.round(target[1]+target[3]/2));
    check(app.cooking.equipment.containsKey("board"),"Release position completes a fast drop without a drag event");
    app.startCooking(0);app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);app.kitchenHeld="board";app.kitchenTravel=200;
    app.mouseX=600;app.mouseY=660;app.mouseButton=PApplet.RIGHT;app.mouseReleased();
    check(app.kitchenHeld.equals("board")&&app.cooking.equipment.isEmpty(),"Right release cannot commit a left drag");
    app.tutorialDragging=true;app.goMenu();check(!app.tutorialDragging&&app.kitchenHeld.isEmpty(),"Leaving tutorial clears captured input");
    app.screen=app.MENU;app.vfxAmount=1;app.burst(640,360,20,app.GOLD);paint(()->app.drawEffects(1500));
    check(app.particles.isEmpty(),"Particle lifetime follows elapsed time after a frame stall");
    MissingArt missing=new MissingArt();initialize(missing);missing.initKitchenAssets();int requests=missing.requests;missing.initKitchenAssets();
    check(missing.requests==requests,"Missing kitchen background is attempted once");
    missing.initKitchenNavigationArt();requests=missing.requests;missing.initKitchenNavigationArt();check(missing.requests==requests,"Missing navigation art is attempted once");
    app.model=new GameModel();app.cooking=new CookingModel();app.wardrobe=new WardrobeInventory();
    Files.writeString(Paths.get(app.progressPath()),"{\"version\":6,\"completed\":31,\"stars\":[3,\"broken\",3],\"cat\":4,\"rewards\":[null],\"music\":0.2,\"sfx\":0.4,\"cookingCompleted\":31,\"mealCompleted\":true,\"mealStars\":2}");
    app.loadProgress();check(app.model.completedCount()==5&&app.selectedCat==4,"Malformed rating does not discard valid customization");
    check(app.cooking.progressMask()==31&&app.meal.completed&&app.meal.bestStars==2,"Malformed reward does not discard later levels");
    check(Math.abs(app.musicVolume-.2f)<.001f&&Math.abs(app.sfxVolume-.4f)<.001f,"Malformed save field does not discard settings");
    app.musicVolume=Float.NaN;app.sfxVolume=Float.POSITIVE_INFINITY;app.saveProgress();
    JSONObject saved=app.loadJSONObject(app.progressPath());
    check(saved!=null&&Float.isFinite(saved.getFloat("music",Float.NaN))&&Float.isFinite(saved.getFloat("sfx",Float.NaN)),"Saved volume values stay finite");
    String originalSave=Files.readString(Paths.get(app.progressPath()));app.failWrites=true;app.saveProgress();app.failWrites=false;
    check(originalSave.equals(Files.readString(Paths.get(app.progressPath()))),"Failed temporary write preserves the previous save");
    try(var files=Files.list(Paths.get(app.progressPath()).getParent())){check(files.noneMatch(p->p.getFileName().toString().startsWith("savegame-")),"Failed saves clean up temporary files");}
    app.key=PApplet.ESC;app.keyCode=27;app.keyEvent=new processing.event.KeyEvent(null,0,processing.event.KeyEvent.PRESS,0,PApplet.ESC,27,true);search();app.keyPressed();
    check(!app.paused,"Keyboard auto-repeat cannot toggle pause");app.keyEvent=null;
    search();app.activePaw=0;app.focusLost();app.applyFocusPause();check(app.paused&&app.activePaw<0,"Focus loss freezes the search and releases pointer capture");
    app.paused=false;app.model.restoreProgress(31);app.startCooking(0);app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);
    app.cooking.equipment.put("knife","prep");float[] tool=app.kitchenEquipmentBounds("knife");
    app.mouseX=Math.round(tool[0]+8);app.mouseY=Math.round(tool[1]+11);app.grabKitchenObject("knife");
    check(Math.abs(app.mouseX+app.kitchenOffsetX-tool[0])<.001f&&Math.abs(app.mouseY+app.kitchenOffsetY-tool[1])<.001f,"Kitchen pickup preserves the grab offset");
    app.cooking.restore(31);app.enterMeal();app.meal.begin();float[] source=app.mealSources[0];
    // Use the supplied sprite's actual opaque hit area when checking the handler.
    boolean picked=false;
    for(int y=-25;y<=25&&!picked;y+=5)for(int x=-25;x<=25&&!picked;x+=5){press(Math.round(source[0]+x),Math.round(source[1]+y));picked=app.mealHeld!=null;}
    check(picked&&Math.abs(app.mouseX+app.mealOffsetX-source[0])<.001f&&Math.abs(app.mouseY+app.mealOffsetY-source[1])<.001f,"Meal pickup preserves the grab offset");
    app.screen=app.MENU;app.particles.clear();
    for(int i=0;i<20;i++){final float shade=i;paint(()->app.sceneBackground(null,shade));}
    check(app.backdropLayers.size()<=8,"Backdrop cache remains bounded across scene changes");
    PImage marker=app.createImage(24,24,PApplet.RGB);marker.loadPixels();java.util.Arrays.fill(marker.pixels,0xffaa3355);marker.updatePixels();
    paint(()->{app.background(app.INK);app.image(marker,0,0,app.width,app.height);app.noStroke();app.fill(app.INK,24);app.rect(0,0,app.width,app.height);});app.g.loadPixels();int[] originalPixels=app.g.pixels.clone();
    paint(()->app.sceneBackground(marker,24));app.g.loadPixels();check(java.util.Arrays.equals(originalPixels,app.g.pixels),"Cached backdrop preserves every output pixel");
    MissingFoodMap food=new MissingFoodMap();initialize(food);food.ensureFoodArt(0);food.ensureFoodArt(0);
    check(food.requests==1&&food.foodArt.length==GameModel.RECIPES[0].length,"Missing ingredient manifest neither crashes nor retries during drawing");
    Files.writeString(Paths.get(app.progressPath()),"{damaged");app.loadProgress();check(app.model.completedCount()==5,"Malformed JSON does not crash or discard in-memory progress");
    search();app.activePaw=0;app.pawOffsetX=0;app.pawOffsetY=0;app.mouseX=605;app.mouseY=377;app.movePaw();
    check(app.heldItem==app.model.top()&&Math.abs(app.pawX[0]+app.heldOffsetX-app.PILE_X)<.001f&&Math.abs(app.pawY[0]+app.heldOffsetY-app.PILE_Y)<.001f,"Paw pickup preserves the top item's position when grabbed off-center");
    app.focusLost();release(1110,260);check(app.paused&&app.activePaw<0&&app.model.collectedCount()==0,"Release arriving before the next draw respects queued focus loss");
    System.out.println("OptimizationTest: "+(checks-failures)+"/"+checks+" passed");
    if(failures>0)throw new AssertionError(failures+" optimization regressions");
  }
}
