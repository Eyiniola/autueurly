import 'dart:math';
import 'package:auteurly/core/models/project_model.dart';
import 'package:auteurly/features/notifications/inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/models/credit_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/features/profile/project_gallery_page.dart';
import 'package:auteurly/core/widgets/credit_poster_card.dart';
import 'package:auteurly/core/widgets/gallery_thumbnail_widget.dart';
import 'package:auteurly/core/widgets/image_viewer_page.dart';
import 'package:auteurly/core/widgets/video_player_page.dart';
import 'package:auteurly/core/widgets/pdf_viewer_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

// instantiate the firestore service used below
final firestoreService = FirestoreService();

class UserProfileContent extends StatefulWidget {
  final UserModel user;
  final Widget actionButton;
  final TabController tabController;
  final VoidCallback? onAvailabilityTap;

  const UserProfileContent({
    super.key,
    required this.user,
    required this.actionButton,
    required this.tabController,
    this.onAvailabilityTap,
  });

  @override
  State<UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends State<UserProfileContent> {
  String? _thumbnailPath;
  late final bool _isAvailable;
  late final Color _availabilityColor;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.user.availabilityStatus.toLowerCase() == 'available';
    _availabilityColor = _isAvailable ? Colors.green : Colors.orange;
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final showreelUrl = widget.user.showreelUrl;
    if (showreelUrl != null && showreelUrl.isNotEmpty) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: showreelUrl,
        imageFormat: ImageFormat.JPEG,
        quality: 50, // Adjust quality for performance
      );
      if (mounted) {
        setState(() {
          _thumbnailPath = thumbnailPath;
        });
      }
    }
  }

  // --- ADD LAUNCH URL METHOD ---
  Future<void> _launchShowreelUrl() async {
    final showreelUrl = widget.user.showreelUrl;
    if (showreelUrl != null && showreelUrl.isNotEmpty) {
      final uri = Uri.parse(showreelUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Show an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Gallery Item Opening Methods ---
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

  void _openPdfViewer(String pdfUrl, String? description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(pdfUrl: pdfUrl, description: description),
      ),
    );
  }

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

  // --- Main method to handle gallery item opening ---
  void _openGalleryItem(Map<String, dynamic> item) {
    final String type = item['type'] ?? 'other';
    final String url = item['storageUrl'] ?? '';
    final String description = item['description'] ?? '';

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid file URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    switch (type) {
      case 'image':
        _openImageViewer(url, description.isNotEmpty ? description : null);
        break;
      case 'video':
        _openVideoPlayer(url, description.isNotEmpty ? description : null);
        break;
      case 'pdf':
        // Try to open in PDF viewer, fallback to external launch
        _openPdfViewer(url, description.isNotEmpty ? description : null);
        break;
      default:
        // For 'other' types, launch externally
        _launchExternalUrl(url);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1B1B1B),
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFA32626), Color(0xFF1B1B1B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Overlay content
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF1B1B1B),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  widget.user.profilePictureUrl != null
                                  ? NetworkImage(widget.user.profilePictureUrl!)
                                  : null,
                              child: widget.user.profilePictureUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.user.headline.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: widget.onAvailabilityTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _availabilityColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.user.availabilityStatus
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: _availabilityColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.user.fullName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.user.location.isNotEmpty)
                            Text(
                              widget.user.location.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            bottom: TabBar(
              controller: widget.tabController,
              indicatorColor: const Color(0xFFA32626),
              labelColor: Colors.white,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'ABOUT'),
                Tab(text: 'PORTFOLIO'),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InboxScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            ],
          ),
        ];
      },
      body: TabBarView(
        controller: widget.tabController,
        children: [_buildAboutTab(context), _buildPortfolioTab(context)],
      ),
    );
  }

  // --- UI for the "About" Tab ---
  Widget _buildAboutTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.actionButton,
          const SizedBox(height: 24),
          const Text(
            'BIO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.user.bio.isNotEmpty ? widget.user.bio : 'No bio available.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'KEY ROLES',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: widget.user.keyRoles
                .map(
                  (role) => Chip(
                    label: Text(role.toUpperCase()),
                    backgroundColor: const Color(0xFFA32626),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'SKILLS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: widget.user.skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: const Color(0xFFA32626),
                    labelStyle: const TextStyle(color: Colors.white),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'GENRE SPECIALIZATION',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: widget.user.genres
                .map(
                  (genre) => Chip(
                    label: Text(genre),
                    backgroundColor: const Color(0xFFA32626),
                    labelStyle: const TextStyle(color: Colors.white),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // --- ADDED THIS SECTION for Equipment ---
          const Text(
            'EQUIPMENT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: widget.user.equipment
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: const Color(0xFFA32626),
                    labelStyle: const TextStyle(color: Colors.white),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // --- ADDED THIS SECTION for Languages ---
          const Text(
            'LANGUAGES',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: widget.user.languages
                .map(
                  (lang) => Chip(
                    label: Text(lang),
                    backgroundColor: const Color(0xFFA32626),
                    labelStyle: const TextStyle(color: Colors.white),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // --- UI for the "Portfolio" Tab ---
  Widget _buildPortfolioTab(BuildContext context) {
    // This UI is a simplified representation.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SHOWREEL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 9,
            child:
                widget.user.showreelUrl != null &&
                    widget.user.showreelUrl!.isNotEmpty
                ? GestureDetector(
                    onTap: _launchShowreelUrl,
                    child: Card(
                      color: const Color(0xFF2C2C2C),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // If thumbnail is generated, show it
                          if (_thumbnailPath != null)
                            Image.file(
                              File(_thumbnailPath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          else
                            // Show a loading indicator while thumbnail generates
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),

                          // Play icon overlay
                          Container(
                            color: Colors.black.withOpacity(
                              0.3,
                            ), // Darken thumbnail slightly
                          ),
                          Icon(
                            Icons.play_circle_outline,
                            color: Colors.white.withOpacity(0.9),
                            size: 60,
                          ),
                        ],
                      ),
                    ),
                  )
                : const Card(
                    color: Color(0xFF2C2C2C),
                    child: Center(
                      child: Text(
                        'No showreel available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CREDIT LIST',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestoreService.getCreditsWithProjectDetails(
              widget.user.uid,
            ), // Use the new stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No credits available yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final creditsWithDetails = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2 / 3, // Aspect ratio for a movie poster
                ),
                itemCount: creditsWithDetails.length,
                itemBuilder: (context, index) {
                  final credit =
                      creditsWithDetails[index]['credit'] as CreditModel;
                  final project =
                      creditsWithDetails[index]['project'] as ProjectModel;
                  return CreditPosterCard(
                    credit: credit,
                    project: project,
                    onTap: () {
                      // Navigate to the ProjectDetailsPage
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // --- PROJECT GALLERY SECTION ---
          const Text(
            'PROJECT GALLERY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.user.projectGallery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  "No gallery items added yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align items to top
              children: [
                // Left Column: Teaser Grid
                Expanded(
                  flex: 3, // Give grid more space
                  child: GridView.builder(
                    shrinkWrap: true, // Important inside SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable grid scrolling
                    itemCount: min(widget.user.projectGallery.length, 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columns in the teaser
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio:
                              1.0, // Square aspect ratio for thumbnails
                        ),
                    itemBuilder: (context, index) {
                      return GalleryThumbnailWidget(
                        item: widget.user.projectGallery[index],
                        onTap: () {
                          _openGalleryItem(widget.user.projectGallery[index]);
                        },
                      );
                    },
                  ),
                ),
                // Right Column: View More Button
                Expanded(
                  flex: 1, // Give button less space
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                    ), // Space between grid and button
                    // Align the button nicely if the grid is short
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectGalleryPage(
                                galleryItems: widget
                                    .user
                                    .projectGallery, // Pass all items
                                userName:
                                    widget.user.fullName, // Pass user's name
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Reduce tap area slightly
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Keep column small
                          children: [
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "View\nMore", // Multi-line text
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- Helper Widget for Gallery Thumbnails ---
  Widget _buildGalleryThumbnail(Map<String, dynamic> item) {
    final String type = item['type'] ?? 'other';
    final String url = item['storageUrl'] ?? '';
    // final String? thumbnailUrl = item['thumbnailUrl']; // Use if available

    Widget content;

    if (type == 'image' /* && thumbnailUrl != null */ ) {
      // Use thumbnailUrl if you generate them, otherwise use full URL
      content = Image.network(
        url, // Use thumbnailUrl here if you have it
        fit: BoxFit.cover,
        // Loading builder for placeholder
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        // Error builder for placeholder
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: Icon(Icons.broken_image_outlined, color: Colors.grey[600]),
        ),
      );
    } else if (type == 'video') {
      // Placeholder for video - consider generating thumbnails
      content = Container(
        color: Colors.black, // Dark background for videos
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white70,
            size: 40,
          ),
        ),
      );
    } else if (type == 'pdf') {
      content = Container(
        color: Colors.grey[800],
        child: Center(
          child: Icon(
            Icons.picture_as_pdf_outlined,
            color: Colors.white70,
            size: 40,
          ),
        ),
      );
    } else {
      // 'other' or unknown
      content = Container(
        color: Colors.grey[800],
        child: Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: Colors.white70,
            size: 40,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _openGalleryItem(item);
      },
      child: Card(
        clipBehavior: Clip.antiAlias, // Clip the content (Image, etc.)
        color: Colors.grey[800], // Background if image fails
        child: content,
      ),
    );
  }

}
