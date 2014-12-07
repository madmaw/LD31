part of game;

typedef DeltaRenderCompletionCallback(bool removeRenderer);

abstract class Render {
  
  attach(PIXI.Stage stage, int width, int height);
  
  detach(PIXI.Stage stage);
  
  apply(Delta delta, DeltaRenderCompletionCallback onComplete);
  
}