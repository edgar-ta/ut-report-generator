abstract class Bloc<T> {
  T initialState;
  void Function(T Function(T)) setState;

  Bloc({required this.initialState, required this.setState});
}
