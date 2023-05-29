import 'dart:developer';

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
  late List<int> _galleryIdList;

  @override
  void initState() {
    super.initState();
    _galleryIdList = widget.galleryIdList.sublist(0, 10);
  }

  void fetchGallery() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      setState(() {
        final length = _galleryIdList.length;
        _galleryIdList
            .addAll(widget.galleryIdList.sublist(length, length + 10));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        cacheExtent: 100.0,
        itemCount: _galleryIdList.length,
        itemBuilder: (context, index) {
          if (index == _galleryIdList.length - 3) {
            fetchGallery();
            log("hi");
          }
          return GalleryCard(id: widget.galleryIdList[index]);
        });
  }
}
