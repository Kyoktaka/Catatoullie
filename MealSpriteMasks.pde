// Clear only near-black pixels connected to the outer matte. Enclosed eyes,
// mouth and fur markings remain intact. Runs once per cached sprite load.
PImage mealCatSprite(String path){
  PImage src=asset(path);if(src==null)return null;
  src.loadPixels();src.format=ARGB;
  int w=src.width,h=src.height,head=0,tail=0;
  boolean[] visited=new boolean[w*h];int[] queue=new int[w*h];
  for(int x=0;x<w;x++){
    tail=queueMealMatte(x,src.pixels,visited,queue,tail);
    tail=queueMealMatte((h-1)*w+x,src.pixels,visited,queue,tail);
  }
  for(int y=1;y<h-1;y++){
    tail=queueMealMatte(y*w,src.pixels,visited,queue,tail);
    tail=queueMealMatte(y*w+w-1,src.pixels,visited,queue,tail);
  }
  while(head<tail){
    int i=queue[head++],x=i%w;
    if(x>0)tail=queueMealMatte(i-1,src.pixels,visited,queue,tail);
    if(x<w-1)tail=queueMealMatte(i+1,src.pixels,visited,queue,tail);
    if(i>=w)tail=queueMealMatte(i-w,src.pixels,visited,queue,tail);
    if(i<w*(h-1))tail=queueMealMatte(i+w,src.pixels,visited,queue,tail);
  }
  for(int i=0;i<w*h;i++)if(visited[i])src.pixels[i]=0;
  src.updatePixels();return trimSprite(src);
}
int queueMealMatte(int i,int[] pixels,boolean[] visited,int[] queue,int tail){
  int p=pixels[i];
  if(!visited[i]&&(isWhiteMatte(p)||((p>>16&255)<24&&(p>>8&255)<24&&(p&255)<24))){
    visited[i]=true;queue[tail++]=i;
  }
  return tail;
}
