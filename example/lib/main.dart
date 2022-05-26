import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_universal_cache/hive_universal_cache.dart';
import 'package:hive_universal_cache_example/json_cache.dart';

Future<JsonTestModel?> hasDataChanged(
    {required JsonTestModel data, required String key}) async {
  if (data.key == "data") {
    return JsonTestModel(key: "changed");
  }
  return null;
}

setAndGetExampleWithInvalidation(CacheStore store) async {
  await store.set<JsonTestModel>("key", JsonTestModel(key: "data"));
  sleep(Duration(seconds: 1));
  var testModel =
      await store.get<JsonTestModel>("key", cacheInvalidation: hasDataChanged);
  print(testModel!.key);
  testModel = await store.get<JsonTestModel>("key");
  print(testModel!.key);
}

setAndGetExample(CacheStore store) async {
  // Simple set and, get
  await store.set<JsonTestModel>("key", JsonTestModel(key: "data"));
  final testModel = await store.get<JsonTestModel>("key");

  // should return data stored in cache
  print(testModel!.key);

  // wait for cache to be expired
  sleep(Duration(seconds: 5));

  // should return null as cache is expired
  print(await store.get<JsonTestModel>("key"));
}

void main() async {
  /// Initialize [Hive]
  Hive.init(".hive");

  /// Register models in [CacheTypeRegistry]
  CacheTypeRegistry.instance.registerJsonAdapter(JsonTestModel.fromJson);
  final store = CacheStore(
      name: "test",
      policy: CachePolicy(
          cacheDuration: Duration(seconds: 5),
          invalidationInterval: Duration(seconds: 1)));
  await store.init();

  await setAndGetExample(store);

  await setAndGetExampleWithInvalidation(store);
}
