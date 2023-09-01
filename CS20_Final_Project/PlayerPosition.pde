/** PLAYERPOSITION CLASS 
 * Manages the position of the player, including collisions with other objects in the stage.
 * Movmeent through forced knockback is also managed through this.
 * The update function does the following:
 *   - Checks if the player is currently being knocked back by something.
 *     - If so, the player is incremented by its next knockback movement.
 *     - Otherwise, the new velocity of the player is calculated based on the WASD movement keys
 *   - Checks if the player is colliding with any wall, then moves the player based on those collisions
 * These supplementary function(s) are also included:
 *   - knockback() (starts the knockback loop where the player gets knocked back by a distance)
 *   - isMoving() */

class PlayerPosition {
  // Pixels/second
  private final float velocityMax = 300/framerateGoal;
  // Goes to top speed in denominator frames (in acceleration var)
  private final float acceleration = velocityMax/(framerateGoal/12);
  private final float deceleration = acceleration/2;
  // Max amount that velocity can be reduced by
  // Example: value of 0.8 means value can be set to a min of 80% of normal
  private final float minVelocityModifier = 0.6;
  private PVector velocityCrnt = defaultPVector.copy();
  private boolean moving = false;
  
  
  boolean isMoving() {
    return moving;
  }
  

  /* Starts the knockback loop where the player gets knocked back by a distance 
   * Starts loop where the player gets moved linearly for a specified time of frames */
  void knockback(PVector distance, int stunLength) {
    moving = true;
    velocityCrnt = new PVector(distance.mag()/stunLength, 0);
    velocityCrnt.rotate(distance.heading());
    player.resetImmunityFrameCrnt(stunLength);
  }
  
  
  //// VARIABLES USED IN UPDATE()
  private float velocityLimiter;
  
  /* Updates the player position.
   * The actions done to the player are done as follows:
   *   - New velocity of the player is calculated based on the pressed movement keys
   *   - Checks if the player is colliding with a wall, then moves the player based on that */
  protected void update() {
    player.updateImmunityFrames();
    
    if (player.isImmune()) {
      // Add flashing animation
      if (frameCount % (framerateGoal/15) == 0) {
        // Toggles visibiliy
        player.appearance.setVisible(!player.appearance.isVisible());
      }
      // Move player by knockback amount based on value set in knockback()
      if (player.isStunned()) {
        player.move(velocityCrnt);
        return;
      }
    } else {
      // Make visible to prevent flashing animation from ending on not being visible
      player.appearance.setVisible(true);
    }
    
    //// Update player's velocity based on acceleration
    // Update x position
    if (xnor(keyA||keyLEFT, keyD||keyRIGHT) && (abs(velocityCrnt.x) < abs(deceleration)) ) {
      velocityCrnt.x = 0;
    } else {
      //changes velocityCrnt.x based on keys pressed, while also consistently moving back to a speed of 0
      velocityCrnt.x += acceleration*int(keyD||keyRIGHT) - acceleration*int(keyA||keyLEFT) - deceleration*signum(velocityCrnt.x);
    }
    
    // Update y position
    if (xnor(keyW||keyUP, keyS||keyDOWN) && (abs(velocityCrnt.y) < abs(deceleration)) ) {
      velocityCrnt.y = 0;
    } else {
      //changes velocityCrnt.y based on keys pressed, while also consistently moving back to a speed of 0
      velocityCrnt.y = velocityCrnt.y + acceleration*int(keyS||keyDOWN) - acceleration*int(keyW||keyUP) - deceleration*signum(velocityCrnt.y);
    }
    
    velocityLimiter = PVector.angleBetween(velocityCrnt, 
                                           new PVector(1, 0).rotate(player.getRotation()) );
    // The more that the player is facing the direction they're moving, the faster they go
    // Range  is 0-1
    // Domain is 0-PI
    // GRAPH y=sqrt(1-(PI-x)/PI) TO UNDERSTAND BETTER
    velocityLimiter = sqrt(1 - (PI-velocityLimiter)/PI);
    // Changing velocityLimiter so that it doesn't completely set velocity to zero if player movment & direction are opposite
    velocityLimiter = 1 - (1-minVelocityModifier)*velocityLimiter;
    
    // velocityCrnt will be less than or equal to velocityMax*velocityLimiter this frame
    if (velocityCrnt.mag() < velocityMax*velocityLimiter+acceleration+deceleration) {
      velocityCrnt.limit(velocityMax*velocityLimiter);
    } // velocityCrnt is more than velocityMax*velocityLimiter this frame
    else {
      velocityCrnt.setMag(velocityCrnt.mag()-deceleration-acceleration);
    }
    
    moving = (velocityCrnt.mag() == 0) ? false : true;
    
    if (!moving) {
      return;
    }
    
    player.move(velocityCrnt);
  }
  
}
