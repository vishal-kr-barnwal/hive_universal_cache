<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A general framework for caching dart object model in Hive.

## Features

This package currently support *JSON parsable* objects and, Hive types.

It has a background Cache Invalidation support at the time of fetching the data.

It also implements TTL in over the Hive framework.

## Getting started

To start using the package go through [Hive basics](https://pub.dev/packages/hive)

To utilize this package **register your data models** before initializing the Cache Store.
Also, don't forget to initialize *Hive* beforehand.

## Usage

1. Initializing store JSON Parsable Object and, Hive Typed Object.

```dart
import 'package:hive_universal_cache/hive_universal_cache.dart';
final store = CacheStore(name: "test", policy: CachePolicy.main);
CacheTypeRegistry.instance.registerJsonAdapter<TestModel>(TestModel.fromJson);
CacheTypeRegistry.instance.registerHiveTypeAdapter<HiveTestModel>(HiveTestModelAdapter());
store.init();
```

2. Set and, Get example
```dart
await store.set<TestModel>("test", TestModel(key: "test"));
final data = await store.get<TestModel>("test");
```

For more detailed examples, kindly go to
[Examples](https://github.com/Vishal07051999/hive_universal_cache/tree/main/example)

## Additional information

This package is just on the initial phase, next inclusions will be :
1. Wrapper over [http](https://pub.dev/packages/http) to directly put cacheable content.
2. Adding support for Images and, Files.
