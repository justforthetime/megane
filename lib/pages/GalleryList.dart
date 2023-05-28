import 'package:flutter/material.dart';
import 'package:mymega/api/hitomi.dart';
import 'package:mymega/pages/GalleryCard.dart';

class GalleryList extends StatefulWidget {
  const GalleryList({super.key, required this.galleryIdList});

  final List<int> galleryIdList;

  @override
  _GalleryListState createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // TODO(jftt) incremental loading
      cacheExtent: 100.0,
      itemCount: widget.galleryIdList.length,
      itemBuilder: (context, index) =>
          GalleryCard(id: widget.galleryIdList[index]),
    );
  }
}
