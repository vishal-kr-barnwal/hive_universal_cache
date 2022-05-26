// Copyright (c) 2022, Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hive_universal_cache/hive_universal_cache.dart';

class CachePolicy {
  /// Default [CachePolicy], having [cacheDuration] = 5 min,
  /// [invalidationInterval] = 10 sec
  static final CachePolicy main = CachePolicy(
      cacheDuration: const Duration(minutes: 5),
      invalidationInterval: const Duration(seconds: 10));

  /// This define after how much time cache will get expire
  final Duration cacheDuration;

  /// This define at what interval [HasDataChanged] logic needs to be executed
  final Duration invalidationInterval;

  CachePolicy(
      {required this.cacheDuration, required this.invalidationInterval});
}
