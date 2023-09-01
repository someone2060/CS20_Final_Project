/*** GAMEOBJECT CLASS 
 * Manages the basic aspects of an enemy or player. 
 * Currently, the position, rotation, turning speed, appearance, health, immunity frames, and stun status of an object is stored in this class.
 * When an object is stunned, they will not be able to move and make certain attacks.
 * All methods in GameObject currently are:
 *   - getPosition()
 *   - getRotation()
 *   - setRotation()
 *   - rotateObj() (PRIVATE)
 *   - rotateTo() (rotates to a wanted heading, taking turning speed into account)
 *   - isDead()
 *   - getHealth()
 *   - damage()
 *   - getImmunityFrameLength()
 *   - getImmunityFrameCrnt()
 *   - getStunLength()
 *   - isStunned()
 *   - isImmune()
 *   - updateImmunityFrames() (decreases the count for stunned and immune by 1 if either is positive, respectively)
 *   - display() (displays object with rotation and position accounted for)
 *   - move() (moves the object along stageCrnt, taking collisions into account) */

abstract class GameObject {
  private PVector position;
  // Object's appearance on the display window. 
  // The center of rotation is at (0, 0).
  protected final PShape appearance;
  protected final float boundingCircleRadius;
  
  // Maximum the object can turn in one frame
  private final float turningSpeed;
  private final float framesForFullRotation;
  private float rotation;
  
  private int health;
  private boolean dead;
  
  private final int immunityFrameLength;
  private int immunityFrameCrnt;
  
  private int stunLength;
  
  //// DEBUGGING VARIABLES
  public PVector debugVelocityInit = defaultPVector, debugVelocityFinal = defaultPVector;
  
  GameObject(PVector position, PShape appearance, float boundingCircleRadius, float turningSpeed, int health, int immunityFrames) {
    this.position = position;
    this.appearance = appearance;
    this.boundingCircleRadius = boundingCircleRadius;
    
    this.turningSpeed = constrain(turningSpeed, 0, PI);
    this.framesForFullRotation = TWO_PI/turningSpeed;
    this.rotation = random(-PI, PI);
    
    this.health = health;
    this.dead = false;
    
    this.immunityFrameLength = immunityFrames;
    this.immunityFrameCrnt = 0;
  }
  
  
  PVector getPosition() {
    return position.copy();
  }
  void setPosition(PVector position) {
    this.position = position;
  }
  
  
  float getRotation() {
    return rotation;
  }
  void setRotation(float rotation) {
    this.rotation = rotation;
  }
  private void rotateObj(float rotation) {
    this.rotation += rotation;
    if (this.rotation == TWO_PI) {
      return;
    }
    this.rotation %= TWO_PI;
  }
  void rotateTo(float heading) {
    // Angle that enemy has to turn by to reach the goal position
    // See https://www.desmos.com/calculator/7giej6abxp
    float angleVelocityToGoal = heading-getRotation()+PI;
    if (angleVelocityToGoal == TWO_PI) {
      angleVelocityToGoal = PI;
    } else {
      angleVelocityToGoal = modulo(angleVelocityToGoal, TWO_PI) - PI;
    }
    
    // Rotates enemy's velocity, capping it at its maximum turning speed
    rotateObj(constrain(angleVelocityToGoal, 0-turningSpeed, turningSpeed));
  }
  
  
  boolean isDead() {
    return dead;
  }
  int getHealth() {
    return health;
  }
  void damage(int damage) {
    health -= damage;
    if (health <= 0) {
      dead = true;
      return;
    }
    immunityFrameCrnt = immunityFrameLength;
  }
  
  int getImmunityFrameLength() {
    return immunityFrameLength;
  }
  int getImmunityFrameCrnt() {
    return immunityFrameCrnt;
  }
  int getStunLength() {
    return stunLength;
  }
  void resetImmunityFrameCrnt(int stunLength) {
    immunityFrameCrnt = immunityFrameLength+1;
    this.stunLength = stunLength+1;
  }
  boolean isStunned() {
    if (stunLength > 0) return true;
    return false;
  }
  boolean isImmune() {
    if (immunityFrameCrnt > 0) return true;
    return false;
  }
  void updateImmunityFrames() {
    if (immunityFrameCrnt > 0) immunityFrameCrnt--;
    if (stunLength > 0) stunLength--;
  }
  
  
  void display() {
    pushMatrix();
    translate(position.x-player.getPosition().x, position.y-player.getPosition().y);

    if (debugging) {
      // Velocity before collision with walls
      strokeWeight(1);
      stroke(0);
      line(0, 0, debugVelocityInit.x*debugLineLength, debugVelocityInit.y*debugLineLength);
      
      // Velocity after collision with walls
      stroke(#FF0000);
      line(0, 0, debugVelocityFinal.x*debugLineLength, debugVelocityFinal.y*debugLineLength);
    }
    
    rotate(rotation);
    shape(appearance);
    
    // Hurtbox of object
    if (!isImmune() && debugging) {
      rotate(getRotation());
      fill(0, 0, 255, 100);
      noStroke();
      circle(0, 0, boundingCircleRadius*2);
    }
    
    popMatrix();
  }
  
  
  //// VARIABLES USED IN MOVE()
  // Polygon coordinates of a polygon used for testing collision
  private PVector[] stagePolyCollisionTesting;
  // Indexes of polygon coordinates where a collision occurred
  private int[] stagePolyIndexesCollided;
  // vertexIDs of all collided walls to be used with stageCrnt
  private StringList vertexIDs;
  // Used in incrementing
  private Polygon crntI;
  // Bounding box of crntI
  private PVector[] boundingBox;
  // New velocity after movement along a wall in vertexIDs
  private PVector velocityModified;
  // Coordinates of a wall in the stage, used to test for collisions
  private PVector[] tempWallCoords;
  // Stores if velocityModified collided with any lines
  private boolean velocityModifiedCollideStage;
  
  /* Moves the object in stageCrnt.
   * This function takes collisions with stage objects in account, 
   *   and slide the object along those walls if the game object is about to run into something */
  void move(PVector movement) {
    debugVelocityInit = movement;
    
    //// Find all indexes of walls that the player is colliding with
    // vertexIDs of all collided walls to be used with stageCrnt
    vertexIDs = new StringList();
    
    /// Find the index(es) of outer walls that collide with the player using polyCircleIndexesCollided()
    stagePolyCollisionTesting = stageCrnt.outerWall.getCoords().toArray(new PVector[0]);
    stagePolyIndexesCollided = polyCircleIndexesCollided(stagePolyCollisionTesting, position.x+movement.x, position.y+movement.y, boundingCircleRadius);
    for (final int crnt : stagePolyIndexesCollided) {
      // "outerWall" signifies the index is from stageCrnt.outerWalls
      vertexIDs.append("outerWall " + crnt);
    }
    
    /// Find the index(es) of inner walls that collide with the player
    // Loop through each polygon in innerWalls
    for (int i=0; i<stageCrnt.innerWalls.size(); i++) {
      crntI = stageCrnt.innerWalls.get(i);
      boundingBox = crntI.getBounds();
      // Player doesn't collide with the bounding box of the inner wall
      if (!circleRect(PVector.add(position, movement).x, PVector.add(position, movement).y, boundingCircleRadius,
                      boundingBox[0].x, boundingBox[0].y,
                        boundingBox[1].x, boundingBox[1].y) ) {
        continue;
      }
      // Add indexes of lines that collide with player
      stagePolyIndexesCollided = polyCircleIndexesCollided(crntI.getCoords().toArray(new PVector[0]), 
                                                           PVector.add(position, movement).x, PVector.add(position, movement).y, boundingCircleRadius);
      for (final int crnt : stagePolyIndexesCollided) {
        // "innerWalls" signifies the index is from stageCrnt.innerWalls
        vertexIDs.append("innerWalls " + i + " " + crnt);
      }
    }
    
    /// Find the index of tables that collide with the player
    // Loop through each polygon in tables
    for (int i=0; i<stageCrnt.tables.size(); i++) {
      crntI = stageCrnt.tables.get(i);
      boundingBox = crntI.getBounds();
      // Player doesn't collide with the bounding box of the inner wall
      if (!circleRect(PVector.add(position, movement).x, PVector.add(position, movement).y, boundingCircleRadius,
                      boundingBox[0].x, boundingBox[0].y,
                        boundingBox[1].x, boundingBox[1].y) ) {
        continue;
      }
      // Add indexes of lines that collide with player
      stagePolyIndexesCollided = polyCircleIndexesCollided(crntI.getCoords().toArray(new PVector[0]), 
                                                           PVector.add(position, movement).x, PVector.add(position, movement).y, boundingCircleRadius);
      for (final int crnt : stagePolyIndexesCollided) {
        // "tables" signifies the index is from stageCrnt.tables
        vertexIDs.append("tables " + i + " " + crnt);
      }
    }
    
    //// Takes the information from vertexIDs, then moves the player based on that information
    switch (vertexIDs.size()) {
      case 0: // Touches no walls, so no movement has to be changed
        debugVelocityFinal = movement;
        position.add(movement);
        break;
      case 1: // Touches one wall
        debugVelocityFinal = stageCrnt.netVelocity(vertexIDs.get(0).split(" "), movement, position, boundingCircleRadius);
        position.add(debugVelocityFinal);
        break;
      default: // Touches two or more walls
        // Loop through each line
        for (int i=0; i<vertexIDs.size(); i++) {
          velocityModified = stageCrnt.netVelocity(vertexIDs.get(i).split(" "), movement, position, boundingCircleRadius );
          velocityModifiedCollideStage = false;
          // Loops through every line in vertexIDs 
          for (final String crnt : vertexIDs) {
            // Assign testLineCoords to coordinates of the line that need to be tested
            tempWallCoords = vertexIDline(stageCrnt, crnt.split(" "));
            
            if (lineCircle(tempWallCoords[0].x, tempWallCoords[0].y, tempWallCoords[1].x, tempWallCoords[1].y, //line of testing line
                  position.x+velocityModified.x, position.y+velocityModified.y, boundingCircleRadius) 
                && crnt != vertexIDs.get(i)) {
              velocityModifiedCollideStage = true;
              break;
            }
          }
          if (!velocityModifiedCollideStage) {
            debugVelocityFinal = velocityModified;
            position.add(velocityModified);
          }
        }
    }
  }
  
}
