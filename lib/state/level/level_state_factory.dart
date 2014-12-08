part of game;

class LevelStateFactory extends StateFactory<Game> {
  
  Random _random;
  int tileDimension;
  Tweening.TweenManager tweenManager;
  
  StateFactory<Game> menuStateFactory;
  
  LevelStateFactory(this._random, this.tileDimension, this.tweenManager) {
    
  }
  
  State createState(Game game) {
    
    
    HardCodedEntityRenderFactory entityRenderFactory = new HardCodedEntityRenderFactory(this.tileDimension, this.tweenManager, this._random);
    RenderFactory<Tile> tileRenderFactory = new HardCodedTileRenderFactory(this.tileDimension, this.tweenManager);
    
    EntityFactory entityFactory = (int movesTaken, int x, int y) {
      
      double top = (sqrt(movesTaken + 25.0) + game.depth);
      double bottom = sqrt(game.depth + 36.0);
      //print("$top vs $bottom");
      
      bool enemy = this._random.nextDouble() * top > bottom && this._random.nextInt(game.depth + 3) > 3;
      EntityType entityType;
      if( enemy ) {
        if( this._random.nextInt(game.depth + 1) > 2 && this._random.nextDouble() > 0.5  ) {
          entityType = EntityType.SPIKE_BLOCK;          
        } else {
          if( this._random.nextBool() && game.depth > 6 ) {
            entityType = EntityType.SPIDER;
          } else {
            entityType = EntityType.SNAKE;            
          }
        }
      } else {
        int type = this._random.nextInt(13);
        entityType = EntityType.DIRT;
        switch( type ) {
          case 1:
          case 5:
          case 9:
            entityType = EntityType.BLUE_STONE;
            break;
          case 2:
          case 6:
          case 10:
            entityType = EntityType.GREEN_STONE;
            break;
          case 3:
          case 7:
          case 11:
            entityType = EntityType.RED_STONE;
            break;
          case 0:
            entityType = EntityType.CRATE;
            break;
          default:
            entityType = EntityType.LADDER;
            break;
        }
        
      }
      return new Entity(entityType);
    };
        
    
    LevelState levelState = new LevelState(
        this._random, 
        game, 
        entityFactory, 
        tileDimension,
        tileRenderFactory, 
        entityRenderFactory,
        menuStateFactory,
        this, 
        tweenManager
      );
    entityRenderFactory.grappleCallback = levelState.grappleCallback;
    return levelState;
  }
  
  List<String> getAssetPaths() {
    
    List<String> assetPaths = [];
    List<String> entityAssetPaths = HardCodedEntityRenderFactory.getAssetPaths();
    List<String> tileAssetPaths =  HardCodedTileRenderFactory.getAssetPaths();
    assetPaths.addAll(entityAssetPaths);
    assetPaths.addAll(tileAssetPaths);
    return assetPaths;    
  }

  
}