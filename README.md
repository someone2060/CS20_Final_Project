# cs20-final-project
This project is a program that I coded for Grade 11 in high school. Using Processing 4, the program is a demo of a top down movement system. Many features are implemented, but not to create a full game.

## How to run
1. If you have not yet, [download Processing 4](https://processing.org/download).
2. Open this repo in Github Desktop.
3. In Github Desktop, view this file in File Explorer/Finder by selecting "Show in Explorer" or using the shortcut Ctrl+Shift+F.
4. Open CS20_Final_Project → CS20_Final_Project.pde.
5. Once Processing is open, click the Run button on the top left.
6. Use WASD or arrow keys, and mouse motion to control your character. Have fun!

## Specific details
### Main features
* Player movement using WASD or arrow keys
* Player and enemy collision along sloped walls
* Enemy that chases player once on-screen
* Invulnerability and knockback to player on collision with enemy
* Player and enemy line of sight
* Debug mode that can be toggled by typing "It's Codin' Time"
### Added polish
* Player uses acceleration motion
* Player looks at the cursor
* Cursor moves player's view depending on distance
* Player moves slower the more the cursor faces away from the player's movement direction
* Player doesn't move towards cursor immediately, instead rotating somewhat fast
* Enemy only see player once they are on the player's screen
### Debug features
* Coordinates on mouse
* Visible polygon vertices are highlighted in red
* Green border displays enemy detection range
* Blue hit/hurtboxes shown
* Movement of player
    * Player intended motion in black
    * Wall affected motion (final motion) in red