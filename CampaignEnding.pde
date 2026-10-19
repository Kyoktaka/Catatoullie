int finaleStarted=0;
PImage finaleGrain;
PFont finaleHeading;
final int FINAL_SAND=0xffe8dcc7,FINAL_OAT=0xffd4b895,FINAL_MOSS=0xff606c38,FINAL_CLAY=0xffb08b6e,FINAL_OCHRE=0xffc08e3a;
boolean campaignComplete(){return model.completedCount()==5&&cooking.progressMask()==31&&meal.completed;}
void initFinale(){
  if(finaleHeading!=null)return;
  finaleHeading=createFont("Georgia Bold",42,true);
  finaleGrain=createImage(512,540,ARGB);finaleGrain.loadPixels();
  java.util.Random grain=new java.util.Random(73);
  for(int i=0;i<finaleGrain.pixels.length;i++)finaleGrain.pixels[i]=((grain.nextInt(6)+1)<<24)|(grain.nextBoolean()?0x606c38:0xe8dcc7);
  finaleGrain.updatePixels();
}
void finaleText(String value,float x,float y,float size,float available,boolean heading){
  pushStyle();textFont(heading&&language!=3?finaleHeading:uiFont);fittedLabel(value,x,y,size,available,FINAL_MOSS);popStyle();
}
void finaleButton(String value,float x,float y){
  boolean hover=hit(x,y,220,52);noStroke();fill(hover?FINAL_OAT:FINAL_MOSS);rect(x,y,220,52,18);
  pushStyle();textFont(uiFont);fittedLabel(value,x+110,y+26,18,202,hover?FINAL_MOSS:FINAL_SAND);popStyle();
}
void drawCampaignEnding(){
  initFinale();pushStyle();imageMode(CORNER);rectMode(CORNER);ellipseMode(CENTER);noTint();
  image(mealRoom,0,0,width,height);noStroke();fill(FINAL_MOSS,95);rect(0,0,width,height);
  fill(FINAL_SAND);rect(64,64,524,580,28);image(finaleGrain,70,70,512,568);
  finaleText("A full belly.",326,123,42,460,true);
  finaleText("A happy ending.",326,177,42,460,true);
  finaleText("You found it. Cooked it. Enjoyed it.",326,237,20,460,false);
  // Display earned progress, never fabricated completion statistics.
  for(int level=0;level<3;level++){
    float y=308+57*level;
    int earned=level==0?totalStars(model.bestStars):level==1?totalStars(cooking.bestStars):meal.bestStars;
    pushStyle();fill(FINAL_OAT);rect(96,y-23,460,46,16);textFont(uiFont);textAlign(LEFT,CENTER);fill(FINAL_MOSS);text(tr("LEVEL "+(level+1)),118,y);popStyle();
    containImage(starImg,430,y-14,28,28);finaleText(earned+" / "+(level==2?3:15),505,y,20,80,false);
  }
  finaleText("ALL LEVELS COMPLETED",326,487,22,460,false);
  finaleText("Thank you for playing Catatoullie.",326,526,17,460,false);
  finaleButton("MAIN MENU",96,566);finaleButton("LEVELS",336,566);
  float elapsed=max(0,millis()-finaleStarted)/1000.0;
  // Bounded, deterministic decoration: no particle allocation or unbounded lists.
  int count=round(44*constrain(vfxAmount,0,1));
  for(int i=0;i<count;i++){
    float x=640+(i*83.7)%600,y=(i*61.3+elapsed*(17+i%7))%480;
    fill(i%3==0?FINAL_OCHRE:i%3==1?FINAL_OAT:0xff8b9d83,185*vfxAmount);
    pushMatrix();translate(x,y);rotate(sin(elapsed*.8+i)*.7);rect(-3,-5,6,10,2);popMatrix();
  }
  float breathe=sin(elapsed*1.7)*3*vfxAmount;
  containImage(mealFat,790,190+breathe,285,340);
  for(int i=0;i<5;i++){
    float x=672+i*112,y=535+abs(2-i)*13;
    fill(FINAL_CLAY,90);ellipse(x+48,y+65,100,19);
    containImage(mealFood[i],x,y,100,85);
  }
  for(int i=0;i<3;i++)containImage(starImg,820+i*65,112-sin(elapsed*1.2+i)*5*vfxAmount,47,47);
  float reveal=constrain((millis()-finaleStarted)/450.0,0,1);
  if(reveal<1){fill(FINAL_SAND,255*(1-reveal));rect(0,0,width,height);}
  popStyle();
}
