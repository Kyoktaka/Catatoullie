void sceneBackground(PImage img,float shade) {cachedBackdrop(img,0,0,width,height,shade);noStroke();fill(INK,shade);}
void panel(float x,float y,float w,float h) {pushStyle();stroke(INK);strokeWeight(3);fill(CREAM,246);rect(x,y,w,h,8);popStyle();}
void label(String s,float x,float y,float sz,int c) {pushStyle();fill(c);textSize(sz);textAlign(CENTER,CENTER);s=tr(s);float tw=textWidth(s);if(tw>min(1120,2*min(x,width-x)-20))textSize(sz*min(1120,2*min(x,width-x)-20)/tw);text(s,x,y);popStyle();}
void title(String s,float x,float y,float sz,int c) {pushStyle();textFont(headingFont);label(s,x,y,sz,c);popStyle();}
boolean hit(float x,float y,float w,float h) {return mouseX>=x&&mouseX<=x+w&&mouseY>=y&&mouseY<=y+h;}
void button(String s,float x,float y,float w,float h,boolean enabled) {
  pushStyle();stroke(INK);strokeWeight(3);fill(enabled?(hit(x,y,w,h)?GOLD:CREAM):0xff66716d);rect(x,y,w,h,6);
  fittedLabel(s,x+w/2,y+h/2,16,w-20,enabled?INK:0xffccd0c3);popStyle();
}
void assetButton(PImage img,String s,float x,float y,float w,float h) {
  img=localizedButton(img,s);
  if(img==null){button(s,x,y,w,h,true);return;}pushStyle();if(hit(x,y,w,h))tint(255,221,120);image(img,x,y,w,h);noTint();popStyle();
}
void containImage(PImage img,float x,float y,float w,float h) {
  if(img==null)return;float scale=min(w/img.width,h/img.height);image(img,x+(w-img.width*scale)/2,y+(h-img.height*scale)/2,img.width*scale,img.height*scale);
}
