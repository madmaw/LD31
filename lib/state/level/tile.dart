part of game;

class Tile {
  
  int x;
  int y;
  TileType type;
  bool exit;
  
  Entity _entity;
  
  Tile(this.x, this.y, this.type, this.exit) {
    
  }
  
  Entity get entity => this._entity;
  
  void set entity(Entity entity) {
    this._entity = entity;
    if( entity != null ) {
      entity.tile = this;      
    }
  }
  
}