// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.10

import 'package:test/test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';

void main() {
  test(
      "downgrades one locked hosted package's dependencies if it's "
      'necessary', () async {
    await servePackages((builder) {
      builder.serve('foo', '2.0.0', deps: {'foo_dep': 'any'});
      builder.serve('foo_dep', '2.0.0');
    });

    await d.appDir({'foo': 'any'}).create();

    await pubGet();

    await d.appPackagesFile({'foo': '2.0.0', 'foo_dep': '2.0.0'}).validate();

    globalPackageServer.add((builder) {
      builder.serve('foo', '1.0.0', deps: {'foo_dep': '<2.0.0'});
      builder.serve('foo_dep', '1.0.0');
    });

    await pubDowngrade(args: ['foo']);

    await d.appPackagesFile({'foo': '1.0.0', 'foo_dep': '1.0.0'}).validate();
  });
}
