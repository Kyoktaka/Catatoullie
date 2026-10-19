// Settle elapsed gameplay time before changing pause state or accepting input.
// A resume event establishes a fresh origin even when no paused frame was drawn.
void settleInputClock(){
  settleInputClockAt(millis());
}
void settleInputClockAt(int now){
  int elapsed=max(0,now-lastTick);lastTick=now;
  if(screen==GAME&&!paused&&!showHelp){
    model.tick(elapsed);
    if(model.failed){resetPaws();screen=TIME_UP;}
  }else if(screen==COOK_GAME){cooking.tick(elapsed,kitchenPaused);updateCookingState();}
  else if(screen==LEVEL3_ENTRY)updateMeal(elapsed);
}
void clearKitchenInput(){
  kitchenHeld="";kitchenTravel=0;tutorialDragging=false;
  kitchenStorage=-1;kitchenNote=false;kitchenStove=false;
}
// The native focus callback can arrive on the AWT thread. Queue the state change
// for the sketch thread instead of mutating a recipe while it is being drawn.
volatile int focusPauseAt=-1;
void focusLost(){focusPauseAt=millis();}
void applyFocusPause(){
  int lostAt=focusPauseAt;if(lostAt<0)return;focusPauseAt=-1;
  settleInputClockAt(lostAt);finishAvatarDrag();
  if(screen==GAME){activePaw=-1;paused=true;}
  else if(screen==COOK_GAME){clearKitchenInput();kitchenPaused=true;}
  else if(screen==LEVEL3_ENTRY&&meal.active()){mealHeld=null;meal.paused=true;}
  if(activeOptionSlider>=0){activeOptionSlider=-1;saveProgress();}
  lastTick=millis();
}
