// Copyright (c) 2022, Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:hive/hive.dart';

import 'model/cache_type.dart';

/// TypeDef for json parsing to type function
typedef JSONParser<T> = T Function(Map<String, dynamic>);

/// TypeDef for Function to convert dynamic object retrieved to Types object
typedef _CacheDataToType<T> = T Function(dynamic);

/// Resolver Object for cache to Typed object based on type
class CacheTypeResolver<T> {
  /// Type of cache to execute specific logic
  final CacheType type;

  /// cache to object converter
  final _CacheDataToType<T> cacheDataToType;

  CacheTypeResolver({required this.type, required this.cacheDataToType});
}

/// A registry for keeping all cacheable model you want to keep.
class CacheTypeRegistry {
  /// Private [Map] to store all registry
  final Map<Type, CacheTypeResolver> _registry = {};

  /// Singleton instance for accessing registry ([CacheTypeRegistry])
  static CacheTypeRegistry instance = CacheTypeRegistry._();

  CacheTypeRegistry._();

  /// Returns resolver for cache based on type
  ///
  /// This must be used while retrieving cache in order to get Typed Object
  CacheTypeResolver<T>? getResolver<T>() {
    return this._registry[T] as CacheTypeResolver<T>?;
  }

  /// add Object Type to registry for parsing and, treating cache as JSON
  void registerJsonAdapter<T>(JSONParser<T> jsonParser) {
    this._registry[T] = CacheTypeResolver<T>(
        type: CacheType.JSON,
        cacheDataToType: (dynamic data) {
          return jsonParser(jsonDecode(data as String));
        });
  }

  /// add Object Type to registry for parsing and, treating cache as HiveType
  void registerHiveTypeAdapter<T>(TypeAdapter<T> typeAdapter) {
    if (!Hive.isAdapterRegistered(typeAdapter.typeId)) {
      Hive.registerAdapter(typeAdapter);
      this._registry[T] = CacheTypeResolver<T>(
          type: CacheType.HiveType,
          cacheDataToType: (dynamic data) => (data as T));
    }
  }
}
