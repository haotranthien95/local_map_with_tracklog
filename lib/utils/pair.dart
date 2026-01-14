class Pair<T, U> {
  final T _first;
  final U _second;

  const Pair(this._first, this._second);

  T get first => _first;
  U get second => _second;
}

class Tripple<T, U, V> {
  final T _first;
  final U _second;
  final V _third;

  const Tripple(this._first, this._second, this._third);

  T get first => _first;
  U get second => _second;
  V get third => _third;
}
