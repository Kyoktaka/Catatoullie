import processing.core.PApplet;
import java.nio.file.*;
import java.util.*;

/** Runs the real Processing animation thread in an owned hidden window. */
public class FramePacingProbe extends Catatoullie {
  static Path output;
  final String[] scenes={"menu","scavenge","kitchen","storage","meal"};
  final long[] intervals=new long[180],drawTimes=new long[180];
  int scene=0,samples=0,warmup=40;
  long previousFrame=0;
  @Override public void settings(){size(1280,720);noSmooth();}
  @Override public void loadProgress(){}
  @Override public void saveProgress(){}
  @Override public void initMedia(){}
  @Override public void updateMusic(){}
  // The probe deliberately hides its window; focus behavior is tested separately.
  @Override public void focusLost(){}
  @Override public void setup(){
    surface.setVisible(false);super.setup();
    if(scene==4){model.restoreProgress(31);cooking.restore(31);enterMeal();meal.begin();}
    try{Files.createDirectories(output);Files.writeString(output.resolve("pacing.csv"),"scene,fps,mean_interval_ms,p95_interval_ms,max_interval_ms,mean_draw_ms\n");}
    catch(Exception error){throw new RuntimeException(error);}
  }
  @Override public void draw(){
    long start=System.nanoTime();
    // Hold the scenario steady; this probe measures rendering and scheduling.
    lastTick=millis();super.draw();
    long duration=System.nanoTime()-start;
    if(warmup>0){warmup--;previousFrame=start;return;}
    intervals[samples]=start-previousFrame;drawTimes[samples]=duration;previousFrame=start;
    if(++samples<intervals.length)return;
    if(paused||showHelp||kitchenPaused||meal.paused)throw new AssertionError("Pacing scenario unexpectedly paused");
    long sum=0,drawSum=0;for(long value:intervals)sum+=value;for(long value:drawTimes)drawSum+=value;
    Arrays.sort(intervals);
    String row=String.format(Locale.ROOT,"%s,%.2f,%.3f,%.3f,%.3f,%.3f%n",scenes[scene],samples*1e9/sum,sum/(samples*1e6),intervals[(int)(samples*.95)]/1e6,intervals[samples-1]/1e6,drawSum/(samples*1e6));
    try{Files.writeString(output.resolve("pacing.csv"),row,StandardOpenOption.APPEND);}catch(Exception error){throw new RuntimeException(error);}
    System.out.print(row);
    if(++scene==scenes.length){System.out.println("Hidden-window pacing probe complete; audio and video excluded.");exit();return;}
    if(scene==1){beginMission(0);model.beginSearch();screen=GAME;}
    else if(scene==2){model.restoreProgress(31);cooking.tutorialSeen=true;startCooking(0);advanceKitchenLoading(KITCHEN_LOADING_MS);}
    else if(scene==3)openKitchenStorage(2);
    else{cooking.restore(31);enterMeal();meal.begin();}
    samples=0;warmup=40;previousFrame=0;
  }
  public static void main(String[] args){
    output=Paths.get(args.length==0?"tmp/performance":args[0]);FramePacingProbe app=new FramePacingProbe();
    if(args.length>1&&args[1].equals("meal"))app.scene=4;
    PApplet.runSketch(new String[]{"FramePacingProbe"},app);
  }
}
