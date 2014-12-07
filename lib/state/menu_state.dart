part of game;

typedef void InteractionHandler(PIXI.InteractionEvent event); 

class MenuState extends State {
  
  StateFactory<Game> _levelStateFactory;
  PIXI.Texture _playButtonUpTexture;
  PIXI.Texture _playButtonHoverTexture;
  PIXI.Texture _playButtonDownTexture;
  
  MenuState(
      this._levelStateFactory,
      this._playButtonUpTexture,
      this._playButtonHoverTexture,
      this._playButtonDownTexture
  ) : super() {
    
  }
  
  start() {
    super.start();

    PIXI.Sprite playButton = new PIXI.Sprite(this._playButtonUpTexture);
    makeButton(
        playButton, 
        this._playButtonUpTexture, 
        this._playButtonHoverTexture, 
        this._playButtonDownTexture,
        (PIXI.InteractionEvent event) {
          List<Player> players = [];
          players.add(new Player(3, 4));
          Game game = new Game(players, 0); 
          var newState = this._levelStateFactory.createState(game);
          this._fireStateChange(newState);      
        }
    );
    
    playButton.position = new Point(
        (this._renderer.view.width - playButton.width)/2, 
        (this._renderer.view.height)/2 - (playButton.height)/2
    ); 
    this._stage.children.add(playButton);

    this.render();
    

  }
  
  stop() {
    
  }
  
  makeButton(PIXI.Sprite button, PIXI.Texture upTexture, PIXI.Texture hoverTexture, PIXI.Texture downTexture, InteractionHandler onClick) {
    var downListener = (PIXI.InteractionEvent event) {
      button.setTexture(downTexture);
      this._renderer.render(this._stage);
    };
    var hoverListener = (PIXI.InteractionEvent event) {
      button.setTexture(hoverTexture);
      this._renderer.render(this._stage);
    };
    var touchUpListener = (PIXI.InteractionEvent event) {
      button.setTexture(upTexture);
      this._renderer.render(this._stage);      
    };
    var mouseUpListener = (PIXI.InteractionEvent event){
      // check the event is actually in the sprite
      if( button.isOver ) {
        hoverListener(event);
      } else {
        touchUpListener(event);
      }
    };
    var mouseOutListener = (PIXI.InteractionEvent event) {
      if( !button.isDown ) {
        touchUpListener(event);        
      }
    };
    button.onMouseDown.listen(downListener);
    button.onMouseOver.listen(hoverListener);
    button.onMouseOut.listen(mouseOutListener);
    //button.onMouseUp.listen(upListener);
    button.onTouchStart.listen(downListener);
    //button.onTouchEnd.listen(upListener);
    button.onTap.listen(onClick);
    button.onClick.listen(onClick);
    this._stage.onMouseUp.listen(mouseUpListener);
    this._stage.onTouchEnd.listen(touchUpListener);
    
  }
  
}