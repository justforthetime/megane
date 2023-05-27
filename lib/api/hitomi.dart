import 'dart:developer';
import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

const domain = "https://ltn.hitomi.la";

Future<List<int>> fetchNozomi(String url) async {
  log('fetching url $url');
  var res = await http.get(Uri.parse(url));
  log('response status: ${res.statusCode}');
  ByteData byteData = ByteData.sublistView(res.bodyBytes);

  List<int> idList = [];
  var length = byteData.lengthInBytes;
  log('byte length $length');
  for (var i = 0; i < length; i += 4) {
    idList.add(byteData.getInt32(i, Endian.big));
  }
  log('id count ${idList.length}');

  return idList;
}

Future<Set<int>> getIdListByTerm(String rawTerm) async {
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
    return Set.from(idList);
  } else {
    return Set();
  }
}

Future<Set<int>> getIdListByQuery(String rawQuery) async {
  final terms = rawQuery.split(" ");
  List<String> positiveTerms = [], negativeTerms = [];

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

  return idSet;
}

class Tag {
  String name;
  String code;

  Tag(this.name, this.code);
}

class Gallery {
  int id;
  String title;
  List<String> artists;
  List<String> series;
  String? type;
  Tag? language;
  List<Tag> characters;
  List<Tag> tags;

  Gallery._create(this.id, this.title, this.artists, this.series, this.type,
      this.language, this.tags, this.characters);

  static Future<Gallery> create(int id) async {
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

    var gallery =
        Gallery._create(id, title, artists, series, type, language, tags, []);

    return gallery;
  }

  logInfo() {
    log('gallery info ===========');
    log('id: $id, title: $title');
    log('type: $type, language: ${language?.name}');
    log('tags: ${tags.map((tag) => tag.name).join(", ")}');
  }
}
