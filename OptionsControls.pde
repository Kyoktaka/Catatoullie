// Slider positions are shared by the renderer and pointer handlers.
final float[] optionSliderRows={166,310,382,238};
final float LANGUAGE_X=600,LANGUAGE_Y=448,LANGUAGE_W=364,LANGUAGE_H=46;
final float LANGUAGE_MENU_TOP=164,LANGUAGE_ROW=38;
boolean languageDropdownOpen=false;
int languageDropdownIndex=0;
void drawLanguageSelector(){
  pushStyle();fill(0xff606c38);textAlign(LEFT,CENTER);textSize(20);text(tr("LANGUAGE"),303,471);
  stroke(0xffb08b6e);strokeWeight(1.5);fill(0xffd4b895);rect(LANGUAGE_X,LANGUAGE_Y,LANGUAGE_W,LANGUAGE_H,16);
  textFont(bodyFonts[language]);fittedLabel(languageNames[language],LANGUAGE_X+LANGUAGE_W/2-12,LANGUAGE_Y+23,19,LANGUAGE_W-65,0xff606c38);
  noFill();stroke(0xff606c38);strokeWeight(2);float arrowX=LANGUAGE_X+LANGUAGE_W-28,arrowY=LANGUAGE_Y+23;
  if(languageDropdownOpen){line(arrowX-6,arrowY+3,arrowX,arrowY-3);line(arrowX,arrowY-3,arrowX+6,arrowY+3);}
  else{line(arrowX-6,arrowY-3,arrowX,arrowY+3);line(arrowX,arrowY+3,arrowX+6,arrowY-3);}popStyle();
}
float languageOptionY(int index){return LANGUAGE_MENU_TOP+6+index*LANGUAGE_ROW;}
void drawLanguageDropdown(){
  if(!languageDropdownOpen)return;
  pushStyle();noStroke();fill(0xff606c38,30);rect(LANGUAGE_X+4,LANGUAGE_MENU_TOP+4,LANGUAGE_W,278,16);
  stroke(0xffb08b6e);fill(0xffe8dcc7);rect(LANGUAGE_X,LANGUAGE_MENU_TOP,LANGUAGE_W,278,16);
  for(int i=0;i<languageNames.length;i++){
    float y=languageOptionY(i);boolean hover=hit(LANGUAGE_X+6,y,LANGUAGE_W-12,LANGUAGE_ROW);
    noStroke();fill(i==languageDropdownIndex||hover?0xff8b9d83:0xffe8dcc7);rect(LANGUAGE_X+6,y,LANGUAGE_W-12,LANGUAGE_ROW,12);
    textFont(bodyFonts[i]);fittedLabel(languageNames[i],LANGUAGE_X+LANGUAGE_W/2,y+LANGUAGE_ROW/2,18,LANGUAGE_W-80,0xff606c38);
    if(i==language){stroke(0xff606c38);strokeWeight(2);line(LANGUAGE_X+20,y+19,LANGUAGE_X+25,y+24);line(LANGUAGE_X+25,y+24,LANGUAGE_X+34,y+13);}
  }popStyle();
}
void chooseOptionsLanguage(int index){languageDropdownOpen=false;setLanguage(index,true);playUiSound();}
boolean optionsLanguageMouse(){
  if(languageDropdownOpen){
    for(int i=0;i<languageNames.length;i++)if(hit(LANGUAGE_X+6,languageOptionY(i),LANGUAGE_W-12,LANGUAGE_ROW)){chooseOptionsLanguage(i);return true;}
    languageDropdownOpen=false;return true;
  }
  if(hit(LANGUAGE_X,LANGUAGE_Y,LANGUAGE_W,LANGUAGE_H)){languageDropdownOpen=true;languageDropdownIndex=language;activeOptionSlider=-1;return true;}
  return false;
}
boolean optionsKeyPressed(){
  if(screen!=OPTIONS||!languageDropdownOpen)return false;
  if(key==ESC){key=0;languageDropdownOpen=false;return true;}
  if(key==CODED){
    if(keyCode==UP)languageDropdownIndex=(languageDropdownIndex+languageNames.length-1)%languageNames.length;
    else if(keyCode==DOWN)languageDropdownIndex=(languageDropdownIndex+1)%languageNames.length;
  }else if(key==ENTER||key==RETURN||key==' ')chooseOptionsLanguage(languageDropdownIndex);
  return true;
}
