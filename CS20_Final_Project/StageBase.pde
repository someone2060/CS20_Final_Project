/*** STAGE BASE CLASS 
 * Manages the initialization and displaying of a stage.
 * When displaying other objects on a stage, run displayOuterWall() first, then displayRest() after everything else has been drawn.
 * 
 * The methods contained inside StageBase are:
 *   - displayOuterWall (displays the outerWall polygon; separated so that other objects can be drawn on top of outerWall)
 *   - displayRest (displays innerWalls, tables, and doors (TODO) polygons if they are in frame)*/

abstract class StageBase {
  protected final String title; // name of stage that player is on
  
  // Walls that show the shape of the building
  protected final PolygonBig outerWall;
  
  // Walls that are enclosed polygons inside the building
  // The first two variables signify the bounding box of the shape (min, max, point0...pointN)
  protected final ArrayList<Polygon> innerWalls;
  
  // Obstacles that only prevent movement
  // The first two variables signify the bounding box of the shape (min, max, point0...pointN)
  protected final ArrayList<Polygon> tables;
  
  // Obstacles that can block line of sight
  protected final ArrayList<ArrayList> doors;
  
  // Collection of all PShapes in innerWalls and tables
  private final PShape stageShapes;
  
  /** HOW TO FORMAT A FILE THAT WILL BE ANALYZED BY THE STAGE CLASS
   * Main idea of the file is that each line is either a coordinate or a divider.
   * Two dashes (--) signify a change in type of obstacles, while one dash (-) signifies a new polygon.
   * ALL POINTS SHOULD BE SPECIFIED COUNTER-CLOCKWISE; EXCEPTION IN OUTERWALLS, WHICH SHOULD BE CLOCKWISE
   * The file in its whole is formatted like so
   * LEGEND: "...": continuation of same instances, "[text]": changeable input):
   * 
   * [stage name]
   * --
   * [outerWall0.x] [outerWall0.y]
   * [outerWall1.x] [outerWall1.y]
   * [outerWall2.x] [outerWall2.y]
   * ...
   * [outerWallN.x] [outerWallN.y]
   * --
   * [innerWalls00.x] [innerWalls00.y]
   * [innerWalls01.x] [innerWalls01.y]
   * ...
   * [innerWalls0N.x] [innerWalls0N.y]
   * -
   * [innerWalls10.x] [innerWalls10.y]
   * [innerWalls11.x] [innerWalls11.y]
   * ...
   * [innerWalls1N.x] [innerWalls1N.y]
   * -...
   * [innerWallsN0.x] [innerWallsN0.y]
   * [innerWallsN1.x] [innerWallsN1.y]
   * ...
   * [innerWallsNN.x] [innerWallsNN.y]
   * --
   * [tables00.x] [tables00.y]
   * [tables01.x] [tables01.y]
   * ...
   * [tables0N.x] [tables0N.y]
   * -...
   * [tablesN0.x] [tablesN0.y]
   * [tablesN1.x] [tablesN1.y]
   * ...
   * [tablesNN.x] [tablesNN.y]
   * --
   * [doors00.x] [doors00.y]
   * [doors01.x] [doors01.y]
   * [doors10.x] [doors10.y]
   * [doors11.x] [doors11.y]
   * ...
   * [doorsN0.x] [doorsN0.y]
   * [doorsN1.x] [doorsN1.y]
   * --
   * */
  StageBase(String fname) {
    final String[] flines = loadStrings(fname);
    // Type of obstacle that's being added to
    // 0=outerWall, 1=innerWalls, 2=tables, & 3=doors
    int stage = 0;
    // Index (polygon #) where PVectors are being added to
    int counter = 0;
    // Same as crnt (iteration in a loop), but split apart on spaces
    String[] crntSeparated;
    // Init temporary variables that will be assigned to the class variables
    String titleTemp = "";
    
    StringList coordsStr = new StringList();
    PolygonBig outerWallTemp = null;
    color outerWallColour = color(#787878);
    
    ArrayList<Polygon> innerWallsTemp = new ArrayList<Polygon>();
    color innerWallColour = color(#646464);
    
    ArrayList<Polygon> tablesTemp = new ArrayList<Polygon>();
    color tableColour = color(#F0F0F0);

    ArrayList<ArrayList> doorsTemp = new ArrayList<ArrayList>();
    doorsTemp.add(new ArrayList<PVector>(1));
    
    // Init variable
    stageShapes = createShape(GROUP);
    
    // Loop for each line in the file
    for (final String crnt : flines) {
      crntSeparated = crnt.split(" ");
      switch (stage) {
        case 0: //// adding to title
          /// Move to adding to next var
          if (crnt.equals("--") ) {
            stage++;
            break;
          }
          /// Set current line to title
          titleTemp = crnt;
          break;
          
        case 1: //// adding to outerWallTemp
          /// Move to adding to next var
          if (crnt.equals("--")) {
            outerWallTemp = new PolygonBig(coordsStr, outerWallColour);
            coordsStr = new StringList();
            stage++;
            break;
          }
          coordsStr.append(crnt);
          break;
          
        case 2: //// adding to innerWallsTemp
          /// Move to next polygon
          if (crnt.equals("-")) {
            innerWallsTemp.add(new Polygon(coordsStr, innerWallColour));
            stageShapes.addChild(innerWallsTemp.get(innerWallsTemp.size()-1).shape);
            coordsStr = new StringList();
            counter++;
            break;
          }
          /// Move to adding to next var
          if (crnt.equals("--")) {
            innerWallsTemp.add(new Polygon(coordsStr, innerWallColour));
            stageShapes.addChild(innerWallsTemp.get(innerWallsTemp.size()-1).shape);
            coordsStr = new StringList();
            counter = 0;
            stage++;
            break;
          }
          coordsStr.append(crnt);
          break;
          
        case 3: //// adding to tablesTemp
          /// Move to next polygon
          if (crnt.equals("-")) {
            tablesTemp.add(new Polygon(coordsStr, tableColour));
            stageShapes.addChild(tablesTemp.get(tablesTemp.size()-1).shape);
            coordsStr = new StringList();
            counter++;
            break;
          }
          /// Move to adding to next var
          if (crnt.equals("--")) {
            tablesTemp.add(new Polygon(coordsStr, tableColour));
            stageShapes.addChild(tablesTemp.get(tablesTemp.size()-1).shape);
            coordsStr = new StringList();
            counter = 0;
            stage++;
            break;
          }
          coordsStr.append(crnt);
          break;
          
        case 4: //// adding to doorsTemp
          /// End adding to vars
          if (crnt.equals("--")) {
            doorsTemp.remove(doorsTemp.size()-1);
            break;
          }
          /// Add current PVector to end of ArrayList
          if (counter != doorsTemp.size()) { // is first coordinate in line
            counter++;
          } else { // is second coordinate in line
            doorsTemp.add(new ArrayList<PVector>(1));
          }
          doorsTemp.get(counter-1).add(new PVector(int(crntSeparated[0]), int(crntSeparated[1]) ));
          break;
      }
    }
    // Assigning class variables to temporary variables inside initialization
    title = titleTemp;
    outerWall = outerWallTemp;
    innerWalls = innerWallsTemp;
    tables = tablesTemp;
    doors = doorsTemp;
    //println(outerWall.coords, "\n", innerWalls.get(0).coords, innerWalls.get(0).bounds[0], innerWalls.get(0).bounds[1], "\n", tables.get(0).coords, tables.get(0).bounds[0], tables.get(0).bounds[1]);//DEBUG
  }
  
  
  /** Displays outerWall */
  protected void displayOuterWall() {
    pushMatrix();
    translate(0 - player.getPosition().x, 
              0 - player.getPosition().y);
    shape(outerWall.shape);
    popMatrix();
  }
  
  
  //// VARIABLES USED IN DISPLAYREST()
  // Stores bounding box of polygon being drawn
  PVector[] boundingBox;

  /** Displays innerWalls and tables if they are on screen
   * If the polygon isn't visible on screen, the polygon isn't displayed. */
  protected void displayRest() {
    pushMatrix();
    translate(0 - player.getPosition().x, 0 - player.getPosition().y);
    shape(stageShapes);
    popMatrix();
  }
  
}
