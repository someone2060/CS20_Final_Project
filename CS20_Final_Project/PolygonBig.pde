/*** POLYGONBIG CLASS 
 * Manages a polygon in the stage that game objects always reside in.
 * Doesn't contain a bounding box, as a game object will always be in this polygon's bounding box.*/

class PolygonBig {
  private final ArrayList<PVector> coords;
  private final int coordsSize;
  private final PShape shape;
  
  PolygonBig(StringList coordsStr, color colour) {
    ArrayList<PVector> coordsTemp = new ArrayList<PVector>();
    
    PShape shapeTemp = createShape();
    shapeTemp.beginShape();
    shapeTemp.fill(colour);
    shapeTemp.noStroke();

    String[] coordStr;
    PVector coord;
    
    for (int i=0; i<coordsStr.size(); i++) {
      coordStr = coordsStr.get(i).split(" ");
      coord = new PVector(int(coordStr[0]), int(coordStr[1]));
      
      coordsTemp.add(coord);
      shapeTemp.vertex(coord.x, coord.y);
    }
    shapeTemp.endShape();
    
    coords = coordsTemp;
    coordsSize = coords.size();
    shape = shapeTemp;
  }
  
  int getSize() {
    return coordsSize;
  }
  
  ArrayList<PVector> getCoords() {
    return coords;
  }
  
  PVector getPoint(int index) {
    return coords.get(index % coordsSize).copy();
  }
  
  PVector[] getLine(int index) {
    PVector[] out = {getPoint(index), getPoint(index+1)};
    return out;
  }
  
}