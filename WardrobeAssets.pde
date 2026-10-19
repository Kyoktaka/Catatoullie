WardrobeInventory wardrobe=new WardrobeInventory();
int wardrobeCategory=0,wardrobePage=0;
boolean newReward=false;
String[] newHatFiles={"01_top_hat","02_cowboy_hat","03_wizard_hat","04_pirate_hat","05_clown_hat","06_party_hat","07_chef_hat","08_pink_crown","09_winter_beanie","10_sun_hat","11_detective_hat"};
String[] newAccessoryFiles={"01_red_polka_dot_bow","02_blue_bow","03_yellow_bow","04_red_bell_collar","05_round_glasses","06_red_yarn_ball","07_brown_satchel","08_red_bandana","09_green_bandana","10_blue_anchor_collar","11_sunglasses","12_striped_scarf","13_purple_fish_collar","14_fishbone_toy","15_toy_mouse"};
// Raw cat-canvas measurements. Brim anchors vary with each silhouette.
float[] hatWidths={0,470,510,420,400,555,455,555,505,310,420,330,440,535,505};
float[] hatBrims={0,.90,.90,.96,.91,.78,.87,.90,.88,.97,.96,.96,.97,.68,.92};
void loadWardrobe(){
  for(int i=0;i<newHatFiles.length;i++)hats[i+4]=sprite("WARDROBE/Hats/"+newHatFiles[i]+".png");
  for(int i=0;i<newAccessoryFiles.length;i++)accessoryImages[i+4]=sprite("WARDROBE/Accessories/"+newAccessoryFiles[i]+".png");
  // The new front-facing chef art has a level brim and fits all four registered views.
  hats[3]=sprite("WARDROBE/Hats/07_chef_hat.png");
}
void drawNewAccessory(int index,int view){
  if(index<4||view!=0)return;
  PImage art=accessoryImages[index];if(art==null)return;
  float x=376,y=611,w=295,anchor=.28;
  if(index>=4&&index<=6){w=235;y=612;anchor=.5;}
  if(index==8||index==14){w=515;y=456;anchor=.5;}
  if(index==9||index==17||index==18){x=555;y=1130;w=index==9?250:265;anchor=.5;}
  if(index==10){x=510;y=815;w=325;anchor=.48;}
  if(index==11||index==12){w=320;y=605;anchor=.18;}
  if(index==15){w=320;y=610;anchor=.18;}
  float h=w*art.height/(float)art.width;
  // Hide the rear rim of neckwear behind the neck instead of exposing an empty ring.
  boolean neckwear=index==7||index==11||index==12||index==13||index==16;
  float top=neckwear?.35:0;
  if(neckwear)image(art,x-w*.5,y,w,h*(1-top),0,round(art.height*top),art.width,art.height);
  else image(art,x-w*.5,y-h*anchor,w,h);
}
void grantMissionReward(){
  newReward=wardrobe.award(model,new java.util.Random());
  if(newReward)burst(640,320,64,GOLD);
}

boolean newCookingReward=false;
void grantCookingReward(){
  newCookingReward=wardrobe.awardCooking(cooking,new java.util.Random());
  if(newCookingReward)burst(640,395,44,GOLD);
}
void drawCookingRewards(){
  int dish=cooking.dish;if(dish<0||!wardrobe.cookingClaimed[dish])return;
  int hat=wardrobe.cookingRewardHats[dish],accessory=wardrobe.cookingRewardAccessories[dish];
  if(hat<0&&accessory<0)return;
  pushStyle();noStroke();fill(0xffe8dcc7);rect(377,413,526,96,20);
  textFont(paperFonts[language]);fittedLabel(newCookingReward?"NEW WARDROBE FINDS":"STAGE REWARDS",640,430,17,490,0xff606c38);
  if(hat>=0){containImage(hats[hat],432,447,58,42);fittedLabel(wardrobeHatNames[hat],500,497,13,236,0xff606c38);}
  if(accessory>=0){containImage(accessoryImages[accessory],722,447,58,42);fittedLabel(wardrobeAccessoryNames[accessory],779,497,13,236,0xff606c38);}
  popStyle();
}
