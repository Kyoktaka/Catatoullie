class GameParticle {
  float x,y,vx,vy,life=1;int ink;
  GameParticle(float px,float py,int c){x=px;y=py;ink=c;vx=random(-150,150);vy=random(-190,30);}
}
ArrayList<GameParticle> particles=new ArrayList<GameParticle>();
void burst(float x,float y,int count,int ink){
  for(int i=0;i<round(count*vfxAmount)&&particles.size()<180;i++)particles.add(new GameParticle(x,y,ink));
}
void drawEffects(int delta){
  if(vfxAmount<=0){particles.clear();kitchenPops.clear();return;}
  if(screen==CUTSCENE||screen==ENDING_MOVIE||paused||showHelp||kitchenPaused||(screen==LEVEL3_ENTRY&&meal.paused))return;
  pushStyle();noStroke();float dt=max(0,delta)/1000.0;
  drawKitchenPops(delta);
  if(screen==MENU||screen==CUSTOMIZE||screen==OPTIONS||screen==LEVEL_SELECT){
    for(int i=0;i<round(38*vfxAmount);i++){
      float x=(i*137.1+millis()*(.006+.004*vfxAmount))%1280,y=170+(i*91.3)%475+sin(millis()*.0007+i)*18;
      fill(GOLD,(25+45*(.5+.5*sin(millis()*.002+i)))*vfxAmount);ellipse(x,y,2+3*vfxAmount,2+3*vfxAmount);
    }
  }
  for(int i=particles.size()-1;i>=0;i--){
    GameParticle p=particles.get(i);p.life-=dt*.8;p.x+=p.vx*dt;p.y+=p.vy*dt+90*dt*dt;p.vy+=180*dt;
    if(p.life<=0){particles.remove(i);continue;}
    if(p.x<0||p.x>width||p.y<0||p.y>height)continue;
    fill(p.ink,255*p.life*vfxAmount);rect(p.x,p.y,3+4*vfxAmount,3+4*vfxAmount);
  }
  if(screen==GAME&&model.remainingMs<30000){
    noFill();stroke(0xffda6555,(70+70*sin(millis()*.008))*vfxAmount);strokeWeight(8*vfxAmount);rect(4,4,width-8,height-8,12);
  }
  popStyle();
}
class KitchenPop {
  String id;float x,y,age=0;
  KitchenPop(String item,float px,float py){id=item;x=px;y=py;}
}
ArrayList<KitchenPop> kitchenPops=new ArrayList<KitchenPop>();
void kitchenDropPop(String id,float x,float y){
  if(vfxAmount>0&&kitchenPops.size()<8)kitchenPops.add(new KitchenPop(id,x,y));
}
void drawKitchenPops(int delta){
  if(screen!=COOK_GAME){kitchenPops.clear();return;}
  for(int i=kitchenPops.size()-1;i>=0;i--){
    KitchenPop p=kitchenPops.get(i);p.age+=delta;
    if(p.age>=280){kitchenPops.remove(i);continue;}
    float t=p.age/280,size=108*(1-t*.8);
    pushStyle();tint(255,255*(1-t)*vfxAmount);
    drawKitchenObject(p.id,p.x-size/2,p.y-size/2-sin(t*PI)*18*vfxAmount,size,size);popStyle();
  }
}
