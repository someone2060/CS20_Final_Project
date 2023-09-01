/*** STAGE CLASS
 * Manages one map.
 * There are three main types of obstacles: walls, tables, and doors.
 * Walls are polygons that block line of sight, destroy projectiles, and cannot be walked over.
 * Tables are polygons that don't block line of sight and don't destroy projectiles, but cannot be walked over. 
 * Doors are lines that block line of sight and destroy projectiles, but can be walked over.
 * When initializing the coordinates of each type of obstacle, create the points relative to the player's spawn point. 
 * For example, a coordinate at (-100, 80) would be 100 pixels left and 80 units below the player's spawn point.
 * When displaying other objects on a stage, run displayOuterWall() first, then displayRest() after everything else has been drawn. 
 * 
 * The methods contained inside Stage are:
 *   - netVelocity (recieves a game object's movement vector along a stage wall, and changes the vector so that it moves parallel to the stage wall)
 *   - pointVisible (returns true if a line doesn't collide with anything in the stage)
 *   - rayCollisionCoords (returns the coordinate that a point collides with when originating from a vertexID) */

class Stage extends StageBase {
  Stage(String fname) {
    super(fname);
  }

  
  // Variables used in netVelocity()
  private PVector[] wallCoords;
  private boolean gameObjInPoly;
  private PVector wallHeading, normalForceHeading, netVelocity, gameObjPositionModified;
  private float theta;
  
  /* Returns the vector of movement that a game object would move along when colliding with the given wall (stageIndex).
   * Additionally, function tries to move the game object closer to the wall to remove potential gaps between the wall and the game object
   * EXPLANATION:
   *   Imagine or sketch the game object as a circle in a free body diagram moving against a wall.
   *   They will have a velocity that moves them towards the wall in a way that is not parallel.
   *   The wall contributes a normal force to the game object that's perpendicular with the wall.
   *   This normal force will cancel out the movement of the game object towards the wall, causing the game object to move parallel to the wall instead of moving through it.
   *   The game object's unmodified velocity, the wall's normal force, and net velocity that that game object will have creates a right triangle.
   *   One angle and one side length is known, which allows right triangle trigonometry to be used to find the game object's net velocity.
   * MAKE SURE VELCUR IS UPDATED BEFORE USING THIS, AND THAT THE GAME OBJECT IS ACTUALLY COLLIDING WITH THE LINE IN QUESTION
   * The object being affected is assumed to be a circle. */
  public PVector netVelocity(final String[] vertexID, final PVector movement, final PVector gameObjPosition, final float gameObjRadius) {
    // Assign wallCoords to coordinates of the line that need to be tested
    wallCoords = vertexIDline(this, vertexID);
    
    gameObjInPoly = false;
    if (vertexID[0].equals("outerWall")) {
        gameObjInPoly = true;
    }
    
    wallHeading = new PVector(wallCoords[1].x - wallCoords[0].x, 
                                      wallCoords[1].y - wallCoords[0].y).normalize();
    if (!gameObjInPoly) wallHeading.rotate(PI);
    normalForceHeading = wallHeading.copy().rotate(-1*HALF_PI);
    
    // One angle in the right triangle
    theta = movement.heading() - normalForceHeading.heading();
    // Uses SOH in right triangle trigonometry to find net velocity
    netVelocity = PVector.mult(movement, sin(theta)).rotate(HALF_PI-theta);
    
    //println(degrees(theta), velCur.mag(), degrees(velCur.heading()), degrees(wallContact.heading()), netV); //DEBUG
    
    // Coordinate of gameObjPosition moved along determined velocity, moved 1 pixel towards the wall
    gameObjPositionModified = PVector.add(PVector.add(gameObjPosition, netVelocity), normalForceHeading);
    
    // Checks if it's possible to move the game object closer to the wall without a collision, and does so if it can
    if (!lineCircle(wallCoords[0].x, wallCoords[0].y, wallCoords[1].x, wallCoords[1].y, 
                   gameObjPositionModified.x, gameObjPositionModified.y, gameObjRadius)) { // if moving 1 pixel towards the wall doesn't cause a collision
      return netVelocity.add(normalForceHeading); // moves 1 pixel towards the wall
    }
    
    // Coordinate of gameObjPosition moved along determined velocity
    gameObjPositionModified = PVector.add(gameObjPosition, netVelocity);
    
    // Checks if the player currently is in the wall after movement, and move the player away from the wall if so
    if (lineCircle(wallCoords[0].x, wallCoords[0].y, wallCoords[1].x, wallCoords[1].y,
                   gameObjPositionModified.x, gameObjPositionModified.y, gameObjRadius)) { // if normal movement along the wall collides with the wall
      return netVelocity.sub(normalForceHeading); // moves 1 pixel away from the wall
    }
    return netVelocity;
  }
  
  
  //// VARIABLES USED IN POINTVISBLE()
  // Variable that stores all coordinates of a tested polygon
  private PVector[] polyCoords;
  // Variable that stores bounding box of a tested polygon
  private PVector[] polyBoundingBox;
    
  /* Returns if a game object (point) can see another specified point */
  public boolean pointVisible(final PVector gameObjPos, final PVector pointCoords) {
    /// Check for collision with outerWall
    polyCoords = outerWall.getCoords().toArray(new PVector[0]);
    if (polyLine(polyCoords, gameObjPos.x, gameObjPos.y, pointCoords.x, pointCoords.y)) {
      return false;
    }
    
    /// Check for collision for each innerWall
    // Loop through each polygon in innerWalls
    for (Polygon crnt : innerWalls) {
      polyCoords = crnt.getCoords().toArray(new PVector[0]);
      polyBoundingBox = crnt.getBounds();
      
      // If bounding boxes don't collide, more expensive calculations don't need to be made
      if (!rectRect(min(gameObjPos.x, pointCoords.x), min(gameObjPos.y, pointCoords.y), max(gameObjPos.x, pointCoords.x), max(gameObjPos.y, pointCoords.y),
                   polyBoundingBox[0].x, polyBoundingBox[0].y, polyBoundingBox[1].x, polyBoundingBox[1].y) ) {
        continue;
      }
      
      // Check for collision with innerWall[i]
      if (polyLine(polyCoords, gameObjPos.x, gameObjPos.y, pointCoords.x, pointCoords.y)) {
        return false;
      }
    }
    
    // If all checks passed, the vertex is visible to the game object
    return true;
  }
  
  
  //// VARIABLES USED IN RAYCOLLISIONCOORDS()
  boolean playerInVertexID;
  PVector[] sightLine;
  PVector wallCoordTest;
  // Will store coordinates that collided with lineSight
  ArrayList<PVector> collisionPointsLocal;
  float collisionDistance;
  
  /* Returns the coordinate of the first wall that a ray (corresponding to a wall) collides with. */
  public PVector rayCollisionCoords(final String[] vertexID, final float heading) {
    // If player in current polygon
    playerInVertexID = false;
    if (vertexID[0].equals("outerWall")) {
      playerInVertexID = true;
    }
    
    sightLine = new PVector[2];
    // Coordinates of polygon vertex
    sightLine[0] = vertexIDcoords(this, vertexID);
    
    // Coordinate used for testing if the current vertex first collides with its own polygon.
    // If the point that's moved one pixel away from the wall collides with the same polygon that the vertex is from, the player can't see further from that vertex
    wallCoordTest = PVector.add(sightLine[0], new PVector(2, 0).rotate(heading));
    if (xor(playerInVertexID, 
            polyPoint(vertexIDpoly(this, vertexID), 
                      wallCoordTest.x, wallCoordTest.y)) ) {
      return sightLine[0];
    }
    
    // Coordinates of extrapolated polygon coordinate
    sightLine[1] = PVector.add(sightLine[0], new PVector(height+width, 0).rotate(heading));
    
    // Length of line for collision that occurred
    collisionDistance = dist(player.getPosition().x, player.getPosition().y, sightLine[1].x, sightLine[1].y);
    
    /// Check for collisions with outerWall
    polyCoords = outerWall.getCoords().toArray(new PVector[0]);
    collisionPointsLocal = polyLineCollisionCoords(polyCoords, sightLine[0].x, sightLine[0].y, sightLine[1].x, sightLine[1].y);
    for (final PVector crnt : collisionPointsLocal) {
      if (dist(player.getPosition().x, player.getPosition().y, crnt.x, crnt.y) < collisionDistance) {
        collisionDistance = dist(player.getPosition().x, player.getPosition().y, crnt.x, crnt.y);
      }
    }
    
    // Loop through each polygon in innerWalls
    for (Polygon crnt : innerWalls) {
      polyCoords = crnt.getCoords().toArray(new PVector[0]);
      polyBoundingBox = crnt.getBounds();
      
      // If bounding boxes don't collide, the innerWall won't collide with lineSight
      if (!rectRect(min(sightLine[0].x, sightLine[1].x), min(sightLine[0].y, sightLine[1].y), max(sightLine[0].x, sightLine[1].x), max(sightLine[0].y, sightLine[1].y),
                    polyBoundingBox[0].x, polyBoundingBox[0].y, polyBoundingBox[1].x, polyBoundingBox[1].y) ) {
        continue;
      }
      
      // Check for collisions with current innerWall
      collisionPointsLocal = polyLineCollisionCoords(polyCoords, sightLine[0].x, sightLine[0].y, sightLine[1].x, sightLine[1].y);
      for (final PVector crntJ : collisionPointsLocal) {
        if (dist(player.getPosition().x, player.getPosition().y, crntJ.x, crntJ.y) < collisionDistance) {
          collisionDistance = dist(player.getPosition().x, player.getPosition().y, crntJ.x, crntJ.y);
        }
      }
    }
    return PVector.add(player.getPosition(), new PVector(collisionDistance, 0).rotate(heading));
  }
  
}
