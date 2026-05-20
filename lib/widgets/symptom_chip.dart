import 'package:flutter/material.dart';
import 'package:cima_mens/utils/constants.dart';

/// SymptomChips — Wrap dari FilterChip untuk memilih gejala.
/// Menggunakan kSymptomList dari constants.dart.
class SymptomChips extends StatelessWidget {
  final List<String> selected;
  final Function(List<String>) onChanged;

  const SymptomChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FlowMateConstants.symptoms.map((symptom) {
        final isSelected = selected.contains(symptom);

        return FilterChip(
          label: Text(symptom),
          selected: isSelected,
          onSelected: (value) {
            final updated = List<String>.from(selected);
            if (value) {
              updated.add(symptom);
            } else {
              updated.remove(symptom);
            }
            onChanged(updated);
          },
          selectedColor: primaryColor.withValues(alpha: 0.2),
          checkmarkColor: primaryColor,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: TextStyle(
            color: isSelected ? primaryColor : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
