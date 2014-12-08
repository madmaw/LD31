part of game;

class EntityType {
  static const PLAYER = const EntityType._(0, 0.0);
  static const GREEN_STONE = const EntityType._(1, 0.34);
  static const BLUE_STONE = const EntityType._(2, 0.34);
  static const RED_STONE = const EntityType._(3, 0.34);  
  static const DIRT = const EntityType._(4, 0.0);
  static const LADDER = const EntityType._(5, 2.0);
  static const SNAKE = const EntityType._(6, 0.0);
  static const GRAPPLE = const EntityType._(7, 3.0);
  static const CRATE = const EntityType._(8, 0.0);
  static const DIAMOND = const EntityType._(9, 10.0);
  static const RUBY = const EntityType._(10, 20.0);
  static const SPIKE_BLOCK = const EntityType._(11, 5.0);
  static const SPIDER = const EntityType._(12, 0.0);
  
  final int value;
  final double monetaryValue;
  
  const EntityType._(this.value, this.monetaryValue);  
}