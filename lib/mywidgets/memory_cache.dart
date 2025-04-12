class MemoryCache<T> {
  final Map<String, T> _cache = {};

  void add(String key, T value) {
    _cache[key] = value;
  }

  // Update the get method to accept a type parameter
  V? get<V>(String key) {
    return _cache[key] as V?;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  Map<String, T> getAllEntries() {
    return Map<String, T>.from(_cache);
  }
}

// class MemoryCache<T> {
//   final Map<String, T> _cache = {};

//   void add(String key, T value) {
//     _cache[key] = value;
//   }

//   T? get(String key) {
//     return _cache[key];
//   }

//   void remove(String key) {
//     _cache.remove(key);
//   }

//   void clear() {
//     _cache.clear();
//   }
// }

// class MemoryCache {
//   final Map<String, dynamic> _cache = {};

//   void add(String key, dynamic value) {
//     _cache[key] = value;
//   }

//   dynamic get(String key) {
//     return _cache[key];
//   }

//   void remove(String key) {
//     _cache.remove(key);
//   }

//   void clear() {
//     _cache.clear();
//   }
// }
