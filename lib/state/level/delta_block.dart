part of game;

class DeltaBlock {
  
  List<Delta> deltas;
  
  DeltaBlock dependantBlock;

  DeltaBlock(this.deltas, this.dependantBlock) {
    
  }
  
  appendDependantBlock(DeltaBlock dependantBlock) {
    if( this.dependantBlock != null ) {
      this.dependantBlock.appendDependantBlock(dependantBlock);
    } else {
      this.dependantBlock = dependantBlock;
    }
  }
  
}