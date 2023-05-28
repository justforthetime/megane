import 'package:flutter/material.dart';
import 'package:mymega/api/hitomi.dart';
import 'package:mymega/pages/GalleryList.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<int>> futureIdList;

  @override
  void initState() {
    super.initState();
    futureIdList = getIdListByQuery("language:korean");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: futureIdList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GalleryList(galleryIdList: snapshot.data!);
            } else {
              return const Text("loading");
            }
          },
        ),
      ),
    );
  }
}
