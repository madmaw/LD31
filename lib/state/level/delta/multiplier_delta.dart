part of game;

class MultiplierDelta extends Delta {
  
  int multiplier;
  
  MultiplierDelta(DeltaType type, Entity entity, this.multiplier) : super(type, entity, null) {
    
  }
  
}