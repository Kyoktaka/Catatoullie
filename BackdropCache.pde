// Cache only static background composition. Eight 1280 x 720 layers use at most
// about 28 MiB of pixel storage; eviction releases references to older scenes.
class BackdropLayer {
  PImage source,pixels;
  float x,y,w,h,shade;
  int viewportWidth,viewportHeight,smoothing;
  boolean matches(PImage image,float px,float py,float pw,float ph,float alpha){
    return source==image&&x==px&&y==py&&w==pw&&h==ph&&shade==alpha&&viewportWidth==width&&viewportHeight==height&&smoothing==g.smooth;
  }
}
ArrayList<BackdropLayer> backdropLayers=new ArrayList<BackdropLayer>();
void cachedBackdrop(PImage source,float x,float y,float w,float h,float shade){
  BackdropLayer found=null;
  for(int i=0;i<backdropLayers.size();i++){
    BackdropLayer layer=backdropLayers.get(i);
    if(layer.matches(source,x,y,w,h,shade)){found=layer;backdropLayers.remove(i);break;}
  }
  if(found==null){
    found=new BackdropLayer();found.source=source;found.x=x;found.y=y;found.w=w;found.h=h;found.shade=shade;
    found.viewportWidth=width;found.viewportHeight=height;found.smoothing=g.smooth;
    PGraphics canvas=createGraphics(width,height);
    if(g.smooth==0)canvas.noSmooth();else canvas.smooth(g.smooth);
    canvas.beginDraw();canvas.background(INK);
    if(source!=null)canvas.image(source,x,y,w,h);
    canvas.noStroke();canvas.fill(INK,shade);canvas.rect(0,0,width,height);canvas.endDraw();
    found.pixels=canvas.get();canvas.dispose();
    if(backdropLayers.size()>=8)backdropLayers.remove(0);
  }
  backdropLayers.add(found);
  pushStyle();imageMode(CORNER);noTint();image(found.pixels,0,0);popStyle();
}
