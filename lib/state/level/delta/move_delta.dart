part of game;

class MoveDelta extends Delta {
  
  Point toTile;
  
  MoveDelta(DeltaType type, Entity entity, Point fromTile, this.toTile): super(type, entity, fromTile) {
    
  }
  
}