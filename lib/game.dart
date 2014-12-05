// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library game;

import 'dart:html';

startGame(CanvasElement canvas) {
  CanvasRenderingContext2D context = canvas.getContext('2d');
  // do your thing
  context.fillStyle = '#FF0000';
  context.fillRect(0, 0, canvas.width, canvas.height);
}
