import processing.awt.PGraphicsJava2D;
import processing.core.PApplet;
import processing.core.PImage;
import java.lang.management.ManagementFactory;
import java.nio.file.*;
import java.util.*;

/** Repeatable Java2D render benchmark, not a display FPS or speaker test. */
public class PerformanceProbe {
  static class App extends Catatoullie {
    int clock=60000, imageLoads=0;
    boolean effectsOnly=false;
    @Override public int millis(){return clock;}
    @Override public PImage loadImage(String path){imageLoads++;return super.loadImage(path);}
    @Override public void saveProgress(){}
    @Override public void updateMusic(){}
    @Override public void draw(){if(effectsOnly){background(INK);drawEffects(16);}else super.draw();}
  }
  static App app;
  static Path out;
  static boolean particleStress=false;
  static final int WARMUP=40, FRAMES=180;
  static final com.sun.management.ThreadMXBean threads=(com.sun.management.ThreadMXBean)ManagementFactory.getThreadMXBean();
  static final long threadId=Thread.currentThread().getId();
  static void frame(){
    if(particleStress)for(Catatoullie.GameParticle particle:app.particles){particle.life=1;particle.x=640;particle.y=360;}
    app.g.beginDraw();app.lastTick=app.clock;app.draw();app.g.endDraw();app.clock+=16;
  }
  static void scene(String name,Runnable setup)throws Exception{
    long cold=System.nanoTime();int coldLoads=app.imageLoads;setup.run();frame();cold=System.nanoTime()-cold;
    int sceneLoads=app.imageLoads-coldLoads;
    for(int i=0;i<WARMUP;i++)frame();
    long[] ns=new long[FRAMES];long allocated=threads.getThreadAllocatedBytes(threadId);int loads=app.imageLoads;
    for(int i=0;i<FRAMES;i++){long start=System.nanoTime();frame();ns[i]=System.nanoTime()-start;}
    allocated=threads.getThreadAllocatedBytes(threadId)-allocated;
    long sum=0;for(long n:ns)sum+=n;Arrays.sort(ns);
    double mean=sum/(FRAMES*1e6),p95=ns[(int)(FRAMES*.95)]/1e6,p99=ns[(int)(FRAMES*.99)]/1e6,max=ns[FRAMES-1]/1e6;
    long heap=Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory();
    String row=String.format(Locale.ROOT,"%s,%.3f,%.3f,%.3f,%.3f,%d,%d,%.3f,%d,%.2f%n",name,mean,p95,p99,max,allocated/FRAMES,app.imageLoads-loads,cold/1e6,sceneLoads,heap/1048576.0);
    Files.writeString(out.resolve("render.csv"),row,StandardOpenOption.APPEND);System.out.print(row);
    app.g.save(out.resolve(name+".png").toString());
  }
  public static void main(String[] args)throws Exception{
    out=Paths.get(args.length==0?"tmp/performance":args[0]);Files.createDirectories(out);
    app=new App();java.lang.reflect.Field path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
    app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);app.g.noSmooth();
    boolean effectsOnly=args.length>1&&args[1].equals("effects");
    long start=System.nanoTime();if(!effectsOnly){app.loadAssets();app.g.beginDraw();app.initLanguages();app.g.endDraw();}
    Files.writeString(out.resolve("environment.txt"),"Java "+System.getProperty("java.version")+"; "+System.getProperty("os.name")+"; processors="+Runtime.getRuntime().availableProcessors()+"; renderer=PGraphicsJava2D; 1280x720; warmup="+WARMUP+"; measured="+FRAMES+"; startup assets ms="+(System.nanoTime()-start)/1e6+"; loads="+app.imageLoads+"\n");
    Files.writeString(out.resolve("render.csv"),"scene,mean_ms,p95_ms,p99_ms,max_ms,allocated_bytes_per_frame,warm_image_loads,cold_ms,cold_image_loads,heap_mib\n");
    if(effectsOnly){
      app.effectsOnly=true;app.screen=app.LEVEL3_ENTRY;app.vfxAmount=1;
      scene("effects-off",()->{});
      scene("effects-180",()->{particleStress=true;app.burst(640,360,180,app.GOLD);});
      return;
    }
    if(args.length>1&&args[1].equals("meal")){
      scene("meal",()->{app.model.restoreProgress(31);app.cooking.restore(31);app.enterMeal();app.meal.begin();});
      return;
    }
    scene("menu",()->{app.screen=app.MENU;app.mouseX=700;app.mouseY=700;});
    scene("scavenge",()->{app.beginMission(0);app.model.beginSearch();app.screen=app.GAME;});
    scene("kitchen",()->{app.model.restoreProgress(31);app.cooking.tutorialSeen=true;app.startCooking(0);app.advanceKitchenLoading(app.KITCHEN_LOADING_MS);});
    scene("storage",()->{app.openKitchenStorage(2);});
    scene("meal",()->{app.cooking.restore(31);app.enterMeal();app.meal.begin();});
    scene("particles",()->{particleStress=true;app.vfxAmount=1;app.burst(640,360,180,app.GOLD);});
    System.out.println("Render benchmark complete. Unpaced offscreen measurements; not display FPS.");
  }
}
