import processing.core.PApplet;
import java.nio.file.*;
public class MealAudioTest {
 static int checks;
 static void check(boolean ok,String message){checks++;if(!ok)throw new AssertionError(message);}
 public static void main(String[] args)throws Exception{
  Catatoullie app=new Catatoullie();var path=PApplet.class.getDeclaredField("sketchPath");path.setAccessible(true);path.set(app,Paths.get("").toAbsolutePath().toString());
  app.gentleAudio=app.new GentleAudio();var audio=app.gentleAudio;
  app.screen=app.LEVEL3_ENTRY;app.musicVolume=1;app.updateMusic();
  check(audio.mealMusicSelected&&app.mealMusicSamples.length==441000,"Level 3 loads its 20-second loop");
  short[] cached=app.mealMusicSamples;app.updateMusic();check(cached==app.mealMusicSamples,"Decoded PCM cached");
  long energy=0;int peak=0;
  for(int i=0;i<cached.length;i++){int value=audio.renderSample(i);energy+=Math.abs(value);peak=Math.max(peak,Math.abs(value));}
  check(energy>100000&&peak<16000,"Music non-silent and leaves effect headroom");check(audio.mealSamplePosition==0,"Track wraps exactly");
  check(Math.abs(cached[0]-cached[cached.length-1])<500,"Loop seam continuous");
  app.meal.paused=true;app.updateMusic();int position=audio.mealSamplePosition;
  for(int i=0;i<100;i++)check(audio.renderSample(i)==0,"Pause mutes music");check(audio.mealSamplePosition==position,"Pause preserves position");
  app.meal.paused=false;app.musicVolume=0;app.updateMusic();check(audio.renderSample(0)==0,"Music slider zero mutes track");
  audio.clickRemaining=1400;audio.effectsGain=1;long clicks=0;for(int i=0;i<1400;i++)clicks+=Math.abs(audio.renderSample(i));check(clicks>0,"Effects remain independent of Music zero");
  app.musicVolume=.5f;app.updateMusic();audio.mealSamplePosition=1000;int half=audio.renderSample(1000);app.musicVolume=1;app.updateMusic();audio.mealSamplePosition=1000;int full=audio.renderSample(1000);check(Math.abs(full-2*half)<=2,"Music slider scales PCM");
  app.meal.phase=MealModel.Phase.COMPLETED;app.updateMusic();check(audio.mealMusicSelected,"Finale keeps cafe soundtrack");
  app.screen=app.MENU;app.updateMusic();audio.renderSample(0);check(!audio.mealMusicSelected&&audio.mealSamplePosition==0,"Leaving Level 3 stops and resets its track");
  app.screen=app.LEVEL3_ENTRY;app.updateMusic();check(audio.mealMusicSelected&&cached==app.mealMusicSamples,"Reentry reuses buffer");
  System.out.println("MealAudioTest passed: "+checks+" checks");
 }
}
