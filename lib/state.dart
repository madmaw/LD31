part of game;

typedef void StateChangeListener(State source, State newState);

abstract class State {
  
  List<StateChangeListener> _changeListeners;
  PIXI.Renderer _renderer;
  PIXI.Stage _stage;
  Tweening.TweenManager _tweenManager;
  
  State() {
    this._changeListeners = [];
  }
  
  addChangeListener(StateChangeListener changeListener) {
    this._changeListeners.add(changeListener);
  }
  
  removeChangeListener(StateChangeListener changeListener) {
    // this works?
    this._changeListeners.remove(changeListener);
  }
  
  _fireStateChange(State newState) {
    for( int i=this._changeListeners.length; i>0 ; ) {
      i--;
      StateChangeListener changeListener = this._changeListeners[i];
      changeListener(this, newState);      
    }
  }
  
  void init(PIXI.Renderer renderer, Tweening.TweenManager tweenManager) {
    this._renderer = renderer;
    this._tweenManager = tweenManager;
  }
  
  void start() {
    this._stage = createStage();   
  }
  
  createStage() {
    return new PIXI.Stage(new PIXI.Colour.fromHtml("#000"));    
  }
  
  void stop();
  
  void destroy() {
    
  }
  
  void render() {
    this._renderer.render(this._stage);
  }
  
  void resized() {
    this.stop();
    this.start();
  }

}

