part of game;

class PlayerRender extends DisplayObjectRender {
  
  // hearts
  int hearts;
  PIXI.Sprite heartSprite;
  PIXI.CanvasText heartText;

  // gold
  int gold;
  PIXI.Sprite goldSprite;
  PIXI.CanvasText goldText;
  
  // grapples
  int grapples;
  PIXI.Sprite grappleSprite;
  PIXI.CanvasText grappleText;
  GrappleCallback grappleCallback;
  var grappleHandler;
  Random random;
  
  PlayerRender(
      PIXI.DisplayObject displayObject, 
      int tileDimension, 
      Tweening.TweenManager tweenManager,
      this.hearts, 
      this.heartSprite,
      
      this.gold,
      this.goldSprite,
      
      this.grapples,
      this.grappleSprite,
      this.grappleCallback,
      this.random
      
  ): super(displayObject, tileDimension, tweenManager) {
    grappleHandler = (PIXI.InteractionEvent e) {
      grappleCallback();
    };
    grappleSprite.onMouseDown.listen(grappleHandler);

  }
  
  attach(PIXI.Stage stage, int width, int height) {
    super.attach(stage, width, height);
    // create and add hearts
    
    Tweening.Timeline timeline = new Tweening.Timeline.sequence();
    
    Tweening.Tween fadeIn = new Tweening.Tween.to(_displayObject, TweenType.Rotate, 1);
    fadeIn.targetValues = [PI / 20];
    fadeIn.easing = Tweening.Cubic.INOUT;
    timeline.push(fadeIn);
    
    Tweening.Tween fadeOut = new Tweening.Tween.to(_displayObject, TweenType.Rotate, 1);
    fadeOut.targetValues = [-PI / 20];
    fadeOut.easing = Tweening.Cubic.INOUT;
    timeline.push(fadeOut);

    Tweening.Tween zero = new Tweening.Tween.to(_displayObject, TweenType.Rotate, 0.5);
    zero.targetValues = [0];
    zero.easing = Tweening.Cubic.INOUT;
    timeline.push(zero);

    timeline.repeat(Tweening.Tween.INFINITY, 5.0);
    
    this.tweenManager.add(timeline);
    this.tweens.add(timeline);

//    Tweening.Tween tween = new Tweening.Tween.to(_displayObject, TweenType.Rotate, 0.5);
//    tween.targetValues = [PI / 20];
//    tween.repeatYoyo(1000, 0.5);
//    tweenManager.add(tween);
//    
    
    int x = (height % this.tileDimension) ~/ 2;
    int y = height - this.tileDimension - x;
    this.heartSprite.position = new Point(x + tileDimension/2, y + tileDimension/2);
    this.heartText = new PIXI.CanvasText(
        "${hearts}",
        new PIXI.TextStyle(
            font: "${tileDimension}px Courier",
            fill: new PIXI.Colour.fromHtml("#FFFFFF")
        )
    );
    this.heartText.position = new Point(x + tileDimension, y);
    stage.children.add(this.heartSprite);
    stage.children.add(this.heartText);
    
    this.goldSprite.position = new Point(x+tileDimension * 2, y);
    this.goldText = new PIXI.CanvasText(
        "${gold}", 
        new PIXI.TextStyle(
            font: "${tileDimension}px Courier",
            fill: new PIXI.Colour.fromHtml("#FFFF00")
        )
    );
    this.goldText.position = new Point(x+ tileDimension * 3, y);
    stage.children.add(this.goldSprite);
    stage.children.add(this.goldText);
    
    this.grappleSprite.position = new Point(width - tileDimension * 2 -x, y);
    this.grappleText = new PIXI.CanvasText(
        "${grapples}", 
        new PIXI.TextStyle(
            font: "${tileDimension}px Courier",
            fill: new PIXI.Colour.fromHtml("#FFFFFF")
        )
    );
    this.grappleText.onMouseDown.listen(grappleHandler);
    this.grappleText.position = new Point(width - tileDimension - x, y);
    stage.children.add(this.grappleText);
    stage.children.add(this.grappleSprite);
  }
  
  detach(PIXI.Stage stage) {
    super.detach(stage);
    stage.children.remove(this.goldText);
    stage.children.remove(this.goldSprite);
    stage.children.remove(this.heartText);
    stage.children.remove(this.heartSprite);
    stage.children.remove(this.grappleText);
    stage.children.remove(this.grappleSprite);
  }
  
  apply(Delta delta, DeltaRenderCompletionCallback onComplete) {
    // check for other deltas
    if( delta is GainGoldDelta ) {
      GainGoldDelta gainGoldDelta = delta;
      int quantity = gainGoldDelta.quantity;
      int quantityHeight = tileDimension~/2;
      PIXI.CanvasText extra = new PIXI.CanvasText("${quantity}", new PIXI.TextStyle(
          font: "${quantityHeight}px Courier",
          fill: new PIXI.Colour.fromHtml("#FFFF00")
      ));
      extra.position = new Point(delta.fromTile.x * this.tileDimension, delta.fromTile.y * this.tileDimension);
      this.stage.children.add(extra);
      // tween to gold position
      Tweening.Tween tween = new Tweening.Tween.to(extra, TweenType.Position, 0.7);
      tween.targetValues = [width/2, height - this.tileDimension];    
      tween.easing = Tweening.Cubic.IN;
      tween.callback = (int type, Tweening.BaseTween source) {
        if( type == Tweening.TweenCallback.COMPLETE ) {
          this.gold += delta.quantity;
          this.goldText.setText("${gold}");
          this.stage.children.remove(extra);
          onComplete(false);
        }
      };
      tweenManager.add(tween);
      
      int id = random.nextInt(2) + 1;
      AudioElement audio = document.querySelector("#gold$id").clone(true);
      audio.play();
      
    } else if( delta is MultiplierDelta ) {
      MultiplierDelta multiplierDelta = delta;
      int multiplier = multiplierDelta.multiplier;
      PIXI.CanvasText extra = new PIXI.CanvasText("x${multiplier}", new PIXI.TextStyle(
          font: "bold ${tileDimension}px Courier",
          fill: new PIXI.Colour.fromHtml("#FF0000"),
          stroke: new PIXI.Colour.fromHtml("#FFFFFF"),
          strokeThickness: tileDimension/5
      ));
      extra.position = new Point((this.width-extra.width)/2, (this.height - extra.height)/2);
      extra.alpha = 0.0;
      this.stage.children.add(extra);
      Tweening.Timeline timeline = new Tweening.Timeline.sequence();
      
      Tweening.Tween fadeIn = new Tweening.Tween.to(extra, TweenType.Alpha, 0.5);
      fadeIn.targetValues = [1.0];
      timeline.push(fadeIn);
      
      Tweening.Tween fadeOut = new Tweening.Tween.to(extra, TweenType.Alpha, 0.25);
      fadeOut.targetValues = [0.0];
      timeline.push(fadeOut);

      timeline.callback = (int type, Tweening.BaseTween source) {
        if( type == Tweening.TweenCallback.COMPLETE ) {
          this.stage.children.remove(extra);
          onComplete(false);
        }
      };


      this.tweenManager.add(timeline);
    } else if( delta.type == DeltaType.TAKE_DAMAGE ) {
      // take one damage
      this.hearts--;
      this.heartText.setText("$hearts");

      Tweening.Timeline timeline = new Tweening.Timeline.sequence();
      
      Tweening.Tween fadeIn = new Tweening.Tween.to(heartSprite, TweenType.Scale, 0.2);
      double scalex = heartSprite.scale.x;
      double scaley = heartSprite.scale.y;
      fadeIn.targetValues = [scalex * 2, scaley * 2];
      timeline.push(fadeIn);
      
      Tweening.Tween fadeOut = new Tweening.Tween.to(heartSprite, TweenType.Scale, 0.3);
      fadeOut.targetValues = [scalex, scaley];
      timeline.push(fadeOut);
      
      if( this.hearts == 0 ) {
        // flip him over
        Tweening.Tween flip = new Tweening.Tween.to(_displayObject, TweenType.Rotate, 0.3);
        flip.targetValues = [PI/2];
        timeline.push(flip);
        
      }
      
      timeline.callback = (int type, Tweening.BaseTween source) {
        if( type == Tweening.TweenCallback.COMPLETE ) {
          // TODO callback
          if( this.hearts == 0 ) {
            killTweens();
          }
          onComplete(false);
        }
      };
      
      AudioElement audio = document.querySelector("#hit1").clone(true);
      audio.play();
      
      tweenManager.add(timeline);
    } else if( delta.type == DeltaType.GAIN_GRAPPLE ) {
      this.grapples++;
      this.grappleText.setText("$grapples");
      onComplete(false);
    } else if( delta.type == DeltaType.LEAVE ) {
      Tweening.Tween exit = new Tweening.Tween.to(this._displayObject, TweenType.Alpha, 2);
      exit.targetValues = [0];
      tweenManager.add(exit);
      exit.callback = (int type, Tweening.BaseTween source) {
              if( type == Tweening.TweenCallback.COMPLETE ) {
                onComplete(false);
              }
            };
            
      Tweening.Tween exit2 = new Tweening.Tween.to(this._displayObject, TweenType.Scale, 2);
      exit2.targetValues = [0, 0];
      tweenManager.add(exit2);
      
      
    } else {
      if( delta.type == DeltaType.MOVE_GRAPPLE ) {
        this.grapples--;
        this.grappleText.setText("$grapples");
      }
      super.apply(delta, onComplete);      
    }
  }
}