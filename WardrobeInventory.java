import java.util.ArrayList;
import java.util.Random;

/** New cosmetics are awarded once per successful Level 1 can, without duplicates. */
public class WardrobeInventory {
  public final boolean[] hats=new boolean[15],accessories=new boolean[19],claimed=new boolean[5];
  public final int[] rewardHats={-1,-1,-1,-1,-1},rewardAccessories={-1,-1,-1,-1,-1};
  public final boolean[] cookingClaimed=new boolean[5];
  public final int[] cookingRewardHats={-1,-1,-1,-1,-1},cookingRewardAccessories={-1,-1,-1,-1,-1};
  public WardrobeInventory(){for(int i=0;i<4;i++){hats[i]=true;accessories[i]=true;}}
  public boolean award(GameModel game,Random random){
    int stage=game.missionIndex;
    if(stage<0||stage>=5||!game.missionComplete()||game.failed||claimed[stage])return false;
    rewardHats[stage]=unlock(hats,random);rewardAccessories[stage]=unlock(accessories,random);
    claimed[stage]=true;return true;
  }
  public boolean awardCooking(CookingModel cooking,Random random){
    int dish=cooking.dish;
    if(dish<0||dish>=5||!cooking.complete()||cooking.failed||cookingClaimed[dish])return false;
    cookingRewardHats[dish]=unlock(hats,random);
    cookingRewardAccessories[dish]=unlock(accessories,random);
    cookingClaimed[dish]=true;
    return cookingRewardHats[dish]>=0||cookingRewardAccessories[dish]>=0;
  }
  private int unlock(boolean[] owned,Random random){
    ArrayList<Integer> candidates=new ArrayList<Integer>();
    for(int i=4;i<owned.length;i++)if(!owned[i])candidates.add(i);
    if(candidates.isEmpty())return -1;
    int chosen=candidates.get(random.nextInt(candidates.size()));owned[chosen]=true;return chosen;
  }
  public void restoreReward(int stage,int hat,int accessory){
    if(stage<0||stage>=5||hat<4||hat>=hats.length||accessory<4||accessory>=accessories.length)return;
    for(int i=0;i<5;i++)if(i!=stage&&(rewardHats[i]==hat||rewardAccessories[i]==accessory))return;
    hats[hat]=true;accessories[accessory]=true;claimed[stage]=true;
    rewardHats[stage]=hat;rewardAccessories[stage]=accessory;
  }
  public void restoreCookingReward(int dish,int hat,int accessory){
    if(dish<0||dish>=5||hat<4||hat>=hats.length||accessory<4||accessory>=accessories.length)return;
    // Restore independently of level progress: a reset keeps these wearable rewards.
    if(hats[hat]||accessories[accessory]||cookingClaimed[dish])return;
    hats[hat]=true;accessories[accessory]=true;cookingClaimed[dish]=true;
    cookingRewardHats[dish]=hat;cookingRewardAccessories[dish]=accessory;
  }
}
