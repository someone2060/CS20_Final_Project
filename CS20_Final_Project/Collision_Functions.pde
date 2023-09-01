/*** COLLISION FUNCTIONS
 * Functions found from Jeffrey Thompson's Collision Detection. Used universally, where collision is needed. Functions include:
 *   - pointCircle (detects collision between a point and a circle)
 *   - circleCircle (detects collision between a circle and a circle)
 *   - pointRect (detects collision between a point and a rectangle)
 *   - rectRect (detects collision between a rectangle and a rectangle)
 *   - circleRect (detects collision between a circle and a rectangle)
 *   - linePoint (detects collision between a line and a point)
 *   - lineCircle (detects collision between a line and a circle)
 *   - lineLine (detects collision between a line and a line)
 *   - lineLineCollisionCoords (same as lineLine, but outputs the point where the two lines collided)
 *   - lineRect (detects collision between a line and a rectangle)
 *   - polyPoint (detects collision between a point and a polygon)
 *   - polyCircle (detects collision between a polygon and a circle)
 *   - polyCircleIndexesCollided (same as polyCircle, but outputs the indexes of the touched lines)
 *   - polyLineCollisionCoords (returns the coordinates of the places that a line collides, ignoring if the collided points are the endpoint of a line)
 *   - polyRect (detects collision between a polygon and a rectangle) */


/* Point/circle collision (from Jeffrey Thompson) */
static boolean pointCircle(float pointX, float pointY, float circleX, float circleY, float circleRadius) {
  if (dist(pointX, pointY, circleX, circleY) <= circleRadius) {
    return true;
  }
  return false;
}

/* Circle/circle collision (from Jeffrey Thompson) */
static boolean circleCircle(float c1x, float c1y, float c1r, float c2x, float c2y, float c2r) {
  // if the distance between the two radii is less than the sum of the circle's radii, the circles are touching
  if (dist(c1x, c1y, c2x, c2y) <= c1r+c2r) {
    return true;
  }
  return false;
}

/* Point/rectangle collision (from Jeffrey Thompson). Uses rectMode(CORNERS). */
static boolean pointRect(float pointX, float pointY, float rectx1, float recty1, float rectx2, float recty2) {
  if (pointX >= rectx1 &&
      pointX <= rectx2 &&
      pointY >= recty1 &&
      pointY <= recty2) {
    return true;
  }
  return false;
}

/* Rectangle/rectangle collision (from Jeffrey Thompson). Uses rectMode(CORNERS). */
static boolean rectRect(float rect1x1, float rect1y1, float rect1x2, float rect1y2, float rect2x1, float rect2y1, float rect2x2, float rect2y2) {
  // are the sides of one rectangle touching the other?
  if (rect1x2 >= rect2x1 &&    // rect1 right edge past rect2 left
      rect1x1 <= rect2x2 &&    // rect1 left edge past rect2 right
      rect1y2 >= rect2y1 &&    // rect1 top edge past rect2 bottom
      rect1y1 <= rect2y2) {    // rect1 bottom edge past rect2 top
        return true;
  }
  return false;
}

/* Circle/rectangle collision (from Jeffrey Thompson) */
static boolean circleRect(float circleX, float circleY, float circleRadius, float rectx1, float recty1, float rectx2, float recty2) {
  // temporary variables to set edges for testing
  float testX = circleX;
  float testY = circleY;

  // Find which side of the rect is closest to the centre of the circle 
  if (circleX < rectx1) { // test left edge
    testX = rectx1;
  } else if (circleX > rectx2) { // test right edge
    testX = rectx2;
  }
  if (circleY < recty1) { // test top edge
    testY = recty1;
  } else if (circleY > recty2) { // test bottom edge
    testY = recty2;
  }

  if (pointCircle(testX, testY, circleX, circleY, circleRadius)) {
    return true;
  }
  return false;
}

/* Line/point collision (from Jeffrey Thompson) */
static boolean linePoint(float linex1, float liney1, float linex2, float liney2, float pointX, float pointY) {
  // Get distance from the point to the two ends of the line
  float dist1 = dist(pointX, pointY, linex1, liney1);
  float dist2 = dist(pointX, pointY, linex2, liney2);

  float lineLength = dist(linex1, liney1, linex2, liney2);

  // Since floats are so minutely accurate, add a little buffer zone that will give collision
  float buffer = 0.1; // higher # = less accurate

  // If the two distances are equal to the line's length, the point is on the line!
  // Note we use the buffer here to give a range, rather than one number
  if (dist1+dist2 >= lineLength-buffer && 
      dist1+dist2 <= lineLength+buffer) {
    return true;
  }
  return false;
}

/* Line/circle collision (from Jeffrey Thompson) */
static boolean lineCircle(float linex1, float liney1, float linex2, float liney2, float circleX, float circleY, float circleRadius) {
  // Is either end of the line inside the circle? If so, return true immediately
  if (pointCircle(linex1, liney1, 
        circleX, circleY, circleRadius) ||
      pointCircle(linex2, liney2, 
        circleX, circleY, circleRadius)) {
    return true;  
  }
  // Get length of the line
  float lineLength = dist(linex1, liney1, linex2, liney2);

  // Get dot product of the line and circle
  float dot = ( ((circleX-linex1)*(linex2-linex1)) + ((circleY-liney1)*(liney2-liney1)) ) / pow(lineLength,2);

  // Find the closest point on the line in relation to the circle
  float closestX = linex1 + (dot * (linex2-linex1));
  float closestY = liney1 + (dot * (liney2-liney1));

  // Is this point actually on the line segment? If so keep going, but if not, return false
  if (!linePoint(linex1, liney1, linex2, liney2, 
        closestX, closestY) ) {
    return false;
  }
  // Get distance to closest point
  float dist = dist(circleX, circleY, closestX, closestY);

  // Is the circle on the line?
  if (dist <= circleRadius) {
    return true;
  }
  return false;
}

/* Line/line collision (from Jeffrey Thompson) */
static boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  // calculate the distance to intersection point
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    return true;
  }
  return false;
}

/* Same as lineLine(), but returns the point where the two lines collided */
static PVector lineLineCollisionCoords (float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  // calculate the distance to intersection point
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    return new PVector(x1 + (uA * (x2-x1)),
                       y1 + (uA * (y2-y1)) );
  }
  // Default output
  return defaultPVector;
}

/* Line/rectangle collision (from Jeffrey Thompson) */
static boolean lineRect(float linex1, float liney1, float linex2, float liney2, float rectx1, float recty1, float rectx2, float recty2) {
  // check if the line has hit any of the rectangle's sides
  // uses the Line/Line function below
  boolean left =   lineLine(linex1, liney1, linex2, liney2, 
                            rectx1, recty1, rectx1, recty2);
  boolean right =  lineLine(linex1, liney1, linex2, liney2, 
                            rectx2, recty1, rectx2, recty2);
  boolean top =    lineLine(linex1, liney1, linex2, liney2, 
                            rectx1, recty1, rectx2, recty1);
  boolean bottom = lineLine(linex1, liney1, linex2, liney2, 
                            rectx1, recty2, rectx2, recty2);

  // if ANY of the above are true, the line has hit the rectangle
  if (left || right || top || bottom) {
    return true;
  }
  return false;
}

//TODO
/* Same as lineRect(), but returns the coordinates of all collisions */
static ArrayList<PVector> lineRectCollisionCoords(float linex1, float liney1, float linex2, float liney2, float rectx1, float recty1, float rectx2, float recty2) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  
  // check if the line has hit any of the rectangle's sides
  // uses the Line/Line function below
  PVector left =   lineLineCollisionCoords(linex1, liney1, linex2, liney2, 
                            rectx1, recty1, rectx1, recty2);
  PVector right =  lineLineCollisionCoords(linex1, liney1, linex2, liney2, 
                            rectx2, recty1, rectx2, recty2);
  PVector top =    lineLineCollisionCoords(linex1, liney1, linex2, liney2, 
                            rectx1, recty1, rectx2, recty1);
  PVector bottom = lineLineCollisionCoords(linex1, liney1, linex2, liney2, 
                            rectx1, recty2, rectx2, recty2);
  if (left != defaultPVector)   out.add(left);
  if (right != defaultPVector)  out.add(right);
  if (top != defaultPVector)    out.add(top);
  if (bottom != defaultPVector) out.add(bottom);
  return out;
}

/* Polygon/point collision (from Jeffrey Thompson) */
static boolean polyPoint(PVector[] vertices, float pointX, float pointY) {
  boolean collision = false;

  int indexNext = 0;
  for (int indexCrnt=0; indexCrnt<vertices.length; indexCrnt++) {
    indexNext = indexCrnt+1;
    if (indexNext == vertices.length) indexNext = 0;

    PVector vectorCrnt = vertices[indexCrnt];
    PVector vectorNext = vertices[indexNext];

    // compare position, flip 'collision' variable back and forth
    if (((vectorCrnt.y > pointY && vectorNext.y < pointY) || (vectorCrnt.y < pointY && vectorNext.y > pointY)) &&
         (pointX < (vectorNext.x-vectorCrnt.x)*(pointY-vectorCrnt.y) / (vectorNext.y-vectorCrnt.y)+vectorCrnt.x)) {
            collision = !collision;
    }
  }
  return collision;
}

/* Polygon/circle collision (from Jeffrey Thompson) */
static boolean polyCircle(PVector[] vertices, float circleX, float circleY, float circleRadius) {
  int indexNext = 0;
  for (int indexCrnt=0; indexCrnt<vertices.length; indexCrnt++) {
    indexNext = indexCrnt+1;
    if (indexNext == vertices.length) indexNext = 0;

    PVector vectorCrnt = vertices[indexCrnt];
    PVector vectorNext = vertices[indexNext];
    
    if (lineCircle(vectorCrnt.x, vectorCrnt.y, vectorNext.x, vectorNext.y, 
                   circleX, circleY, circleRadius)) {
      return true;
    }
  }
  return false;
}

/* Has the same polyCircle collision detection, but returns the index of line(s) that were collided with in vertices */
static int[] polyCircleIndexesCollided(PVector[] vertices, float circleX, float circleY, float circleRadius) {
  // Stores the indexes of the PVectors that were found to have a collision.
  // Example: if the first line of the polygon had a collision, a value of 0 is appended to indexCollisions.
  int[] indexCollisions = new int[0];
  
  int indexNext = 0;
  for (int indexCrnt=0; indexCrnt<vertices.length; indexCrnt++) {
    indexNext = indexCrnt+1;
    if (indexNext == vertices.length) indexNext = 0;

    PVector vectorCrnt = vertices[indexCrnt];
    PVector vectorNext = vertices[indexNext];

    if (lineCircle(vectorCrnt.x, vectorCrnt.y, vectorNext.x, vectorNext.y, 
                   circleX, circleY, circleRadius)) {
      indexCollisions = append(indexCollisions, indexCrnt);
    }
  }
  return indexCollisions;
}

/* Polygon/line collision (from Jeffrey Thompson),
 * Modified to ignore points on the polygon that share points with the line. */
static boolean polyLine(PVector[] vertices, float x1, float y1, float x2, float y2) {
  // go through each of the vertices, plus the next vertex in the list
  int next = 0;
  for (int current=0; current<vertices.length; current++) {
    // get next vertex in list
    // if we've hit the end, wrap around to 0
    next = current+1;
    if (next == vertices.length) next = 0;

    // get the PVectors at our current position
    // extract X/Y coordinates from each
    float x3 = vertices[current].x;
    float y3 = vertices[current].y;
    float x4 = vertices[next].x;
    float y4 = vertices[next].y;

    PVector collisionCoord = lineLineCollisionCoords(x1, y1, x2, y2, x3, y3, x4, y4);
    if (collisionCoord != defaultPVector) {
      // Checks if the coordinate where the collision occurred is the same as a coordinate in the line that's being tested
      if (!((round(collisionCoord.x) == round(x1) && round(collisionCoord.y) == round(y1) ) ||
            (round(collisionCoord.x) == round(x2) && round(collisionCoord.y) == round(y2) )) ) {
        return true;
      }
    }
  }
  
  return false;
}

/* Polygon/line collision (from Jeffrey Thompson),
 * Modified to ignore points on the polygon that share points with the line.
 * Modified to return the coordinates that a collision occurred. */
static ArrayList<PVector> polyLineCollisionCoords(PVector[] vertices, float x1, float y1, float x2, float y2) {
  ArrayList<PVector> out = new ArrayList<PVector>();

  // go through each of the vertices, plus the next vertex in the list
  int next = 0;
  for (int current=0; current<vertices.length; current++) {
    // get next vertex in list
    // if we've hit the end, wrap around to 0
    next = current+1;
    if (next == vertices.length) next = 0;

    // get the PVectors at our current position
    // extract X/Y coordinates from each
    float x3 = vertices[current].x;
    float y3 = vertices[current].y;
    float x4 = vertices[next].x;
    float y4 = vertices[next].y;

    PVector collisionCoord = lineLineCollisionCoords(x1, y1, x2, y2, x3, y3, x4, y4);
    if (collisionCoord != defaultPVector) {
      // Checks if the coordinate where the collision occurred is the same as a coordinate in the line that's being tested
      if (!((round(collisionCoord.x) == round(x1) && round(collisionCoord.y) == round(y1) ) ||
            (round(collisionCoord.x) == round(x2) && round(collisionCoord.y) == round(y2) )) ) {
        out.add(collisionCoord);
      }
    }
  }
  
  return out;
}

/* Polygon/rectangle collision (from Jeffrey Thompson) */
static boolean polyRect(PVector[] vertices, float rectx1, float recty1, float rectx2, float recty2, boolean testInside) {
  int indexNext = 0;
  for (int indexCrnt=0; indexCrnt<vertices.length; indexCrnt++) {
    indexNext = indexCrnt+1;
    if (indexNext == vertices.length) indexNext = 0;

    PVector vectorCrnt = vertices[indexCrnt];
    PVector vectorNext = vertices[indexNext];

    if (lineRect(vectorCrnt.x, vectorCrnt.y, vectorNext.x, vectorNext.y, 
                 rectx1, recty1, rectx2, recty2)) {
      return true;
    }

    // optional: test if the rectangle is INSIDE the polygon
    // note that this iterates all sides of the polygon
    // again, so only use this if you need to
    if (testInside) {
      if (pointRect(vertices[0].x, vertices[0].y, rectx1, recty1, rectx2, recty2) ||
          polyPoint(vertices, rectx1, recty1)) {
        return true;
      }
    }
  }
  return false;
}