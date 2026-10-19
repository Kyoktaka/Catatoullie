boolean mealAudioAttempted=false;
short[] mealMusicSamples;

void updateMealMusic(){
  if(gentleAudio==null)return;
  if(screen==LEVEL3_ENTRY&&!mealAudioAttempted){
    mealAudioAttempted=true;
    try(javax.sound.sampled.AudioInputStream stream=javax.sound.sampled.AudioSystem.getAudioInputStream(new java.io.File(dataPath("LEVEL3/full-course-cafe.wav")))){
      javax.sound.sampled.AudioFormat format=stream.getFormat();
      if(format.getSampleRate()!=22050||format.getChannels()!=1||format.getSampleSizeInBits()!=16||format.isBigEndian()||!format.getEncoding().equals(javax.sound.sampled.AudioFormat.Encoding.PCM_SIGNED))throw new java.io.IOException("Expected 22050 Hz mono PCM16");
      byte[] bytes=stream.readAllBytes();short[] decoded=new short[bytes.length/2];
      for(int i=0;i<decoded.length;i++)decoded[i]=(short)((bytes[i*2]&255)|(bytes[i*2+1]<<8));
      if(decoded.length==0)throw new java.io.IOException("Empty Level 3 music");
      mealMusicSamples=decoded;
    }catch(Exception unavailable){println("Level 3 music unavailable: "+unavailable.getMessage());}
  }
  // Publish the immutable sample buffer before enabling it on the audio thread.
  gentleAudio.mealPcm=mealMusicSamples;
  gentleAudio.mealMusicPaused=meal.paused;
  gentleAudio.mealMusicSelected=screen==LEVEL3_ENTRY&&mealMusicSamples!=null;
}
