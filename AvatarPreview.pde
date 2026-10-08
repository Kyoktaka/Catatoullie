// Drag to turn through the four supplied views. Easing and a short dissolve keep
// the turn continuous; releasing settles on the nearest complete view.
String[] viewNames={"FRONT","RIGHT","BACK","LEFT"};
float avatarYaw=0,avatarTargetYaw=0,avatarLastMouseX=0;
boolean avatarDragging=false;

int avatarView(int quarter){return ((quarter%4)+4)%4;}
void setAvatarView(int view){
  catAngle=avatarView(view);avatarYaw=catAngle;avatarTargetYaw=catAngle;avatarDragging=false;
}
void advanceAvatarRotation(float deltaMs){
  float distance=avatarTargetYaw-avatarYaw;
  avatarYaw+=distance*(1-exp(-min(deltaMs,100)/65.0));
  if(abs(avatarTargetYaw-avatarYaw)<.001)avatarYaw=avatarTargetYaw;
  if(!avatarDragging&&avatarYaw==avatarTargetYaw){
    avatarYaw=avatarView(round(avatarYaw));avatarTargetYaw=avatarYaw;
  }
  catAngle=avatarView(round(avatarTargetYaw));
}
boolean beginAvatarDrag(){
  boolean over=screen==MENU?hit(60,190,254,383):screen==CUSTOMIZE&&wardrobeTab==0&&hit(897,192,306,313);
  if(!over)return false;
  avatarDragging=true;avatarLastMouseX=mouseX;return true;
}
void dragAvatar(){
  if(!avatarDragging)return;
  avatarTargetYaw+=(mouseX-avatarLastMouseX)/100.0;avatarLastMouseX=mouseX;
  catAngle=avatarView(round(avatarTargetYaw));
}
void finishAvatarDrag(){
  if(!avatarDragging)return;
  dragAvatar();avatarDragging=false;avatarTargetYaw=round(avatarTargetYaw);
  catAngle=avatarView(round(avatarTargetYaw));saveProgress();
}
void rotationHint(float cx,float y){label("DRAG TO TURN",cx,y,12,CREAM);}
void catPreview(float cx,float bottom,float h){
  float yaw=avatarYaw;int first=floor(yaw);float blend=yaw-first;
  if(blend<.001){drawAvatarPose(avatarView(first),cx,bottom,h,1,1);return;}
  // A small squeeze suggests the foreshortening between the supplied poses.
  float squeeze=1-.065*sin(PI*blend);
  drawAvatarPose(avatarView(first),cx,bottom,h,1-blend,squeeze);
  drawAvatarPose(avatarView(first+1),cx,bottom,h,blend,squeeze);
}
void drawAvatarPose(int view,float cx,float bottom,float h,float opacity,float squeeze){
  PImage cat=catViews[selectedCat][view];if(cat==null)return;
  int[] crop=catCropBounds[selectedCat][view];float scale=h/cat.height;
  pushStyle();pushMatrix();imageMode(CORNER);tint(255,255*opacity);
  translate(cx,bottom-h);scale(squeeze,1);
  // Use the original registered canvas, not a trim box shifted by the tail.
  translate(-384*scale,-crop[1]*scale);scale(scale);
  image(cat,crop[0],crop[1],cat.width,cat.height);
  if(selectedAccessory==1&&view==0){
    PImage acc=accessoryImages[1];
    if(acc!=null)image(acc,376-300,220,600,380);
  }
  if(selectedHat>0){
    PImage hat=hats[selectedHat];boolean side=view==1||view==3;
    float headX=view==1?420:view==3?360:view==2?388:376;
    float hw=selectedHat==3?(side?290:355):selectedHat==1?(side?360:470):(side?370:510);
    float brimY=side?260:278;
    if(hat!=null){float hh=hw*hat.height/(float)hat.width;image(hat,headX-hw/2,brimY-hh*(selectedHat==3?.85:.9),hw,hh);}
  }
  // Only front artwork is available for these accessories. Do not paste a
  // forward-facing collar, ear cups or glasses onto the side/back of the cat.
  if(selectedAccessory==2&&view==0){
    PImage acc=accessoryImages[2];
    if(acc!=null){
      pushMatrix();translate(376,670);rotate(.4);
      float aw=300,ah=aw*acc.height/(float)acc.width;image(acc,-aw*.5,-ah*.33,aw,ah);popMatrix();
    }
  }else if(selectedAccessory==3&&view==0){
    PImage acc=accessoryImages[3];
    if(acc!=null){
      pushMatrix();translate(376,455);rotate(.61);
      float aw=520,ah=aw*acc.height/(float)acc.width;image(acc,-aw*.60,-ah*.46,aw,ah);popMatrix();
    }
  }
  popMatrix();popStyle();
}
