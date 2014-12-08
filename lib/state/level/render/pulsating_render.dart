part of game;

class PulsatingRender extends DisplayObjectRender {
  
  PulsatingRender(PIXI.DisplayObject displayObject, int tileDimension, Tweening.TweenManager tweenManager) : super(displayObject, tileDimension, tweenManager) {
    
  }
  
  attach(PIXI.Stage stage, int width, int height) {
    super.attach(stage, width, height);
    
    Tweening.Timeline timeline = new Tweening.Timeline.sequence();
    
    
    double scaleX = this._displayObject.scale.x;
    double scaleY = this._displayObject.scale.y;
    
    Tweening.Tween fadeIn = new Tweening.Tween.to(_displayObject, TweenType.Scale, 2);
    fadeIn.targetValues = [scaleX * 1.1, scaleY * 1.1];
    fadeIn.easing = Tweening.Cubic.INOUT;
    timeline.push(fadeIn);
    
    Tweening.Tween fadeOut = new Tweening.Tween.to(_displayObject, TweenType.Scale, 2);
    fadeOut.targetValues = [scaleX, scaleY];
    fadeOut.easing = Tweening.Cubic.INOUT;
    timeline.push(fadeOut);

    timeline.repeat(Tweening.Tween.INFINITY, 0);
    
    this.tweenManager.add(timeline);
    this.tweens.add(timeline);
    
  }

  
}