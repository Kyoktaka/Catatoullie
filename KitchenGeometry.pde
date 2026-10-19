// Coordinates are traced on the supplied 2012 x 1258 kitchen artwork.
// Drawing and hit testing share the same cover transform as the backdrop.
final float[][] kitchenStationSourcePolygons={
  {770,807,1100,807,1100,1020,770,1020},
  {0,124,272,211,272,473,0,456},
  {1500,411,1790,411,1790,806,1500,751}
};
final float[][] kitchenStationRects=new float[3][4];
final float[][] kitchenStationPolygons=new float[3][8];
final float[] kitchenSinkRect=new float[4],kitchenStoveRect=new float[4];
float kitchenSceneScale=1,kitchenSceneX=0,kitchenSceneY=0;
int kitchenGeometryWidth=-1,kitchenGeometryHeight=-1;
void updateKitchenSceneGeometry(){updateKitchenSceneGeometry(width,height);}
void updateKitchenSceneGeometry(int viewportWidth,int viewportHeight){
  if(kitchenGeometryWidth==viewportWidth&&kitchenGeometryHeight==viewportHeight)return;
  kitchenGeometryWidth=viewportWidth;kitchenGeometryHeight=viewportHeight;
  kitchenSceneScale=max(viewportWidth/2012.0,viewportHeight/1258.0);
  kitchenSceneX=(viewportWidth-2012*kitchenSceneScale)/2;
  kitchenSceneY=(viewportHeight-1258*kitchenSceneScale)/2;
  for(int station=0;station<3;station++){
    float[] source=kitchenStationSourcePolygons[station],points=kitchenStationPolygons[station],bounds=kitchenStationRects[station];
    float left=Float.MAX_VALUE,top=Float.MAX_VALUE,right=-Float.MAX_VALUE,bottom=-Float.MAX_VALUE;
    for(int i=0;i<source.length;i+=2){
      float x=kitchenSceneX+source[i]*kitchenSceneScale,y=kitchenSceneY+source[i+1]*kitchenSceneScale;
      points[i]=x;points[i+1]=y;left=min(left,x);right=max(right,x);top=min(top,y);bottom=max(bottom,y);
    }
    bounds[0]=left;bounds[1]=top;bounds[2]=right-left;bounds[3]=bottom-top;
  }
  kitchenSceneRect(kitchenSinkRect,0,740,210,76);
  kitchenSceneRect(kitchenStoveRect,414,715,338,95);
}
void kitchenSceneRect(float[] result,float x,float y,float w,float h){
  result[0]=kitchenSceneX+x*kitchenSceneScale;result[1]=kitchenSceneY+y*kitchenSceneScale;
  result[2]=w*kitchenSceneScale;result[3]=h*kitchenSceneScale;
}
boolean kitchenStationHit(int station,float x,float y){
  updateKitchenSceneGeometry();float[] points=kitchenStationPolygons[station];boolean inside=false;
  for(int i=0,j=points.length-2;i<points.length;j=i,i+=2){
    float xi=points[i],yi=points[i+1],xj=points[j],yj=points[j+1];
    if((yi>y)!=(yj>y)&&x<(xj-xi)*(y-yi)/(yj-yi)+xi)inside=!inside;
  }
  return inside;
}

void drawKitchenStationOutline(int station){
  updateKitchenSceneGeometry();float[] points=kitchenStationPolygons[station];
  beginShape();for(int i=0;i<points.length;i+=2)vertex(points[i],points[i+1]);endShape(CLOSE);
}
