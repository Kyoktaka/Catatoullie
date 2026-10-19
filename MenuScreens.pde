// Menu, wardrobe, preferences and achievements for the Level 1 prototype.
int wardrobeTab = 0;
int activeOptionSlider = -1;
int menuMuted = #BAC5BC;
String[] wardrobeHatNames = {"No hat", "Straw hat", "Brown hat", "Chef hat", "Top hat", "Cowboy hat", "Wizard hat", "Pirate hat", "Clown hat", "Party hat", "Tall chef hat", "Pink crown", "Winter beanie", "Sun hat", "Detective hat"};
String[] wardrobeAccessoryNames = {"No accessory", "Headphones", "Tag collar", "Eyewear", "Polka dot bow", "Blue bow", "Yellow bow", "Bell collar", "Round glasses", "Yarn ball", "Satchel", "Red bandana", "Green bandana", "Anchor collar", "Sunglasses", "Striped scarf", "Fish collar", "Fishbone toy", "Toy mouse"};
String[] wardrobeColorNames = {"Ginger", "Blue", "White", "Black", "Silver Vox"};

void drawMenu() {
  pushStyle();
  sceneBackground(bg, 25);
  menuPill("A LITTLE CAT. A BIG APPETITE.", 36, 31, 350, 34);
  assetButton(achievementsBtn, "ACHIEVEMENTS", 900, 29, 266, 51);
  containImage(achievementIcon, 1182, 18, 65, 65);
  catPreview(187, 571, 280);
  rotationHint(187, 602);
  assetButton(customBtn, "CUSTOMIZATION", 44, 636, 290, 51);
  assetButton(playBtn, "PLAY", 970, 435, 260, 61);
  assetButton(optionsBtn, "OPTIONS", 970, 519, 260, 61);
  assetButton(exitBtn, "EXIT", 970, 603, 260, 61);
  popStyle();
}

void drawCustomize() {
  pushStyle();sceneBackground(bg,205);
  title("CUSTOMIZATION",640,55,32,CREAM);
  menuTab("CATS",30,161,wardrobeTab==0);menuTab("MAPS",30,239,wardrobeTab==1);
  if(wardrobeTab==0){
    menuPanel(220,137,612,473);
    wardrobeCategoryButton("HATS",244,265,wardrobeCategory==0);
    wardrobeCategoryButton("ACCESSORIES",527,281,wardrobeCategory==1);
    PImage[] icons=wardrobeCategory==0?hats:accessoryImages;
    String[] names=wardrobeCategory==0?wardrobeHatNames:wardrobeAccessoryNames;
    boolean[] owned=wardrobeCategory==0?wardrobe.hats:wardrobe.accessories;
    int selected=wardrobeCategory==0?selectedHat:selectedAccessory;
    for(int slot=0;slot<8;slot++){
      int index=wardrobePage*8+slot;if(index>=icons.length)break;
      wardrobeCard(icons[index],names[index],242+(slot%4)*143,215+(slot/4)*142,index==selected,!owned[index]);
    }
    button("<",244,520,55,40,wardrobePage>0);
    fittedLabel((wardrobePage+1)+" / "+ceil(icons.length/8.0),520,539,15,220,CREAM);
    button(">",753,520,55,40,(wardrobePage+1)*8<icons.length);
    fittedLabel("Complete a trash can or dish to unlock wardrobe rewards.",526,586,15,553,MUTED);
    menuPanel(852,137,396,473);title("YOUR CAT",1050,173,21,CREAM);
    catPreview(1050,490,230);rotationHint(1050,590);
    int[] colors={color(226,140,49),color(79,115,162),color(240,235,215),color(65,66,77),color(169,182,185)};
    for(int i=0;i<5;i++){
      stroke(i==selectedCat?GOLD:color(92,100,111));strokeWeight(i==selectedCat?3:1);fill(colors[i]);rect(915+i*57,518,42,35,8);
    }
    fittedLabel(wardrobeColorNames[selectedCat],1050,565,14,320,CREAM);
  }else drawWardrobeMaps();
  assetButton(backBtn,"BACK TO MENU",34,646,250,47);
  menuText("Your choices save automatically.",1244,671,14,menuMuted,false,RIGHT);popStyle();
}
void wardrobeCategoryButton(String name,float x,float w,boolean active){
  pushStyle();stroke(active?GOLD:MUTED);fill(active?GOLD:0xff263638);rect(x,156,w,43,7);
  fittedLabel(name,x+w/2,177,17,w-20,active?INK:CREAM);popStyle();
}
void wardrobeCard(PImage art,String name,float x,float y,boolean selected,boolean locked){
  pushStyle();stroke(selected?GOLD:0xff455454);strokeWeight(selected?2:1);
  fill(selected?0xff494536:0xff263638);rect(x,y,135,128,12);
  if(locked)tint(255,85);containImage(art,x+30,y+10,75,70);noTint();
  if(art==null){noFill();stroke(MUTED);ellipse(x+67,y+43,28,28);line(x+57,y+53,x+77,y+33);}
  if(locked)containImage(lockImg,x+105,y+10,18,22);
  fittedLabel(name,x+67,y+101,13,122,locked?MUTED:CREAM);
  if(selected){noStroke();fill(GOLD);ellipse(x+120,y+114,5,5);}
  popStyle();
}

void menuTab(String title, float x, float y, boolean selected) {
  stroke(selected ? GOLD : color(107, 114, 124));
  strokeWeight(selected ? 2 : 1);
  fill(selected ? GOLD : color(29, 38, 47, 238));
  rect(x, y, 164, 60, 6);
  menuTextFit(title, x+111, y+30, 18, selected ? INK : CREAM, true,92);
  float lift=hit(x,y,164,60)?-5:0;
  containImage(title.equals("CATS")?catsIcon:mapsIcon,x+9,y+7+lift,49,47);
}

void wardrobeSlot(PImage icon, String title, float x, float y, boolean selected, boolean locked) {
  stroke(selected ? GOLD : color(92, 103, 114));
  strokeWeight(selected ? 3 : 1);
  fill(locked ? color(29, 35, 42) : selected ? color(95, 73, 40) : color(46, 55, 63));
  rect(x, y, 100, 101, 5);
  if (locked) {
    if (lockImg != null) menuFitImage(lockImg, x+30, y+14, 40, 47);
    else menuText("?", x+50, y+40, 30, menuMuted, true);
  } else if (icon != null) {
    menuFitImage(icon, x+15, y+9, 70, 58);
  } else {
    stroke(CREAM);
    strokeWeight(2);
    noFill();
    ellipse(x+50, y+37, 31, 31);
    line(x+39, y+48, x+61, y+26);
  }
  menuTextFit(title, x+50, y+83, 12, locked ? menuMuted : CREAM, true, 91);
  if (!locked && hit(x, y, 100, 101)) {
    noFill();
    stroke(CREAM);
    strokeWeight(1);
    rect(x+4, y+4, 92, 93, 3);
  }
}

void drawWardrobeMaps() {
  menuPanel(220, 137, 1028, 473);
  menuText("YOUR NEIGHBORHOOD", 248, 172, 22, CREAM, false);
  float x = 249;
  stroke(77,89,102);
  strokeWeight(1);
  fill(25, 33, 41);
  rect(x, 210, 294, 289, 7);
  if (selectionBg != null) {
    imageMode(CORNER);
    image(selectionBg, x+10, 221, 274, 171);
  }
  menuText("LEVEL 1", x+147, 425, 23, CREAM, true);
  menuText("The first shift", x+147, 456, 17, menuMuted, true);
  drawLevelRating(0,x+147,482);
  drawLevelBorder(0,x,210,294,289);
  for (int i = 0; i < 2; i++) {
    float tx = 575 + i*325;
    fill(25, 33, 41, 210);
    stroke(77, 89, 102);
    strokeWeight(1);
    rect(tx, 210, 294, 289, 7);
    if(i==0&&level2Unlocked())containImage(kitchenImage("dish_spaghetti"),tx+63,250,170,120);
    else if(i==1&&cooking.progressMask()==31){initMealAssets();containImage(mealFood[0],tx+63,250,170,120);}
    else if (lockImg != null) menuFitImage(lockImg, tx+113, 266, 68, 78);
    menuText("LEVEL " + (i+2), tx+147, 425, 23, menuMuted, true);
    menuText(i==0?"Cooking Time":"Full Course Meal", tx+147, 458, 17, menuMuted, true);
    drawLevelRating(i+1,tx+147,482);
    drawLevelBorder(i+1,tx,210,294,289);
  }
}

void drawOptions() {
  pushStyle();sceneBackground(bg,185);title("OPTIONS",640,55,34,0xffe8dcc7);
  stroke(0xffb08b6e);strokeWeight(1.5);fill(0xffe8dcc7);rect(268,100,744,452,24);
  fill(0xff606c38,5);noStroke();for(int i=0;i<180;i++)ellipse(282+(i*71)%715,114+(i*97)%425,2,2);
  optionSlider("MUSIC","Background melody volume",0,musicVolume,optionSliderRows[0],round(musicVolume*100)+"%");
  optionSlider("SOUND EFFECTS","Buttons, paws, and cooking sounds",3,sfxVolume,optionSliderRows[3],round(sfxVolume*100)+"%");
  optionSlider("VFX","Ambient effects intensity",1,vfxAmount,optionSliderRows[1],round(vfxAmount*100)+"%");
  optionSlider("SENSITIVITY","Paw pickup reach",2,(sensitivity-.5)/1.5,optionSliderRows[2],nf(sensitivity,1,1)+"x");
  drawLanguageSelector();
  button("RESTORE DEFAULTS",350,583,262,47,true);
  button("RESET PROGRESS",640,583,290,47,true);
  assetButton(backBtn,"BACK TO MENU",34,646,250,47);
  fittedLabel("Changes apply immediately and save automatically.",784,670,14,700,MUTED);
  drawLanguageDropdown();if(confirmProgressReset)drawResetConfirmation();popStyle();
}

void optionSlider(String title, String subtitle, int index, float value, float y, String amount) {
  menuTextFit(title, 303, y-9, 20, 0xff606c38, false,280);
  menuTextFit(subtitle, 303, y+15, 13, 0xff606c38, false,275);
  float start = 600;
  float end = 921;
  stroke(0xffb08b6e);
  strokeWeight(7);
  line(start, y, end, y);
  stroke(0xff606c38);
  line(start, y, lerp(start, end, constrain(value, 0, 1)), y);
  noStroke();
  fill(activeOptionSlider == index || hit(start-15, y-22, end-start+30, 44) ? 0xff8b9d83 : 0xff606c38);
  ellipse(lerp(start, end, constrain(value, 0, 1)), y, 24, 24);
  menuText(amount, 962, y, 15, 0xff606c38, true);
}

void drawAchievements() {
  pushStyle();sceneBackground(bg,190);
  title("ACHIEVEMENTS",640,65,34,CREAM);
  int count=model.completedCount(),quick=0;
  for(int rating:model.bestStars)if(rating==3)quick=1;
  achievementCard("FIRST FINDS","Collect the ingredients from your first trash can.",min(count,1),1,100,145);
  achievementCard("NEIGHBORHOOD SCAVENGER","Collect every ingredient set in Level 1.",count,5,660,145);
  achievementCard("QUICK PAWS","Earn three stars by finishing with 80 seconds left.",quick,1,100,370);
  int dishes=Integer.bitCount(cooking.progressMask());
  achievementCard("Cooking Time","Complete five dishes. Follow each recipe in order.",dishes,5,660,370);
  assetButton(backBtn,"BACK TO MENU",34,646,250,47);popStyle();
}
void achievementCard(String name,String description,int progress,int target,float x,float y){
  boolean earned=progress>=target;
  pushStyle();noStroke();fill(0xffe8dcc7);rect(x,y,520,193,24);
  fill(earned?0xff606c38:0xffb08b6e);ellipse(x+45,y+46,46,46);
  if(earned){stroke(0xffe8dcc7);strokeWeight(3);line(x+34,y+45,x+42,y+53);line(x+42,y+53,x+58,y+37);}
  else containImage(lockImg,x+33,y+30,24,31);
  textFont(paperFonts[language]);fittedLabel(name,x+294,y+40,22,408,0xff606c38);
  fittedLabel(description,x+260,y+91,16,472,0xff606c38);
  fittedLabel(earned?"EARNED":progress+" / "+target,x+260,y+134,15,450,0xff606c38);
  noStroke();fill(0xffb08b6e);rect(x+25,y+163,470,8,4);
  fill(0xff606c38);if(progress>0)rect(x+25,y+163,470*constrain(progress/(float)target,0,1),8,4);popStyle();
}

boolean menuMousePressed() {
  if(screen==OPTIONS&&confirmProgressReset){
    if(hit(400,408,220,46))confirmProgressReset=false;
    else if(hit(660,408,220,46)){resetLevelProgress();confirmProgressReset=false;}
    return true;
  }
  if(beginAvatarDrag())return true;
  if (screen == MENU) {
    if (hit(970, 435, 260, 61)) { playUiSound(); startCutscene(WORLD_SELECT); return true; }
    if (hit(970, 519, 260, 61)) { playUiSound(); screen = OPTIONS; languageDropdownOpen=false; return true; }
    if (hit(970, 603, 260, 61)) { saveProgress(); exit(); return true; }
    if (hit(44, 636, 290, 51)) { playUiSound(); screen = CUSTOMIZE; return true; }
    if ((hit(900, 29, 266, 51)||hit(1182,18,65,65))) { playUiSound(); screen = ACHIEVEMENTS; return true; }
    return false;
  }
  if (screen == CUSTOMIZE || screen == OPTIONS || screen == ACHIEVEMENTS) {
    if (hit(34, 646, 250, 47)) {
      playUiSound(); saveProgress(); goMenu(); return true;
    }
  }
  if(screen==CUSTOMIZE){
    if(wardrobeTab==1&&hit(900,210,294,289)&&cooking.progressMask()==31){startEndingMovie(2);return true;}
    if(wardrobeTab==1&&hit(249,210,294,289)){startCutscene();return true;}
    if(wardrobeTab==1&&hit(575,210,294,289)&&level2Unlocked()){startEndingMovie(1);return true;}
    if(hit(30,161,164,60)){wardrobeTab=0;playUiSound();return true;}
    if(hit(30,239,164,60)){wardrobeTab=1;playUiSound();return true;}
    if(wardrobeTab==0){
      for(int i=0;i<5;i++)if(hit(915+i*57,518,42,35)){selectedCat=i;playUiSound();saveProgress();return true;}
      if(hit(244,156,265,43)){wardrobeCategory=0;wardrobePage=0;return true;}
      if(hit(527,156,281,43)){wardrobeCategory=1;wardrobePage=0;return true;}
      int count=wardrobeCategory==0?hats.length:accessoryImages.length;
      if(hit(244,520,55,40)){wardrobePage=max(0,wardrobePage-1);return true;}
      if(hit(753,520,55,40)){wardrobePage=min((count-1)/8,wardrobePage+1);return true;}
      for(int slot=0;slot<8;slot++)if(hit(242+(slot%4)*143,215+(slot/4)*142,135,128)){
        int index=wardrobePage*8+slot;if(index>=count)return true;
        boolean owned=wardrobeCategory==0?wardrobe.hats[index]:wardrobe.accessories[index];
        if(!owned){notifyPlayer("Complete a trash can or dish to unlock wardrobe rewards.");return true;}
        if(wardrobeCategory==0)selectedHat=index;else selectedAccessory=index;
        burst(mouseX,mouseY,12,GOLD);playUiSound();saveProgress();return true;
      }
    }
  }
  if (screen == OPTIONS) {
    if(optionsLanguageMouse())return true;
    for (int i = 0; i < 4; i++) {
      if (hit(585, optionSliderRows[i]-22, 351, 44)) {
        activeOptionSlider = i;
        updateOptionSlider();
        return true;
      }
    }
    if(hit(640,583,290,47)){confirmProgressReset=true;return true;}
    if (hit(350, 583, 262, 47)) {
      musicVolume = .35;sfxVolume=.7;
      vfxAmount = .7;
      sensitivity = 1;
      setLanguage(0,false);resetIntroLanguage();
      playUiSound();
      saveProgress();
      return true;
    }
  }
  return false;
}

void menuMouseDragged() {
  dragAvatar();
  if (screen == OPTIONS && activeOptionSlider >= 0) updateOptionSlider();
}

void menuMouseReleased() {
  finishAvatarDrag();
  if (activeOptionSlider >= 0) {
    activeOptionSlider = -1;
    saveProgress();
  }
}

void updateOptionSlider() {
  float value = constrain((mouseX-600.0)/321.0, 0, 1);
  if (activeOptionSlider == 0) musicVolume = value;
  else if (activeOptionSlider == 1) vfxAmount = value;
  else if (activeOptionSlider == 2) sensitivity = .5 + 1.5*value;
  else if (activeOptionSlider == 3){sfxVolume=value;if(gentleAudio!=null)gentleAudio.effectsGain=value;playUiSound();}
}

void menuText(String value, float x, float y, float fontSize, int ink, boolean centered) {
  menuText(value, x, y, fontSize, ink, centered, LEFT);
}

void menuText(String value, float x, float y, float fontSize, int ink, boolean centered, int alignment) {
  fill(ink);
  textAlign(centered ? CENTER : alignment, CENTER);
  textSize(fontSize);
  text(tr(value), x, y);
}

void menuTextFit(String value, float x, float y, float fontSize, int ink, boolean centered, float maxWidth) {
  textSize(fontSize);
  float measured = textWidth(tr(value));
  float fitted = measured > maxWidth ? fontSize*maxWidth/measured : fontSize;
  menuText(value, x, y, fitted, ink, centered);
}

void menuPanel(float x, float y, float w, float h) {
  stroke(171, 185, 179, 220);
  strokeWeight(2);
  fill(22, 32, 36, 239);
  rect(x, y, w, h, 9);
}

void menuPill(String title, float x, float y, float w, float h) {
  noStroke();
  fill(INK, 210);
  rect(x, y, w, h, 4);
  fittedLabel(title,x+w/2,y+h/2,13,w-20,CREAM);
}

void menuFitImage(PImage icon, float x, float y, float w, float h) {
  if (icon == null || icon.width == 0 || icon.height == 0) return;
  float scale = min(w/icon.width, h/icon.height);
  imageMode(CORNER);
  image(icon, x+(w-icon.width*scale)/2, y+(h-icon.height*scale)/2, icon.width*scale, icon.height*scale);
}
