// Utensils move on their actual work surface; the model owns completion and timing.
String kitchenGestureLabel(CookingModel.Action action){
  if(action.source.equals("spoon"))return "STIRRING...";
  if(action.source.equals("brush"))return "BRUSHING...";
  if(action.source.equals("knife"))return "CHOPPING...";
  return action.target.equals("bowl")?"WHISKING...":"SEALING...";
}
String kitchenGestureFood(){
  CookingModel.Action action=cooking.action();
  if(action==null||action.mode!=CookingModel.Mode.GESTURE)return "";
  String food=action.target.equals("wrapper")?"rolled_lumpia":action.target.equals("pastry")?"filled_pastry":"";
  return cooking.prepared.contains(food)?food:"";
}
void drawKitchenGesture(){
  CookingModel.Action action=cooking.action();
  if(action==null||action.mode!=CookingModel.Mode.GESTURE)return;
  float[] target=kitchenTarget(action.target);
  float cx=target[0]+target[2]/2,cy=target[1]+target[3]/2;
  String food=kitchenGestureFood();
  if(!food.isEmpty())drawKitchenObject(food.equals("filled_pastry")?"sealed_pie":food,cx-71,cy-31,142,62);
  if(!cooking.gesturing)return;
  float t=constrain(cooking.gestureElapsed/(float)action.duration,0,1);
  float phase=TWO_PI*2*(t*t*(3-2*t));
  boolean mixing=action.source.equals("spoon")||action.source.equals("fork")&&action.target.equals("bowl");
  float x=cx,y=cy,angle=0;
  if(mixing){
    float[] vessel=kitchenEquipmentBounds(action.target);
    cx=vessel[0]+vessel[2]/2;
    cy=vessel[1]+vessel[3]*(action.target.equals("bowl")?.32:.38);
    x=cx+cos(phase)*min(19,vessel[2]*.16);y=cy+sin(phase)*5;angle=-.4+sin(phase)*.2;
    pushStyle();noFill();stroke(0xffd4b895,150*vfxAmount);strokeWeight(1.5);
    arc(cx,cy,min(43,vessel[2]*.5),14,phase,phase+PI);popStyle();
  }else if(action.source.equals("brush")){
    x=cx+sin(phase)*42;y=cy-3;angle=.3+cos(phase)*.15;
    pushStyle();stroke(0xffe8dcc7,150*vfxAmount);strokeWeight(3);
    line(cx-42,cy+10,cx-42+84*t,cy+10);popStyle();
  }else if(action.source.equals("knife")){
    x=cx-25+50*t;y=cy-abs(sin(phase*1.5))*17;angle=-.15;
  }else{
    x=cx-42+84*t;y=cy-abs(sin(phase*1.5))*11;angle=.12;
    pushStyle();stroke(0xffb08b6e);strokeWeight(2);
    for(int i=0;i<floor(t*7);i++)line(cx-42+i*12,cy+17,cx-42+i*12,cy+22);popStyle();
  }
  pushStyle();pushMatrix();translate(x,y);rotate(angle);
  drawKitchenObject(action.source,-15,-56,42,76);popMatrix();popStyle();
}
