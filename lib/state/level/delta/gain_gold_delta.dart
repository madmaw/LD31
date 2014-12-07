part of game;

class GainGoldDelta extends Delta {
  
  int quantity;
  int multiplier;
  
  GainGoldDelta(
      DeltaType type, 
      Entity entity,
      Point fromTile, 
      this.quantity, 
      this.multiplier
  ): super(type, entity, fromTile) {
    
  }
}