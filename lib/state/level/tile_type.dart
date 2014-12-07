part of game;

class TileType {
  static const BRICK = const TileType._(1);
  
  final int value;
  
  const TileType._(this.value);  
}