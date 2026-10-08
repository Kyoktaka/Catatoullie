// Small code-native food icons. Entry coordinates are the CENTER of the icon.
void ingredientArt(GameModel.Item item, float x, float y, float size) {
  if (item == null) return;
  pushStyle();
  pushMatrix();
  translate(x-size/2, y-size/2);
  scale(size/64.0);
  rectMode(CORNER);
  ellipseMode(CENTER);
  stroke(INK);
  strokeWeight(2.5);
  strokeJoin(ROUND);
  String food = item.name;
  if (food.equals("Banana Peel") && bananaImg != null) containImage(bananaImg, 2, 2, 60, 60);
  else if (food.equals("Fish Bones") && bonesImg != null) containImage(bonesImg, 2, 2, 60, 60);
  else if (food.equals("Fish Bones") && fishImg != null) containImage(fishImg, 2, 2, 60, 60);
  else if (food.equals("Empty Bottle") && bottleImg != null) containImage(bottleImg, 2, 2, 60, 60);
  else if (food.equals("Pasta")) {
    for (int i = 0; i < 6; i++) {
      fill(i%2 == 0 ? color(247, 198, 70) : color(231, 170, 43));
      quad(13+i*5, 9, 17+i*5, 10, 46-i*4, 56, 41-i*4, 55);
    }
    fill(202, 81, 54); rect(17, 30, 29, 9, 2);
  } else if (food.equals("Meatballs")) {
    fill(244, 230, 196); ellipse(32, 47, 55, 20);
    ingredientMeatball(21, 37, 21); ingredientMeatball(43, 36, 23); ingredientMeatball(31, 23, 23);
  } else if (food.equals("Hot Dogs")) {
    pushMatrix(); translate(31, 31); rotate(-.55);
    fill(190, 78, 48); rect(-21, -18, 43, 15, 8); rect(-21, 3, 43, 15, 8);
    stroke(239, 150, 91); line(-9, -15, -5, -7); line(3, -15, 7, -7); line(-9, 6, -5, 14); line(3, 6, 7, 14);
    popMatrix();
  } else if (food.equals("Tomato Can") || food.equals("Canned Peach")) {
    ingredientTin(food.equals("Tomato Can") ? color(214, 72, 45) : color(244, 174, 58), food.equals("Tomato Can") ? "T" : "P");
  } else if (food.equals("Milk") || food.equals("Buttermilk")) {
    ingredientCarton(food.equals("Milk") ? color(102, 169, 190) : color(179, 135, 199), food.equals("Milk") ? "M" : "B");
  } else if (food.equals("Onion") || food.equals("White Onion") || food.equals("Garlic")) {
    boolean garlic = food.equals("Garlic");
    fill(food.equals("Onion") ? color(220, 166, 84) : color(238, 225, 184));
    ellipse(32, 36, 44, 39);
    if (garlic) { ellipse(21, 37, 18, 29); ellipse(43, 37, 18, 29); ellipse(32, 37, 18, 34); }
    else { noFill(); arc(32, 36, 26, 38, -.9, .9); arc(31, 36, 23, 38, PI-.9, PI+.9); }
    fill(185, 144, 83); quad(27, 19, 29, 8, 36, 8, 37, 19);
    stroke(143, 115, 73); line(32, 55, 28, 60); line(32, 55, 34, 60); line(35, 54, 39, 58);
  } else if (food.equals("Oil")) ingredientBottle(color(226, 168, 47), color(65, 116, 66), "O");
  else if (food.equals("Water Bottle") || food.equals("Empty Bottle")) ingredientBottle(color(137, 204, 214), color(66, 132, 173), "W");
  else if (food.equals("Lemon Juice")) ingredientBottle(color(244, 211, 71), color(85, 143, 61), "L");
  else if (food.equals("Peach Syrup")) ingredientBottle(color(237, 160, 76), color(169, 97, 58), "P");
  else if (food.equals("Cheese")) {
    fill(247, 194, 61); triangle(9, 47, 51, 47, 50, 15);
    fill(224, 156, 37); quad(9, 47, 51, 47, 55, 54, 13, 54);
    noStroke(); fill(189, 129, 37); ellipse(40, 36, 7, 8); ellipse(30, 43, 5, 5); ellipse(45, 24, 4, 4);
  } else if (food.equals("Chicken")) ingredientDrumstick(32, 30, 1);
  else if (food.equals("All-Purpose Flour") || food.equals("Cornstarch") || food.equals("Sugar")) {
    int band = food.equals("All-Purpose Flour") ? color(198, 137, 76) : food.equals("Cornstarch") ? color(223, 172, 48) : color(106, 175, 202);
    ingredientBag(band, food.equals("All-Purpose Flour") ? "F" : food.equals("Cornstarch") ? "C" : "S");
  } else if (food.equals("Salt") || food.equals("Pepper") || food.equals("Black Pepper") || food.equals("Garlic Powder") || food.equals("Ground Cinnamon")) {
    int spice = food.equals("Salt") ? color(236, 233, 211) : food.equals("Garlic Powder") ? color(220, 189, 112) : food.equals("Ground Cinnamon") ? color(161, 87, 46) : color(98, 88, 71);
    ingredientSpice(spice, food.equals("Salt") ? "S" : food.equals("Garlic Powder") ? "G" : food.equals("Ground Cinnamon") ? "C" : "P");
  } else if (food.equals("Ground Pork")) {
    fill(219, 225, 213); rect(5, 15, 54, 40, 7);
    fill(213, 135, 128); rect(10, 19, 44, 31, 4);
    stroke(174, 81, 80); strokeWeight(2);
    for (int i = 0; i < 4; i++) { line(15, 23+i*7, 45, 23+i*7); line(45, 23+i*7, 49, 26+i*7); }
    stroke(246, 178, 162); line(20, 22, 20, 44); line(36, 22, 36, 44);
  } else if (food.equals("Carrots")) {
    stroke(INK); fill(235, 135, 36); triangle(15, 18, 35, 26, 20, 57); triangle(37, 19, 53, 30, 36, 57);
    stroke(60, 130, 57); strokeWeight(4); line(24, 22, 17, 7); line(24, 22, 29, 8); line(43, 25, 39, 9); line(43, 25, 51, 13);
    stroke(177, 95, 32); strokeWeight(2); line(19, 33, 26, 36); line(20, 44, 24, 46); line(41, 35, 46, 38);
  } else if (food.equals("Scallions")) {
    strokeWeight(6); stroke(62, 128, 66); line(29, 43, 12, 8); line(33, 44, 35, 5); line(38, 45, 52, 12);
    stroke(206, 228, 152); line(29, 44, 21, 25); line(34, 45, 35, 27); line(39, 46, 45, 31);
    stroke(239, 234, 198); line(29, 44, 28, 56); line(34, 45, 35, 57); line(39, 46, 43, 56);
    strokeWeight(1.5); stroke(145, 117, 70); line(28, 56, 24, 61); line(35, 57, 36, 62); line(43, 56, 47, 60);
  } else if (food.equals("Egg")) {
    fill(239, 216, 175); ellipse(32, 34, 36, 46);
    noStroke(); fill(255, 242, 211); ellipse(26, 24, 10, 16);
  } else if (food.equals("Lumpia Wrapper") || food.equals("Puff Pastry")) {
    boolean pastry = food.equals("Puff Pastry");
    fill(pastry ? color(216, 168, 92) : color(207, 203, 164)); rect(9, 14, 43, 41, 2);
    fill(pastry ? color(243, 202, 126) : color(244, 234, 188)); rect(14, 9, 43, 41, 2);
    stroke(pastry ? color(182, 134, 65) : color(199, 186, 146));
    if (pastry) for (int a = 0; a < 3; a++) for (int b = 0; b < 3; b++) point(24+a*10, 19+b*10);
    else { line(18, 44, 50, 15); line(18, 15, 50, 44); }
  } else if (food.equals("Mangoes")) {
    fill(240, 169, 43); ellipse(24, 36, 30, 40); fill(249, 194, 52); ellipse(42, 35, 26, 37);
    noStroke(); fill(255, 220, 99); ellipse(23, 30, 9, 20); fill(72, 130, 64); ellipse(35, 15, 18, 8);
  } else if (food.equals("Lettuce")) {
    fill(97, 160, 70);
    ellipse(18, 32, 25, 29); ellipse(33, 24, 30, 30); ellipse(48, 33, 23, 28); ellipse(33, 43, 39, 29);
    stroke(191, 211, 123); strokeWeight(3); line(33, 55, 30, 21); line(32, 43, 17, 31); line(32, 43, 47, 29);
  } else if (food.equals("Tomato")) {
    fill(218, 72, 47); ellipse(32, 36, 47, 42); noStroke(); fill(245, 126, 78); ellipse(22, 28, 9, 11);
    fill(64, 126, 57); beginShape(); vertex(32, 12); vertex(36, 23); vertex(46, 19); vertex(40, 29); vertex(31, 25); vertex(22, 30); vertex(25, 21); vertex(18, 17); vertex(29, 19); endShape(CLOSE);
  } else if (food.equals("Pickles")) {
    fill(183, 198, 123); rect(12, 17, 40, 41, 7); fill(93, 131, 73); rect(11, 9, 42, 11, 2);
    fill(104, 156, 64); ellipse(25, 37, 12, 26); ellipse(40, 38, 11, 29);
    stroke(173, 192, 91); line(25, 28, 25, 43); line(40, 27, 40, 47);
  } else if (food.equals("Mayo") || food.equals("Ketchup") || food.equals("Mustard")) {
    int sauce = food.equals("Mayo") ? color(239, 225, 168) : food.equals("Ketchup") ? color(204, 65, 44) : color(225, 182, 43);
    ingredientSqueeze(sauce, food.equals("Ketchup") ? "K" : "M");
  } else if (food.equals("Buns")) {
    fill(204, 141, 66); rect(10, 41, 45, 13, 7);
    fill(231, 171, 85); arc(32, 33, 46, 43, PI, TWO_PI, CHORD); rect(9, 31, 46, 7, 3);
    stroke(249, 224, 157); strokeWeight(3); line(23, 20, 24, 22); line(35, 16, 36, 18); line(44, 24, 45, 26);
  } else {
    // Fallback only for future ingredients without an icon.
    ingredientBag(color(168, 147, 99), "?");
  }
  popMatrix();
  popStyle();
}

void ingredientMeatball(float x, float y, float d) {
  stroke(INK); fill(147, 78, 49); ellipse(x, y, d, d);
  noStroke(); fill(200, 119, 67); ellipse(x-d*.14, y-d*.17, d*.24, d*.24); fill(99, 62, 41); rect(x+d*.16, y, 3, 3);
}

void ingredientTin(int labelColor, String letter) {
  stroke(INK); fill(187, 196, 178); rect(13, 12, 38, 44, 4);
  fill(labelColor); rect(13, 23, 38, 25); fill(215, 222, 202); ellipse(32, 13, 38, 10);
  noFill(); stroke(114, 130, 119); ellipse(32, 13, 27, 5); line(17, 52, 47, 52);
  ingredientLetter(letter, 32, 36, color(255, 242, 198));
}

void ingredientCarton(int band, String letter) {
  stroke(INK); fill(239, 230, 199); rect(14, 20, 36, 38);
  fill(217, 211, 182); quad(14, 20, 22, 8, 43, 8, 50, 20); line(22, 8, 22, 20);
  fill(band); rect(14, 31, 36, 18); fill(251, 241, 213); ellipse(39, 21, 8, 5);
  ingredientLetter(letter, 32, 40, color(255, 246, 217));
}

void ingredientBottle(int contents, int cap, String letter) {
  stroke(INK); fill(contents); beginShape(); vertex(25, 13); vertex(39, 13); vertex(39, 23); vertex(47, 28); vertex(47, 56); vertex(17, 56); vertex(17, 28); vertex(25, 23); endShape(CLOSE);
  fill(cap); rect(24, 7, 16, 9, 2); fill(245, 229, 187); rect(18, 32, 28, 16, 1);
  ingredientLetter(letter, 32, 40, INK);
}

void ingredientBag(int band, String letter) {
  stroke(INK); fill(233, 217, 170); beginShape(); vertex(17, 8); vertex(47, 8); vertex(44, 18); vertex(51, 56); vertex(13, 56); vertex(20, 18); endShape(CLOSE);
  fill(band); rect(15, 30, 34, 18, 2); line(19, 14, 44, 14);
  ingredientLetter(letter, 32, 39, INK);
}

void ingredientSpice(int contents, String letter) {
  stroke(INK); fill(contents); rect(17, 19, 30, 39, 5); fill(128, 135, 117); rect(15, 8, 34, 13, 3);
  stroke(74, 85, 76); line(23, 10, 23, 18); line(32, 10, 32, 18); line(41, 10, 41, 18);
  stroke(INK); fill(248, 230, 177); rect(18, 32, 28, 17, 1);
  ingredientLetter(letter, 32, 41, INK);
}

void ingredientSqueeze(int sauce, String letter) {
  stroke(INK); fill(sauce); rect(17, 23, 30, 34, 7); triangle(24, 23, 32, 7, 40, 23);
  fill(240, 227, 185); rect(17, 35, 30, 13);
  ingredientLetter(letter, 32, 41, INK);
}

void ingredientLetter(String value, float x, float y, int ink) {
  fill(ink); textAlign(CENTER, CENTER); textSize(15); text(value, x, y-1);
}

void ingredientDrumstick(float x, float y, float multiplier) {
  pushMatrix(); translate(x, y); scale(multiplier);
  stroke(INK); strokeWeight(2.5);
  fill(238, 225, 185); quad(3, 4, 9, 0, 25, 21, 18, 27); ellipse(23, 26, 12, 10); ellipse(28, 21, 10, 12);
  fill(199, 128, 58); ellipse(-5, -4, 35, 30); fill(227, 157, 73); ellipse(-11, -8, 22, 23);
  noStroke(); fill(167, 98, 40); rect(-16, -13, 4, 4); rect(-3, -7, 4, 4); rect(-10, 2, 4, 4);
  popMatrix();
}

void drawMeal(int index, float x, float y, float size, boolean unlocked) {
  pushStyle(); pushMatrix();
  translate(x-size/2, y-size/2); scale(size/64.0);
  rectMode(CORNER); ellipseMode(CENTER); strokeJoin(ROUND);
  stroke(INK); strokeWeight(2);
  if (!unlocked) {
    fill(116, 122, 111); ellipse(32, 49, 58, 19); fill(143, 145, 124); arc(32, 39, 49, 38, PI, TWO_PI, CHORD); rect(8, 36, 48, 8, 2);
    noFill(); stroke(56, 67, 60); strokeWeight(4); arc(32, 27, 17, 21, PI, TWO_PI);
    fill(190, 184, 142); strokeWeight(2); rect(21, 26, 22, 20, 3); fill(56, 67, 60); ellipse(32, 34, 4, 4); rect(31, 34, 2, 6);
  } else if (index == 4) {
    fill(215, 148, 63); rect(8, 46, 49, 11, 6);
    fill(91, 60, 41); rect(7, 37, 51, 10, 4);
    fill(240, 192, 46); triangle(7, 34, 56, 34, 43, 46);
    fill(207, 70, 44); rect(9, 28, 45, 7, 3);
    fill(91, 144, 60); beginShape(); vertex(6, 28); vertex(13, 23); vertex(21, 27); vertex(30, 23); vertex(41, 26); vertex(50, 23); vertex(59, 29); vertex(53, 34); vertex(42, 31); vertex(32, 34); vertex(20, 31); vertex(10, 34); endShape(CLOSE);
    fill(230, 168, 77); arc(32, 26, 50, 42, PI, TWO_PI, CHORD); rect(7, 23, 50, 6, 3);
    stroke(250, 225, 149); strokeWeight(2.5); line(20, 16, 22, 17); line(32, 10, 34, 11); line(44, 17, 46, 18);
  } else {
    fill(221, 225, 207); ellipse(32, 43, 59, 31); fill(245, 238, 206); ellipse(32, 41, 47, 22);
    if (index == 0) {
      stroke(206, 149, 42); strokeWeight(3); fill(236, 190, 61); ellipse(32, 34, 43, 28);
      noFill(); stroke(250, 217, 101); for (int i = 0; i < 4; i++) arc(31, 32+i*3, 34-i*3, 19, -.5, PI+.5);
      noStroke(); fill(202, 72, 43); ellipse(32, 29, 28, 18);
      ingredientMeatball(25, 26, 11); ingredientMeatball(40, 28, 12); ingredientMeatball(32, 36, 11);
      stroke(89, 139, 61); strokeWeight(3); line(30, 17, 34, 20);
    } else if (index == 1) {
      ingredientDrumstick(26, 30, .75); ingredientDrumstick(41, 38, .66);
      noStroke(); fill(88, 147, 60); ellipse(13, 42, 14, 9); ellipse(17, 48, 13, 7);
    } else if (index == 2) {
      pushMatrix(); translate(31, 33); rotate(-.35);
      for (int i = 0; i < 3; i++) { stroke(116, 83, 42); fill(220+i*8, 161+i*9, 69); rect(-22, -17+i*12, 43, 10, 3); stroke(246, 210, 122); line(-16, -14+i*12, 13, -14+i*12); }
      popMatrix();
      fill(188, 72, 46); stroke(INK); ellipse(51, 46, 13, 11);
    } else if (index == 3) {
      fill(214, 133, 40); triangle(10, 46, 51, 46, 47, 15);
      fill(239, 186, 72); triangle(10, 38, 49, 38, 47, 11);
      stroke(158, 103, 43); strokeWeight(4); line(47, 11, 51, 46);
      stroke(252, 219, 130); strokeWeight(3); line(23, 32, 45, 29); line(34, 24, 46, 22); line(35, 36, 43, 18);
    }
  }
  popMatrix(); popStyle();
}
