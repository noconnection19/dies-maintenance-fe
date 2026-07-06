import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_loading.dart';
import '../../dashboard/data/line_stop_service.dart';

class LineStopDetailScreen extends StatefulWidget {
  final DiesTask task;
  const LineStopDetailScreen({super.key, required this.task});

  @override
  State<LineStopDetailScreen> createState() => _LineStopDetailScreenState();
}

class _LineStopDetailScreenState extends State<LineStopDetailScreen> {
  late DiesTask _task;
  bool _isLoading = false;

  // Timer states
  int _secondsRemaining = 900; // 15 Minutes default countdown
  bool _isTimerRunning = true;
  Timer? _timer;

  // Form states
  String? _selectedPros;
  String? _selectedClassification;
  String? _selectedProblem;
  String? _selectedPenyebab;
  String? _selectedPenanggulangan;
  final _noteCtrl = TextEditingController();
  String _changePartVal = 'No';

  // Dropdown list options
  final _prosList = ['2/5 : TRIM&PIERCE', '1/5 : DRAW', '3/5 : BENDING', '4/5 : PIERCING'];
  final _classifications = ['A (Critical)', 'B (Major)', 'C (Minor)'];
  final _problems = ['SF (Surface Scratch)', 'B (Burry)', 'O (Other)', 'W (Ware)'];
  final _penyebabs = ['PAD DIRATAKAN', 'KETRIK & DIRAPIHKAN', 'GANTI MISGRIP BARU', 'NOBI', 'INSERT LOWER MINUS'];
  final _penanggulangans = ['ADJUST SLIDE & SETTING STOPER', 'ADJUST SLIDE & GANJAL SIM', 'DIRAPIKAN DENGAN BATU GOSOK'];

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _startTimer();
    
    // Autofill initial values if present
    _selectedProblem = _task.problem;
    _selectedPenyebab = _task.rootcause;
    _selectedPenanggulangan = _task.countermeasure;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning) {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
  }

  String _formatDuration(int totalSeconds) {
    final isNegative = totalSeconds < 0;
    final absSeconds = totalSeconds.abs();
    final minutes = absSeconds ~/ 60;
    final seconds = absSeconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return '${isNegative ? '-' : ''}$minutesStr:$secondsStr';
  }

  Future<void> _finishReparation() async {
    // Validate required form fields
    if (_selectedClassification == null ||
        _selectedProblem == null ||
        _selectedPenyebab == null ||
        _selectedPenanggulangan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required form fields (*)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final elapsedSeconds = 900 - _secondsRemaining;
      final elapsedMinutes = (elapsedSeconds > 0 ? elapsedSeconds : 0) ~/ 60;

      final payload = {
        'status': 'CLOSED',
        'problem': _selectedProblem,
        'rootcause': _selectedPenyebab,
        'countermeasure': _selectedPenanggulangan,
        'remark': 'Change Part: $_changePartVal. Note: ${_noteCtrl.text}',
        'duration_ls': elapsedMinutes,
        'duration_mh': elapsedMinutes + 5, // MH default is slightly longer
        'repaired_dt': DateTime.now().toIso8601String(),
      };

      // Call API to complete task
      final updated = await LineStopService.update(_task.id, payload);
      setState(() {
        _task = updated;
        _isTimerRunning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reparation completed successfully')),
      );
      Navigator.of(context).pop(true); // Return to list screen and refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete reparation: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _task.repairedDt != null || _task.status == 'CLOSED' || _task.status == '2';
    
    return Stack(
      children: [
        AppShell(
          contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Back + Title ─────────────────────────────────
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconMd),
                label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  backgroundColor: AppColors.greenLight,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              const Text(
                'DETAIL - DIES LINE STOP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // ── Columns Split ─────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left Panel (Detail Card + Form) ─────────────────────
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Detail Header Code
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                                    children: [
                                      const TextSpan(
                                        text: 'Detail Dies ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: 'LS${_task.id.padLeft(8, '0')}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Detail Grid Info
                            _buildInfoGrid(isCompleted),
                            const Divider(height: 40, color: AppColors.divider),

                            // Record Reparation
                            const Text(
                              'Record Reparation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormDropdown(
                                    label: 'Pros',
                                    isRequired: true,
                                    hint: 'Select Pros',
                                    value: _selectedPros,
                                    items: _prosList,
                                    onChanged: isCompleted ? null : (v) => setState(() => _selectedPros = v),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildFormDropdown(
                                    label: 'Klasifikasi',
                                    isRequired: true,
                                    hint: 'Select Classification',
                                    value: _selectedClassification,
                                    items: _classifications,
                                    onChanged: isCompleted ? null : (v) => setState(() => _selectedClassification = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormDropdown(
                                    label: 'Problem',
                                    isRequired: true,
                                    hint: 'Select Problem',
                                    value: _selectedProblem,
                                    items: _problems,
                                    onChanged: isCompleted ? null : (v) => setState(() => _selectedProblem = v),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildFormDropdown(
                                    label: 'Penyebab (Root Cause)',
                                    isRequired: true,
                                    hint: 'Select Rootcause',
                                    value: _selectedPenyebab,
                                    items: _penyebabs,
                                    onChanged: isCompleted ? null : (v) => setState(() => _selectedPenyebab = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildFormDropdown(
                              label: 'Penanggulangan (Countermeasure)',
                              isRequired: true,
                              hint: 'Select Countermeasure',
                              value: _selectedPenanggulangan,
                              items: _penanggulangans,
                              onChanged: isCompleted ? null : (v) => setState(() => _selectedPenanggulangan = v),
                            ),
                            const SizedBox(height: 16),

                            // Note optional
                            const Text(
                              'Note (Optional)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _noteCtrl,
                              maxLines: 4,
                              enabled: !isCompleted,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Input note here...',
                                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.divider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.divider),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Detail Change Part
                            const Text(
                              'Detail Change Part',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  'Change Part *  ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Radio<String>(
                                  value: 'Yes',
                                  groupValue: _changePartVal,
                                  activeColor: AppColors.green,
                                  onChanged: isCompleted ? null : (v) => setState(() => _changePartVal = v!),
                                ),
                                const Text('Yes', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 16),
                                Radio<String>(
                                  value: 'No',
                                  groupValue: _changePartVal,
                                  activeColor: AppColors.green,
                                  onChanged: isCompleted ? null : (v) => setState(() => _changePartVal = v!),
                                ),
                                const Text('No', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // ── Right Panel (Duration & Slider) ──────────────────────
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Repair Duration Card
                        Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Repair Duration (15 Minutes)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Large timer and pause
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(isCompleted ? (_task.durationLs ?? 0) * -60 : _secondsRemaining),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    if (!isCompleted)
                                      OutlinedButton.icon(
                                        onPressed: _toggleTimer,
                                        icon: Icon(
                                          _isTimerRunning ? Icons.pause : Icons.play_arrow,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        label: Text(
                                          _isTimerRunning ? 'Pause' : 'Resume',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.orange,
                                          side: const BorderSide(color: Colors.orange),
                                          shape: const StadiumBorder(),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Swipe confirming slider
                                if (!isCompleted) ...[
                                  _SwipeToFinish(onFinished: _finishReparation),
                                  const SizedBox(height: 20),
                                ],

                                // Documentation area
                                const Text(
                                  'Documentation',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Before Reparation :',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),

                                // Mock Image Box
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.divider),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?q=80&w=600&auto=format&fit=crop',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Section: History Part Reparation
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'History Part Reparation',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Maintenance in Last a Month 1x',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                const Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 24, color: AppColors.textMuted),
                                      SizedBox(height: 8),
                                      Text(
                                        'No History Yet',
                                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    if (_isLoading)
      const Positioned.fill(
        child: ColoredBox(
          color: Colors.black12,
          child: Center(
            child: AppLoading.overlay(message: 'Saving reparation record...'),
          ),
        ),
      ),
  ],
);
}

  Widget _buildInfoGrid(bool isCompleted) {
    final statusLabel = isCompleted ? 'Completed' : 'On Progress';
    final statusColor = isCompleted ? AppColors.green : Colors.blue;
    final dateTimeStr = _task.repairedDt ?? _task.createdDt ?? '-';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoLabel('Status'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _infoLabel('Process'),
              const SizedBox(height: 6),
              _infoVal('${_task.machineCd} - ${_task.partNo}'), // Mocking process
            ],
          ),
        ),
        // Column 2
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoLabel('Shift'),
              const SizedBox(height: 6),
              _infoVal(_task.shift == 'R' ? 'Red' : (_task.shift == 'B' ? 'Blue' : (_task.shift ?? '-'))),
              const SizedBox(height: 16),
              _infoLabel('Machine'),
              const SizedBox(height: 6),
              _infoVal(_task.machineCd ?? '-'),
            ],
          ),
        ),
        // Column 3
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoLabel('Date Time'),
              const SizedBox(height: 6),
              _infoVal(dateTimeStr),
              const SizedBox(height: 16),
              _infoLabel('Line'),
              const SizedBox(height: 6),
              _infoVal(_task.lineCd ?? '-'),
            ],
          ),
        ),
        // Column 4
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoLabel('Part Number'),
              const SizedBox(height: 6),
              _infoVal(_task.partNo ?? '-'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
    );
  }

  Widget _infoVal(String val) {
    return Text(
      val,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildFormDropdown({
    required String label,
    required bool isRequired,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─── Swipe Slider Widget ────────────────────────────────────────────
class _SwipeToFinish extends StatefulWidget {
  final VoidCallback onFinished;
  const _SwipeToFinish({required this.onFinished});

  @override
  State<_SwipeToFinish> createState() => _SwipeToFinishState();
}

class _SwipeToFinishState extends State<_SwipeToFinish> {
  double _dragPosition = 0;
  static const double _width = 300;
  static const double _buttonWidth = 90;

  @override
  Widget build(BuildContext context) {
    final maxDrag = _width - _buttonWidth - 8;
    
    return Container(
      width: _width,
      height: 52,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Stack(
        children: [
          // Drag instruction label
          Center(
            child: Text(
              'Swap right to finish',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Drag confirmation area
          Positioned(
            right: 4,
            top: 4,
            bottom: 4,
            child: Container(
              width: _buttonWidth,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  'Finish ≫',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Slider Button
          Positioned(
            left: _dragPosition + 4,
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragPosition >= maxDrag * 0.85) {
                  setState(() {
                    _dragPosition = maxDrag;
                  });
                  widget.onFinished();
                } else {
                  setState(() {
                    _dragPosition = 0;
                  });
                }
              },
              child: Container(
                width: _buttonWidth,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Finish ≫',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
