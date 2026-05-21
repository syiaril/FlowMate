import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cima_mens/providers/mood_provider.dart';

/// MoodEmojiPicker — Deretan tombol emoji untuk memilih mood.
/// Menggunakan data image_moods dari database Supabase.
class MoodEmojiPicker extends StatelessWidget {
  final String? selectedMoodId;
  final Function(String) onSelected;

  const MoodEmojiPicker({
    super.key,
    this.selectedMoodId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final imageMoods = context.watch<MoodProvider>().imageMoods;

    if (imageMoods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: imageMoods.map((mood) {
        final id = mood['id'] as String;
        final emoji = mood['image_url'] as String;
        final label = mood['name'] as String;
        final isSelected = selectedMoodId == id;

        return GestureDetector(
          onTap: () => onSelected(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji besar
                Image.network(
                  emoji,
                  width: isSelected ? 40 : 32,
                  height: isSelected ? 40 : 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),

                // Label mood
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
