import processing.core.PApplet;
import processing.awt.PGraphicsJava2D;
import processing.video.Movie;
import java.nio.file.*;

/** Decodes and plays the real supplied MP4s through Processing Video, without a window. */
public class EndingPlaybackTest extends Catatoullie {
  volatile int decodedFrames=0;
  @Override public void updateMusic(){}
  @Override public void movieEvent(Movie movie){if(movie==endingMovie)decodedFrames++;super.movieEvent(movie);}
  public static void main(String[] args){try{runPlayback();}catch(Exception error){error.printStackTrace();System.exit(1);}}
  static void runPlayback()throws Exception {
    EndingPlaybackTest app=new EndingPlaybackTest();
    java.lang.reflect.Field path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
    app.width=1280;app.height=720;app.g=new PGraphicsJava2D();app.g.setParent(app);app.g.setPrimary(false);app.g.setSize(1280,720);
    app.model.restoreProgress(31);app.cooking.restore(31);app.musicVolume=0;
    for(int level=1;level<=2;level++){
      app.decodedFrames=0;app.startEndingMovie(level);Movie movie=app.endingMovie;
      if(movie==null)throw new AssertionError("Ending decoder did not start");
      app.startEndingMovie(level);if(app.endingMovie!=movie)throw new AssertionError("Duplicate playback instance");
      long start=System.nanoTime();float furthest=0,duration=0;boolean saved=false;
      while((System.nanoTime()-start)/1000000000.0<17){
        Thread.sleep(80);float position=movie.time();duration=movie.duration();furthest=Math.max(furthest,position);
        if(app.decodedFrames>15&&!saved){movie.save("tmp/qa-kitchen/actual-ending-"+level+".png");saved=true;}
        app.advanceEndingPlayback(position,duration,movie.width>1&&movie.height>1);
        if(app.screen!=app.ENDING_MOVIE)break;
      }
      if(app.decodedFrames<100||furthest<9.8f||duration<9.9f||duration>10.2f)throw new AssertionError("Video "+level+" incomplete: frames="+app.decodedFrames+", time="+furthest+", duration="+duration);
      if(app.endingMovie!=null||app.screen!=(level==1?app.COOK_SELECT:app.LEVEL3_ENTRY))throw new AssertionError("Ending did not dispose and enter its destination");
      System.out.println("Ending "+level+" Movie playback passed: "+app.decodedFrames+" frames, "+duration+" s.");
      app.startEndingMovie(level);movie=app.endingMovie;
      if(movie==null)throw new AssertionError("Replay did not start");
      app.finishEndingMovie();if(app.endingMovie!=null||app.screen==app.ENDING_MOVIE)throw new AssertionError("Skip retained the decoder");
      app.movieEvent(movie); // Late callback from the disposed instance is ignored.
    }
    // This decoder harness has no Processing surface/event loop. All Movies have
    // been disposed above; bypass Processing's GUI shutdown hook in this process.
    Files.writeString(Paths.get(System.getProperty("catatoullie.video.result","tmp/video-check/passed.txt")),"Both videos completed at native speed after frame decoding and Movie disposal.");
    Runtime.getRuntime().halt(0);
  }
}
