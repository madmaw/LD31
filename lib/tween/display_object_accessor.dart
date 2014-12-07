part of game;

class DisplayObjectAccessor implements Tweening.TweenAccessor<PIXI.DisplayObject> {
  int getValues(PIXI.DisplayObject object, Tweening.Tween tween, int tweenType, List<num> values) {
    int result;
    switch( tweenType ) {
      case TweenType.Position: 
        values[0] = object.position.x.toDouble();
        values[1] = object.position.y.toDouble();
        result = 2;
        break;
      case TweenType.Alpha:
        values[0] = object.alpha.toDouble();
        result = 1;
        break;
      case TweenType.Scale:
        values[0] = object.scale.x.toDouble();
        values[1] = object.scale.y.toDouble();
        result = 2;
        break;
      case TweenType.Rotate:
        values[0] = object.rotation.toDouble();
        result = 1;
        break;
    }
    return result;
  }
  
  void setValues(PIXI.DisplayObject object, Tweening.Tween tween, int tweenType, List<num> values) {
    switch( tweenType ) {
      case TweenType.Position:
        object.position = new Point(values[0], values[1]);
        break;
      case TweenType.Alpha:
        object.alpha = values[0].toDouble();
        break;
      case TweenType.Scale:
        object.scale = new Point(values[0], values[1]);
        break;
      case TweenType.Rotate:
        object.rotation = values[0].toDouble();
        break;
    }
  }
}
