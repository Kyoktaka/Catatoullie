public class GameModelTest {
  static int checks=0;
  static void check(boolean value,String message){checks++;if(!value)throw new AssertionError(message);}
  static void checkLocations(GameModel g){
    check(g.pile.size()+g.collected.size()+g.aside.size()+g.staged.size()==g.items.size(),"Every item remains in exactly one location");
    for(GameModel.Item item:g.items){
      int locations=(g.pile.contains(item)?1:0)+(g.collected.contains(item)?1:0)+(g.aside.contains(item)?1:0)+(g.staged.contains(item)?1:0);
      check(locations==1,"Each item has one location");
      check(item.state==(g.pile.contains(item)?GameModel.AVAILABLE:g.collected.contains(item)?GameModel.COLLECTED:g.staged.contains(item)?GameModel.STAGED:GameModel.SET_ASIDE),"Location matches item state");
      if(g.collected.contains(item))check(item.required,"Only needed food enters bag");
      if(g.aside.contains(item))check(!item.required,"Set-aside items are always junk");
    }
  }
  static void drain(GameModel g){
    while(!g.missionComplete()){
      GameModel.Item staged=null;
      for(GameModel.Item item:g.staged)if(g.isNextIngredient(item))staged=item;
      if(staged!=null){check(g.collectStaged(staged),"Collect next staged ingredient");check(!g.collectStaged(staged),"No duplicate staged collection");checkLocations(g);continue;}
      GameModel.Item top=g.top();check(top!=null,"All ingredients reachable");
      int count=g.pile.size();
      if(top.required&&g.isNextIngredient(top)){check(g.collectTop(top),"Collect next top food");}
      else if(top.required){check(!g.collectTop(top),"Reject out-of-order food");check(g.setAsideTop(top),"Stage later food");check(!g.collectStaged(top),"Cannot bypass order from staging");}
      else {check(!g.collectTop(top),"Cannot collect junk");check(g.setAsideTop(top),"Set top junk aside");check(g.aside.contains(top),"Junk remains beside pile");}
      check(g.pile.size()==count-1,"Exactly one pop");
      check(top.state!=GameModel.AVAILABLE,"Popped item changes state");
      check(!g.collectTop(top),"Cannot collect same item twice");
      check(!g.setAsideTop(top),"Cannot set an item aside twice");
      checkLocations(g);
    }
  }
  public static void main(String[] args){
    GameModel g=new GameModel();check(!g.startMission(1),"Later cans locked");check(!g.startMission(-1),"Negative invalid");check(!g.startMission(5),"No Level 2");
    for(int mission=0;mission<5;mission++){
      check(g.startMission(mission),"Sequential can available");
      check(g.remainingMs==120000&&!g.searching,"Preparation not timed");
      g.tick(999999);check(g.remainingMs==120000,"Loading and papers cost no time");
      GameModel.Item top=g.top(),bottom=g.pile.firstElement();
      check(!g.collectTop(top),"Cannot pick during preparation");g.beginSearch();
      int size=g.pile.size();check(!g.collectTop(bottom)&&!g.setAsideTop(bottom),"Only top allowed LIFO");check(g.pile.size()==size,"Illegal pop leaves stack intact");
      check(!g.collectTop(new GameModel.Item(top.id,top.name,top.required)),"Reject stale/forged reference");
      drain(g);check(g.completed[mission],"Mark finished");check(g.completedCount()==mission+1,"Progress exact");
      check(g.lastStars==3,"Fast finish awards 3 stars");check(g.collectedCount()==GameModel.RECIPES[mission].length,"Whole list collected");
      check(!g.searching,"Timer stops on completion");int remaining=g.remainingMs;g.tick(999999);check(g.remainingMs==remaining,"Success timer frozen");
    }
    check(g.progressMask()==31,"All Level 1 complete");
    for(int elapsed:new int[]{0,40000,40001,80000,80001,119999}){
      check(g.startMission(0),"Replay available");g.beginSearch();g.tick(elapsed);drain(g);
      check(g.lastStars==(elapsed<=40000?3:elapsed<=80000?2:1),"Star thresholds");
      check(g.bestStars[0]==3,"Replay cannot reduce best stars");check(g.completedCount()==5,"Replay preserves progression");
    }
    g.startMission(0);g.beginSearch();g.tick(120000);check(g.failed&&g.remainingMs==0&&!g.searching,"Exact timeout");
    check(!g.collectTop(g.top())&&!g.setAsideTop(g.top()),"Cannot act after expiry");check(g.completedCount()==5,"Failed replay keeps progress");
    g.startMission(0);check(!g.failed&&g.remainingMs==120000&&g.collected.isEmpty()&&g.aside.isEmpty(),"Retry resets all attempt state");
    checkLocations(g);
    g.beginSearch();g.tick(-10);check(g.remainingMs==120000,"Ignore invalid clock delta");g.tick(Integer.MAX_VALUE);check(g.failed&&g.remainingMs==0,"Large elapsed does not overflow");
    GameModel fresh=new GameModel();fresh.startMission(0);fresh.beginSearch();fresh.tick(120000);check(fresh.completedCount()==0,"Failure never unlocks next can");check(!fresh.startMission(1),"Locked after failure");
    for(int mask=0;mask<64;mask++){
      GameModel save=new GameModel();save.restoreProgress(mask);int expected=0;while(expected<5&&(mask&(1<<expected))!=0)expected++;
      check(save.completedCount()==expected,"Only contiguous saves restored");check(save.progressMask()==(1<<expected)-1,"Save roundtrip mask");
    }
    WardrobeInventory rewards=new WardrobeInventory();GameModel rewardGame=new GameModel();java.util.Random random=new java.util.Random(1);
    check(!rewards.award(rewardGame,random),"No reward before play");
    for(int stage=0;stage<5;stage++){
      rewardGame.startMission(stage);check(!rewards.award(rewardGame,random),"No preparation reward");
      rewardGame.beginSearch();drain(rewardGame);check(rewards.award(rewardGame,random),"First success gives cosmetics");
      int hat=rewards.rewardHats[stage],acc=rewards.rewardAccessories[stage];
      check(hat>=4&&acc>=4&&rewards.hats[hat]&&rewards.accessories[acc],"New cosmetics become wearable");
      check(!rewards.award(rewardGame,random),"Same result cannot award twice");
      for(int prior=0;prior<stage;prior++)check(hat!=rewards.rewardHats[prior]&&acc!=rewards.rewardAccessories[prior],"No duplicate rewards");
    }
    WardrobeInventory restored=new WardrobeInventory();
    for(int i=0;i<5;i++){restored.restoreReward(i,rewards.rewardHats[i],rewards.rewardAccessories[i]);check(restored.claimed[i],"Restore claims");}
    check(java.util.Arrays.equals(rewards.hats,restored.hats)&&java.util.Arrays.equals(rewards.accessories,restored.accessories),"Restore ownership exactly");
    rewardGame.startMission(0);rewardGame.beginSearch();drain(rewardGame);check(!restored.award(rewardGame,random),"Replay does not reroll saved rewards");
    WardrobeInventory invalid=new WardrobeInventory();invalid.restoreReward(0,100,4);check(!invalid.claimed[0],"Invalid reward rejected");
    System.out.println("GameModelTest passed: "+checks+" checks.");
  }
}
