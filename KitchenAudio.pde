// PCM copy of the supplied MP3: Java Sound playback needs no extra dependency.
javax.sound.sampled.Clip kitchenMusicClip;
boolean kitchenAudioAttempted=false,kitchenMusicPlaying=false;
float kitchenLastVolume=Float.NaN;
boolean kitchenAudioActive(){return kitchenMusicClip!=null&&(screen==COOK_LOADING||screen==COOK_SELECT||screen==COOK_TUTORIAL||screen==COOK_GAME||screen==COOK_SUCCESS||screen==COOK_TIMEOUT);}
void updateKitchenMusic(){
  boolean active=screen==COOK_LOADING||screen==COOK_SELECT||screen==COOK_TUTORIAL||screen==COOK_GAME||screen==COOK_SUCCESS||screen==COOK_TIMEOUT;
  if(active&&!kitchenAudioAttempted){
    kitchenAudioAttempted=true;
    try(javax.sound.sampled.AudioInputStream stream=javax.sound.sampled.AudioSystem.getAudioInputStream(new java.io.File(dataPath("LEVEL2/Sound epeks/BgMusic.wav")))){
      kitchenMusicClip=javax.sound.sampled.AudioSystem.getClip();kitchenMusicClip.open(stream);
      registerMethod("dispose",new KitchenAudioCleanup());
    }catch(Exception unavailable){if(kitchenMusicClip!=null)kitchenMusicClip.close();kitchenMusicClip=null;}
  }
  if(kitchenMusicClip==null)return;
  boolean audible=active&&!kitchenPaused&&musicVolume>0;
  if(kitchenLastVolume!=musicVolume&&kitchenMusicClip.isControlSupported(javax.sound.sampled.FloatControl.Type.MASTER_GAIN)){
    javax.sound.sampled.FloatControl gain=(javax.sound.sampled.FloatControl)kitchenMusicClip.getControl(javax.sound.sampled.FloatControl.Type.MASTER_GAIN);
    gain.setValue(constrain(musicVolume<=0?gain.getMinimum():20*log(musicVolume*.65)/log(10),gain.getMinimum(),gain.getMaximum()));
    kitchenLastVolume=musicVolume;
  }
  if(audible&&!kitchenMusicPlaying){kitchenMusicClip.loop(javax.sound.sampled.Clip.LOOP_CONTINUOUSLY);kitchenMusicPlaying=true;}
  else if(!audible&&kitchenMusicPlaying){kitchenMusicClip.stop();kitchenMusicPlaying=false;}
}
public class KitchenAudioCleanup {public void dispose(){if(kitchenMusicClip!=null){kitchenMusicClip.stop();kitchenMusicClip.close();kitchenMusicClip=null;}}}
