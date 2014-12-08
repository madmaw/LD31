// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';

import 'package:tweenengine/tweenengine.dart' as Tweening;
import 'package:pixi/pixi.dart' as PIXI;

import 'package:LD31/game.dart';

void main() {
  // TODO pick best renderer
  PIXI.Renderer renderer;
  try {
    renderer = new PIXI.WebGLRenderer(
        width: window.innerWidth, 
        height: window.innerHeight,
        interactive: true
    );
  } catch ( e ) {
    renderer = new PIXI.CanvasRenderer(
        width: window.innerWidth, 
        height: window.innerHeight,
        interactive: true
    );
  }
  document.body.append(renderer.view);
  
  // LOL, only works on startup, subsequent resizes will look shit
  int tileDimension = min( window.innerWidth ~/ 9, window.innerHeight ~/ 9);
  
  Tweening.Tween.registerAccessor(PIXI.Sprite, new DisplayObjectAccessor());  
  Tweening.Tween.registerAccessor(PIXI.CanvasText, new DisplayObjectAccessor());  
  Tweening.TweenManager tweenManager = new Tweening.TweenManager();
  State state;
  num lastUpdate = 0;
  var update;
  update = (num delta){
    num deltaTime = (delta - lastUpdate) / 1000;
    lastUpdate = delta;
    tweenManager.update(deltaTime);
    state.render();
    window.animationFrame.then(update);
  };

  List<String> assetURLs = [];
  Random random = new Random();
  LevelStateFactory levelStateFactory = new LevelStateFactory(random, tileDimension, tweenManager);
  MenuStateFactory menuStateFactory = new MenuStateFactory(levelStateFactory);
  levelStateFactory.menuStateFactory = menuStateFactory;
  assetURLs.addAll(menuStateFactory.getAssetPaths());
  assetURLs.addAll(levelStateFactory.getAssetPaths());

  state = new AssetLoaderState(assetURLs, menuStateFactory);
  
  var resizeRenderer = (Event event) {
    renderer.resize(window.innerWidth, window.innerHeight);
    // restart the current state
    state.resized();
  };
  
  window.onResize.listen(resizeRenderer);
  window.animationFrame.then(update);
  
  var stateChanged;
  stateChanged = (State oldState, State newState) {
    if( state == oldState ) {
      if( state != null ) {
        state.stop();
        state.destroy();
        state.removeChangeListener(stateChanged);
      }
      state = newState;
      if( state != null ) {
        state.addChangeListener(stateChanged);
        state.init(renderer, tweenManager);
        state.start();      
      }      
    }
  };
  
  state.addChangeListener(stateChanged);
  state.init(renderer, tweenManager);
  state.start();

}

