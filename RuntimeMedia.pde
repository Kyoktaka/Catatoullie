import processing.video.*;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;

Movie introMovie;
boolean introEnglishFallback=false;
String introLoadedSource="";
PImage[] introStory = new PImage[5];
boolean introUsesMovie = false;
boolean introMovieAttempted = false;
boolean introMediaActive = false;
boolean introFrameSeen = false;
int introLastProgressAt;
float introLastPosition = -1;
final int STORY_PAGE_MS = 3800;
GentleAudio gentleAudio;

void initMedia() {
  for (int i = 0; i < introStory.length; i++) {
    java.io.File storyFile = new java.io.File(dataPath("INTRO/story-" + (i + 1) + ".png"));
    if (storyFile.isFile()) introStory[i] = loadImage(storyFile.getAbsolutePath());
  }
  gentleAudio = new GentleAudio();
  registerMethod("dispose", gentleAudio);
  gentleAudio.start();
  updateMusic();
}

void startIntroMedia() {
  introStarted = millis();
  introLastProgressAt = introStarted;
  introLastPosition = -1;
  introFrameSeen = false;
  introMediaActive = true;
  introUsesMovie = false;
  if (!introMovieAttempted) {
    introMovieAttempted = true;
    try {
      String source=introSource();
      if(source.length()>0){introLoadedSource=source;introMovie=new Movie(this,source);}
    }
    catch (Throwable unavailableVideo) {
      println("The intro is using the illustrated story (video decoder unavailable).");
      introMovie = null;
    }
  }
  if (introMovie != null) {
    try {
      introMovie.volume(constrain(musicVolume, 0, 1));
      introMovie.play();
      introUsesMovie = true;
    }
    catch (Throwable unavailableVideo) {
      useIllustratedIntro();
    }
  }
  // Library initialization can take a moment; start the clock after it completes.
  introStarted = millis();
  introLastProgressAt = introStarted;
  updateMusic();
}

String introSource(){
  JSONObject sources=null;
  try{sources=loadJSONObject(dataPath("cutscenes.json"));}catch(Exception unavailable){}
  if(sources==null)sources=new JSONObject();
  String preferred=sources.getString(languageCodes[language],"");
  introEnglishFallback=false;
  if(playableSource(preferred))return preferred;
  String english=sources.getString("en","cutscene1-english.mp4");
  introEnglishFallback=language!=0;
  return playableSource(english)?english:"";
}
boolean playableSource(String source){
  return source.length()>0&&(source.startsWith("https://")||new java.io.File(dataPath(source)).isFile());
}
void resetIntroLanguage(){
  Movie previous=introMovie;introMovie=null;disposeMovie(previous);
  introMovie=null;introMovieAttempted=false;introLoadedSource="";introUsesMovie=false;introMediaActive=false;
}

void stopIntroMedia() {
  introMediaActive = false;
  if (introMovie != null) {
    try { introMovie.stop(); }
    catch (Throwable unavailableVideo) { /* The story fallback needs no decoder. */ }
  }
  introUsesMovie = false;
  updateMusic();
}

void useIllustratedIntro() {
  if (introMovie != null) {
    try { introMovie.stop(); }
    catch (Throwable unavailableVideo) { }
  }
  introUsesMovie = false;
  introStarted = millis();
  updateMusic();
}

void movieEvent(Movie movie) {
  if(movie!=introMovie&&movie!=endingMovie)return;
  try { movie.read(); }
  catch (Throwable unavailableVideo) { /* The draw-loop watchdog switches to the story. */ }
}

void updateIntroMedia() {
  if (!introMediaActive || screen != CUTSCENE) return;
  if (introUsesMovie && introMovie != null) {
    try {
      float position = introMovie.time();
      float duration = introMovie.duration();
      if (position > introLastPosition + 0.04f) {
        introLastPosition = position;
        introLastProgressAt = millis();
      }
      if (introMovie.width > 1 && introMovie.height > 1) introFrameSeen = true;
      if (introFrameSeen && duration > 0 && position >= duration - 0.12f) {
        finishCutscene();
        return;
      }
      if (millis() - introLastProgressAt > 7000 ||
          (!introFrameSeen && millis() - introStarted > 7000)) useIllustratedIntro();
    }
    catch (Throwable unavailableVideo) { useIllustratedIntro(); }
  }
  if (!introUsesMovie && millis() - introStarted >= introStory.length * STORY_PAGE_MS) {
    finishCutscene();
  }
}

void drawIntroMedia() {
  background(18, 17, 32);
  PImage frame = null;
  if (introUsesMovie && introFrameSeen && introMovie != null) frame = introMovie;
  else {
    int page = constrain((millis() - introStarted) / STORY_PAGE_MS, 0, introStory.length - 1);
    frame = introStory[page];
  }
  if (frame != null && frame.width > 0) {
    float fit = min(width / (float)frame.width, height / (float)frame.height);
    float w = frame.width * fit, h = frame.height * fit;
    pushStyle();
    imageMode(CORNER);
    noTint();
    image(frame, (width - w) / 2, (height - h) / 2, w, h);
    popStyle();
  }
}

void setMusicVolume(float volume) {
  musicVolume = constrain(volume, 0, 1);
  if (introMovie != null && introUsesMovie) {
    try { introMovie.volume(musicVolume); }
    catch (Throwable unavailableVideo) { }
  }
  updateMusic();
}

void updateMusic() {
  updateKitchenMusic();
  updateMealMusic();
  if (gentleAudio != null) {
    gentleAudio.gain = constrain(musicVolume, 0, 1);
    gentleAudio.effectsGain=constrain(sfxVolume,0,1);
    gentleAudio.scavenging = screen==LEVEL_SELECT||screen==GAME||screen==CONGRATS||screen==LOADING||screen==FOLDER||screen==OPEN_FOLDER||screen==PAPERS||screen==TIME_UP;
    gentleAudio.playMelody = !((screen == CUTSCENE && introUsesMovie)||(screen==ENDING_MOVIE&&!endingUnavailable)||kitchenAudioActive());
  }
}

void playUiSound() {
  if (gentleAudio != null) gentleAudio.clickRemaining = 1400;
}

// A small original, looping melody. A short buffer and volatile gain make the
// options slider audible immediately, including a true zero-volume setting.
public class GentleAudio implements Runnable {
  volatile boolean running = true;
  volatile boolean playMelody = true;
  volatile boolean scavenging = false;
  volatile short[] mealPcm;
  volatile boolean mealMusicSelected=false,mealMusicPaused=false;
  int mealSamplePosition=0;
  final int[] alleyMelody = {57,0,60,64,62,0,60,0,55,0,59,62,60,0,59,0,53,0,57,60,59,0,57,0,52,0,56,59,57,0,0,0};
  final int[] alleyBass = {45,45,43,43,41,41,40,40};
  volatile float gain = 0;
  volatile float effectsGain=.7f;
  volatile int clickRemaining = 0;
  volatile int meowRemaining=0,actionRemaining=0;
  volatile boolean chopSound=false;
  SourceDataLine line;
  final int sampleRate = 22050;
  final int noteSamples = 6615;
  final int[] melody = {
    72, 76, 79, 76, 74, 77, 81, 77,
    71, 74, 79, 74, 72, 76, 79, 0,
    69, 72, 76, 72, 67, 71, 74, 71,
    65, 69, 72, 69, 67, 71, 74, 0
  };
  final int[] bass = {48, 50, 43, 48, 45, 43, 41, 43};
  final double[] pitchFrequencies=new double[128];

  GentleAudio(){for(int pitch=0;pitch<pitchFrequencies.length;pitch++)pitchFrequencies[pitch]=440*Math.pow(2,(pitch-69)/12.0);}

  void start() {
    Thread worker = new Thread(this, "Catatoullie music");
    worker.setDaemon(true);
    worker.start();
  }

  public void run() {
    try {
      AudioFormat format = new AudioFormat(sampleRate, 16, 1, true, false);
      line = AudioSystem.getSourceDataLine(format);
      line.open(format, 4096);
      line.start();
      byte[] samples = new byte[1024];
      long clock = 0;
      while (running) {
        for (int i = 0; i < samples.length / 2; i++, clock++) {
          int sample = renderSample(clock);
          samples[i * 2] = (byte)sample;
          samples[i * 2 + 1] = (byte)(sample >> 8);
        }
        line.write(samples, 0, samples.length);
      }
    }
    catch (Exception unavailableAudio) {
      // Audio devices are optional; the game remains fully playable without one.
    }
    finally {
      if (line != null) { line.stop(); line.close(); }
    }
  }

  int renderSample(long clock) {
          double tone = 0;
          short[] mealSamples=mealPcm;
          if(mealMusicSelected&&mealSamples!=null){
            if(!mealMusicPaused){
              tone=mealSamples[mealSamplePosition]/32768.0;
              mealSamplePosition=(mealSamplePosition+1)%mealSamples.length;
            }
          }else{
            mealSamplePosition=0;
          if (playMelody) {
          int note = (int)((clock / noteSamples) % melody.length);
          double seconds = (clock % noteSamples) / (double)sampleRate;
          double envelope = Math.min(1, seconds / 0.008) * Math.exp(-seconds * 10);

            int pitch=scavenging?alleyMelody[note]:melody[note];
            if (pitch > 0) {
              double frequency = pitchFrequencies[pitch];
              tone = Math.sin(2 * Math.PI * frequency * seconds) * envelope * 0.095;
              tone += Math.sin(4 * Math.PI * frequency * seconds) * envelope * 0.018;
            }
            double bassFrequency = pitchFrequencies[scavenging?alleyBass[note / 4]:bass[note / 4]];
            double bassTime = (clock % (noteSamples * 4)) / (double)sampleRate;
            double bassEnvelope = Math.min(1, bassTime / 0.025) * Math.exp(-bassTime * 2.7);
            tone += Math.sin(2 * Math.PI * bassFrequency * bassTime) * bassEnvelope * 0.04;
          }
          }
          // Music gain never mutes interaction feedback.
          tone *= gain;
          double music=tone;tone=0;
          int remaining = clickRemaining;
          if (remaining > 0) {
            double clickTime = (1400 - remaining) / (double)sampleRate;
            tone += Math.sin(2 * Math.PI * 880 * clickTime) * (remaining / 1400.0) * 0.1;
            clickRemaining = remaining - 1;
          }
          int meow=meowRemaining;
          if(meow>0){
            double t=(13230-meow)/(double)sampleRate;
            double f=420+240*Math.sin(Math.PI*t/.6);
            double env=Math.sin(Math.PI*t/.6);
            tone+=(Math.sin(2*Math.PI*f*t)+.3*Math.sin(4*Math.PI*f*t))*.13*env;
            meowRemaining=meow-1;
          }
          int action=actionRemaining;
          if(action>0){
            double t=(3300-action)/(double)sampleRate;
            tone+=(chopSound?Math.sin(t*2300)*Math.exp(-t*60):Math.sin(2*Math.PI*(650-1800*t)*t)*Math.exp(-t*23))*.17;
            actionRemaining=action-1;
          }
          return (int)(Math.max(-1,Math.min(1,music+tone*effectsGain)) * 32767);
  }

  public void dispose() {
    running = false;
    if (line != null) { line.stop(); line.close(); }
  }
}

void playMeow(){if(gentleAudio!=null)gentleAudio.meowRemaining=13230;}
void playCookingSound(boolean chop){if(gentleAudio!=null){gentleAudio.chopSound=chop;gentleAudio.actionRemaining=3300;}}
