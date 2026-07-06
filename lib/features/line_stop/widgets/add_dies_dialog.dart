import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../dashboard/data/line_stop_service.dart';

class AddDiesDialog extends StatefulWidget {
  const AddDiesDialog({super.key});

  @override
  State<AddDiesDialog> createState() => _AddDiesDialogState();
}

class _AddDiesDialogState extends State<AddDiesDialog> {
  XFile? _imageFile;
  bool _isFetching = true;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _dies = [];
  List<Map<String, dynamic>> _machines = [];
  List<Map<String, dynamic>> _pics = [];

  String? _selectedPartNo;
  String? _selectedMachineCd;
  String? _selectedShift;
  String? _selectedPic;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    try {
      final diesData = await LineStopService.getDies();
      final machinesData = await LineStopService.getMachines();
      final picsData = await LineStopService.getPics();

      setState(() {
        _dies = diesData;
        _machines = machinesData;
        _pics = picsData;
        _isFetching = false;
      });
    } catch (e) {
      setState(() => _isFetching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load master data: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
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

  Future<void> _submitForm() async {
    if (_selectedPartNo == null || _selectedMachineCd == null || _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields (*)')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Find line_cd from selected machine
      final machine = _machines.firstWhere((m) => m['machine_cd'] == _selectedMachineCd);
      final lineCd = machine['line_cd'] as String;

      // Find model from selected die
      final die = _dies.firstWhere((d) => d['part_no'] == _selectedPartNo);
      final model = die['model'] as String?;

      // Create new DiesTask payload
      final newTask = DiesTask(
        id: '', // Generated on backend
        partNo: _selectedPartNo,
        machineCd: _selectedMachineCd,
        lineCd: lineCd,
        shift: _selectedShift,
        repairedBy: _selectedPic, // PIC username
        model: model,
        status: 'OPEN',
      );

      final savedTask = await LineStopService.create(newTask);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Line Stop entry created successfully')),
      );
      
      // Close dialog and return the saved task containing its ID
      Navigator.of(context).pop(savedTask);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit form: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoading(),
              SizedBox(height: 16),
              Text('Loading master data...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
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

                // ── Form Row 1: Part Number & Machine (Process) ───────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Part Number',
                        isRequired: true,
                        hint: 'Select Part Number',
                        value: _selectedPartNo,
                        items: _dies.map((d) {
                          final partNo = d['part_no'] as String;
                          final model = d['model'] as String? ?? '-';
                          return DropdownMenuItem<String>(
                            value: partNo,
                            child: Text('$partNo ($model)'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPartNo = val),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Process (Machine)',
                        isRequired: true,
                        hint: 'Select Machine',
                        value: _selectedMachineCd,
                        items: _machines.map((m) {
                          final code = m['machine_cd'] as String;
                          final name = m['machine_name'] as String;
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text('$code - $name'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedMachineCd = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Form Row 2: Shift & Add PIC ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Shift',
                        isRequired: true,
                        hint: 'Select Shift',
                        value: _selectedShift,
                        items: const [
                          DropdownMenuItem(value: 'B', child: Text('Blue Shift')),
                          DropdownMenuItem(value: 'R', child: Text('Red Shift')),
                        ],
                        onChanged: (val) => setState(() => _selectedShift = val),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Add PIC',
                        optionalLabel: ' (Optional)',
                        isRequired: false,
                        hint: 'Select PIC',
                        value: _selectedPic,
                        items: _pics.map((p) {
                          final username = p['username'] as String;
                          final fullName = p['full_name'] as String? ?? username;
                          return DropdownMenuItem<String>(
                            value: username,
                            child: Text(fullName),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPic = val),
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
                      ' *',
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
                      onPressed: _submitForm,
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
          if (_isSubmitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black12,
                child: Center(
                  child: AppLoading.overlay(message: 'Submitting repair task...'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required bool isRequired,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? optionalLabel,
  }) {
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
                optionalLabel,
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
        // Dropdown Form Field
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
