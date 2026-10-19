int language=0;
String[] languageCodes={"en","tl","es","zh","it","fr","ru"};
String[] languageNames={"English","Tagalog","Español","简体中文","Italiano","Français","Русский"};
String[] buttonFolders={"","Tagalog","Espanol","Chinese_Simplified","Italiano","Francais","Russian"};
JSONObject translations;
HashMap<String,String> translatedCache=new HashMap<String,String>();
ArrayList<String> translationTemplates=new ArrayList<String>();
HashMap<String,java.util.regex.Pattern> templatePatterns=new HashMap<String,java.util.regex.Pattern>();
PFont[] paperFonts=new PFont[7];
PFont[] bodyFonts=new PFont[7],titleFonts=new PFont[7];
PImage[][] translatedButtons=new PImage[7][8];
String[] buttonKeys={"PLAY","CUSTOMIZATION","OPTIONS","EXIT","ACHIEVEMENTS","BACK TO MENU","MAPS","CATS"};
String[] buttonFiles={"play-button","customization-button","options-button","exit-button","achievements-button","back-to-menu-button","maps-button","cats-accesory-button"};
void initLanguages(){
  try{translations=loadJSONObject(dataPath("languages.json"));}catch(Exception unavailable){println("Languages unavailable: "+unavailable.getMessage());}
  if(translations==null)translations=new JSONObject();
  for(Object raw:translations.keys()){
    String key=(String)raw;if(!key.contains("{0}"))continue;
    translationTemplates.add(key);String pattern=java.util.regex.Pattern.quote(key);
    for(int i=0;i<4;i++)pattern=pattern.replace("{"+i+"}","\\E(.+?)\\Q");
    templatePatterns.put(key,java.util.regex.Pattern.compile(pattern));
  }
  // Match specific sentences before general templates such as LEVEL {0}.
  java.util.Collections.sort(translationTemplates,new java.util.Comparator<String>(){
    public int compare(String a,String b){return b.length()-a.length();}
  });
  for(int i=0;i<7;i++){
    paperFonts[i]=createFont(i==3?"Microsoft YaHei":"Georgia",18,true);
    bodyFonts[i]=createFont(i==3?"Microsoft YaHei":"Trebuchet MS",18,true);
    titleFonts[i]=createFont(i==3?"Microsoft YaHei Bold":"Trebuchet MS Bold",28,true);
  }
  setLanguage(language,false);
}
void setLanguage(int value,boolean save){
  language=constrain(value,0,6);translatedCache.clear();
  uiFont=bodyFonts[language];headingFont=titleFonts[language];if(uiFont!=null)textFont(uiFont);
  if(language>0&&translatedButtons[language][0]==null)for(int i=0;i<buttonFiles.length;i++)
    translatedButtons[language][i]=sprite("LOCALIZED_BUTTONS/"+buttonFolders[language]+"/"+buttonFiles[i]+".png");
  if(save){resetIntroLanguage();saveProgress();}
}
String tr(String source){
  if(source==null)return "";
  if(language==0||translations==null||source.length()==0)return source;
  if(translatedCache.containsKey(source))return translatedCache.get(source);
  String result=source;
  if(translations.hasKey(source))result=translations.getJSONArray(source).getString(language-1);
  else {
    for(String key:translationTemplates){
      java.util.regex.Matcher match=templatePatterns.get(key).matcher(source);
      if(!match.matches())continue;
      result=translations.getJSONArray(key).getString(language-1);
      for(int i=0;i<match.groupCount();i++)result=result.replace("{"+i+"}",tr(match.group(i+1)));
      break;
    }
  }
  if(translatedCache.size()>2048)translatedCache.clear();
  translatedCache.put(source,result);return result;
}
String phrase(String key,Object... values){String s=key;for(int i=0;i<values.length;i++)s=s.replace("{"+i+"}",String.valueOf(values[i]));return tr(s);}
PImage localizedButton(PImage original,String key){
  if(language>0)for(int i=0;i<buttonKeys.length;i++)if(buttonKeys[i].equals(key))return translatedButtons[language][i];
  return original;
}
void fittedLabel(String s,float x,float y,float size,float maxWidth,int ink){
  pushStyle();s=tr(s);textSize(size);float measured=textWidth(s);
  if(measured>maxWidth)textSize(size*maxWidth/measured);
  fill(ink);textAlign(CENTER,CENTER);text(s,x,y);popStyle();
}
