part of game;

class DeltaType {
  
  static const MOVE_SWAP = const DeltaType._(0);
  static const MOVE_TELEPORT = const DeltaType._(1);
  static const DIE_MATCHED = const DeltaType._(2);
  static const DIE_CRUSHED = const DeltaType._(3);  
  static const MOVE_FALL = const DeltaType._(4);
  static const MOVE_CLIMB = const DeltaType._(5);
  static const GAIN_GOLD = const DeltaType._(6);
  static const MULTIPLIER = const DeltaType._(7);
  static const DIE_WOUNDS = const DeltaType._(8);
  static const TAKE_DAMAGE = const DeltaType._(9);
  static const MOVE_GRAPPLE = const DeltaType._(10);
  static const GAIN_GRAPPLE = const DeltaType._(11);
  static const DIE_COLLECTED = const DeltaType._(12);
  static const REVEAL = const DeltaType._(13);
  static const LEAVE = const DeltaType._(14);
  
  final int value;
  
  const DeltaType._(this.value);  

}