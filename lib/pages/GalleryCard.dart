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
          return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 210, color: Colors.amber),
                  Container(width: 10),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gallery.title,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          gallery.artist ?? "",
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.left,
                        ),
                        Container(
                          height: 10,
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: gallery.tags
                              .map((tag) => Chip(
                                    padding: const EdgeInsets.all(1.0),
                                    label: Text(tag.name),
                                  ))
                              .toList(),
                        )
                      ],
                    ),
                  )
                ],
              ));
        } else {
          return Container(
            height: 210,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
