import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_universal_cache/hive_universal_cache.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

import 'hive_test_model.dart';

@JsonSerializable()
class TestModel {
  final String key;

  TestModel({required this.key});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(key: json["key"]);
  }

  Map<String, dynamic> toJson() {
    return {"key": key};
  }
}

@JsonSerializable()
class NestedTestModel {
  final String key;
  final TestModel testModel;

  NestedTestModel({required this.key, required this.testModel});

  factory NestedTestModel.fromJson(Map<String, dynamic> json) {
    return NestedTestModel(
        key: json["key"], testModel: TestModel.fromJson(json["testModel"]));
  }

  Map<String, dynamic> toJson() {
    return {"key": key, "testModel": testModel.toJson()};
  }
}

Future<TestModel?> invalidateCache(
    {required TestModel data, required String key}) async {
  return TestModel(key: "changed");
}

Future<TestModel?> invalidateCacheNoUpdate(
    {required TestModel data, required String key}) async {
  return null;
}

void main() async {
  await initTest();

  final store = CacheStore(name: "test", policy: CachePolicy.main);
  CacheTypeRegistry.instance
      .registerHiveTypeAdapter<HiveTestModel>(HiveTestModelAdapter());
  CacheTypeRegistry.instance.registerJsonAdapter<TestModel>(TestModel.fromJson);
  CacheTypeRegistry.instance
      .registerJsonAdapter<NestedTestModel>(NestedTestModel.fromJson);

  await store.init();

  test("failure on writing unknown types", () async {
    expect(
        () => store.get("test").catchError((err) {
              expect(err.message.contains("doesn't have any registry added"),
                  true);
              throw err;
            }),
        throwsUnimplementedError);
  });

  test("store clear", () async {
    await store.set<NestedTestModel>(
        "test", NestedTestModel(key: "key", testModel: TestModel(key: "test")));
    await store.set<NestedTestModel>("test1",
        NestedTestModel(key: "key", testModel: TestModel(key: "test")));
    await store.set<NestedTestModel>("test2",
        NestedTestModel(key: "key", testModel: TestModel(key: "test")));
    expect(await store.getLength(), 3);
    await store.clear();
    expect(await store.getLength(), 0);
  });

  test("nested model cache test", () async {
    await store.set<NestedTestModel>(
        "test", NestedTestModel(key: "key", testModel: TestModel(key: "test")));
    final data = (await store.get<NestedTestModel>("test"))!;
    expect(data.key, "key");
    expect(data.testModel.key, "test");
  });

  test('putting and, getting data from cache', () async {
    await store.set<TestModel>("test", TestModel(key: "test"));
    final data = await store.get<TestModel>("test");
    expect(data != null, true);
  });

  test('cache invalidation', () async {
    await store.set<TestModel>("test", TestModel(key: "test"));
    sleep(const Duration(seconds: 10));
    final data =
        await store.get<TestModel>("test", cacheInvalidation: invalidateCache);
    sleep(const Duration(seconds: 1));
    expect(data?.key, "test");
    final changedData =
        await store.get<TestModel>("test", cacheInvalidation: invalidateCache);
    expect(changedData!.key, "changed");
  });

  test('cache invalidation no update', () async {
    await store.set<TestModel>("test", TestModel(key: "test"));
    sleep(const Duration(seconds: 10));
    final data = await store.get<TestModel>("test",
        cacheInvalidation: invalidateCacheNoUpdate);
    sleep(const Duration(seconds: 1));
    expect(data?.key, "test");
    final newData = await store.get<TestModel>("test");
    expect(await store.getLength(), 1);
    expect(newData?.key, "test");
  });

  test('expired cache flushing', () async {
    await store.set<TestModel>("test", TestModel(key: "test"),
        expiryDuration: const Duration(seconds: 0));
    await store.clearExpired();
    expect(await store.getLength(), 0);
  });

  test('expired cache fetching', () async {
    await store.set<TestModel>("test", TestModel(key: "test"),
        expiryDuration: const Duration(seconds: 0));
    final cachedData = await store.get<TestModel>("test");
    expect(cachedData, null);
    expect(await store.getLength(), 0);
  });

  test('delete from cache', () async {
    await store.set<TestModel>("test", TestModel(key: "test"),
        expiryDuration: const Duration(seconds: 0));
    await store.delete("test");
    expect(await store.getLength(), 0);
  });

  test("test with custom hive model", () async {
    expect(Hive.isAdapterRegistered(1), true);
    await store.set<HiveTestModel>("test", HiveTestModel(key: "key"));
    final cachedData = await store.get<HiveTestModel>("test");
    expect(cachedData?.key, "key");
  });

  test("dispose and, init test", () async {
    await store.dispose();
    await store.init();
  });
}

initTest() async {
  Hive.init(".hive");
}
