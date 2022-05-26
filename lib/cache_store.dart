// Copyright (c) 2022, Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:hive_universal_cache/hive_universal_cache.dart';

import 'model/cache_type.dart';

/// TypeDef for invalidation function which you can pass in get method to run
/// while fetching data from cache in certain interval of time
///
/// [data] is the cached value that you will get for the [key]
/// It should return either updated value or,
/// null if nothing has changed.
typedef HasDataChanged<T> = Future<T?> Function(
    {required T data, required String key});

/// Object to access specific [CacheStore]
class CacheStore {
  /// Getting local reference of singleton Cache Registry instance
  final _registry = CacheTypeRegistry.instance;

  /// Cache Policy for the store
  final CachePolicy policy;

  /// [CacheStore] name to create multiple typeof cache
  final String name;

  /// Private reference for Hive Box
  late Box<ItemCache> _box;

  CacheStore({required this.name, required this.policy});

  /// Cache Store [init] function.
  ///
  /// Must be executed and, awaited before accessing data from store.
  init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemCacheAdapter());
    }

    _box = await Hive.openBox<ItemCache>("__cache__.$name");

    clearExpired();
  }

  /// [CacheStore] dispose function to close box once work is done
  dispose() async {
    await _box.close();
  }

  /// Returns the count of data stored in the cache
  Future<int> getLength() async {
    return _box.length;
  }

  /// It clears all the expired caches manually
  clearExpired() async {
    for (var item in _box.values) {
      if (item.expireOn.millisecondsSinceEpoch <=
          DateTime.now().millisecondsSinceEpoch) {
        delete(item.key);
      }
    }
  }

  /// Clear the box irrespective whether is expired or not.
  ///
  /// Avoid using it if not required
  clear() async {
    await _box.clear();
  }

  /// Delete a specific Cache
  delete(key) async {
    await _box.delete(_generateHiveKey(key));
  }

  /// Returns data from Hive based on [key]
  ///
  /// [cacheInvalidation] is the optional parameter.
  /// It gets executed after certain invalidationInterval which is defined
  /// at [policy]
  /// [cacheInvalidation] runs after returning the cached data.
  /// It will return the updated data the next time you will hit.
  Future<T?> get<T>(String key, {HasDataChanged<T>? cacheInvalidation}) async {
    final resolver = _getResolver<T>();
    final item = _box.get(_generateHiveKey(key));
    if (item != null) {
      if (item.expireOn.compareTo(DateTime.now()) > -1 && item.key == key) {
        _invalidateCache<T>(item, cacheInvalidation);
        return resolver.cacheDataToType(item.data);
      }
      delete(key);
    }
    return null;
  }

  CacheTypeResolver<T> _getResolver<T>() {
    final resolver = _registry.getResolver<T>();
    if (resolver == null) {
      throw UnimplementedError("${T} doesn't have any registry added");
    }
    return resolver;
  }

  /// Set data in Cache
  ///
  /// [key] will be used to fetch data back from cache.
  ///
  /// [data] which needs to be stored, it will be converted to Hive Format,
  /// based on [CacheTypeRegistry]
  set<T>(String key, T data, {Duration? expiryDuration}) async {
    final resolver = this._getResolver<T>();
    final currentEpoch = DateTime.now();
    final item = ItemCache(
      key: key,
      expireOn: currentEpoch.add(expiryDuration ?? policy.cacheDuration),
      data: _generateHiveData(resolver.type, data),
      lastValidated: currentEpoch,
    );
    _box.put(_generateHiveKey(key), item);
  }

  _generateHiveData(CacheType? cacheType, dynamic data) {
    switch (cacheType) {
      case CacheType.HiveType:
        return data;
      case CacheType.JSON:
      default:
        return jsonEncode(data);
    }
  }

  void _invalidateCache<T>(
      ItemCache item, HasDataChanged<T>? hasDataChanged) async {
    if (hasDataChanged != null &&
        item.lastValidated
                .add(policy.invalidationInterval)
                .compareTo(DateTime.now()) <
            1) {
      final resolver = _getResolver<T>();
      final updatedCache = await hasDataChanged(
          data: resolver.cacheDataToType(item.data), key: item.key);
      if (updatedCache == null) {
        _box.put(
            _generateHiveKey(item.key),
            ItemCache(
              lastValidated: DateTime.now(),
              key: item.key,
              expireOn: item.expireOn,
              data: item.data,
            ));
      } else {
        await this.set(item.key, updatedCache);
      }
    }
  }

  _generateHiveKey(String key) {
    final bytes = utf8.encode(key);
    return md5.convert(bytes).toString();
  }
}
