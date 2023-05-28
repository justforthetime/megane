import 'dart:developer';

import 'package:mymega/api/hitomi.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  test("getIdListByQuery()", () async {
    // var query = "language:korean -female:loli";
    var query = " ";
    final idSet = await getIdListByQuery(query);
    log('${idSet.length}');
  });

  test("http get", () async {
    final res = await http.get(Uri.parse("https://google.com"));
    log('${res.bodyBytes.lengthInBytes}');
  });

  test("gallery info", () async {
    var query = "language:korean -female:loli";
    final idSet = await getIdListByQuery(query);
    final gallery = await Gallery.create(idSet.first);
    gallery.logInfo();
  });
}
