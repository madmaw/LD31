// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:LD31/game.dart';

void main() {
  CanvasElement canvas = querySelector('#canvas');
  var resizeCanvas = (event) {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    startGame(canvas);
  };
  window.onResize.listen(resizeCanvas);
  resizeCanvas(null);
}

