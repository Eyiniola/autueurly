import 'package:flutter/material.dart';

class TagInputWidget extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> tags;
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;

  const TagInputWidget({
    super.key,
    required this.label,
    required this.hintText,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      widget.onTagAdded(_tagController.text);
      _tagController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA32626)),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFFA32626), size: 30),
              onPressed: _addTag,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: widget.tags.map((tag) {
            return Chip(
              label: Text(tag, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF2C2C2C),
              onDeleted: () {
                widget.onTagRemoved(tag);
              },
              deleteIcon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
