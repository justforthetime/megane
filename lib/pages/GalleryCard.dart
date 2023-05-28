import 'package:flutter/material.dart';
import 'package:mymega/api/hitomi.dart';

class GalleryCard extends StatefulWidget {
  const GalleryCard({super.key, required this.id});

  final int id;

  @override
  _GalleryCardState createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  late Future<Gallery> futureGallery;

  @override
  void initState() {
    super.initState();
    futureGallery = Gallery.create(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureGallery,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final gallery = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(gallery.title)],
          );
        } else {
          return const Text("loading");
        }
      },
    );
  }
}
