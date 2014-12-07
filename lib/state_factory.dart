part of game;

abstract class StateFactory<StateParameterType> {
  
  State createState(StateParameterType parameter);
  
  List<String> getAssetPaths();
  
}