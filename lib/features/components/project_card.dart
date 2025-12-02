import 'package:auteurly/core/models/project_model.dart';
import 'package:auteurly/features/projects/project_details_page.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  ColorScheme? _colorScheme;
  bool _isLoadingColor = true;

  // Define a dark surface color for the default state
  final Color _defaultCardColor = const Color(0xFF2C2C2C);
  final Color _defaultTextColor = Colors.white;
  final Color _defaultSubtitleColor = Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
    _generateColorScheme();
  }

  @override
  void didUpdateWidget(covariant ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.project.posterUrl != oldWidget.project.posterUrl) {
      _generateColorScheme();
    }
  }

  Future<void> _generateColorScheme() async {
    if (mounted) {
      setState(() {
        _isLoadingColor = true;
        _colorScheme = null;
      });
    }

    if (widget.project.posterUrl == null || widget.project.posterUrl!.isEmpty) {
      if (mounted) {
        setState(() => _isLoadingColor = false);
      }
      return;
    }

    try {
      final ColorScheme scheme = await ColorScheme.fromImageProvider(
        provider: NetworkImage(widget.project.posterUrl!),
        brightness: Brightness.dark, // Generate dark colors for this surface
      );
      if (mounted) {
        setState(() {
          _colorScheme = scheme;
          _isLoadingColor = false;
        });
      }
    } catch (e) {
      print("Error generating ColorScheme from image: $e");
      if (mounted) {
        setState(() => _isLoadingColor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine the base color (dynamic or default dark)
    final Color schemeBaseColor = _isLoadingColor
        ? _defaultCardColor
        : (_colorScheme?.surfaceContainerHighest ?? _defaultCardColor);

    // 2. Apply opacity to the base color for the smoky, transparent effect
    final Color finalCardColor = schemeBaseColor.withOpacity(0.7); // 30% opaque

    // 3. Ensure text is high-contrast white, regardless of the card's color
    final Color textColor = Colors.white;
    final Color subtitleColor = Colors.grey[400]!;

    return InkWell(
      onTap: () {
        // ... (Navigation logic remains the same)
      },
      // --- FIX: Use the semi-transparent color and remove elevation ---
      child: Card(
        color: finalCardColor, // Apply the 30% opaque color
        elevation: 0, // Ensure it's flat against the background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.only(bottom: 20.0),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Left Side: Project Poster (Image) ---
                Container(
                  height: 100,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    image: widget.project.posterUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.project.posterUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.project.posterUrl == null
                      ? Icon(Icons.movie, color: Colors.grey[500], size: 30)
                      : null,
                ),
                const SizedBox(width: 12),

                // --- Right Side: Details and Button ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- Top Block (Title & Type/Year) ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.title.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor, // Use high-contrast white
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.project.projectType} - ${widget.project.year}',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 10,
                            ), // Use high-contrast subtitle color
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                      // --- Description Block ---
                      Text(
                        widget.project.description.isNotEmpty
                            ? widget.project.description
                            : 'No description available.',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              subtitleColor, // Use high-contrast subtitle color
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
