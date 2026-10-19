final int COOK_LOADING=22,KITCHEN_LOADING_MS=1200;
int kitchenLoadingStarted=0,kitchenLoadingDestination=0,kitchenVisibleStage=0;
void beginKitchenLoading(int destination){
  kitchenHeld="";kitchenPaused=false;kitchenStorage=-1;kitchenNote=false;kitchenStove=false;kitchenLoadingDestination=destination;
  kitchenLoadingStarted=millis();screen=COOK_LOADING;
}
void advanceKitchenLoading(int elapsed){
  if(screen!=COOK_LOADING||elapsed<KITCHEN_LOADING_MS)return;
  screen=kitchenLoadingDestination;
  if(screen==COOK_GAME)cooking.begin();
  lastTick=millis();
}
void drawKitchenLoading(){
  kitchenBackdrop(130);drawKitchenRightHand(640,350);
  title("Loading...",640,435,28,CREAM);
  fittedLabel(CookingModel.DISHES[cooking.dish],640,480,23,650,CREAM);
  CookingModel.CookingStep stage=cooking.front();
  if(stage!=null)fittedLabel(stage.name,640,519,18,700,CREAM);
  float progress=constrain((millis()-kitchenLoadingStarted)/(float)KITCHEN_LOADING_MS,0,1);
  pushStyle();noStroke();fill(0xffb08b6e);rect(420,557,440,12,6);
  fill(0xff8b9d83);if(progress>0)rect(420,557,440*progress,12,6);popStyle();
  button("LEVELS",32,658,200,42,true);
  advanceKitchenLoading(millis()-kitchenLoadingStarted);
}
