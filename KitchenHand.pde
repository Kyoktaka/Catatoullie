// Reuse the cached right-paw art. Only the forearm length changes as it reaches.
void drawKitchenRightHand(float x,float y){
  preparePawSprite(1);if(pawCaps[1]==null)return;
  float tipX=constrain(x,60,1220),tipY=constrain(y,140,650);
  float baseX=1190,baseY=790,dx=tipX-baseX,dy=tipY-baseY,len=max(100,sqrt(dx*dx+dy*dy));
  pushMatrix();translate(baseX,baseY);rotate(atan2(dy,dx)+HALF_PI);
  image(pawForearms[1],-78,-len+48,156,len-48);
  image(pawCaps[1],-78,-len-39,156,88);popMatrix();
}
