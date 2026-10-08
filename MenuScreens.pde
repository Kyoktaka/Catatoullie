// Menu, wardrobe, preferences and achievements for the Level 1 prototype.
int wardrobeTab = 0;
int activeOptionSlider = -1;
int menuMuted = #BAC5BC;
String[] wardrobeHatNames = {"No hat", "Straw hat", "Brown hat", "Chef hat"};
String[] wardrobeAccessoryNames = {"No accessory", "Headphones", "Tag collar", "Eyewear"};
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
  pushStyle();
  sceneBackground(bg, 150);
  menuText("MAKE THIS CAT YOUR OWN", 640, 64, 32, CREAM, true);
  menuText("A few good finds. A little personality.", 640, 103, 16, menuMuted, true);

  menuTab("CATS", 30, 161, wardrobeTab == 0);
  menuTab("MAPS", 30, 239, wardrobeTab == 1);
  if (wardrobeTab == 0) {
    menuPanel(220, 137, 612, 473);
    menuText("HATS", 244, 169, 21, CREAM, false);
    for (int i = 0; i < 5; i++) {
      wardrobeSlot(i < 4 ? hats[i] : null, i < 4 ? wardrobeHatNames[i] : "Locked", 244+i*114, 193, i == selectedHat, i >= 4);
    }
    menuText("ACCESSORIES", 244, 329, 21, CREAM, false);
    for (int i = 0; i < 5; i++) {
      wardrobeSlot(i < 4 ? accessoryImages[i] : null, i < 4 ? wardrobeAccessoryNames[i] : "Locked", 244+i*114, 353, i == selectedAccessory, i >= 4);
    }
    menuTextFit("Choose a hat and an accessory to dress your chef.", 246, 513, 17, menuMuted, false, 558);
    menuTextFit("More wardrobe finds are coming in future levels.", 246, 550, 15, menuMuted, false, 558);

    menuPanel(852, 137, 396, 490);
    menuText("YOUR CAT", 1050, 170, 21, CREAM, true);
    catPreview(1050, 497, 252);
    rotationHint(1050, 600);
    int[] colors = {color(226, 140, 49), color(79, 115, 162), color(240, 235, 215), color(65, 66, 77), color(169, 182, 185)};
    for (int i = 0; i < 5; i++) {
      float x = 915 + i*57;
      stroke(i == selectedCat ? GOLD : color(92, 100, 111));
      strokeWeight(i == selectedCat ? 4 : 1);
      fill(colors[i]);
      rect(x, 518, 42, 35, 4);
      if (hit(x, 518, 42, 35)) {
        noFill();
        stroke(CREAM);
        strokeWeight(1);
        rect(x+4, 522, 34, 27, 2);
      }
    }
    menuText(wardrobeColorNames[selectedCat], 1050, 565, 15, menuMuted, true);
  } else {
    drawWardrobeMaps();
  }
  assetButton(backBtn, "BACK TO MENU", 34, 646, 250, 47);
  menuText("Your choices save automatically.", 1244, 671, 14, menuMuted, false, RIGHT);
  popStyle();
}

void menuTab(String title, float x, float y, boolean selected) {
  stroke(selected ? GOLD : color(107, 114, 124));
  strokeWeight(selected ? 2 : 1);
  fill(selected ? GOLD : color(29, 38, 47, 238));
  rect(x, y, 164, 60, 6);
  menuText(title, x+111, y+30, 21, selected ? INK : CREAM, true);
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
  stroke(GOLD);
  strokeWeight(2);
  fill(25, 33, 41);
  rect(x, 210, 294, 289, 7);
  if (selectionBg != null) {
    imageMode(CORNER);
    image(selectionBg, x+10, 221, 274, 171);
  }
  menuText("LEVEL 1", x+147, 425, 23, CREAM, true);
  menuText("The first shift", x+147, 456, 17, menuMuted, true);
  menuText("AVAILABLE", x+147, 482, 13, GOLD, true);
  for (int i = 0; i < 2; i++) {
    float tx = 575 + i*325;
    fill(25, 33, 41, 210);
    stroke(77, 89, 102);
    strokeWeight(1);
    rect(tx, 210, 294, 289, 7);
    if (lockImg != null) menuFitImage(lockImg, tx+113, 266, 68, 78);
    menuText("LEVEL " + (i+2), tx+147, 425, 23, menuMuted, true);
    menuText("Coming later", tx+147, 458, 17, menuMuted, true);
  }
  menuTextFit("This demo takes you from the menu through all five ingredient collections in Level 1.", 250, 551, 17, menuMuted, false, 964);
}

void drawOptions() {
  pushStyle();
  sceneBackground(bg, 155);
  menuText("OPTIONS", 640, 72, 34, CREAM, true);
  menuText("Settle in for your shift.", 640, 110, 17, menuMuted, true);
  menuPanel(268, 153, 744, 410);
  optionSlider("MUSIC", "Background melody volume", 0, musicVolume, 226, round(musicVolume*100)+"%");
  optionSlider("VFX", "Ambient effects intensity", 1, vfxAmount, 343, round(vfxAmount*100)+"%");
  optionSlider("SENSITIVITY", "Paw pickup reach", 2, (sensitivity-.5)/1.5, 460, nf(sensitivity, 1, 1)+"x");
  button("RESTORE DEFAULTS", 509, 583, 262, 47, true);
  assetButton(backBtn, "BACK TO MENU", 34, 646, 250, 47);
  menuText("Changes apply immediately and save automatically.", 640, 668, 15, menuMuted, true);
  popStyle();
}

void optionSlider(String title, String subtitle, int index, float value, float y, String amount) {
  menuText(title, 303, y-11, 20, CREAM, false);
  menuText(subtitle, 303, y+18, 13, menuMuted, false);
  float start = 600;
  float end = 921;
  stroke(84, 98, 112);
  strokeWeight(7);
  line(start, y, end, y);
  stroke(GOLD);
  line(start, y, lerp(start, end, constrain(value, 0, 1)), y);
  noStroke();
  fill(activeOptionSlider == index || hit(start-15, y-22, end-start+30, 44) ? CREAM : GOLD);
  ellipse(lerp(start, end, constrain(value, 0, 1)), y, 24, 24);
  menuText(amount, 962, y, 15, CREAM, true);
}

void drawAchievements() {
  pushStyle();
  sceneBackground(bg, 155);
  menuText("ACHIEVEMENTS", 640, 78, 34, CREAM, true);
  int count = model.completedCount();
  menuText(count + " / 5 trash cans searched in Level 1", 640, 119, 18, menuMuted, true);
  achievementCard("FIRST FINDS", "Collect the ingredients from your first trash can.", min(count, 1), 1, 187);
  achievementCard("NEIGHBORHOOD SCAVENGER", "Collect every ingredient set in Level 1.", count, 5, 325);
  int quick=0; for(int rating:model.bestStars) if(rating==3) quick=1;
  achievementCard("QUICK PAWS", "Earn three stars by finishing with 80 seconds left.", quick, 1, 463);
  assetButton(backBtn, "BACK TO MENU", 34, 646, 250, 47);
  menuText("Keep searching. Cooking comes in Level 2.", 640, 672, 15, menuMuted, true);
  popStyle();
}

void achievementCard(String title, String description, int progress, int target, float y) {
  boolean unlocked = progress >= target;
  menuPanel(250, y, 780, 114);
  noStroke();
  fill(unlocked ? GOLD : color(68, 80, 91));
  ellipse(305, y+56, 61, 61);
  if (unlocked) {
    stroke(INK);
    strokeWeight(4);
    line(292, y+56, 302, y+66);
    line(302, y+66, 320, y+44);
  } else if (lockImg != null) {
    menuFitImage(lockImg, 290, y+36, 30, 38);
  }
  menuText(title, 358, y+30, 22, unlocked ? GOLD : CREAM, false);
  menuTextFit(description, 358, y+63, 15, menuMuted, false, 626);
  menuText(unlocked ? "EARNED" : progress+" / "+target, 984, y+31, 14, unlocked ? GOLD : menuMuted, false, RIGHT);
  noStroke();
  fill(68, 80, 91);
  rect(358, y+87, 626, 5, 2);
  fill(GOLD);
  float progressWidth = 626 * constrain((float)progress/target, 0, 1);
  if (progressWidth > 0) rect(358, y+87, progressWidth, 5, 2);
}

boolean menuMousePressed() {
  if(beginAvatarDrag())return true;
  if (screen == MENU) {
    if (hit(970, 435, 260, 61)) { playUiSound(); startCutscene(); return true; }
    if (hit(970, 519, 260, 61)) { playUiSound(); screen = OPTIONS; return true; }
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
  if (screen == CUSTOMIZE) {
    if (hit(30, 161, 164, 60)) { wardrobeTab = 0; playUiSound(); return true; }
    if (hit(30, 239, 164, 60)) { wardrobeTab = 1; playUiSound(); return true; }
    if (wardrobeTab == 0) {
      for(int i=0;i<5;i++) if(hit(915+i*57,518,42,35)){selectedCat=i;playUiSound();saveProgress();return true;}
      for (int i = 0; i < 4; i++) {
        if (hit(244+i*114, 193, 100, 101)) { selectedHat = i; playUiSound(); saveProgress(); return true; }
        if (hit(244+i*114, 353, 100, 101)) { selectedAccessory = i; playUiSound(); saveProgress(); return true; }
      }
    }
  }
  if (screen == OPTIONS) {
    for (int i = 0; i < 3; i++) {
      if (hit(585, 204+i*117, 351, 44)) {
        activeOptionSlider = i;
        updateOptionSlider();
        return true;
      }
    }
    if (hit(509, 583, 262, 47)) {
      musicVolume = .35;
      vfxAmount = .7;
      sensitivity = 1;
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
}

void menuText(String value, float x, float y, float fontSize, int ink, boolean centered) {
  menuText(value, x, y, fontSize, ink, centered, LEFT);
}

void menuText(String value, float x, float y, float fontSize, int ink, boolean centered, int alignment) {
  fill(ink);
  textAlign(centered ? CENTER : alignment, CENTER);
  textSize(fontSize);
  text(value, x, y);
}

void menuTextFit(String value, float x, float y, float fontSize, int ink, boolean centered, float maxWidth) {
  textSize(fontSize);
  float measured = textWidth(value);
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
  menuText(title, x+w/2, y+h/2, 13, CREAM, true);
}

void menuFitImage(PImage icon, float x, float y, float w, float h) {
  if (icon == null || icon.width == 0 || icon.height == 0) return;
  float scale = min(w/icon.width, h/icon.height);
  imageMode(CORNER);
  image(icon, x+(w-icon.width*scale)/2, y+(h-icon.height*scale)/2, icon.width*scale, icon.height*scale);
}
