// Copyright (c) 2022, Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hive_universal_cache/hive_universal_cache.dart';

/// This store format of data that we are trying to store.
///
/// Only used while model type adding it to [CacheTypeRegistry]
enum CacheType {
  /// [JSON] for the data models which support standard dart JSON parsing.
  JSON,

  /// [HiveType] for the data models which has Hive Type Adapter written.
  HiveType,
}
