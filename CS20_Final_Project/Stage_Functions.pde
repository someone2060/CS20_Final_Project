/*** STAGE FUNCTIONS
 * Manages functions that a stage deals with, using vertexID.
 * A vertexID stores the location of a wall.
 * It consists of two parts, each separated by a space.
 * The first part contains the object type that was collided with. This can be outerWall, innerWalls, tables, or doors.
 * The second part contains the array indexes of the location of the wall.
 * As an example, if a wall was the third location in the second polygon in innerWalls, the vertexID would be formatted ["innerWalls", "1", "2"].
 *
 * The functions included in this tab are:
 *   - vertexIDpoly (returns the polygon associated with vertexID)
 *   - vertexIDbounds (returns the boundaries of the vertexID; only works for innerWalls and tables)
 *   - vertexIDcoords (returns the coordinate associated with vertexID)
 *   - vertexIDline (returns coordinates of a line that uses vertexID, and the coordinate after vertexID) */

/** Uses vertexID to find the polygon that it is associated with */
static PVector[] vertexIDpoly(final Stage stage, final String[] vertexID) {
  switch (vertexID[0]) {
    case "outerWall": // wanted polygon is from outerWall
      return stage.outerWall.getCoords().toArray(new PVector[0]);
      
    case "innerWalls": // wanted polygon is from innerWalls
      return stage.innerWalls.get(int(vertexID[1])).getCoords().toArray(new PVector[0]);
      
    case "tables": // wanted polygon is from tables
      return stage.tables.get(int(vertexID[1])).getCoords().toArray(new PVector[0]);
      
    default: // error occurs
      println("ERROR IN vertexIDpoly FUNCTION: INVALID VERTEXID");
      return new PVector[0];
  }
}

/** Uses vertexID to return the bounding box that corresponds with it. */
static PVector[] vertexIDbounds(final Stage stage, final String[] vertexID) {
  switch (vertexID[0]) {
    case "innerWalls": // wanted bounds is from innerWalls
      return stage.innerWalls.get(int(vertexID[1])).getBounds();
      
    case "tables": //wanted bounds is from tables
      return stage.tables.get(int(vertexID[1])).getBounds();
      
    default:
      println("ERROR IN vertexIDbounds FUNCTION: INVALID VERTEXID");
      return new PVector[0];
  }
}

/** Uses vertexID to find the point that corresponds with it. */
static PVector vertexIDcoords(final Stage stage, final String[] vertexID) {
  switch (vertexID[0]) {
    case "outerWall": // wanted line is from outerWall
      return stage.outerWall.getPoint(int(vertexID[1]));
      
    case "innerWalls": // wanted line is from innerWalls
      return stage.innerWalls.get(int(vertexID[1])).getPoint(int(vertexID[2]));
      
    case "tables": // wanted line is from tables
      return stage.tables.get(int(vertexID[1])).getPoint(int(vertexID[2]));
      
    default: // error occurs
      println("ERROR IN vertexIDcoords FUNCTION: INVALID VERTEXID");
      return new PVector();
  }
}

/** Uses vertexID to find the point that corresponds with it. */
static PVector[] vertexIDline(final Stage stage, final String[] vertexID) {
  switch (vertexID[0]) {
    case "outerWall": // wanted line is from outerWall
      return stage.outerWall.getLine(int(vertexID[1]));
      
    case "innerWalls": // wanted line is from innerWalls
      return stage.innerWalls.get(int(vertexID[1])).getLine(int(vertexID[2]));
      
    case "tables": // wanted line is from tables
      return stage.tables.get(int(vertexID[1])).getLine(int(vertexID[2]));
      
    default: // error occurs
      println("ERROR IN vertexIDline FUNCTION: INVALID VERTEXID");
      PVector[] out = {defaultPVector};
      return out;
  }
  
}