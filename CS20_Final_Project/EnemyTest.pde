/*** ENEMYTEST CLASS 
 * Class for testing the EnemyBase class */

private final class EnemyTest extends EnemyBase {
  EnemyTest(PVector position, PShape appearance, float boundingCircleRadius, int health,
            float velocityMax, float acceleration, float deceleration, 
            float turningSpeed, float knockback) {
    super(position, appearance, boundingCircleRadius, health,
          velocityMax, acceleration, deceleration, 
          turningSpeed, knockback);
  }
  
  
  void checkPlayerCollision() {
    // If this enemy collides with the player, the player will get damaged and get knocked back a bit
    if (circleCircle(getPosition().x, getPosition().y, boundingCircleRadius, 
                     player.getPosition().x, player.getPosition().y, player.boundingCircleRadius) &&
       !player.isImmune() ) {
      // See Player.pde for more info
      player.damage(1, 
                    new PVector(knockback, 0)
                      .rotate(PVector.sub(player.getPosition(), getPosition()).heading()),
                    framerateGoal/10);
    }
  }
  
  void update() {
    if (isDead()) {
      return;
    }
    updateImmunityFrames();

    updatePosition();
    checkPlayerCollision();
    
    if (polyPoint(player.playerSight.polyVisibleArea.toArray(new PVector[0]), getPosition().x, getPosition().y)) {
      display();
    }
    
    if (!seesPlayer()) {
      return;
    }
    setGoalPosition(player.getPosition());
  }
  
}
