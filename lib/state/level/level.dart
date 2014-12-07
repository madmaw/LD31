part of game;

typedef Entity EntityFactory(int movesTaken, int x, int y);

class Level {
  
  static final int MinMatchLength = 3; 
  
  Random _random;
  
  int tilesAcross;
  int tilesDown;
  int _movesTaken;
  int _currentPlayerIndex;
  int _nextEntityId;
  int exitColumn;
  
  List<List<Tile>> _tiles;
  Map<Player, Entity> _playerEntities;
  
  Game _game;
  EntityFactory _entityFactory;
  
  Level(
      this._random,
      this._game,
      this._entityFactory,
      this.tilesAcross, 
      this.tilesDown,
      int exitRow,
      int playerRow
  ) {
    this._tiles = new List<List<Tile>>(this.tilesAcross);
    this._movesTaken = 0;
    this._nextEntityId = 0;
    this._playerEntities = {};

    
    Map<int, Player> playerColumns = {};
    for( int i=0; i<this._game.players.length; i++ ) {
      Player player = this._game.players[i];
      bool done = false;
      while( !done && playerColumns.length != this._game.players.length ) {
        int column = this._random.nextInt(this.tilesAcross-1);    
        if( playerColumns[column] == null ) {
          playerColumns[column] = player;
          done = true;
        }
      }
    }
    exitColumn = this._random.nextInt(this.tilesAcross - 1);
    
    for( int x=0; x<this.tilesAcross; x++ ) {
      this._tiles[x] = new List<Tile>(this.tilesDown);
      for( int y=0; y<this.tilesDown; y++ ) {
        bool exit = y == exitRow && x == exitColumn;
        TileType tileType = TileType.BRICK;
        Tile tile = new Tile(x, y, tileType, exit);
        Entity entity = null;
        if( y == playerRow ) {
          Player player = playerColumns[x];
          if( player != null ) {
            // create a player entity
            entity = new PlayerEntity(player);
          }
          this._playerEntities[player] = entity;
        }
        if( entity == null && !exit ) {
          entity = this._entityFactory(0, x, y);
        }        
        tile.entity = entity;
        this._tiles[x][y] = tile;          
      }
    }
    this._currentPlayerIndex = 0;
    
    // TODO do until there are no changes
    this.applyMatches(null, null, false);
  }
  
  DeltaBlock grapple() {
    Player player = this._game.players[this._currentPlayerIndex];
    if( player.grapples > 0 ) {
      Tile playerTile = this._playerEntities[player].tile;
      Entity playerEntity = playerTile.entity;
      if( playerTile.y > 0 ) {
        Tile targetTile = this._tiles[playerTile.x][playerTile.y - 1];
        if( targetTile.entity != null ) {

          Entity targetEntity = targetTile.entity;
          targetTile.entity = playerEntity;
          playerTile.entity = targetEntity;

          Point from = new Point(playerTile.x, playerTile.y);
          Point to = new Point(playerTile.x, playerTile.y - 1);

          Delta playerDelta = new MoveDelta(DeltaType.MOVE_GRAPPLE, playerEntity, from, to);
          Delta targetDelta = new MoveDelta(DeltaType.MOVE_SWAP, targetEntity, to, from);

          List<Delta> deltas = [targetDelta, playerDelta];

          // check vertical movement
          // cascade changes (matches and gravity)
          // is there a ladder above?
          DeltaBlock consequences = climbOrFall(0, false);
          player.grapples --;
          return new DeltaBlock(deltas, consequences);
          
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
  
  DeltaBlock moveToColumn(int column) {
    // find the current player entity
    Player player = this._game.players[this._currentPlayerIndex];
    Tile playerTile = this._playerEntities[player].tile;
    if( playerTile.x != column ) {
      this._movesTaken++;
      Entity playerEntity = playerTile.entity;
      // get the target column
      int row = playerTile.y;
      Tile targetTile = this._tiles[column][row];
      
      Point from = new Point(playerTile.x, playerTile.y);
      Point to = new Point(column, playerTile.y);
      
      Entity targetEntity = targetTile.entity;
      targetTile.entity = playerEntity;
      
      Delta playerDelta = new MoveDelta(DeltaType.MOVE_SWAP, playerEntity, from, to);
      List<Delta> deltas = [playerDelta];
      bool forceGravity = false;
      if( targetEntity != null && targetEntity.type == EntityType.GRAPPLE ) {
        // did we collect a rope?
        playerTile.entity = null;
        player.grapples++;
        Delta grappleDelta = new Delta(DeltaType.GAIN_GRAPPLE, playerEntity, to);
        deltas.add(grappleDelta);
        Delta targetDelta = new Delta(DeltaType.DIE_COLLECTED, targetEntity, to);
        deltas.add(targetDelta);
        forceGravity = true;
      } else if( targetEntity != null && (targetEntity.type == EntityType.DIAMOND || targetEntity.type == EntityType.RUBY ) ) {
        playerTile.entity = null;
        int amount = targetEntity.type.monetaryValue.toInt();
        player.gold += amount;
        Delta goldDelta = new GainGoldDelta(DeltaType.GAIN_GOLD, playerEntity, to, amount, 1);
        deltas.add(goldDelta);
        Delta targetDelta = new Delta(DeltaType.DIE_COLLECTED, targetEntity, to);
        deltas.add(targetDelta);
        forceGravity = true;
      } else {
        playerTile.entity = targetEntity;
        if( targetEntity != null ) {
          Delta targetDelta = new MoveDelta(DeltaType.MOVE_SWAP, targetEntity, to, from);
          deltas.insert(0, targetDelta);
          // did we swap with a snake?
          if( targetEntity.type == EntityType.SNAKE ) {
            // bring the pain
            player.health--;
            deltas.add(new Delta(DeltaType.TAKE_DAMAGE, playerEntity, to));
          } 
          
        }        
      }
      
      // check vertical movement
      // cascade changes (matches and gravity)
      // is there a ladder above?
      DeltaBlock consequences = climbOrFall(0, forceGravity);
      DeltaBlock result = new DeltaBlock(deltas, consequences);
      if( this.playerHasExited() ) {
        // exit
        Tile exitTile = this._playerEntities[player].tile;
        Delta exitDelta = new Delta(DeltaType.LEAVE, playerEntity, new Point(exitTile.x, exitTile.y));
        result.appendDependantBlock(new DeltaBlock([exitDelta], null));
      }
      
      return result;
    } else {
      return null;
    }
  }
  
  bool playerHasDied() {
    Player player = this._game.players[this._currentPlayerIndex];
    return player.health <= 0;
  }
  
  bool playerHasExited() {
    Player player = this._game.players[this._currentPlayerIndex];
    Tile playerTile = this._playerEntities[player].tile;
    return playerTile.exit;
  }
  
  DeltaBlock climbOrFall(int multiplier, bool forceGravity) {
    Player player = this._game.players[this._currentPlayerIndex];
    Entity playerEntity = this._playerEntities[player];
    Tile playerTile = playerEntity.tile;
    int x = playerTile.x;
    int y = playerTile.y;
    
    bool done = false;
    int currentRow = y;
    DeltaBlock result = null;
    while( !done ) {
      bool wentUp = false;
      DeltaBlock next;
      if( currentRow > 0 ) {
        Tile tileAbove = this._tiles[x][currentRow -1];
        if( tileAbove.entity != null && tileAbove.entity.type == EntityType.LADDER ) {
          Entity ladderEntity = tileAbove.entity;
          // move up
          Point climbTo = new Point(x, currentRow-1);
          Point climbFrom = new Point(x, currentRow);
          Delta playerClimbDelta = new MoveDelta(DeltaType.MOVE_CLIMB, playerEntity, climbFrom, climbTo);
          Delta ladderDelta = new MoveDelta(DeltaType.MOVE_SWAP, ladderEntity, climbTo, climbFrom);
          
          tileAbove.entity = playerEntity;
          playerTile.entity = ladderEntity;
          playerTile = tileAbove;
          
          next = new DeltaBlock([ladderDelta, playerClimbDelta], null);
          currentRow--;
          wentUp = true;
        }
      }
      bool wentDown = false;
      if( !wentUp ) {
        // can we go down?
        if( currentRow < this.tilesDown - 1) {
          Tile tileBelow = this._tiles[x][currentRow + 1];
          if( tileBelow.entity != null && tileBelow.entity.type == EntityType.SNAKE ) {
            Entity snakeEntity = tileBelow.entity;
            // move down
            Point climbTo = new Point(x, currentRow+1);
            Point climbFrom = new Point(x, currentRow);
            Delta playerClimbDelta = new MoveDelta(DeltaType.MOVE_CLIMB, playerEntity, climbFrom, climbTo);
            Delta snakeDelta = new MoveDelta(DeltaType.MOVE_SWAP, snakeEntity, climbTo, climbFrom);
            
            tileBelow.entity = playerEntity;
            playerTile.entity = snakeEntity;
            playerTile = tileBelow;
            
            next = new DeltaBlock([snakeDelta, playerClimbDelta], null);
            currentRow++;
            wentDown = true;
          }
        }
      }
      if( !wentDown && !wentUp ) {
        done = true;
      }
      if( next != null ) {
        if( result == null ) {
          result = next;
        } else {
          result.appendDependantBlock(next);
        }
      }
    }

    var matches = applyMatches(multiplier, playerEntity, forceGravity);
    //var matches = climbOrFall();
    if( result == null ) {
      result = matches;
    } else {
      result.appendDependantBlock(matches);      
    }
    return result;
    
    
  }
  
  DeltaBlock applyMatches(int multiplier, PlayerEntity playerEntity, bool forceGravity) {
    // check all over for matches
    List<Delta> deltas = [];
    List<TileMatch> matches = [];
    for( int x=0; x< this.tilesAcross; x++ ) {
      for( int y=0; y< this.tilesDown; y++ ) {
        // check vertical
        Tile tile = this._tiles[x][y];
        if( tile.entity != null && tile.entity.type != EntityType.PLAYER ) {
          double baseVerticalValue = tile.entity.type.monetaryValue;
          double baseHorizontalValue = baseVerticalValue;
          // does the previous not match?
          // vertical matches
          bool firstVertical;
          if( y > 0 ) {
            Tile previousTile = this._tiles[x][y-1];
            firstVertical = previousTile.entity == null || tile.entity.type != previousTile.entity.type; 
          } else {
            firstVertical = true;
          }
          if( firstVertical ) {
            int length = 1;
            for( int iy=y + 1; iy<this.tilesDown; iy++ ){
              Tile nextTile = this._tiles[x][iy];
              
              if( nextTile.entity != null && nextTile.entity.type == tile.entity.type) {
                length++;
                baseVerticalValue += nextTile.entity.type.monetaryValue;
              } else {
                break;
              }
            }
            if( length >= MinMatchLength ) {
              matches.add(new TileMatch(x, y, length, true, baseVerticalValue, tile.entity.type));
            }
          }
          // horizontal matches
          bool firstHorizontal;
          if( x > 0 ) {
            Tile previousTile = this._tiles[x-1][y];
            firstHorizontal = previousTile.entity == null || tile.entity.type != previousTile.entity.type; 
          } else {
            firstHorizontal = true;
          }
          if( firstHorizontal ) {
            int length = 1;
            for( int ix=x + 1; ix<this.tilesAcross; ix++ ){
              Tile nextTile = this._tiles[ix][y];
              if( nextTile.entity != null && nextTile.entity.type == tile.entity.type) {
                baseHorizontalValue += nextTile.entity.type.monetaryValue;
                length++;
              } else {
                break;
              }
            }
            if( length >= MinMatchLength ) {
              matches.add(new TileMatch(x, y, length, false, baseHorizontalValue, tile.entity.type));
            }            
          }
        }
      }
    }
    if( multiplier != null ) {
      multiplier += matches.length;
    }
    int addedValue = 0;
    matches.forEach((TileMatch match) {
      for( int i=0; i<match.length; i++ ) {
        int x = match.x;
        int y = match.y;
        if( match.vertical ) {
          y += i;
        } else {
          x += i;
        }
        Tile tile = this._tiles[x][y];
        if( tile.entity != null ) {
          // disappear
          Point position = new Point(tile.x, tile.y);
          deltas.add(new Delta(DeltaType.DIE_MATCHED, tile.entity, position));
          // work out the accumulated score for the current player
          tile.entity = null;
        }
      }
      if( playerEntity != null && multiplier != null ) {
        int quantity = (multiplier * match.baseValue).toInt();
        int x = match.x;
        int y = match.y;
        if( match.vertical ) {
          y += match.length ~/ 2;
        } else {
          x += match.length ~/ 2;
        }
        Point position = new Point(x, y);
        if( quantity > 0 ) {
          deltas.add(new GainGoldDelta(DeltaType.GAIN_GOLD, playerEntity, position, quantity, multiplier));
          
        }
        // we..might want to spawn something here
        EntityType bonusType;
        if( match.entityType == EntityType.BLUE_STONE || match.entityType == EntityType.RED_STONE || match.entityType == EntityType.GREEN_STONE ) {
          bonusType = EntityType.DIAMOND;
        } else if( match.entityType == EntityType.CRATE ) {
          bonusType = EntityType.GRAPPLE;
        } else if( match.entityType == EntityType.SNAKE ) {
          bonusType = EntityType.RUBY;
        }
        if( bonusType != null && this._tiles[position.x][position.y].entity == null ) {
          double probability = match.length / 5;
          probability = probability * probability;
          if( this._random.nextDouble() < probability ) {
            // need a delta for this
            Entity bonusEntity = new Entity(bonusType);
            this._tiles[position.x][position.y].entity = bonusEntity;
            deltas.add(new Delta(DeltaType.REVEAL, bonusEntity, position));
          }
        }
        addedValue += quantity;
      }
      
    });
    if( playerEntity != null && multiplier != null ) {
      playerEntity.player.gold += addedValue;      
      if( multiplier > 1 && addedValue > 0 ) {
        deltas.add(new MultiplierDelta(DeltaType.MULTIPLIER, playerEntity, multiplier));        
      }
    }
    if( matches.length > 0 || forceGravity ) {
      DeltaBlock gravity = applyGravity(multiplier, playerEntity);
      return new DeltaBlock(deltas, gravity);          
    } else {
      return null;
    }
  }
  
  DeltaBlock applyGravity(int multiplier, PlayerEntity playerEntity) {
    List<Delta> deltas = [];
    for( int x=0; x<this.tilesAcross; x++ ) {
      int missingBlockCount = 0;
      for( int y=this.tilesDown; y>0; ) {
        y--;
        Tile tile = this._tiles[x][y];
        if( tile.entity == null ) {
          missingBlockCount++;
        } else if( missingBlockCount > 0 ) {
          Tile toTile = this._tiles[x][y+missingBlockCount];
          deltas.add(new MoveDelta(DeltaType.MOVE_FALL, tile.entity, new Point(x, y), new Point(x, y + missingBlockCount)));
          toTile.entity = tile.entity;
          tile.entity = null;
        }
      }
      // add in the missing blocks
      int i = 0;
      if( x == this.exitColumn ) {
        i = 1;
      }
      for( ; i<missingBlockCount; i++ ) {
        Tile toTile = this._tiles[x][i];
        var entity = this._entityFactory(this._movesTaken, x, i);
        deltas.add(new MoveDelta(DeltaType.MOVE_FALL, entity, new Point(x, i-missingBlockCount), new Point(x, i)));
        toTile.entity = entity;
      }
    }
    if( deltas.length > 0 ) {
      //DeltaBlock matches = applyMatches(multiplier, playerEntity);
      DeltaBlock matches = climbOrFall(multiplier, false);
      return new DeltaBlock(deltas, matches);    
    } else {
      return null;
    }
 
  }
  
  Tile getTile(int x, int y) {
    return this._tiles[x][y];
  }
  
}