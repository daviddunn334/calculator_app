import 'package:flutter/material.dart';
import '../utils/location_colors.dart';
import '../theme/app_theme.dart';

class ColorPickerWidget extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;
  final String title;

  const ColorPickerWidget({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
    this.title = 'Select Color',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Wrap(
          spacing: AppTheme.paddingSmall,
          runSpacing: AppTheme.paddingSmall,
          children: LocationColors.getColorOptions().map((colorEntry) {
            final colorHex = colorEntry.key;
            final color = colorEntry.value;
            final isSelected = selectedColorHex.toUpperCase() == colorHex.toUpperCase();

            return GestureDetector(
              onTap: () => onColorSelected(colorHex),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: LocationColors.getTextColor(colorHex),
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          LocationColors.getColorName(selectedColorHex),
          style: AppTheme.bodyMedium.copyWith(
            color: LocationColors.getColor(selectedColorHex),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
