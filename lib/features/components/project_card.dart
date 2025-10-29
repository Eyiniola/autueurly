import 'package:flutter/material.dart';
import 'package:auteurly/core/models/project_model.dart';
import 'package:auteurly/features/projects/project_details_page.dart';

class ProjectCard extends StatefulWidget {
  // Changed to StatefulWidget
  final ProjectModel project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  ColorScheme? _colorScheme; // State for generated scheme
  bool _isLoadingColor = true; // Track color generation

  // --- Define Default/Fallback Colors ---
  // Using colors that fit your dark theme
  final Color _defaultCardColor = const Color(0xFF2C2C2C); // Dark grey surface
  final Color _defaultTextColor = Colors.white; // White text
  final Color _defaultSubtitleColor = Colors.grey.shade400; // Lighter grey
  final Color _defaultButtonBg = const Color(0xFFA32626); // Your primary red
  final Color _defaultButtonText = Colors.white;

  @override
  void initState() {
    super.initState();
    _generateColorScheme();
  }

  // Regenerate if project image changes
  @override
  void didUpdateWidget(covariant ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.project.posterUrl != oldWidget.project.posterUrl) {
      _generateColorScheme();
    }
  }

  Future<void> _generateColorScheme() async {
    // Reset state before generating
    if (mounted) {
      setState(() {
        _isLoadingColor = true;
        _colorScheme = null;
      });
    }

    if (widget.project.posterUrl == null || widget.project.posterUrl!.isEmpty) {
      if (mounted)
        setState(() => _isLoadingColor = false); // No image, stop loading
      return;
    }

    try {
      final ColorScheme scheme = await ColorScheme.fromImageProvider(
        provider: NetworkImage(widget.project.posterUrl!),
        brightness:
            Brightness.dark, // Generate colors suitable for a dark theme
      );
      if (mounted) {
        setState(() {
          _colorScheme = scheme;
          _isLoadingColor = false;
        });
      }
    } catch (e) {
      print("Error generating ColorScheme from image: $e");
      if (mounted)
        setState(() => _isLoadingColor = false); // Stop loading on error
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Determine Colors ---
    // Use generated scheme if available, otherwise fallbacks
    final Color cardColor = _isLoadingColor
        ? _defaultCardColor // Show default while loading color
        : (_colorScheme?.surfaceVariant ?? _defaultCardColor).withOpacity(
            0.8,
          ); // Use surfaceVariant (semi-transparent) or default

    // Use colors ON the surface/background from the scheme or defaults
    final Color textColor = _isLoadingColor
        ? _defaultTextColor
        : (_colorScheme?.onSurface ?? _defaultTextColor);
    final Color subtitleColor = _isLoadingColor
        ? _defaultSubtitleColor
        : (_colorScheme?.onSurfaceVariant ?? _defaultSubtitleColor);
    final Color buttonBg = _isLoadingColor
        ? _defaultButtonBg
        : (_colorScheme?.primary ?? _defaultButtonBg);
    final Color buttonText = _isLoadingColor
        ? _defaultButtonText
        : (_colorScheme?.onPrimary ?? _defaultButtonText);

    print(
      "Building card for project title: '${widget.project.title}', ${widget.project.description}",
    );

    return Card(
      color: cardColor, // Apply the dynamic or default color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.only(bottom: 20.0),
      clipBehavior: Clip.antiAlias, // Important for DecorationImage
      child: InkWell(
        // Make card tappable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProjectDetailsPage(projectId: widget.project.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            // --- Align items to the top ---
            crossAxisAlignment: CrossAxisAlignment.start,
            // ---
            children: [
              // --- FIX: Use Flexible instead of Expanded ---
              Flexible(
                flex: 2,
                fit: FlexFit.loose, // Allow child to determine its own height
                // --- END FIX ---
                child: Column(
                  // Keep this shrink-wrapped
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // Poster
                      height: 80,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300]?.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        image: widget.project.posterUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.project.posterUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.project.posterUrl == null
                          ? Icon(
                              Icons.movie_filter_outlined,
                              color: subtitleColor.withOpacity(0.7),
                              size: 30,
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      // Title
                      widget.project.title.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      // Year and Status
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.project.year.toString(),
                          style: TextStyle(color: subtitleColor, fontSize: 10),
                        ),
                        if (widget.project.status.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: subtitleColor.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            widget.project.status.toUpperCase(),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // --- FIX: Use Flexible instead of Expanded ---
              Flexible(
                flex: 3,
                fit: FlexFit.loose, // Allow child to determine its own height
                // --- END FIX ---
                child: SizedBox(
                  height: 120, // Keep fixed height for content balance
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Keep this
                    children: [
                      Padding(
                        // Description
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          widget.project.description.isNotEmpty
                              ? widget.project.description
                              : 'No description available.',
                          style: TextStyle(fontSize: 10, color: subtitleColor),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Align(
                        // Button
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            /* ... Navigation ... */
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: buttonBg,
                            foregroundColor: buttonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'VIEW MORE',
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
