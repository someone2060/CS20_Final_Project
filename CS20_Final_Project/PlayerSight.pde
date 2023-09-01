/*** PLAYERSIGHT CLASS 
 * Manages the line of sight of the player.
 * Only walls can change the player's line of sight. (See Stage.pde to see what a wall does.)
 * The update function finds the points on vertices that a player can see, 
 *   then saves those points to visiblePoints.
 * visiblePoints is sorted in increasing order of heading.
 * Concept for implementation found from https://www.redblobgames.com/articles/visibility/ */

class PlayerSight {
  // List of vertexIDs that the player can see
  private ArrayList<String> visibleVertexIDs;
  // Polygon of space the player can see
  private ArrayList<PVector> polyVisibleArea;
  
  
  ////VARIABLES USED IN TRANSLATEWINDOW()
  private PVector mousePos;
  
  /** Translates the window of the screen based on where the player's mouse is.
   * If the player is stunned in some way, the location of the player's mouse will not be updated. */
  private void translateWindow() {
    if (!player.isStunned()) {
      mousePos = new PVector(mouseX, mouseY);
    }
    translate(lerp(0-width/10.0, width/10.0, (width-mousePos.x)/width), 
              lerp(0-height/10.0, height/10.0, (height-mousePos.y)/height) );
  }
  
  //// VARIABLES USED IN UPDATESTAGEVISION()
  private PVector[] crntI;
  private PVector crnt, crntJ;
  private int index;
  private String crntVertexID, lastVertexID;
  private PVector prevVisibleCoord, crntVisibleCoord;
  private PVector crntVisibleCoordMod;
  
  /** Finds the points on vertices that a player can see, then saves those points to visiblePoints sorted rotationally 
   * visiblePoints is sorted in increasing order of heading.
   * Concept for implementation found from https://www.redblobgames.com/articles/visibility/ */
  private void updateStageVision() {
    if (!player.playerPosition.isMoving() && polyVisibleArea != null) { //removing the "...!= null" will give a NullPointerException
      return;
    }

    // Reset sight variables
    visibleVertexIDs = new ArrayList<String>();
    polyVisibleArea = new ArrayList<PVector>();
    
    // Find visible vertices in outerWall
    for (int i = 0; i<stageCrnt.outerWall.getCoords().size(); i++) {
      crnt = stageCrnt.outerWall.getPoint(i);
      // Insert the current vertexID into visibleVertexIDs, sorted by 
      if (stageCrnt.pointVisible(player.getPosition(), crnt)) {
        // Stores the vertexID of the seen point
        crntVertexID = "outerWall "+ i;
        // Stores the coordinates of the seen point
        crntVisibleCoord = vertexIDcoords(stageCrnt, (crntVertexID).split(" ")).sub(player.getPosition());
        // Index that's being compared with crntVertexID
        index = 0;
        // Essentially insertion sort
        // Increases index while:
        // - the seen vertex's heading of the shape is larger than the item that's being tested with 
        // - index is less than the size of visibleVertexIDs
        while (index < visibleVertexIDs.size()) {
          if (crntVisibleCoord.heading() < 
              PVector.sub(vertexIDcoords(stageCrnt, visibleVertexIDs.get(index).split(" ")), 
                          player.getPosition()).heading()) {
            break;
          }
          index++;
        }
        visibleVertexIDs.add(index, crntVertexID);
      }
    }
    
    // Find visible vertices in innerWalls
    for (int i = 0; i<stageCrnt.innerWalls.size(); i++) {
      crntI = stageCrnt.innerWalls.get(i).getCoords().toArray(new PVector[0]);
      for (int j = 0; j<crntI.length; j++) {
        crntJ = crntI[j];
        if (stageCrnt.pointVisible(player.getPosition(), crntJ)) {
          // Stores the vertexID of the seen point
          crntVertexID = "innerWalls "+ i +" "+ j;
          // Stores the coordinates of the seen point
          crntVisibleCoord = vertexIDcoords(stageCrnt, (crntVertexID).split(" ")).sub(player.getPosition());
          // Index that's being compared with crntVertexID
          index = 0;
          // Essentially insertion sort
          // Increases index while:
          // - the seen vertex's heading of the shape is larger than the item that's being tested with 
          // - index is less than the size of visibleVertexIDs
          while (index < visibleVertexIDs.size()) {
            if (crntVisibleCoord.heading() < 
                PVector.sub(vertexIDcoords(stageCrnt, visibleVertexIDs.get(index).split(" ")), 
                            player.getPosition()).heading()) {
              break;
            }
            index++;
          }
          visibleVertexIDs.add(index, crntVertexID);
        }
      }
    }
    
    lastVertexID = visibleVertexIDs.get(visibleVertexIDs.size()-1);
    prevVisibleCoord = vertexIDcoords(stageCrnt, lastVertexID.split(" "));
    
    for (final String crnt : visibleVertexIDs) {
      crntVisibleCoord = vertexIDcoords(stageCrnt, crnt.split(" "));
      crntVisibleCoordMod = stageCrnt.rayCollisionCoords(crnt.split(" "), 
                                        PVector.sub(crntVisibleCoord, player.getPosition()).heading() );
      // used as a do/while loop so that the break keyword can be used
      do {
        if (crntVisibleCoord != crntVisibleCoordMod) {
          if (stageCrnt.pointVisible(crntVisibleCoordMod,
                                     prevVisibleCoord)) { //don't know how to explain this, try making use cases to justify this reasoning
            polyVisibleArea.add(crntVisibleCoordMod);
            polyVisibleArea.add(crntVisibleCoord);
            break;
          }
          polyVisibleArea.add(crntVisibleCoord);
          polyVisibleArea.add(crntVisibleCoordMod);
          break;
        }
        polyVisibleArea.add(crntVisibleCoord);
      } while (false);

      prevVisibleCoord = crntVisibleCoord;
    }
  }
  
}
