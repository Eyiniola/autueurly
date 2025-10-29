import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String? description;
  const ImageViewerPage({super.key, required this.imageUrl, this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: description != null && description!.isNotEmpty
            ? Text(description!, style: TextStyle(fontSize: 14))
            : null,
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          loadingBuilder: (context, event) =>
              Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) =>
              Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
    );
  }
}
