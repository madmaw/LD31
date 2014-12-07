part of game;

typedef void GrappleCallback();

class LevelState extends State {
    
  Random _random;
  Game _game;
  EntityFactory _entityFactory;
  int _tileDimension;
  Level _level;
  
  List<Render> _allRenders;
  Map<Entity, Render> _entityRenders;
  
  RenderFactory<Tile> _tileRenderFactory;
  RenderFactory<Entity> _entityRenderFactory;
  
  StateFactory<Game> _menuStateFactory;
  StateFactory<Game> _nextLevelStateFactory;
  
  GrappleCallback grappleCallback;
  
  bool busy;
  
  LevelState(
      this._random, 
      this._game, 
      this._entityFactory, 
      this._tileDimension,
      this._tileRenderFactory, 
      this._entityRenderFactory,
      this._menuStateFactory,
      this._nextLevelStateFactory
      
  ): super() {
    grappleCallback = () {
      DeltaBlock deltaBlock = this._level.grapple();
      this.renderDeltaBlock(deltaBlock);
    };
  }
  
  void start() {
    super.start();
    int tilesAcross = this._renderer.view.width ~/ this._tileDimension;
    int tilesDown = (this._renderer.view.height ~/ this._tileDimension) - 1;
    
    this._level = new Level(
        this._random,
        this._game,        
        this._entityFactory,
        tilesAcross, 
        tilesDown,
        0,
        tilesDown - 1
    );
    this.busy = false;
    this.redraw();
    
    
  }
  
  void addListeners() {
    var onClick = (PIXI.InteractionEvent event) {
      // work out the column
      if( !busy ) {
        if( this._level.playerHasDied() ) {
          State state = this._menuStateFactory.createState(this._game);
          this._fireStateChange(state);
        } else {
          int column = event.x ~/ this._tileDimension;
          int row = event.y ~/ this._tileDimension;
          if( column >= 0 && column < this._level.tilesAcross && row >= 0 && row < this._level.tilesDown) {
            DeltaBlock deltaBlock = this._level.moveToColumn(column);
            
            if( deltaBlock != null ) {
              this.renderDeltaBlock(deltaBlock);        
            }        
          }                  
        }
      }
      //this.redraw();
    };
    // excepting these, touch events seem to be being ignored?
    this._stage.onMouseUp.listen(onClick);
    this._stage.onTouchEnd.listen(onClick);
  }
  
  void renderDeltaBlock(DeltaBlock deltaBlock) {
    if( deltaBlock != null ) {
      busy = true;
      List<Delta> deltas = deltaBlock.deltas;

      var renderDependencies = () {
        if( deltaBlock.dependantBlock != null ) {
          renderDeltaBlock(deltaBlock.dependantBlock);
        } else {
          // has the level ended?
          busy = false;
          
          if( this._level.playerHasDied() ) {
            // slap up some text
            PIXI.CanvasText text = new PIXI.CanvasText("GAME OVER", new PIXI.TextStyle(
                fill: new PIXI.Colour.fromHtml("#FFFFFF"),
                font: "bold ${_tileDimension}px Courier"
            ));
            text.position = new Point((this._renderer.view.width - text.width)/2, (this._renderer.view.height - text.height)/2);
            this._stage.children.add(text);
          } else if( this._level.playerHasExited() ) {
            // next game
            this._game.depth++;
            this._game.players.forEach((Player player) {
              player.health++;
            });
            State nextLevelState = this._nextLevelStateFactory.createState(this._game);
            this._fireStateChange(nextLevelState);
          } 
        }
      };
      
      if( deltas != null && deltas.length > 0 ) {
        int deltaCount = deltas.length;
        deltas.forEach((Delta delta) {        
          if( delta.entity != null ) {
            Render render = this._entityRenders[delta.entity];
            if( render == null ) {
              // need to create this renderer
              render = this._entityRenderFactory.createRender(delta.fromTile.x, delta.fromTile.y, delta.entity, this._renderer.view.width, this._renderer.view.height);
              this._entityRenders[delta.entity] = render;
              render.attach(this._stage, this._renderer.view.width, this._renderer.view.height);
            }
            render.apply(delta, (bool removeRender) {
              deltaCount--;
              if( removeRender ) {
                render.detach(this._stage);
                this._entityRenders.remove(delta.entity);
              }
              if( deltaCount == 0) {
                renderDependencies();
              }
            });              
          }
        });      
      } else {
        // immediately render the dependencies
        renderDependencies();
      }
      
    }
  }
  
  void redraw() {
    
    // clear existing renders
    if( this._allRenders != null ) {
      this._allRenders.forEach((Render render) {
        render.detach(this._stage);
      });      
    }    
    this._allRenders = [];
    this._entityRenders = {};
    
    this._stage = createStage();
    this.addListeners();
    
    // add all the tiles first
    for( int x=0; x<this._level.tilesAcross; x++ ) {
      for( int y=0; y<this._level.tilesDown; y++ ) {
        Tile tile = this._level.getTile(x, y);
        // get a display object for this tile 
        Render tileRender = this._tileRenderFactory.createRender(x, y, tile, this._renderer.view.width, this._renderer.view.height);
        this._allRenders.add(tileRender);
        tileRender.attach(this._stage, this._renderer.view.width, this._renderer.view.height);
      }
    }
    // then add in the entities
    for( int x=0; x<this._level.tilesAcross; x++ ) {
      for( int y=0; y<this._level.tilesDown; y++ ) {
        Tile tile = this._level.getTile(x, y);
        Entity entity = tile.entity;
        if( entity != null ) {
          // get a display object for this tile 
          Render entityRender = this._entityRenderFactory.createRender(x, y, entity, this._renderer.view.width, this._renderer.view.height);
          this._allRenders.add(entityRender);
          this._entityRenders[entity] = entityRender;
          entityRender.attach(this._stage, this._renderer.view.width, this._renderer.view.height);
        }
      }
    }
    this.render();
  }
  
  void stop() {
    
  }  
  
}