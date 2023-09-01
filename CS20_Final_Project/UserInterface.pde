/*** USERINTERFACE CLASS 
 * Manages visual elements that are fixated on the screen, and don't move. 
 * Methods in this class include:
 *   - displayHealth() (displays the health bar at a given position) */

class UserInterface {
  void displayHealth(float x, float y, float len, float wid) {
    translate(x, y);
    fill(0);
    noStroke();
    rectMode(CORNER);
    rect(x, y, len, wid);
    rectMode(CENTER);
  }
  
  
  /** Displays the box where enemies will spot the player, 
   *   as well as coordinates on the mouse displaying coordinates at that location. */
  void displayDebugCoordinates() {
    if (!debugging) {
      return;
    }
    // Coordinates of mouse position
    pushMatrix();
    translate(10, 10);
    fill(0);
    textSize(14);
    textAlign(LEFT, TOP);
    text(round(mouseX+player.getPosition().x-width/2) + ", " + round(mouseY+player.getPosition().y-height/2), mouseX, mouseY);
    popMatrix();
  }
}
