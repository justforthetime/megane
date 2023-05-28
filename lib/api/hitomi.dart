import 'dart:developer';
import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

const domain = "https://ltn.hitomi.la";

Map<int, Gallery> galleryCache = {};

Future<List<int>> fetchNozomi(String url, [int? offset, int? length]) async {
  log('fetching url $url');
  http.Response res;
  if (offset != null && length != null) {
    res = await http.get(Uri.parse(url),
        headers: {"Range": 'bytes=$offset-${offset + length - 1}'});
  } else {
    res = await http.get(Uri.parse(url));
  }
  log('response status: ${res.statusCode}');
  ByteData byteData = ByteData.sublistView(res.bodyBytes);

  List<int> idList = [];
  var byteLength = byteData.lengthInBytes;
  log('byte length $length');
  for (var i = 0; i < byteLength; i += 4) {
    idList.add(byteData.getInt32(i, Endian.big));
  }
  log('id count ${idList.length}');

  return idList;
}

Future<List<int>> getIdListByTerm(String rawTerm) async {
  String term = rawTerm.replaceAll(RegExp(r'_'), " ");
  if (term.contains(':')) {
    final sides = term.split(':');
    final namespace = sides[0];
    final tag = sides[1];
    var url = "";

    if (namespace == "female" || namespace == "male" || namespace == "tag") {
      url = '$domain/tag/$term-all.nozomi';
    } else if (namespace == "artist") {
      url = '$domain/artist/$term-all.nozomi';
    } else if (namespace == "type") {
      url = '$domain/type/$term-all.nozomi';
    } else if (namespace == "language") {
      url = '$domain/index-$tag.nozomi';
    } else {
      throw Error();
    }

    final idList = await fetchNozomi(url);
    return idList;
  } else if (term.isEmpty) {
    var url = '$domain/index-all.nozomi';
    final idList = await fetchNozomi(url, 0, 100);
    return idList;
  } else {
    return [];
  }
}

Future<List<int>> getIdListByQuery(String rawQuery) async {
  final terms = rawQuery.trim().split(" ");
  List<String> positiveTerms = [], negativeTerms = [];

  if (terms.isEmpty) {
    final idSet = await getIdListByTerm("");
    return idSet;
  }

  terms.forEach((term) {
    term = term.replaceAll(RegExp(r'_'), " ");
    if (term.startsWith('-')) {
      term = term.substring(1);
      negativeTerms.add(term);
    } else {
      positiveTerms.add(term);
    }
  });

  Set<int> idSet = <int>{};
  await Future.wait(positiveTerms.map((String term) async {
    final termSet = await getIdListByTerm(term);
    termSet.forEach((id) => idSet.add(id));
  }));
  await Future.wait(negativeTerms.map((String term) async {
    final termSet = await getIdListByTerm(term);
    termSet.forEach((id) => idSet.remove(id));
  }));

  return idSet.toList();
}

class Tag {
  String name;
  String code;

  Tag(this.name, this.code);
}

class Gallery {
  int id;
  String title;
  String thumbnail;
  List<String> artists;
  List<String> series;
  String? type;
  Tag? language;
  List<Tag> characters;
  List<Tag> tags;

  Gallery._create(this.id, this.title, this.thumbnail, this.artists,
      this.series, this.type, this.language, this.tags, this.characters);

  static Future<Gallery> create(int id) async {
    if (galleryCache.containsKey(id)) {
      log('cache hit id: $id');
      return galleryCache[id]!;
    }

    log('fetching gallery id: $id');
    String uri = "https://ltn.hitomi.la/galleryblock/$id.html";
    final res = await http.get(Uri.parse(uri));
    final document = parse(res.body);

    final titleElement = document.querySelector("h1.lillie > a");
    if (titleElement == null) throw Error();
    final title = titleElement.text;

    final artists = document
        .querySelectorAll(".artist-list li > a")
        .map((elem) => elem.text)
        .toList();

    // TODO(jftt) parse thumbnail image

    final tableRows = document.querySelectorAll("tbody > tr");

    final series = tableRows[0]
        .querySelectorAll("li > a")
        .map((elem) => elem.text)
        .toList();

    final type = tableRows[1].querySelector("td > a")?.text;

    final languageElement = tableRows[2].querySelector("td > a");
    Tag? language;
    if (languageElement != null) {
      final languageText = languageElement.text;
      final languageCode = "";
      language = Tag(languageText, languageCode);
    }

    final tags = document.querySelectorAll("td.relatedtags li > a").map((elem) {
      final name = elem.text;
      final code = elem.attributes['href'];

      if (code == null) throw Error();
      return Tag(name, code);
    }).toList();

    var gallery = Gallery._create(
        id, title, "", artists, series, type, language, tags, []);

    galleryCache[id] = gallery;
    return gallery;
  }

  logInfo() {
    log('gallery info');
    log('id: $id, title: $title');
    log('type: $type, language: ${language?.name}');
    log('tags: ${tags.map((tag) => tag.name).join(", ")}');
  }
}
