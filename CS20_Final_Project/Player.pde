/*** PLAYER CLASS
 * Manages the player.
 * Methods contained inside Player are:
 *   - display() (displays the player)
 *   - damage() (hurts the player, adding immunity frames and knocking the player back by a bit) */

class Player extends GameObject {
  final PlayerPosition playerPosition;
  final PlayerSight playerSight;
  
  Player(PVector position, PShape appearance, float boundingCircleRadius, float turningSpeed, int health, int immunityFrameLength) {
    super(position, appearance, boundingCircleRadius, turningSpeed, health, immunityFrameLength);
    playerPosition = new PlayerPosition();
    playerSight = new PlayerSight();
  }
  
  
  void damage(int damage, PVector distance, int time) {
    super.damage(damage);
    playerPosition.knockback(distance, time);
  }
  
  /** Shows the player, along with potential debugging lines */
  void display() {
    //// Draw a polygon that represents the player's vision
    pushMatrix();
    translate(0 - getPosition().x, 
              0 - getPosition().y);
    noStroke();
    fill(200);
    beginShape();
    for (PVector crnt : player.playerSight.polyVisibleArea) {
      vertex(crnt.x, crnt.y);
    }
    endShape();
    popMatrix();

    //// Display player
    pushMatrix();
    rotate(getRotation());
    shape(appearance);
    popMatrix();
    
    if (debugging) {
      
      // Velocity before collision with walls
      strokeWeight(1);
      stroke(0);
      line(0, 0, debugVelocityInit.x*debugLineLength, debugVelocityInit.y*debugLineLength);
      
      // Velocity after collision with walls
      stroke(#FF0000);
      line(0, 0, debugVelocityFinal.x*debugLineLength, debugVelocityFinal.y*debugLineLength);
      
      // Hurtbox of player
      if (!isImmune()) {
        fill(0, 0, 255, 100);
        noStroke();
        circle(0, 0, boundingCircleRadius*2);
      }
      
      pushMatrix();
      translate(0-player.getPosition().x, 0-player.getPosition().y);
      // Draw a red circle on visible points
      fill(#ff0000);
      for (String crnt : player.playerSight.visibleVertexIDs) { //DEBUG
        PVector temp = vertexIDcoords(stageCrnt, crnt.split(" "));
        circle(temp.x, temp.y, 5);
      }
      
      // Box where enemies will spot player
      stroke(#00FF00);
      strokeWeight(1);
      noFill();
      rectMode(CORNERS);
      rect(screenCoords[0].x, screenCoords[0].y,
          screenCoords[1].x, screenCoords[1].y);
      rectMode(CENTER);

      popMatrix();
    }
  }
  
}
