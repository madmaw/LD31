part of game;

class HardCodedEntityRenderFactory extends RenderFactory<Entity> {
  
  static final PathDirtBlock = "images/rocks.png";
  static final PathRedStoneBlock = "images/red_block.png";
  static final PathBlueStoneBlock = "images/blue_block.png";
  static final PathGreenStoneBlock = "images/green_block.png";
  static final PathLadder = "images/ladder.png";
  static final PathPlayer = "images/gnome.png";
  static final PathSnake = "images/snake.png";
  static final PathHeart = "images/heart.png";
  static final PathGrapple = "images/grapple.png";
  static final PathCrate = "images/crate.png";
  static final PathGold = "images/gold.png";
  static final PathDiamond = "images/diamond.png";
  static final PathRuby = "images/ruby.png";
  

  static List<String> getAssetPaths() {
    return [
            PathDirtBlock, 
            PathPlayer, 
            PathRedStoneBlock, 
            PathGreenStoneBlock, 
            PathBlueStoneBlock,
            PathLadder,
            PathSnake,
            PathHeart,
            PathGrapple,
            PathCrate,
            PathGold,
            PathDiamond,
            PathRuby
    ];
  }
  
  int tileDimension;
  Tweening.TweenManager tweenManager;
  GrappleCallback grappleCallback;
  Random random;
  
  HardCodedEntityRenderFactory(this.tileDimension, this.tweenManager, this.random) {
    
  }
  
  Render createRender(int tx, int ty, Entity object, int width, int height) {
    
    PIXI.Sprite sprite;
    if( object.type == EntityType.PLAYER ) {
      sprite = new PIXI.Sprite.fromImage(PathPlayer);
    } else if( object.type == EntityType.BLUE_STONE ) {
      sprite = new PIXI.Sprite.fromImage(PathBlueStoneBlock);
    } else if( object.type == EntityType.RED_STONE ) {
      sprite = new PIXI.Sprite.fromImage(PathRedStoneBlock);
    } else if( object.type == EntityType.GREEN_STONE ) {
      sprite = new PIXI.Sprite.fromImage(PathGreenStoneBlock);
    } else if( object.type == EntityType.LADDER ) {
      sprite = new PIXI.Sprite.fromImage(PathLadder);
    } else if( object.type == EntityType.SNAKE ) {
      sprite = new PIXI.Sprite.fromImage(PathSnake);
    } else if( object.type == EntityType.GRAPPLE ) {
      sprite = new PIXI.Sprite.fromImage(PathGrapple);
    } else if( object.type == EntityType.CRATE ) {
      sprite = new PIXI.Sprite.fromImage(PathCrate);
    } else if( object.type == EntityType.DIAMOND ) {
      sprite = new PIXI.Sprite.fromImage(PathDiamond);
    } else if( object.type == EntityType.RUBY ) {
      sprite = new PIXI.Sprite.fromImage(PathRuby);
    } else {
      sprite = new PIXI.Sprite.fromImage(PathDirtBlock);
    }
    sprite.position = new Point(tx * this.tileDimension + this.tileDimension/2, ty * this.tileDimension + this.tileDimension/2);
    sprite.anchor = new Point(0.5, 0.5);
    sprite.width = this.tileDimension;
    sprite.height = this.tileDimension;
    if( object.type == EntityType.PLAYER ) {
      PlayerEntity playerEntity = object;
      int score = playerEntity.player.gold;
      PIXI.Sprite heartSprite = new PIXI.Sprite.fromImage(PathHeart);
      heartSprite.width = tileDimension;
      heartSprite.height = tileDimension;
      heartSprite.anchor = new Point(0.5, 0.5);
      PIXI.Sprite grappleSprite = new PIXI.Sprite.fromImage(PathGrapple);
      grappleSprite.width = tileDimension;
      grappleSprite.height = tileDimension;
      PIXI.Sprite goldSprite = new PIXI.Sprite.fromImage(PathGold);
      goldSprite.width = tileDimension;
      goldSprite.height = tileDimension;
            
      return new PlayerRender(
          sprite, 
          this.tileDimension, 
          this.tweenManager,
          playerEntity.player.health,
          heartSprite, 
          score,
          goldSprite,
          playerEntity.player.grapples,
          grappleSprite,          
          grappleCallback, 
          random
      );
    } else {
      return new DisplayObjectRender(sprite, this.tileDimension, this.tweenManager);
    }
  }

}