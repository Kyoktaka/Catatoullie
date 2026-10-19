// Read each field independently so one damaged value cannot discard later data.
int savedInt(JSONObject object,String key,int fallback){try{return object.getInt(key,fallback);}catch(Exception invalid){return fallback;}}
boolean savedBoolean(JSONObject object,String key,boolean fallback){try{return object.getBoolean(key,fallback);}catch(Exception invalid){return fallback;}}
JSONArray savedArray(JSONObject object,String key){try{return object.getJSONArray(key);}catch(Exception invalid){return null;}}
JSONObject savedObject(JSONArray array,int index){try{return array.getJSONObject(index);}catch(Exception invalid){return null;}}
int savedRating(JSONArray array,int index){try{return constrain(array.getInt(index),1,3);}catch(Exception invalid){return 1;}}
float finiteSetting(float value,float fallback,float low,float high){return Float.isFinite(value)?constrain(value,low,high):fallback;}
float savedSetting(JSONObject object,String key,float fallback,float low,float high){
  try{return finiteSetting(object.getFloat(key,fallback),fallback,low,high);}catch(Exception invalid){return fallback;}
}
void writeProgressAtomically(JSONObject data)throws java.io.IOException{
  java.nio.file.Path target=java.nio.file.Paths.get(progressPath()).toAbsolutePath();
  java.nio.file.Path temporary=java.nio.file.Files.createTempFile(target.getParent(),"savegame-",".json");
  try{
    if(!saveJSONObject(data,temporary.toString()))throw new java.io.IOException("Could not write temporary save");
    try{java.nio.file.Files.move(temporary,target,java.nio.file.StandardCopyOption.ATOMIC_MOVE,java.nio.file.StandardCopyOption.REPLACE_EXISTING);}
    catch(java.nio.file.AtomicMoveNotSupportedException unsupported){java.nio.file.Files.move(temporary,target,java.nio.file.StandardCopyOption.REPLACE_EXISTING);}
  }finally{java.nio.file.Files.deleteIfExists(temporary);}
}
