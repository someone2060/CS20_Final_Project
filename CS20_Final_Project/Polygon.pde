/*** POLYGON CLASS 
 * Manages a polygon in the stage that can be interacted with.
 * Contains a bounding box that consists of the smallest and largest boxes. */

class Polygon {
  // Stores the polygon
  private final PShape shape;
  // Stores the coordinates of the polygon
  private final ArrayList<PVector> coords;
  private final int coordsSize;
  // Stores the coordinates of a rect of the bounding box
  private final PVector[] bounds;
  
  Polygon(StringList coordsStr, color colour) {
    String[] coordStr;
    PVector coord;

    PVector[] boundsTemp = new PVector[2];

    ArrayList<PVector> coordsTemp = new ArrayList<PVector>();
    
    PShape shapeTemp = createShape();
    shapeTemp.beginShape();
    shapeTemp.fill(colour);
    shapeTemp.noStroke();
    
    for (int i=0; i<coordsStr.size(); i++) {
      coordStr = coordsStr.get(i).split(" ");
      coord = new PVector(int(coordStr[0]), int(coordStr[1]));
      
      coordsTemp.add(coord);
      shapeTemp.vertex(coord.x, coord.y);
      
      if (boundsTemp[0] == null) {
        boundsTemp[0] = coord.copy();
        boundsTemp[1] = coord.copy();
        continue;
      }
      if (boundsTemp[0].x > coord.x) boundsTemp[0].x = coord.x;
      if (boundsTemp[0].y > coord.y) boundsTemp[0].y = coord.y;
      if (boundsTemp[1].x < coord.x) boundsTemp[1].x = coord.x;
      if (boundsTemp[1].y < coord.y) boundsTemp[1].y = coord.y;
    }
    shapeTemp.endShape();
    
    coords = coordsTemp;
    coordsSize = coords.size();
    bounds = boundsTemp;
    shape = shapeTemp;
  }
  
  int getSize() {
    return coordsSize;
  }
  
  ArrayList<PVector> getCoords() {
    return coords;
  }
  
  PVector[] getBounds() {
    return bounds;
  }
  
  PVector getPoint(int index) {
    return coords.get(index % coordsSize).copy();
  }
  
  PVector[] getLine(int index) {
    PVector[] out = {getPoint(index), getPoint(index+1)};
    return out;
  }
  
}