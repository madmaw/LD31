part of game;

abstract class RenderFactory<ObjectType> {
  
  Render createRender(int tx, int ty, ObjectType object, int width, int height);
  
}