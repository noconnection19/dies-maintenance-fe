import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class AddDiesDialog extends StatefulWidget {
  const AddDiesDialog({super.key});

  @override
  State<AddDiesDialog> createState() => _AddDiesDialogState();
}

class _AddDiesDialogState extends State<AddDiesDialog> {
  XFile? _imageFile;

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    // Buka aplikasi kamera (jika di browser web, ini bisa ditangkap sebagai prompt upload camera)
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    
    if (photo != null) {
      setState(() {
        _imageFile = photo;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Title & Close Button ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Dies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Form Row 1: Part Number & Process ───────────────────────────
            const Row(
              children: [
                Expanded(
                  child: _FormDropdown(
                    label: 'Part Number',
                    isRequired: true,
                    hint: 'Select',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _FormDropdown(
                    label: 'Process',
                    isRequired: true,
                    hint: 'Select',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Form Row 2: Shift & Add PIC ─────────────────────────────────
            const Row(
              children: [
                Expanded(
                  child: _FormDropdown(
                    label: 'Shift',
                    isRequired: true,
                    hint: 'Select',
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _FormDropdown(
                    label: 'Add PIC',
                    optionalLabel: ' (Optional)',
                    isRequired: false,
                    hint: 'Select',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Documentation Area ──────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Documentation - Before Reparation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageFile == null 
               ? Center(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text(
                      'Take Photos',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                )
               : Stack(
                 alignment: Alignment.center,
                 children: [
                   // Image Preview
                   Positioned.fill(
                     child: Image.network(
                       _imageFile!.path, // Support rendering web blob
                       fit: BoxFit.cover,
                     ),
                   ),
                   // Optional Overlay Gradient (for delete button visibility)
                   Positioned.fill(
                     child: Container(color: Colors.black.withValues(alpha: 0.15)),
                   ),
                   // Change / Retake Photo Button
                   ElevatedButton.icon(
                     onPressed: _removePhoto,
                     icon: const Icon(Icons.delete_outline, size: 16),
                     label: const Text(
                       'Remove Photo',
                       style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                     ),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.error,
                       foregroundColor: Colors.white,
                       elevation: 0,
                       shape: const StadiumBorder(),
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                     ),
                   ),
                 ]
               ),
            ),
            const SizedBox(height: 32),

            // ── Action Buttons ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.greenLight),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Submit logic
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text(
                    'Submit & Start Repair',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Dropdown Component ───────────────────────────────────────────
class _FormDropdown extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String hint;
  final String? optionalLabel;

  const _FormDropdown({
    required this.label,
    this.isRequired = false,
    required this.hint,
    this.optionalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Text
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (optionalLabel != null)
              Text(
                optionalLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Selector Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hint,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
