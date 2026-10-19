// Runtime sprite compositing: preserve supplied files; ignore their outside matte.
// Flood only the connected border, so white markings inside outlines remain white.
PImage sprite(String path){
  PImage src=asset(path);if(src==null)return null;
  src.loadPixels();
  // Keep existing alpha and white subject details in supplied transparent PNGs.
  if((src.pixels[0]>>>24)==0&&(src.pixels[src.width-1]>>>24)==0)return trimSprite(src);
  // This necklace has a closed white hole inside its ring. Its supplied artwork
  // contains no white subject details, so expose the fur through that hole too.
  if(path.equals("ACCESSORIES/tag.png")){
    src.loadPixels();src.format=ARGB;
    for(int i=0;i<src.pixels.length;i++)if(isWhiteMatte(src.pixels[i]))src.pixels[i]=0;
    src.updatePixels();return trimSprite(src);
  }
  return removeSpriteMatte(src,null);
}
PImage removeSpriteMatte(PImage src,int[] bounds){
  src.loadPixels();src.format=ARGB;int w=src.width,h=src.height;
  boolean[] outside=new boolean[w*h];int[] queue=new int[w*h];int head=0,tail=0;
  for(int x=0;x<w;x++){
    tail=queueMattePixel(x,src.pixels,outside,queue,tail);
    tail=queueMattePixel((h-1)*w+x,src.pixels,outside,queue,tail);
  }
  for(int y=1;y<h-1;y++){
    tail=queueMattePixel(y*w,src.pixels,outside,queue,tail);
    tail=queueMattePixel(y*w+w-1,src.pixels,outside,queue,tail);
  }
  // Reuse one primitive queue. No temporary neighbor arrays per visited pixel.
  while(head<tail){
    int i=queue[head++],x=i%w;
    if(x>0)tail=queueMattePixel(i-1,src.pixels,outside,queue,tail);
    if(x<w-1)tail=queueMattePixel(i+1,src.pixels,outside,queue,tail);
    if(i>=w)tail=queueMattePixel(i-w,src.pixels,outside,queue,tail);
    if(i<w*(h-1))tail=queueMattePixel(i+w,src.pixels,outside,queue,tail);
  }
  for(int i=0;i<w*h;i++)if(outside[i])src.pixels[i]=0;
  src.updatePixels();return trimSprite(src,bounds);
}
int queueMattePixel(int i,int[] pixels,boolean[] visited,int[] queue,int tail){
  if(!visited[i]&&isWhiteMatte(pixels[i])){visited[i]=true;queue[tail++]=i;}
  return tail;
}
boolean isWhiteMatte(int p){return (p>>>24)<16 || ((p>>16&255)>239&&(p>>8&255)>239&&(p&255)>239);}
PImage trimSprite(PImage src){return trimSprite(src,null);}
PImage trimSprite(PImage src,int[] bounds){
  src.loadPixels();int minX=src.width,minY=src.height,maxX=-1,maxY=-1;
  for(int y=0,i=0;y<src.height;y++)for(int x=0;x<src.width;x++,i++)if((src.pixels[i]>>>24)>30){
    if(x<minX)minX=x;if(x>maxX)maxX=x;
    if(y<minY)minY=y;if(y>maxY)maxY=y;
  }
  if(maxX<0){if(bounds!=null){bounds[0]=0;bounds[1]=0;bounds[2]=src.width;bounds[3]=src.height;}return src;}
  int cropW=maxX-minX+1,cropH=maxY-minY+1;
  if(bounds!=null){bounds[0]=minX;bounds[1]=minY;bounds[2]=cropW;bounds[3]=cropH;}
  return src.get(minX,minY,cropW,cropH);
}

// Five coats share four registered views. Keep only the reusable masks, not
// duplicate full-resolution reference images. Each mask is built once at startup.
class CatSilhouette {
  int width,height;
  boolean[] exterior,nearExterior;
  CatSilhouette(int w,int h,boolean[] outside,boolean[] edge){width=w;height=h;exterior=outside;nearExterior=edge;}
}
CatSilhouette[] catSilhouettes=new CatSilhouette[4];
String[] catSilhouetteViews={"front","right","back","left"};
// Raw-source {left,top,width,height} registration used to anchor avatar accessories.
int[][][] catCropBounds=new int[5][4][4];

// Call before reloading assets if the source artwork is replaced during a session.
void clearSpriteMasks(){for(int i=0;i<catSilhouettes.length;i++)catSilhouettes[i]=null;}

PImage catSprite(String path,int coat,int angle){
  PImage src=asset(path);if(src==null)return null;
  src.loadPixels();src.format=ARGB;int w=src.width,h=src.height;
  CatSilhouette silhouette=catSilhouettes[angle];
  if(silhouette==null||silhouette.width!=w||silhouette.height!=h){
    String referencePath="CAT/Cat-Cuztomize-Character/cat-menu-"+catSilhouetteViews[angle]+"-orange.jpg";
    PImage reference=path.equals(referencePath)?src:asset(referencePath);
    if(reference==null||reference.width!=w||reference.height!=h)return removeSpriteMatte(src,catCropBounds[coat][angle]);
    silhouette=buildCatSilhouette(reference);catSilhouettes[angle]=silhouette;
  }
  for(int i=0;i<w*h;i++){
    if(silhouette.exterior[i]){src.pixels[i]=0;continue;}
    if(!silhouette.nearExterior[i])continue;
    int p=src.pixels[i],r=p>>16&255,g=p>>8&255,b=p&255;
    if(max(r,max(g,b))-min(r,min(g,b))<16&&r>155&&r<236)src.pixels[i]=0;
  }
  src.updatePixels();return trimSprite(src,catCropBounds[coat][angle]);
}

CatSilhouette buildCatSilhouette(PImage reference){
  reference.loadPixels();int w=reference.width,h=reference.height;
  boolean[] shape=new boolean[w*h];
  for(int i=0;i<w*h;i++){
    int p=reference.pixels[i],r=p>>16&255,g=p>>8&255,b=p&255;
    shape[i]=r-g>17&&r-b>25;
  }
  // The same two-pixel outline as before; separable windows avoid 25 lookups
  // per pixel. Preserve the original two-pixel border exclusion exactly.
  boolean[] mask=squareNeighborhood(shape,w,h,2);
  for(int y=0;y<h;y++)for(int x=0;x<w;x++)if(x<2||x>=w-2||y<2||y>=h-2)mask[y*w+x]=false;
  boolean[] exterior=new boolean[w*h];int[] queue=new int[w*h];int head=0,tail=0;
  for(int x=0;x<w;x++){
    tail=queueExteriorPixel(x,mask,exterior,queue,tail);
    tail=queueExteriorPixel((h-1)*w+x,mask,exterior,queue,tail);
  }
  for(int y=1;y<h-1;y++){
    tail=queueExteriorPixel(y*w,mask,exterior,queue,tail);
    tail=queueExteriorPixel(y*w+w-1,mask,exterior,queue,tail);
  }
  while(head<tail){
    int i=queue[head++],x=i%w;
    if(x>0)tail=queueExteriorPixel(i-1,mask,exterior,queue,tail);
    if(x<w-1)tail=queueExteriorPixel(i+1,mask,exterior,queue,tail);
    if(i>=w)tail=queueExteriorPixel(i-w,mask,exterior,queue,tail);
    if(i<w*(h-1))tail=queueExteriorPixel(i+w,mask,exterior,queue,tail);
  }
  // A three-pixel exterior neighborhood is identical for every coat. Compute
  // once, then apply each coat's own grey-fringe condition during alpha removal.
  return new CatSilhouette(w,h,exterior,squareNeighborhood(exterior,w,h,3));
}
int queueExteriorPixel(int i,boolean[] mask,boolean[] visited,int[] queue,int tail){
  if(!visited[i]&&!mask[i]){visited[i]=true;queue[tail++]=i;}
  return tail;
}

// True when any in-bounds pixel in the square radius is true. Sliding window
// counts make both passes linear in image size, independent of the radius.
boolean[] squareNeighborhood(boolean[] source,int w,int h,int radius){
  boolean[] horizontal=new boolean[w*h],result=new boolean[w*h];
  for(int y=0;y<h;y++){
    int row=y*w,count=0;
    for(int x=0;x<=radius&&x<w;x++)if(source[row+x])count++;
    for(int x=0;x<w;x++){
      horizontal[row+x]=count>0;
      int leaving=x-radius,entering=x+radius+1;
      if(leaving>=0&&source[row+leaving])count--;
      if(entering<w&&source[row+entering])count++;
    }
  }
  for(int x=0;x<w;x++){
    int count=0;
    for(int y=0;y<=radius&&y<h;y++)if(horizontal[y*w+x])count++;
    for(int y=0;y<h;y++){
      result[y*w+x]=count>0;
      int leaving=y-radius,entering=y+radius+1;
      if(leaving>=0&&horizontal[leaving*w+x])count--;
      if(entering<h&&horizontal[entering*w+x])count++;
    }
  }
  return result;
}
