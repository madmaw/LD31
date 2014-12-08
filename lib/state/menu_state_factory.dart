part of game;

class MenuStateFactory extends StateFactory<Game> {
  
  static final PathPlayButtonUp = "images/playbutton_normal.png";
  static final PathPlayButtonDown = "images/playbutton_down.png";
  static final PathPlayButtonHover = "images/playbutton_hover.png";
  
  StateFactory _gameStateFactory;
  
  MenuStateFactory(this._gameStateFactory) {
    
  }
  
  State createState(Game parameter) {
    
    // TODO show results of previous game (if any)
    
    PIXI.Texture playButtonUp = new PIXI.Texture.fromImage(PathPlayButtonUp);
    PIXI.Texture playButtonDown = new PIXI.Texture.fromImage(PathPlayButtonDown);
    PIXI.Texture playButtonHover = new PIXI.Texture.fromImage(PathPlayButtonHover);
    return new MenuState(
        this._gameStateFactory,
        playButtonUp, 
        playButtonHover, 
        playButtonDown,
        parameter
    );
  }
  
  List<String> getAssetPaths() {
    return [PathPlayButtonUp, PathPlayButtonDown, PathPlayButtonHover];
  }
  
}