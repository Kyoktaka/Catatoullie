import java.util.Stack;

/** Level 3 owns one stack throughout placement and consumption. No rendering or I/O. */
public final class MealModel {
  public enum Phase { INTRO, STACKING, EATING, ENDING, COMPLETED, FAILED }
  public enum Dish { BURGER, PIE, LUMPIA, CHICKEN, SPAGHETTI }
  private final Stack<Dish> mealStack = new Stack<>();
  public Phase phase = Phase.INTRO;
  public int hearts = 3, remainingMs = 30000, eaten = 0, reactionMs = 0, animationMs = 0;
  public boolean paused = false;
  public boolean completed = false;
  public int bestStars = 0;

  public void restart() {
    mealStack.clear(); phase=Phase.INTRO; hearts=3; remainingMs=30000; eaten=0;
    reactionMs=0; animationMs=0; paused=false;
  }
  public void begin() { if (phase==Phase.INTRO) phase=Phase.STACKING; }
  public int size() { return mealStack.size(); }
  public Dish at(int index) { return mealStack.get(index); }
  public Dish top() { return mealStack.empty()?null:mealStack.peek(); }
  public boolean contains(Dish dish) { return mealStack.contains(dish); }
  public boolean active() { return !paused && (phase==Phase.STACKING || phase==Phase.EATING) && animationMs==0; }
  public boolean place(Dish dish, boolean onStack) {
    if (!active() || phase!=Phase.STACKING || dish==null || !onStack || contains(dish)) return false;
    if (dish.ordinal()!=mealStack.size()) { mistake(); return false; }
    mealStack.push(dish);
    if (mealStack.size()==Dish.values().length) phase=Phase.EATING;
    return true;
  }
  public boolean feed(Dish dish, boolean atCat) {
    if (!active() || phase!=Phase.EATING || dish==null || !atCat) return false;
    if (dish!=top()) { mistake(); return false; }
    mealStack.pop(); eaten++; animationMs=800;
    if (mealStack.empty()) { phase=Phase.ENDING; animationMs=2200; }
    return true;
  }
  public void mistake() {
    if (!active()) return;
    hearts=Math.max(0,hearts-1); reactionMs=800;
    if (hearts==0) phase=Phase.FAILED;
  }
  public void tick(int elapsed) {
    if (paused || elapsed<=0) return;
    reactionMs=Math.max(0,reactionMs-elapsed);
    if (phase==Phase.STACKING) {
      remainingMs=Math.max(0,remainingMs-elapsed);
      if (remainingMs==0) phase=Phase.FAILED;
    }
    animationMs=Math.max(0,animationMs-elapsed);
    if (phase==Phase.ENDING && animationMs==0) {
      phase=Phase.COMPLETED; completed=true; bestStars=Math.max(bestStars,hearts);
    }
  }
  public void restore(boolean done,int stars) {
    completed=done; bestStars=done?Math.max(1,Math.min(3,stars)):0;
  }
}
