import 'package:flutter/material.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/features/profile/public_profile_page.dart';

class ProfessionalCard extends StatelessWidget {
  final UserModel user;

  const ProfessionalCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Determine availability chip color and text
    final bool isAvailable =
        user.availabilityStatus.toLowerCase() == 'available';
    final Color availabilityColor = isAvailable
        ? Colors.greenAccent.shade700
        : Colors.orangeAccent.shade700;
    final String availabilityText = user.availabilityStatus.isNotEmpty
        ? user.availabilityStatus.toUpperCase()
        : 'UNKNOWN';

    // Placeholder image URL
    const String placeholderImageUrl =
        'https://i.imgur.com/8h3jS8S.jpeg'; // Replace with your actual placeholder if different

    return Card(
      color: const Color(0xFF2C2C2C), // Dark card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      child: InkWell(
        // Make the whole card tappable
        onTap: () {
          // Navigate to the PublicProfilePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicProfilePage(userId: user.uid),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Use Column for overall structure (Top Row, Bottom Row)
            children: [
              // --- Top Row: Profile Pic + Info ---
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align items to the top
                children: [
                  // --- Left: Profile Picture ---
                  CircleAvatar(
                    radius: 35, // Adjust size as needed
                    backgroundColor:
                        Colors.grey[800], // Background for error/loading
                    backgroundImage: NetworkImage(
                      user.profilePictureUrl ?? placeholderImageUrl,
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Optional: Log error or handle it
                      print("Error loading image: $exception");
                    },
                    child: user.profilePictureUrl == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 35,
                          ) // Fallback icon
                        : null,
                  ),
                  const SizedBox(width: 16), // Spacing
                  // --- Right: User Info ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18, // Slightly larger name
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Headline
                        Text(
                          user.headline,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Skills (or Bio)
                        if (user.skills.isNotEmpty)
                          Wrap(
                            spacing: 6.0, // Spacing between chips
                            runSpacing: 4.0, // Spacing between lines of chips
                            children: user.skills
                                .take(3) // Limit to first 3 skills, for example
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    backgroundColor:
                                        Colors.grey[800], // Darker chip
                                    labelStyle: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 0,
                                    ), // Compact padding
                                    materialTapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, // Reduce tap area
                                    side: BorderSide.none,
                                  ),
                                )
                                .toList(),
                          )
                        // --- ALTERNATIVE: Show Bio instead of Skills ---
                        else if (user.bio.isNotEmpty)
                          Text(
                            user.bio,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 2, // Limit bio lines
                            overflow: TextOverflow.ellipsis,
                          )
                        else // Fallback if no skills (or bio)
                          SizedBox(
                            height: 20,
                          ), // Placeholder for consistent height
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Space between top and bottom rows
              // --- Bottom Row: Availability + View Button ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Availability Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: availabilityColor.withOpacity(
                        0.15,
                      ), // Softer background
                      borderRadius: BorderRadius.circular(10), // Pill shape
                      border: Border.all(
                        color: availabilityColor.withOpacity(0.5),
                        width: 0.5,
                      ), // Subtle border
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: availabilityColor,
                          size: 8,
                        ), // Small dot indicator
                        const SizedBox(width: 4),
                        Text(
                          availabilityText,
                          style: TextStyle(
                            color: availabilityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // View Button
                  TextButton(
                    // Use TextButton for a less prominent look
                    onPressed: () {
                      // Navigate to the PublicProfilePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PublicProfilePage(userId: user.uid),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ), // Smaller padding
                      foregroundColor: Colors.grey[300], // Subtle text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.grey[700]!,
                          width: 0.5,
                        ), // Subtle border
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Profile', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
