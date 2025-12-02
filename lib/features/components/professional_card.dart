import 'package:flutter/material.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/features/profile/public_profile_page.dart';

class ProfessionalCard extends StatelessWidget {
  final UserModel user;

  const ProfessionalCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isAvailable = user.availabilityStatus.toLowerCase() == 'available';
    final availabilityColor = isAvailable ? Colors.green : Colors.orange;

    // Get the first 3 skills to display on the card
    final displaySkills = user.skills.take(3).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicProfilePage(userId: user.uid),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- Layer 1: Background Image (Profile Picture) ---
              Image.network(
                user.profilePictureUrl ??
                    'https://placehold.co/300x400/2C2C2C/FFFFFF?text=AUTEURLY',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF2C2C2C)),
              ),

              // --- Layer 2: Darkening Gradient Overlay ---
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // --- Layer 3: Text Content ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- NEW: Display Skills as Chips ---
                    if (displaySkills.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          children: displaySkills
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      0.2,
                                    ), // Light, semi-transparent chip background
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    skill.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    // Availability Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: availabilityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.availabilityStatus.toUpperCase(),
                        style: TextStyle(
                          color: availabilityColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Name
                    Text(
                      user.fullName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Headline
                    Text(
                      user.headline.isNotEmpty ? user.headline : 'Professional',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
