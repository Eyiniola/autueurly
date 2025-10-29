import 'package:auteurly/core/widgets/tag_input_widget.dart';
import 'package:flutter/material.dart';
import '../../../components/textfield.dart';

class Step2CreativeIdentity extends StatelessWidget {
  final TextEditingController bioController;
  final List<String> keyRoles;
  final List<String> skills;
  final List<String> genres;
  final Function(String) onRoleAdded;
  final Function(String) onRoleRemoved;
  final Function(String) onSkillAdded;
  final Function(String) onSkillRemoved;
  final Function(String) onGenreAdded;
  final Function(String) onGenreRemoved;

  const Step2CreativeIdentity({
    super.key,
    required this.bioController,
    required this.skills,
    required this.genres,
    required this.keyRoles,
    required this.onRoleAdded,
    required this.onRoleRemoved,
    required this.onSkillAdded,
    required this.onSkillRemoved,
    required this.onGenreAdded,
    required this.onGenreRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Creative Identity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Write a short bio and add your skills and genre specializations.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Bio Field (This is correct)
          MyTextfield(controller: bioController, hintText: 'Short Bio'),
          const SizedBox(height: 24),

          // --- Key Roles Input Section ---
          TagInputWidget(
            label: 'Key Roles',
            hintText: 'e.g., Director',
            tags: keyRoles,
            onTagAdded: onRoleAdded,
            onTagRemoved: onRoleRemoved,
          ),

          // --- Skills Input Section ---
          TagInputWidget(
            label: 'Key Skills',
            hintText: 'e.g., Cinematography',
            tags: skills,
            onTagAdded: onSkillAdded,
            onTagRemoved: onSkillRemoved,
          ),
          const SizedBox(height: 24),

          // --- Genres Input Section ---
          TagInputWidget(
            label: 'Genre Specializations',
            hintText: 'e.g., Documentary',
            tags: genres,
            onTagAdded: onGenreAdded,
            onTagRemoved: onGenreRemoved,
          ),
        ],
      ),
    );
  }
}
