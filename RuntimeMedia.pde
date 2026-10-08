import processing.video.*;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;

Movie introMovie;
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
      if (new java.io.File(dataPath("cutscene1.mp4")).isFile()) {
        introMovie = new Movie(this, "cutscene1.mp4");
      }
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
  if (gentleAudio != null) {
    gentleAudio.gain = constrain(musicVolume, 0, 1);
    gentleAudio.playMelody = !(screen == CUTSCENE && introUsesMovie);
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
  volatile float gain = 0;
  volatile int clickRemaining = 0;
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
          int note = (int)((clock / noteSamples) % melody.length);
          double seconds = (clock % noteSamples) / (double)sampleRate;
          double envelope = Math.min(1, seconds / 0.008) * Math.exp(-seconds * 10);
          double tone = 0;
          if (playMelody) {
            if (melody[note] > 0) {
              double frequency = 440 * Math.pow(2, (melody[note] - 69) / 12.0);
              tone = Math.sin(2 * Math.PI * frequency * seconds) * envelope * 0.095;
              tone += Math.sin(4 * Math.PI * frequency * seconds) * envelope * 0.018;
            }
            double bassFrequency = 440 * Math.pow(2, (bass[note / 4] - 69) / 12.0);
            double bassTime = (clock % (noteSamples * 4)) / (double)sampleRate;
            double bassEnvelope = Math.min(1, bassTime / 0.025) * Math.exp(-bassTime * 2.7);
            tone += Math.sin(2 * Math.PI * bassFrequency * bassTime) * bassEnvelope * 0.04;
          }
          int remaining = clickRemaining;
          if (remaining > 0) {
            double clickTime = (1400 - remaining) / (double)sampleRate;
            tone += Math.sin(2 * Math.PI * 880 * clickTime) * (remaining / 1400.0) * 0.1;
            clickRemaining = remaining - 1;
          }
          int sample = (int)(tone * gain * 32767);
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

  public void dispose() {
    running = false;
    if (line != null) { line.stop(); line.close(); }
  }
}
