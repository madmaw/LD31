part of game;

class Player {
  
  // persistent info between levels
  int gold;
  int health;
  int grapples;
  bool dead;
  
  Player(this.health, this.grapples) {
    this.gold = 0;
    this.dead = false;    
  }
  
}