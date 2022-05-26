// Copyright (c) 2022, Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_cache.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)

/// Wrapper object for storing data in Hive.
class ItemCache {
  /// [expireOn] field store when [ItemCache] is going to expire.
  @HiveField(0)
  final DateTime expireOn;

  /// [lastValidated] field store when [ItemCache] was last validated.
  @HiveField(1)
  DateTime lastValidated;

  /// [key] required for resolving Hash Collisions
  ///
  /// Hash Collision can happen as we are storing in [Hive] using md5(key)
  @HiveField(2)
  final String key;

  /// [data] contains what info we stored
  @HiveField(3)
  final dynamic data;

  ItemCache({
    required this.lastValidated,
    required this.key,
    required this.expireOn,
    required this.data,
  });
}
