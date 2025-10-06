abstract class Bloc<T> {
  T initialState;
  void Function(T Function(T)) setInitialState;

  Bloc({required this.initialState, required this.setInitialState});
}
