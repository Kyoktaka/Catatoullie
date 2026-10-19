import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

/** Stable, disjoint tray slots shared by drawing and pointer selection. */
public class PreparedLayout {
  public static final int CAPACITY=8;
  private final Map<String,Integer> slots=new LinkedHashMap<String,Integer>();
  private final float[][] slotBounds=new float[CAPACITY][4];
  public PreparedLayout(){for(int i=0;i<CAPACITY;i++)slotBounds[i]=new float[]{302+i*80,548,76,60};}
  public void clear(){slots.clear();}
  public void sync(Collection<String> items){
    slots.keySet().retainAll(items);
    for(String id:items){
      if(slots.containsKey(id))continue;
      int slot=0;while(slots.containsValue(slot))slot++;
      if(slot>=CAPACITY)throw new IllegalStateException("Prepared tray capacity exceeded");
      slots.put(id,slot);
    }
  }
  public float[] bounds(String id){
    Integer slot=slots.get(id);
    // Read-only coordinates: shared by rendering and hit testing.
    return slot==null?null:slotBounds[slot];
  }
}
