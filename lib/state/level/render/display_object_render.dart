part of game;

class DisplayObjectRender extends Render {

  int tileDimension;
  PIXI.DisplayObject _displayObject;
  List<Tweening.BaseTween> tweens;
  Tweening.TweenManager tweenManager;
  PIXI.Stage stage;
  int width;
  int height;
  
  DisplayObjectRender(this._displayObject, this.tileDimension, this.tweenManager) {
    this.tweens = [];
  }
  
  attach(PIXI.Stage stage, int width, int height) {
    stage.children.add(this._displayObject);
    this.stage = stage;
    this.width = width;
    this.height = height;
    
  }
  
  detach(PIXI.Stage stage) {
    stage.children.remove(this._displayObject);
    killTweens();
  }
  
  killTweens() {
    this.tweens.forEach((Tweening.BaseTween tween) {
      tween.kill();
    });    
    this.tweens.clear();
  }
  
  apply(Delta delta, DeltaRenderCompletionCallback onComplete) {
    // move to front
    this.stage.children.remove(this._displayObject);
    this.stage.children.add(this._displayObject);
    if( delta is MoveDelta ) {
      MoveDelta moveDelta = delta;
      
      double x = (moveDelta.toTile.x * this.tileDimension + tileDimension/2).toDouble();
      double y = (moveDelta.toTile.y * this.tileDimension + tileDimension/2).toDouble();
      
      Tweening.Timeline timeline = new Tweening.Timeline.sequence();

      Tweening.Tween tween = new Tweening.Tween.to(this._displayObject, TweenType.Position, 0.5);
      tween.targetValues = [x, y];    
      tween.easing = Tweening.Cubic.IN;
      timeline.push(tween);
      
      timeline.callback = (int type, Tweening.BaseTween source) {
        if( type == Tweening.TweenCallback.COMPLETE ) {
          // TODO callback
          onComplete(false);
        }
      };
      
      tweenManager.add(timeline);
      
      if( moveDelta.type == DeltaType.MOVE_CLIMB ) {
        AudioElement audio = document.querySelector("#climb1").clone(true);
        audio.play();
      } else if( moveDelta.type == DeltaType.MOVE_SLIDE ) {
        AudioElement audio = document.querySelector("#slide1").clone(true);
        audio.play();        
      } else if( moveDelta.type == DeltaType.MOVE_GRAPPLE ) {
        AudioElement audio = document.querySelector("#grapple1").clone(true);
        audio.play();                
      }
      
    } else if( delta.type == DeltaType.DIE_CRUSHED || delta.type == DeltaType.DIE_MATCHED || delta.type == DeltaType.DIE_COLLECTED) {

      Tweening.Tween tween1 = new Tweening.Tween.to(this._displayObject, TweenType.Alpha, 0.5);
      tween1.targetValues = [0];
      tweenManager.add(tween1);
      
      Tweening.Tween tween2 = new Tweening.Tween.to(this._displayObject, TweenType.Scale, 0.5);
      tween2.easing = Tweening.Cubic.OUT;
      tween2.targetValues = [0.9, 0.0];
      tweenManager.add(tween2);

      Tweening.Tween tween3 = new Tweening.Tween.to(this._displayObject, TweenType.Rotate, 0.5);
      tween3.targetValues = [PI/2];
      tweenManager.add(tween3);

      
      tween1.callback = (int type, Tweening.BaseTween source) {
        if( type == Tweening.TweenCallback.COMPLETE ) {
          onComplete(true);
        }
      };      
      if( delta.type == DeltaType.DIE_CRUSHED ) {
          AudioElement audio = document.querySelector("#squashed1").clone(true);
          audio.play();                
        }
    } else if( delta.type == DeltaType.REVEAL ) {
      Tweening.Timeline timeline = new Tweening.Timeline.sequence();
      
      Tweening.Tween fadeIn = new Tweening.Tween.to(_displayObject, TweenType.Scale, 0.2);
      double scalex = _displayObject.scale.x;
      double scaley = _displayObject.scale.y;
      fadeIn.targetValues = [scalex * 1.5, scaley * 1.5];
      timeline.push(fadeIn);
      
      Tweening.Tween fadeOut = new Tweening.Tween.to(_displayObject, TweenType.Scale, 0.3);
      fadeOut.targetValues = [scalex, scaley];
      timeline.push(fadeOut);
      
      timeline.callback = (int type, Tweening.BaseTween source) {
        if( type == Tweening.TweenCallback.COMPLETE ) {
          // TODO callback
          onComplete(false);
        }
      };
      tweenManager.add(timeline);
      
    } else{
      onComplete(false);
    }
  }

  
}