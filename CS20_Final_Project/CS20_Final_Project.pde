/***
BUGS:
  - Player can get stuck on a corner by moving perpendicular to wall corner
  - A gap appears between the sprite and a wall if the player is already moving along another wall
  - If the player gets hit when next to a wall, 
      they can go through the wall if the next frame will pass through the wall
  - When player isn't moving, vertexIDs from move() can have a size of >1 somehow
      (even though bounding boxes should account for this)
TODO:
  - Player damage from enemy visualization (WIP)
  - Debug lines for enemy
  - Food class
  - Food variation
  - Sounds
  - Player feedback in general
  - Better enemy pathfinding (traces polygons)
  - Tables hidden when not visible
  - Door obstacle
  - Camera is chaser instead of locked */

//// DEBUGGING VARIABLES
static boolean debugging = true;
// How long vector lines are drawn (modifier; values are multiplied by this number)
static final float debugLineLength = 7;
// What needs to be typed to turn debug mode on/off
static final String debugPassword = "It's Codin' Time";
// Position that checks the next button that the player has to press to progress toggling debug mode
static int debugPasswordIndex = 0;

//// GENERAL VARIABLES
static final String title = "Working Title";
static PVector screenCentre;
// Min and max y coordinates that screenCoords is covering
static PVector[] screenCoords = new PVector[2];

static final int framerateGoal = 30;
// tracks key presses
static boolean keyW, keyA, keyS, keyD, keyUP, keyLEFT, keyDOWN, keyRIGHT;
// PVector that's returned in functions that contain an empty amount of PVector
static final PVector defaultPVector = new PVector(0, 0);

//// UI VARIABLES
static UserInterface userInterface;

//// STAGE VARIABLES
// Each variable corresponds with a .txt file in data folder
static Stage stageTest, ghostKitchen, buffet, fastFood, casualDining, fineDining, cafe, storage;
static Stage stageCrnt;

//// PLAYER VARIABLES
static Player player;

//// ENEMY VARIABLES
EnemyTest enemyTest;
PShape enemyTestAppearance;
static final int enemyTestHealth = 5;
static final float enemyTestVelocityMax = 200/framerateGoal;
static final float enemyTestAcceleration = enemyTestVelocityMax/(framerateGoal/12.0);
static final float enemyTestDeceleration = enemyTestAcceleration/2.0;
static final float enemyTestTurningSpeed = radians(180)/framerateGoal;
static final float enemyTestKnockback = 120;
void setup() {
  //// GENERAL SETUP
  surface.setTitle(title);
  //fullScreen();
  size(800, 600); //DEBUG
  //println(width, height); //DEBUG
  frameRate(framerateGoal);
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
  keyW = false;
  keyA = false;
  keyS = false;
  keyD = false;
  keyUP = false;
  keyLEFT = false;
  keyDOWN = false;
  keyRIGHT = false;
  screenCentre = new PVector(width/2, height/2);
  
  //// UI SETUP
  userInterface = new UserInterface();
  
  //// STAGE SETUP
  stageTest = new Stage("stageTest.txt");
  stageCrnt = stageTest;
  
  //// PLAYER SETUP
  // Creating the appearance of the player
  fill(255);
  stroke(0);
  strokeWeight(1);
  PShape playerBody = createShape(ELLIPSE, 0, 0, 48, 48);
  PShape playerHandL = createShape(ELLIPSE, 5, 28, 12, 12);
  PShape playerHandR = createShape(ELLIPSE, 5, -28, 12, 12);
  fill(0);
  noStroke();
  PShape playerEyeL = createShape(ELLIPSE, 8, 8, 6, 6);
  PShape playerEyeR = createShape(ELLIPSE, 8, -8, 6, 6);
  
  PShape playerAppearance = createShape(GROUP);
  playerAppearance.addChild(playerHandL);
  playerAppearance.addChild(playerHandR);
  playerAppearance.addChild(playerBody);
  playerAppearance.addChild(playerEyeL);
  playerAppearance.addChild(playerEyeR);
  // See Player.pde to see what each value does
  player = new Player(new PVector(0, 0), playerAppearance, 24, 5*PI/framerateGoal, 50, framerateGoal/2);
  
  //// ENEMY SETUP
  fill(#ff0000);
  PShape enemyTestBody = createShape(RECT, 0, 0, 40, 40);
  fill(0);
  PShape enemyTestEye = createShape(ELLIPSE, 10, 0, 10, 10);
  enemyTestAppearance = createShape(GROUP);
  enemyTestAppearance.addChild(enemyTestBody);
  enemyTestAppearance.addChild(enemyTestEye);
  //DEBUG
  enemyTest = new EnemyTest(new PVector(-600, 100), enemyTestAppearance, 24, enemyTestHealth,
                            enemyTestVelocityMax, enemyTestAcceleration, enemyTestDeceleration, enemyTestTurningSpeed, 
                            enemyTestKnockback);
}



void draw() {
  if (!player.isImmune()) {
    player.rotateTo(atan2(mouseY-screenCentre.y, mouseX-screenCentre.x));
  }
  
  background(100);
  screenCoords[0] = PVector.sub(player.getPosition(), screenCentre);
  screenCoords[1] = PVector.add(player.getPosition(), screenCentre);
  player.playerPosition.update();
  player.playerSight.updateStageVision();
  
  pushMatrix();
  translate(screenCentre.x, screenCentre.y);
  player.playerSight.translateWindow();
  
  stageTest.displayOuterWall();
  player.display();
  enemyTest.update(); //DEBUG
  stageTest.displayRest();
  
  popMatrix();
  
  //userInterface.displayHealth(10, 10, 200, 20);
  userInterface.displayDebugCoordinates();
  
  fill(0);
  textAlign(RIGHT, BOTTOM);
  textSize(14);
  text(round(frameRate) + " FPS", width, height);
}



/** Mechanism that checks if the player typed in the code to toggle debug mode */
void keyTyped() {
  if (key != debugPassword.charAt(debugPasswordIndex)) { //next key isn't the right button in the password
    debugPasswordIndex = 0;
    return;
  }
  if (debugPasswordIndex+1 < debugPassword.length()) { //password isn't fully typed out yet
    debugPasswordIndex++;
    return;
  }
  // debug mode toggled
  debugging = (debugging) ? false : true;
  debugPasswordIndex = 0;
}



void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
      case UP:
        keyUP = true;
        break;
      case LEFT:
        keyLEFT = true;
        break;
      case DOWN:
        keyDOWN = true;
        break;
      case RIGHT:
        keyRIGHT = true;
        break;
    }
  }
  switch(key) {
    case 'w':
      keyW = true;
      break;
    case 'a':
      keyA = true;
      break;
    case 's':
      keyS = true;
      break;
    case 'd':
      keyD = true;
      break;
  }
}



void keyReleased() {
  if (key == CODED) {
    switch(keyCode) {
      case UP:
        keyUP = false;
        break;
      case LEFT:
        keyLEFT = false;
        break;
      case DOWN:
        keyDOWN = false;
        break;
      case RIGHT:
        keyRIGHT = false;
        break;
    }
  }
  switch(key) {
    case 'w':
      keyW = false;
      break;
    case 'a':
      keyA = false;
      break;
    case 's':
      keyS = false;
      break;
    case 'd':
      keyD = false;
      break;
  }
}
