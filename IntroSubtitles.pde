JSONObject introSubtitleTracks;
boolean introSubtitlesLoaded=false;

String introSubtitleAt(float seconds,boolean movie){
  if(language==0)return "";
  if(!introSubtitlesLoaded){
    introSubtitlesLoaded=true;
    try{introSubtitleTracks=loadJSONObject(dataPath("intro-subtitles.json"));}
    catch(Exception unavailable){println("Intro subtitles unavailable: "+unavailable.getMessage());}
  }
  if(introSubtitleTracks==null||Float.isNaN(seconds)||seconds<0)return "";
  JSONArray cues=introSubtitleTracks.getJSONArray(movie?"movie":"illustrated");
  if(cues==null)return "";
  for(int i=0;i<cues.size();i++){
    JSONObject cue=cues.getJSONObject(i);
    if(seconds>=cue.getFloat("start")&&seconds<cue.getFloat("end"))return tr(cue.getString("text"));
  }
  return "";
}

void drawIntroSubtitles(){
  if(language==0)return;
  float seconds;
  if(introUsesMovie){
    if(!introFrameSeen||introMovie==null)return;
    try{seconds=introMovie.time();}catch(Throwable unavailable){return;}
  }else seconds=max(0,millis()-introStarted)/1000.0;
  drawIntroSubtitle(introSubtitleAt(seconds,introUsesMovie));
}

void drawIntroSubtitle(String caption){
  if(caption.length()==0)return;
  pushStyle();rectMode(CORNER);noStroke();fill(0,200);rect(140,570,1000,78,8);
  textFont(uiFont);textSize(22);textLeading(28);textAlign(CENTER,TOP);fill(255);
  text(caption,162,581,956,60);popStyle();
}
