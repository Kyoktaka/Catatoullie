Movie endingMovie;
int endingLevel=0,endingStarted=0,endingProgressAt=0;
float endingPosition=-1;
boolean endingFrame=false,endingUnavailable=false;
String endingSource="";
boolean canStartEnding(int level){return level==1?level2Unlocked():level==2&&level2Unlocked()&&cooking.progressMask()==31;}
Movie createEndingMovie(String source){return new Movie(this,source);}
void startEndingMovie(int level){
  if(!canStartEnding(level)||screen==ENDING_MOVIE)return;
  stopIntroMedia();stopEndingMovie();clearKitchenInput();resetPaws();particles.clear();kitchenPops.clear();paused=false;showHelp=false;kitchenPaused=false;
  endingLevel=level;endingSource="LEVEL2/level"+level+"-cutscene-after.mp4";
  endingStarted=millis();endingProgressAt=endingStarted;endingPosition=-1;endingFrame=false;endingUnavailable=false;screen=ENDING_MOVIE;
  try{endingMovie=createEndingMovie(endingSource);if(endingMovie!=null){endingMovie.volume(musicVolume);endingMovie.play();}else endingUnavailable=true;}
  catch(Throwable unavailable){markEndingUnavailable();println("Ending video unavailable: "+unavailable.getMessage());}
  endingStarted=millis();endingProgressAt=endingStarted;updateMusic();
}
void stopEndingMovie(){
  Movie previous=endingMovie;endingMovie=null;disposeMovie(previous);
}
void markEndingUnavailable(){endingUnavailable=true;stopEndingMovie();}
void disposeMovie(Movie movie){
  if(movie==null)return;
  try{movie.stop();}catch(Throwable unavailable){}
  try{movie.dispose();}catch(Throwable unavailable){}
}
void finishEndingMovie(){
  if(screen!=ENDING_MOVIE)return;
  int destination=endingLevel;stopEndingMovie();
  if(destination==1)openCookingSelection();else enterMeal();
  endingLevel=0;updateMusic();
}
void advanceEndingPlayback(float position,float duration,boolean hasFrame){
  if(screen!=ENDING_MOVIE)return;
  if(hasFrame)endingFrame=true;
  if(position>endingPosition+.04){endingPosition=position;endingProgressAt=millis();}
  if(endingFrame&&duration>0&&position>=duration-.08){finishEndingMovie();return;}
  if(millis()-endingProgressAt>8000)markEndingUnavailable();
}
void drawEndingMovie(){
  background(INK);
  if(endingMovie!=null&&!endingUnavailable){
    try{
      advanceEndingPlayback(endingMovie.time(),endingMovie.duration(),endingMovie.width>1&&endingMovie.height>1);
      if(screen!=ENDING_MOVIE)return;
      if(endingFrame&&endingMovie!=null)containImage(endingMovie,0,0,width,height);
    }catch(Throwable unavailable){markEndingUnavailable();}
  }
  if(endingUnavailable){fittedLabel("Video unavailable. Continue with SKIP.",640,360,22,1000,CREAM);}
  else if(!endingFrame)fittedLabel("Loading video...",640,360,20,1000,CREAM);
  button("SKIP [SPACE]",1020,660,220,43,true);
}
