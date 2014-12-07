part of game;

class HardCodedTileRenderFactory extends RenderFactory<Tile> {
  
  static final PathNormalTile = "images/background1.png";
  static final PathDoorFrame = "images/doorframe.png";

  static List<String> getAssetPaths() {
    return [PathNormalTile, PathDoorFrame];
  }
  
  int tileDimension;
  Tweening.TweenManager tweenManager;
  
  HardCodedTileRenderFactory(this.tileDimension, this.tweenManager) {
    
  }
  
  Render createRender(int tx, int ty, Tile object, int width, int height) {
    // everything is a dirt block
    PIXI.Sprite sprite = new PIXI.Sprite.fromImage(PathNormalTile);
    sprite.width = this.tileDimension;
    sprite.height = this.tileDimension;
    
    // add in the door frame if it's the exit
    PIXI.DisplayObject displayObject;
    if( object.exit ) {
      PIXI.DisplayObjectContainer container = new PIXI.DisplayObjectContainer();
      container.children.add(sprite);
      
      PIXI.Sprite door = new PIXI.Sprite.fromImage(PathDoorFrame);
      door.width = this.tileDimension;
      door.height = this.tileDimension;
      container.children.add(door);
      
      displayObject = container;
    } else {
      displayObject = sprite;
    }
    displayObject.position = new Point(tx * this.tileDimension, ty * this.tileDimension);
    
    return new DisplayObjectRender(displayObject, this.tileDimension, this.tweenManager);
  }
  
}