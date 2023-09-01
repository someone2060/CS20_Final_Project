/*** ENEMYBASE CLASS TODO TODO
 * Manages the basic aspects of an enemy.
 * The variable types that are managed by EnemyBase can be split into three main categories: GameObject, player awareness, and movement.
 *   GameObject corresponds to basic object properties managed by the GameObject class.
 *   Player awareness corresponds to whether the enemy can see the player or not.
 *   Movement corresponds to the movement of the enemy.
 *     When you want to change the location of an enemy, use setPositionGoal() to set the wanted position.
 *     When updatePosition() is ran, the enemy will move towards the position set in setPositionGoal().
 * Methods located in EnemyBase are listed below:
 *   - seesPlayer()
 *   - getPositionGoal()
 *   - setPositionGoal()
 *   - updatePosition() */

abstract class EnemyBase extends GameObject {
  //// Player awareness variables
  private boolean seesPlayer;
  private int pframeCount;
  //// Movement variables
  private PVector velocityCrnt;
  private final float velocityMax, acceleration, deceleration;
  private boolean moving;
  // Position that enemy wants to reach
  private PVector goalPosition;
  // Distance from enemy's position to wanted position
  private float distToGoal;
  //// Interaction wtih player variables
  // How many pixels the player will move when getting hit
  protected final float knockback;
  
  EnemyBase(PVector position, PShape appearance, float boundingCircleRadius, int health,
            float velocityMax, float acceleration, float deceleration, float turningSpeed,
            float knockback) {
    super(position, appearance, boundingCircleRadius, turningSpeed, 
          health, framerateGoal/6);
    setRotation(random(-PI, PI)); //TODO
    this.goalPosition = getPosition();
    
    this.velocityCrnt = new PVector(0, 0);
    this.velocityMax = velocityMax;
    this.acceleration = acceleration;
    this.deceleration = deceleration;
    
    this.knockback = knockback;
  }
  
  
  boolean seesPlayer() {
    // If this function has already been run on the same frame
    if (frameCount == pframeCount) {
      return seesPlayer;
    }
    // Enemy isn't on screen
    if (!pointRect(getPosition().x, getPosition().y, 
        screenCoords[0].x, screenCoords[0].y, screenCoords[1].x, screenCoords[1].y)) {
      pframeCount = frameCount;
      seesPlayer = false;
      return false;
    }
    // Enemy isn't in player's line of sight
    if (!stageCrnt.pointVisible(getPosition(), player.getPosition())) {
      pframeCount = frameCount;
      seesPlayer = false;
      return false;
    }
    // If all checks pass, enemy can see player
    pframeCount = frameCount;
    seesPlayer = true;
    return true;
  }
  
  
  
  PVector getGoalPosition() {
    return goalPosition.copy();
  }
  
  void setGoalPosition(PVector coordinate) {
    goalPosition = coordinate;
  }
  
  
  // Variables used by updatePosition()
  private PVector vectorPositionToGoal;
  private float headingGoal;
  private float angleVelocityToGoal;
  
  void updatePosition() {
    // If the enemy already is already at goalPosition
    if (getGoalPosition().x == getPosition().x &&
        getGoalPosition().y == getPosition().y) {
      return;
    }

    // Vector of position to positionGoal
    vectorPositionToGoal = PVector.sub(getGoalPosition(), getPosition());
    distToGoal = vectorPositionToGoal.mag();
    headingGoal = vectorPositionToGoal.heading();

    moving = (velocityCrnt.mag() != 0) ? true : false;
    
    // Enemy can reach its goal position in the current frame
    if (distToGoal < velocityCrnt.mag()) {
      velocityCrnt = new PVector(0, 0);
      setPosition(getGoalPosition());
      return;
    }
    
    rotateTo(headingGoal);
    
    if (!moving) {
      velocityCrnt = new PVector(acceleration, 0).rotate(getRotation());
      return;
    }
    
    velocityCrnt = new PVector(velocityCrnt.mag()+acceleration, 0).rotate(getRotation());
    velocityCrnt.setMag(constrain(velocityCrnt.mag(), 0, velocityMax));
    move(velocityCrnt);
  }
  
}
