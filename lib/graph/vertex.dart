import 'dart:collection';

/// A vertex of a [Graph]. A vertex contains a `key` uniquely identifying it.
/// Value is optional, it is used when complex data structure may be attached to
/// the vertex. By default, the `key` and `value` are the same.
class Vertex<T> {
  final String _key;
  bool _isLocked;

  /// Uniquely identifiable key to this [Vertex]
  String get key => _key;

  /// Optional value
  T value;

  final LinkedHashSet<Vertex> _incomingVertices;

  /// Incoming connections from this [Vertex]
  List<Vertex> get incomingVertices =>
      List<Vertex>.unmodifiable(_incomingVertices);

  final LinkedHashMap<Vertex, num> _outgoingConnections;

  /// Outgoing connections from this [Vertex]
  UnmodifiableMapView<Vertex, num> get outgoingConnections =>
      Map<Vertex, num>.unmodifiable(_outgoingConnections);

  /// Constructor
  Vertex(this._key, [T value])
      : _isLocked = true,
        _incomingVertices = <Vertex>{} as LinkedHashSet,
        _outgoingConnections = <Vertex, num>{} as LinkedHashMap {
    this.value = value ?? key;
  }

  void lock() => _isLocked = true;
  void unlock() => _isLocked = false;

  /// Adds a connection with [Vertex] `dst` and with `weight`
  bool addConnection(Vertex dst, [num weight = 1]) {
    if (_isLocked || dst._isLocked)
      throw UnsupportedError('Cannot add to a locked vertex');
    if (_outgoingConnections.containsKey(dst)) {
      return false;
    }
    _outgoingConnections[dst] = weight;
    dst._incomingVertices.add(this);
    return true;
  }

  /// Removes a connection with `other` with `weight`. `false` for non-existent
  /// connection.
  bool removeConnection(Vertex other, [num weight = 1]) {
    if (_isLocked || other._isLocked)
      throw UnsupportedError('Cannot remove from a locked vertex');
    var outgoingRemoved = _outgoingConnections.remove(other) != null;
    var incomingRemoved = other._incomingVertices.remove(this);

    return outgoingRemoved && incomingRemoved;
  }

  /// Checks if [Vertex] `other` is connected to this vertex
  bool containsConnectionTo(Vertex other) =>
      _outgoingConnections.containsKey(other);

  /// Checks if [Vertex] `other` is connected to this vertex
  bool containsConnectionFrom(Vertex other) =>
      _incomingVertices.contains(other);

  /// Get a list of adjacent outgoing vertices
  Set<Vertex> get outgoingVertices =>
      _outgoingConnections.keys.map((connection) => connection).toSet();

  /// Is this vertex isolated?
  bool get isIsolated => _outgoingConnections.isEmpty;

  /// Calculate the inDegree of the vertex
  int get inDegree => _incomingVertices.length;

  /// Calculate the outDegree of the vertex
  int get outDegree => _outgoingConnections.length;

  @override
  String toString() => key;
}
