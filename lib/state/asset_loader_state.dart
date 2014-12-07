part of game;

class AssetLoaderState extends State {
  
  List<String> _assets;
  StateFactory<Object> _nextStateFactory;
  
  AssetLoaderState(this._assets, this._nextStateFactory): super() {
    
  }
  
  start() {
    super.start();
    PIXI.AssetLoader assetLoader = new PIXI.AssetLoader(this._assets);
    PIXI.CanvasText progressText = new PIXI.CanvasText(
        "0%", 
        new PIXI.TextStyle(
            fill: new PIXI.Colour.fromHtml("#AAAAAA"),
            align: PIXI.TextStyle.CENTRE,
            
            font: 'bold 60px Courier'
        )
    );
    progressText.position = new Point(
        this._renderer.view.width / 2 - progressText.width/2, 
        this._renderer.view.height / 2 - progressText.height/2
    );
    this._stage.children.add(progressText);
    this._renderer.render(this._stage);
    
    assetLoader.onComplete.forEach((x) {
      State nextState = this._nextStateFactory.createState(null);
      this._fireStateChange(nextState);
    });
    assetLoader.onProgress.forEach((double progress) {
      progressText.setText((progress * 100).toInt().toString() + "%");
      this._renderer.render(this._stage);
    });
    assetLoader.load();
  }
  
  stop() {
    
  }
  
}