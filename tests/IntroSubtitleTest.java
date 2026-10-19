import processing.awt.PGraphicsJava2D;
import processing.core.PApplet;
import java.nio.file.*;
public class IntroSubtitleTest {
 static int checks;
 static void check(boolean ok,String why){checks++;if(!ok)throw new AssertionError(why);}
 public static void main(String[] args)throws Exception{
  Catatoullie app=new Catatoullie();
  var path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
  app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);
  app.g.beginDraw();app.initLanguages();app.g.endDraw();
  Files.createDirectories(Paths.get("tmp/qa-subtitles"));
  app.setLanguage(0,false);check(app.introSubtitleAt(13,true).isEmpty()&&app.introSubtitleAt(0,false).isEmpty(),"English has no subtitles");
  for(int language=1;language<7;language++){
   app.setLanguage(language,false);
   check(app.introSubtitleAt(0,true).isEmpty(),"No caption before first cue");
   check(!app.introSubtitleAt(.3f,true).isEmpty(),"First cue starts inclusively");
   check(app.introSubtitleAt(3.8f,true).isEmpty(),"Cue ends exclusively");
   check(app.introSubtitleAt(10,true).isEmpty(),"No stale cue in gap");
   String dream=app.introSubtitleAt(12.5f,true),help=app.introSubtitleAt(16.5f,true);
   check(!dream.isEmpty()&&!help.isEmpty()&&!dream.equals(help),"Story captions advance");
   check(app.introSubtitleAt(22,true).isEmpty(),"Caption clears after story");
   check(app.introSubtitleAt(0,false).equals(dream),"Illustrated first-page caption");
   check(app.introSubtitleAt(15.2f,false).equals(help),"Illustrated last-page caption");
   check(app.introSubtitleAt(19,false).isEmpty(),"Illustrated caption ends");
   if(language>0)check(!dream.equals("Catatoullie dreams of eating a full-course meal."),"Selected language translates captions");
   app.g.beginDraw();app.background(30);app.drawIntroSubtitle(help);app.button("SKIP [SPACE]",1020,660,220,43,true);app.g.endDraw();app.g.save("tmp/qa-subtitles/language-"+language+".png");
  }
  check(app.introSubtitleAt(-1,true).isEmpty()&&app.introSubtitleAt(Float.NaN,true).isEmpty(),"Invalid timestamps ignored");
  app.screen=app.CUTSCENE;app.introDestination=app.LEVEL_SELECT;app.mouseX=1130;app.mouseY=681;app.mouseButton=PApplet.LEFT;app.mousePressed();check(app.screen==app.LEVEL_SELECT,"Skip still reaches Level 1 selection");
  System.out.println("IntroSubtitleTest passed: "+checks+" checks");
 }
}
