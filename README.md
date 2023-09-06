# cs20-final-project
This project is a program that I coded for Grade 11 in high school. Using Processing 4, the program is a demo of a top down movement system. Many features are implemented, but not to create a full game.
## Main features
* Player movement using WASD or arrow keys
* Player and enemy collision along sloped walls
* Enemy that chases player once on-screen
* Invulnerability and knockback to player on collision with enemy
* Player and enemy line of sight
* Debug mode that can be toggled by typing "It's Codin' Time"
## Added polish
* Player uses acceleration motion
* Player looks at the cursor
* Cursor moves player's view depending on distance
* Player moves slower the more the cursor faces away from the player's movement direction
* Player doesn't move towards cursor immediately, instead rotating somewhat fast
* Enemy only see player once they are on the player's screen
## Debug features
* Coordinates on mouse
* Visible polygon vertices are highlighted in red
* Green border displays enemy detection range
* Blue hit/hurtboxes shown
* Movement of player
    * Player intended motion in black
    * Wall affected motion (final motion) in red