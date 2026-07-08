import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  bool _isLoadingSubData = false;

  List<Map<String, dynamic>> _dies = [];
  List<Map<String, dynamic>> _operations = [];
  List<Map<String, dynamic>> _machines = [];
  List<Map<String, dynamic>> _pics = [];

  String? _selectedPartNo;
  String? _selectedProcess;
  String? _selectedMachineCd;
  String? _selectedShift;
  List<String> _selectedPics = [];

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    try {
      final diesData = await LineStopService.getDies();
      final picsData = await LineStopService.getPics();

      setState(() {
        _dies = diesData;
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

  Future<void> _fetchMachines(String partNo) async {
    setState(() => _isLoadingSubData = true);
    try {
      final machinesData = await LineStopService.getMachinesForPart(partNo);

      setState(() {
        _machines = machinesData;
        _isLoadingSubData = false;
      });
    } catch (e) {
      setState(() => _isLoadingSubData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load machines: $e')),
      );
    }
  }

  Future<void> _fetchOperations(String partNo, String machineCd) async {
    setState(() => _isLoadingSubData = true);
    try {
      final operationsData = await LineStopService.getOperationsForMachine(partNo, machineCd);

      setState(() {
        _operations = operationsData;
        _isLoadingSubData = false;
      });
    } catch (e) {
      setState(() => _isLoadingSubData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load operations: $e')),
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

  void _showZoomedImage() {
    if (_imageFile == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 4.0,
                child: kIsWeb
                    ? Image.network(_imageFile!.path)
                    : Image.file(File(_imageFile!.path)),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_selectedPartNo == null || _selectedProcess == null || _selectedMachineCd == null || _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields (*)')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo for documentation before saving.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // 1. Upload photo first
      int? uploadedBeforeId;
      if (_imageFile != null) {
        final attachment = await LineStopService.uploadAttachment(_imageFile!);
        if (attachment.containsKey('data')) {
          final dataMap = attachment['data'] as Map<String, dynamic>;
          uploadedBeforeId = dataMap['id'] as int?;
        } else {
          uploadedBeforeId = attachment['id'] as int?;
        }
      }

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
        repairedBy: null,
        model: model,
        status: 'OPEN',
        documentationBeforeId: uploadedBeforeId,
        operationSeq: _selectedProcess,
        picUsernames: _selectedPics,
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
            child: SingleChildScrollView(
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

                // ── Form Row 1: Part Number & Machine ───────────────────
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
                        onChanged: (val) {
                          if (val != _selectedPartNo) {
                            setState(() {
                              _selectedPartNo = val;
                              _selectedMachineCd = null;
                              _selectedProcess = null;
                              _operations = [];
                              _machines = [];
                            });
                            if (val != null) {
                              _fetchMachines(val);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Machine',
                        isRequired: true,
                        hint: _isLoadingSubData
                            ? 'Loading...'
                            : (_selectedPartNo == null
                                ? 'Select Part Number first'
                                : 'Select Machine'),
                        value: _selectedMachineCd,
                        items: _machines.map((m) {
                          final code = m['machine_cd'] as String;
                          final name = m['machine_name'] as String;
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text('$code - $name'),
                          );
                        }).toList(),
                        onChanged: _selectedPartNo == null
                            ? null
                            : (val) {
                                if (val != _selectedMachineCd) {
                                  setState(() {
                                    _selectedMachineCd = val;
                                    _selectedProcess = null;
                                    _operations = [];
                                  });
                                  if (val != null && _selectedPartNo != null) {
                                    _fetchOperations(_selectedPartNo!, val);
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Form Row 2: Process & Shift ───────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Process',
                        isRequired: true,
                        hint: _isLoadingSubData
                            ? 'Loading...'
                            : (_selectedMachineCd == null
                                ? 'Select Machine first'
                                : 'Select Process'),
                        value: _selectedProcess,
                        items: _operations.map((o) {
                          final op = o['op'] as String;
                          final proses = o['proses'] as String;
                          return DropdownMenuItem<String>(
                            value: op,
                            child: Text('$op - $proses'),
                          );
                        }).toList(),
                        onChanged: _selectedMachineCd == null
                            ? null
                            : (val) => setState(() => _selectedProcess = val),
                      ),
                    ),
                    const SizedBox(width: 24),
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
                  ],
                ),
                const SizedBox(height: 20),

                // ── Form Row 3: Add PIC ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildMultiSelectDropdown(
                        label: 'Add PIC',
                        optionalLabel: ' (Optional)',
                        isRequired: false,
                        hint: 'Select PICs',
                        values: _selectedPics,
                        items: _pics.map((p) {
                          final username = p['username'] as String;
                          final fullName = p['full_name'] as String? ?? username;
                          return DropdownMenuItem<String>(
                            value: username,
                            child: Text(fullName),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPics = val),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(child: SizedBox()),
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
                _imageFile == null 
                 ? Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    alignment: Alignment.center,
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
                 : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image Preview
                      Container(
                        width: 180,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: kIsWeb
                                  ? Image.network(
                                      _imageFile!.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_imageFile!.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _showZoomedImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.crop_free_rounded,
                                      size: 16,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Retake Button
                      OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF10B981)),
                        label: const Text(
                          'Retake',
                          style: TextStyle(
                            fontWeight: FontWeight.w600, 
                            fontSize: 13,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
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
    required ValueChanged<String?>? onChanged,
    String? optionalLabel,
  }) {
    // Map item values to labels for searching and display
    final Map<String, String> valueToLabel = {};
    for (var item in items) {
      if (item.value != null) {
        String labelText = '';
        if (item.child is Text) {
          labelText = (item.child as Text).data ?? '';
        }
        valueToLabel[item.value!] = labelText;
      }
    }

    final bool isSearchEnabled = label != 'Shift';

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
        DropdownSearch<String>(
          key: ValueKey('${label}_${value ?? 'null'}_${items.length}'),
          items: (filter, loadProps) => valueToLabel.keys.toList(),
          selectedItem: value,
          enabled: onChanged != null && items.isNotEmpty,
          onSelected: onChanged,
          itemAsString: (String? val) {
            if (val == null) return '';
            return valueToLabel[val] ?? val;
          },
          popupProps: PopupProps.menu(
            showSearchBox: isSearchEnabled,
            menuProps: const MenuProps(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: AppColors.divider),
              ),
            ),
            searchFieldProps: TextFieldProps(
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search $label...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ),
            containerBuilder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: child,
              );
            },
          ),
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
            ),
            baseStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown({
    required String label,
    required bool isRequired,
    required String hint,
    required List<String> values,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<List<String>> onChanged,
    String? optionalLabel,
  }) {
    // Map item values to labels for searching and display
    final Map<String, String> valueToLabel = {};
    for (var item in items) {
      if (item.value != null) {
        String labelText = '';
        if (item.child is Text) {
          labelText = (item.child as Text).data ?? '';
        }
        valueToLabel[item.value!] = labelText;
      }
    }

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
        DropdownSearch<String>.multiSelection(
          key: ValueKey('${label}_${values.join(",")}_${items.length}'),
          items: (filter, loadProps) => valueToLabel.keys.toList(),
          selectedItems: values,
          onSelected: onChanged,
          itemAsString: (String? val) {
            if (val == null) return '';
            return valueToLabel[val] ?? val;
          },
          popupProps: MultiSelectionPopupProps.menu(
            showSearchBox: true,
            menuProps: const MenuProps(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: AppColors.divider),
              ),
            ),
            searchFieldProps: TextFieldProps(
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search $label...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ),
            containerBuilder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: child,
              );
            },
          ),
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
            baseStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
