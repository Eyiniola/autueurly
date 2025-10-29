import 'package:auteurly/core/widgets/image_viewer_page.dart';
import 'package:auteurly/core/widgets/video_player_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // To launch URLs
import 'dart:io'; // For File check if using video_thumbnail File output
import 'package:video_thumbnail/video_thumbnail.dart'; // For video thumbnails

class ProjectGalleryPage extends StatefulWidget {
  final List<Map<String, dynamic>> galleryItems;
  final String userName;

  const ProjectGalleryPage({
    super.key,
    required this.galleryItems,
    required this.userName,
  });

  @override
  State<ProjectGalleryPage> createState() => _ProjectGalleryPageState();
}

class _ProjectGalleryPageState extends State<ProjectGalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _mediaItems;
  late List<Map<String, dynamic>> _documentItems;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _mediaItems = widget.galleryItems
        .where((item) => item['type'] == 'image' || item['type'] == 'video')
        .toList();
    _documentItems = widget.galleryItems
        .where((item) => item['type'] == 'pdf' || item['type'] == 'other')
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Navigation Helpers ---
  void _openImageViewer(String imageUrl, String? description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ImageViewerPage(imageUrl: imageUrl, description: description),
      ),
    );
  }

  void _openVideoPlayer(String videoUrl, String? description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VideoPlayerPage(videoUrl: videoUrl, description: description),
      ),
    );
  }

  // Future<void> _openPdfViewer(String pdfUrl, String? description) async {
  //    // Requires flutter_pdfview and native setup
  //    // You might need to download the PDF first or use its URL directly
  //    Navigator.push(context, MaterialPageRoute(
  //       builder: (_) => PdfViewerPage(pdfUrl: pdfUrl, description: description),
  //    ));
  // }

  Future<void> _launchExternalUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file/link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: Text("${widget.userName}'s Gallery"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFA32626),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'MEDIA'),
            Tab(text: 'DOCUMENTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMediaGrid(), _buildDocumentsList()],
      ),
    );
  }

  Widget _buildMediaGrid() {
    if (_mediaItems.isEmpty) {
      /* ... Empty state ... */
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _mediaItems.length,
      itemBuilder: (context, index) {
        return _buildGalleryItem(_mediaItems[index]);
      },
    );
  }

  Widget _buildDocumentsList() {
    if (_documentItems.isEmpty) {
      /* ... Empty state ... */
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _documentItems.length,
      itemBuilder: (context, index) {
        return _buildGalleryItem(_documentItems[index], isListItem: true);
      },
    );
  }

  Widget _buildGalleryItem(
    Map<String, dynamic> item, {
    bool isListItem = false,
  }) {
    final String type = item['type'] ?? 'other';
    final String url = item['storageUrl'] ?? '';
    final String description = item['description'] ?? '';
    final String fileName = Uri.decodeComponent(
      Uri.parse(url).pathSegments.last,
    ); // Decode filename

    Widget content;
    IconData listIcon = Icons.insert_drive_file; // Default for list

    // --- Build Content based on type ---
    if (type == 'image') {
      listIcon = Icons.image;
      content = Image.network(
        url,
        fit: BoxFit.cover /* Add loading/error builders */,
      );
    } else if (type == 'video') {
      listIcon = Icons.videocam;
      // Use FutureBuilder to generate and display thumbnail
      content = FutureBuilder<String?>(
        future: VideoThumbnail.thumbnailFile(
          video: url,
          imageFormat: ImageFormat.JPEG,
          quality: 30,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return Stack(
              // Overlay play icon on thumbnail
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Image.file(File(snapshot.data!), fit: BoxFit.cover),
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white70,
                  size: 40,
                ),
              ],
            );
          }
          // Show placeholder while loading or if error
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
                size: 40,
              ),
            ),
          );
        },
      );
    } else if (type == 'pdf') {
      listIcon = Icons.picture_as_pdf;
      content = Container(/* ... PDF Icon Placeholder ... */);
    } else {
      // 'other'
      listIcon = Icons.attach_file;
      content = Container(/* ... File Icon Placeholder ... */);
    }

    // --- Return ListTile or Card ---
    if (isListItem) {
      // Documents Tab
      return Card(
        color: Colors.grey[850],
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          leading: Icon(listIcon, color: Colors.grey[400]),
          title: Text(
            fileName,
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: description.isNotEmpty
              ? Text(
                  description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
          onTap: () {
            if (type == 'pdf') {
              // _openPdfViewer(url, description); // Call PDF viewer function
              _launchExternalUrl(
                url,
              ); // Fallback: try opening in browser/external app
            } else {
              _launchExternalUrl(url); // Launch other types externally
            }
          },
        ),
      );
    } else {
      // Media Tab
      return GestureDetector(
        onTap: () {
          if (type == 'image') _openImageViewer(url, description);
          if (type == 'video') _openVideoPlayer(url, description);
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: Colors.grey[800],
          child: Tooltip(
            // Show description on hover/long press
            message: description,
            preferBelow: false,
            child: content,
          ),
        ),
      );
    }
  }
}
