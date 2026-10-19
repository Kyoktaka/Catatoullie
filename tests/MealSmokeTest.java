import processing.awt.PGraphicsJava2D;
import processing.core.PApplet;
import processing.video.Movie;
import java.nio.file.*;
public class MealSmokeTest {
 static class App extends Catatoullie {
  int videos;
  @Override public String progressPath(){return Paths.get("tmp/qa-meal/save.json").toAbsolutePath().toString();}
  @Override public Movie createEndingMovie(String path){videos++;return null;}
  @Override public void updateKitchenMusic(){}
 }
 static App app;static int checks;
 static void check(boolean ok,String message){checks++;if(!ok)throw new AssertionError(message);}
 static void press(int x,int y){app.lastTick=app.millis();app.mouseX=x;app.mouseY=y;app.mouseButton=PApplet.LEFT;app.mousePressed();}
 static void release(int x,int y){app.lastTick=app.millis();app.mouseX=x;app.mouseY=y;app.mouseReleased();}
 static void click(int x,int y){press(x,y);release(x,y);}
 static void capture(String name)throws Exception{app.g.beginDraw();app.textFont(app.uiFont);app.drawLevel3Entry();app.g.endDraw();app.g.save("tmp/qa-meal/"+name+".png");}
 static void pick(MealModel.Dish dish,boolean source){
  float[] b=source?app.mealSources[dish.ordinal()]:app.mealStackBounds(app.meal.size()-1);
  // Use an actual opaque sprite pixel, independent of transparent padding.
  for(int y=(int)(b[1]-b[3]*.3);y<b[1]+b[3]*.3;y+=2)for(int x=(int)(b[0]-b[2]*.3);x<b[0]+b[2]*.3;x+=2)
   if(app.mealSpriteHit(app.mealFood[dish.ordinal()],b,x,y)){press(x,y);check(app.mealHeld==dish,"Opaque dish pixel grabs "+dish);return;}
  throw new AssertionError("No opaque pixel for "+dish);
 }
 public static void main(String[] args)throws Exception{
  Files.createDirectories(Paths.get("tmp/qa-meal"));app=new App();
  java.lang.reflect.Field path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
  app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);
  app.g.beginDraw();app.uiFont=app.createFont("Arial",18,true);app.headingFont=app.createFont("Arial Bold",28,true);app.initLanguages();app.g.endDraw();app.loadAssets();
  app.enterMeal();check(app.screen!=app.LEVEL3_ENTRY,"Level 3 remains locked");
  app.model.restoreProgress(31);app.cooking.restore(31);java.util.Arrays.fill(app.model.bestStars,3);java.util.Arrays.fill(app.cooking.bestStars,3);app.startEndingMovie(2);check(app.videos==1,"Previous ending starts once");app.finishEndingMovie();
  check(app.screen==app.LEVEL3_ENTRY&&app.meal.phase==MealModel.Phase.INTRO,"Cutscene enters playable intro");capture("01-intro");
  for(processing.core.PImage cat:new processing.core.PImage[]{app.mealEating,app.mealFat}){
   cat.loadPixels();int clear=0,opaque=0,dark=0;
   for(int pixel:cat.pixels){if((pixel>>>24)==0)clear++;else{opaque++;if((pixel&0xffffff)<0x181818)dark++;}}
   check(clear>cat.pixels.length/5&&opaque>cat.pixels.length/3,"Cat matte transparent while body retained");
   check(dark>20,"Enclosed dark cat details preserved");
  }
  app.mealEating.save("tmp/qa-meal/eating-transparent.png");app.mealFat.save("tmp/qa-meal/fat-transparent.png");
  app.updateMeal(5000);check(app.meal.remainingMs==30000,"Intro timer frozen");click(600,580);check(app.meal.phase==MealModel.Phase.STACKING,"Game image starts stacking");capture("03-stacking");
  pick(MealModel.Dish.PIE,true);release(620,600);check(app.meal.size()==0&&app.meal.hearts==2,"Wrong stack order costs one heart");capture("08-mistake");
  pick(MealModel.Dish.BURGER,true);release(400,500);check(app.meal.size()==0&&app.meal.hearts==2,"Outside drop free");
  app.updateMeal(1000);int time=app.meal.remainingMs;click(1150,40);app.updateMeal(10000);check(app.meal.remainingMs==time,"Pause freezes timer");click(600,345);
  click(150,40);check(!app.mealLists,"Task hides papers");click(150,40);check(app.mealLists,"Task restores papers");
  for(MealModel.Dish dish:MealModel.Dish.values()){pick(dish,true);release(620,600);check(app.meal.top()==dish,"Push "+dish);capture("stack-"+dish);}
  check(app.meal.phase==MealModel.Phase.EATING&&app.meal.size()==5,"Same stack enters eating");time=app.meal.remainingMs;app.updateMeal(90000);check(app.meal.remainingMs==time,"Eating untimed");capture("09-full-stack");
  press(620,681);check(app.mealHeld==null&&app.meal.size()==5&&app.meal.hearts==1,"Exposed lower plate cannot be removed and costs one heart");release(825,410);check(app.meal.hearts==1&&app.meal.size()==5,"Release cannot repeat lower-plate penalty");
  for(int i=4;i>=0;i--){MealModel.Dish dish=MealModel.Dish.values()[i];pick(dish,false);release(825,410);check(app.meal.size()==i&&app.meal.eaten==5-i,"Pop "+dish);capture("eat-"+dish);press(620,600);check(app.mealHeld==null,"Animation blocks second input");app.updateMeal(i==0?2200:800);}
  check(app.meal.completed&&app.meal.bestStars==1,"Finish persists remaining-heart rating");app.finaleStarted=app.millis()-1000;capture("19-final");
  check(app.campaignComplete(),"Finale requires all three levels complete");
  for(int lang=0;lang<7;lang++){app.setLanguage(lang,false);capture("ending-language-"+lang);}
  app.setLanguage(0,false);app.vfxAmount=0;capture("ending-no-effects");app.vfxAmount=1;capture("ending-full-effects");
  click(445,592);check(app.screen==app.WORLD_SELECT&&app.meal.completed,"Ending levels button preserves progress");
  app.screen=app.LEVEL3_ENTRY;click(205,592);check(app.screen==app.MENU&&app.meal.completed,"Ending main menu button preserves progress");
  app.meal=new MealModel();app.loadProgress();check(app.meal.completed&&app.meal.bestStars==1&&app.cooking.progressMask()==31&&app.model.progressMask()==31,"Save restores all levels");
  app.enterMeal();check(app.videos==1&&app.meal.size()==0&&app.meal.hearts==3&&app.meal.completed,"Retry keeps achievements without video");click(600,580);app.updateMeal(30000);check(app.meal.phase==MealModel.Phase.FAILED,"Timeout fails");capture("timeout");click(600,345);check(app.meal.phase==MealModel.Phase.INTRO&&app.meal.remainingMs==30000,"Retry resets attempt");
  for(int language=0;language<7;language++){app.setLanguage(language,false);capture("intro-language-"+language);check(!app.tr("Full Course Meal").isEmpty(),"Localized level title");}app.setLanguage(0,false);
  app.key=PApplet.ESC;app.keyPressed();check(app.screen==app.WORLD_SELECT,"Intro escape returns to levels");
  app.resetLevelProgress();check(!app.meal.completed&&app.meal.bestStars==0,"Global reset clears Level 3");
  System.out.println("MealSmokeTest passed: "+checks+" checks");
 }
}
