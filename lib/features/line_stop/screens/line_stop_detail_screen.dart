import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/session/session_store.dart';
import '../../dashboard/data/line_stop_service.dart';

class LineStopDetailScreen extends StatefulWidget {
  final DiesTask task;
  final bool startPaused;
  const LineStopDetailScreen({super.key, required this.task, this.startPaused = true});

  @override
  State<LineStopDetailScreen> createState() => _LineStopDetailScreenState();
}

class _LineStopDetailScreenState extends State<LineStopDetailScreen> {
  late DiesTask _task;
  bool _isLoading = false;

  // Timer states
  int _secondsRemaining = 900; // 15 Minutes default countdown
  bool _isTimerRunning = false;
  Timer? _timer;

  // Form states
  String? _selectedClassification;
  String? _selectedProblemCd;
  String? _selectedProblemCdAndName;
  final _problemNameCtrl = TextEditingController();
  bool _isProblemNameEditable = false;
  String? _selectedPenyebab;
  String? _selectedPenanggulangan;
  String? _selectedRepairedBy;
  final _repairedByCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _classificationCtrl = TextEditingController();
  String _changePartVal = 'No';

  // Options fetched from DB
  List<Map<String, dynamic>> _problemOptions = [];
  List<Map<String, dynamic>> _classificationOptions = [];
  List<Map<String, dynamic>> _rootcauseOptions = [];
  List<Map<String, dynamic>> _countermeasureOptions = [];

  bool _loadingOptions = false;

  // History states
  List<DiesTask> _historyTasks = [];
  bool _loadingHistory = false;
  final Set<String> _expandedHistoryIds = {};

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _isTimerRunning = !widget.startPaused;

    // Timer 15 menit mengambil hitung mundur dari created_dt
    if (_task.createdDt != null) {
      try {
        final raw = _task.createdDt!.replaceAll(' ', 'T');
        final DateTime createdTime;
        if (raw.contains('Z') || raw.contains('+') || (raw.lastIndexOf('-') > 10)) {
          createdTime = DateTime.parse(raw).toUtc();
        } else {
          // Jika naive local time (UTC+7), parse sebagai local lalu jadikan UTC
          createdTime = DateTime.parse(raw).toUtc();
        }
        final elapsed = DateTime.now().toUtc().difference(createdTime).inSeconds;
        _secondsRemaining = 900 - elapsed;
      } catch (_) {
        _secondsRemaining = 900;
      }
    } else {
      _secondsRemaining = 900;
    }

    _startTimer();

    if (_task.partOrders != null && _task.partOrders!.isNotEmpty) {
      _changePartVal = 'Yes';
    }

    _loadHistory();
    _fetchSystemOptions();
  }

  Future<void> _loadHistory() async {
    if (_task.partNo == null) return;
    setState(() => _loadingHistory = true);
    try {
      final res = await LineStopService.getPaginated(page: 1, size: 100, status: 'CLOSED');
      final list = res['items'] as List<dynamic>;
      final tasks = list.map((e) => DiesTask.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        _historyTasks = tasks.where((t) => t.partNo == _task.partNo && t.id != _task.id).toList();
        _loadingHistory = false;
      });
    } catch (e) {
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _fetchSystemOptions() async {
    setState(() => _loadingOptions = true);
    try {
      final problems = await LineStopService.getSystems('PROBLEM');
      final classifications = await LineStopService.getSystems('CLASSIFICATION');
      final rootcauses = await LineStopService.getSystems('ROOTCAUSE');
      final countermeasures = await LineStopService.getSystems('COUNTERMEASURE');

      setState(() {
        _problemOptions = problems;
        _classificationOptions = classifications;
        _rootcauseOptions = rootcauses;
        _countermeasureOptions = countermeasures;

        // Autofill default repaired by
        final currentUser = SessionStore.instance.currentUser;
        _selectedRepairedBy = _task.repairedBy ?? currentUser?.fullName ?? currentUser?.username;
        _repairedByCtrl.text = _selectedRepairedBy ?? '';

        _loadingOptions = false;

        // Autofill initial values if present
        if (_task.problemCd != null) {
          _selectedProblemCd = _task.problemCd;
          _problemNameCtrl.text = _task.problem ?? '';
          _isProblemNameEditable = (_selectedProblemCd == 'O' || _selectedProblemCd == 'Others');
          
          final matchOpt = _problemOptions.firstWhere(
            (e) => e['system_cd'] == _selectedProblemCd,
            orElse: () => <String, dynamic>{},
          );
          if (matchOpt.isNotEmpty) {
            _selectedProblemCdAndName = "${matchOpt['system_cd']} - ${matchOpt['system_value']}";
          } else {
            _selectedProblemCdAndName = "$_selectedProblemCd - ${_task.problem ?? 'Others'}";
          }
        } else if (_task.problem != null) {
          final matched = _problemOptions.firstWhere(
            (element) => element['system_value'] == _task.problem,
            orElse: () => <String, dynamic>{},
          );
          if (matched.isNotEmpty) {
            _selectedProblemCd = matched['system_cd'];
            _problemNameCtrl.text = matched['system_value'];
            _selectedProblemCdAndName = "${matched['system_cd']} - ${matched['system_value']}";
            _isProblemNameEditable = false;
          } else {
            _selectedProblemCd = 'O';
            _problemNameCtrl.text = _task.problem ?? '';
            _selectedProblemCdAndName = 'O - Others';
            _isProblemNameEditable = true;
          }
        }

        if (_task.classification != null) {
          _classificationCtrl.text = _task.classification!;
          // final matched = _classificationOptions.any((element) => element['system_value'] == _task.classification);
          // if (matched) {
          //   _selectedClassification = _task.classification;
          // }
        }
        if (_task.rootcause != null) {
          final matched = _rootcauseOptions.any((element) => element['system_value'] == _task.rootcause);
          if (matched) {
            _selectedPenyebab = _task.rootcause;
          }
        }
        if (_task.countermeasure != null) {
          final matched = _countermeasureOptions.any((element) => element['system_value'] == _task.countermeasure);
          if (matched) {
            _selectedPenanggulangan = _task.countermeasure;
          }
        }
      });
    } catch (e) {
      setState(() => _loadingOptions = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dropdown options: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _onProblemCdChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedProblemCdAndName = val;
      final parts = val.split(' - ');
      final code = parts[0];
      final name = parts.sublist(1).join(' - ');
      _selectedProblemCd = code;
      if (code == 'O' || code == 'Others') {
        _problemNameCtrl.text = '';
        _isProblemNameEditable = true;
      } else {
        _problemNameCtrl.text = name;
        _isProblemNameEditable = false;
      }
    });
  }

  Future<void> _refreshTask() async {
    try {
      final updatedTask = await LineStopService.getById(_task.id);
      setState(() {
        _task = updatedTask;
        if (_task.partOrders != null && _task.partOrders!.isNotEmpty) {
          _changePartVal = 'Yes';
        }
      });
      _loadHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh task details: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteCtrl.dispose();
    _problemNameCtrl.dispose();
    _repairedByCtrl.dispose();
    _classificationCtrl.dispose();
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
    if (_selectedProblemCd == null ||
        _problemNameCtrl.text.trim().isEmpty ||
        _classificationCtrl.text.trim().isEmpty ||
        _selectedPenyebab == null ||
        _selectedPenanggulangan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required form fields (*)')),
      );
      return;
    }

    _showAfterReparationDialog();
  }

  XFile? _afterPhoto;

  void _showZoomedImage(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: kIsWeb
                  ? Image.network(path, fit: BoxFit.contain)
                  : Image.file(File(path), fit: BoxFit.contain),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAfterReparationDialog() {
    final remarkCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 720,
                padding: const EdgeInsets.all(24),
                child: StatefulBuilder(
                  builder: (context, setDialogState) {
                    final isMobile = MediaQuery.of(context).size.width < 600;

                    final cameraWidget = Column(
                      children: [
                        _afterPhoto != null
                            ? Container(
                                height: 140,
                                width: 240,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: kIsWeb
                                          ? Image.network(
                                              _afterPhoto!.path,
                                              height: 140,
                                              width: 240,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(_afterPhoto!.path),
                                              height: 140,
                                              width: 240,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: InkWell(
                                        onTap: () {
                                          _showZoomedImage(_afterPhoto!.path);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.crop_free_rounded, size: 16, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final photo = await picker.pickImage(source: ImageSource.camera);
                                  if (photo != null) {
                                    setDialogState(() {
                                      _afterPhoto = photo;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 140,
                                  width: 240,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt_outlined, size: 28, color: Colors.grey),
                                        SizedBox(height: 6),
                                        Text('Take Photo', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 12),
                        if (_afterPhoto != null)
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final photo = await picker.pickImage(source: ImageSource.camera);
                              if (photo != null) {
                                setDialogState(() {
                                  _afterPhoto = photo;
                                });
                              }
                            },
                            icon: const Icon(Icons.reply_rounded, color: Color(0xFF10B981), size: 16),
                            label: const Text(
                              'Retake',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF10B981)),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                      ],
                    );

                    final remarkWidget = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remark (Optional)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: remarkCtrl,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Input remark here...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.divider),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '-550 Karakter',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    );

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Documentation - After Reparation',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          isMobile
                              ? Column(
                                  children: [
                                    cameraWidget,
                                    const SizedBox(height: 24),
                                    remarkWidget,
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: cameraWidget),
                                    const SizedBox(width: 24),
                                    Expanded(child: remarkWidget),
                                  ],
                                ),
                          const SizedBox(height: 24),
                          // Action button
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _saveAndCompleteReparation(remarkCtrl.text);
                              },
                              icon: const Icon(Icons.save_outlined, size: 16),
                              label: const Text('Save & Completed Repairation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveAndCompleteReparation(String remark) async {
    setState(() => _isLoading = true);
    try {
      int? documentationAfterId;
      if (_afterPhoto != null) {
        final uploadRes = await LineStopService.uploadAttachment(_afterPhoto!);
        if (uploadRes.containsKey('data')) {
          final dataMap = uploadRes['data'] as Map<String, dynamic>;
          documentationAfterId = dataMap['id'] as int?;
        } else {
          documentationAfterId = uploadRes['id'] as int?;
        }
      }

      final elapsedSeconds = 900 - _secondsRemaining;
      final elapsedMinutes = (elapsedSeconds > 0 ? elapsedSeconds : 0) ~/ 60;
      final durationLsVal = elapsedMinutes > 0 ? elapsedMinutes : 14;
      final picCount = (_task.picUsernames != null && _task.picUsernames!.isNotEmpty)
          ? _task.picUsernames!.length
          : 1;
      final durationMhVal = durationLsVal * picCount;

      final payload = {
        'status': '3',  // Approved
        'problem_cd': _selectedProblemCd,
        'problem': _problemNameCtrl.text.trim(),
        'classification': _classificationCtrl.text.trim(),
        'rootcause': _selectedPenyebab,
        'countermeasure': _selectedPenanggulangan,
        'repaired_by': _selectedRepairedBy,
        'remark': remark.trim().isNotEmpty ? remark.trim() : '-',
        'sub_problem': _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : '-',
        'duration_ls': durationLsVal,
        'duration_mh': durationMhVal,
        'repaired_dt': DateTime.now().toIso8601String(),
        if (documentationAfterId != null) 'documentation_after_id': documentationAfterId,
      };

      final updated = await LineStopService.update(_task.id, payload);
      setState(() {
        _task = updated;
        _isTimerRunning = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reparation completed successfully'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete reparation: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _task.status == '3' || _task.status == '4';
    
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
                                        text: '${_task.id.padLeft(8, '0')}',
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

                             if (_loadingOptions)
                               const Center(
                                 child: Padding(
                                   padding: EdgeInsets.symmetric(vertical: 20),
                                   child: CircularProgressIndicator(),
                                 ),
                               )
                             else if (isCompleted) ...[
                               Row(
                                 children: [
                                   Expanded(child: _buildReadOnlyField('Problem Code', _selectedProblemCd ?? _task.problemCd ?? '-')),
                                   const SizedBox(width: 20),
                                   Expanded(child: _buildReadOnlyField('Problem Name', _problemNameCtrl.text.isNotEmpty ? _problemNameCtrl.text : (_task.problem ?? '-'))),
                                 ],
                               ),
                               const SizedBox(height: 16),
                               Row(
                                 children: [
                                   Expanded(child: _buildReadOnlyField('Classification', _classificationCtrl.text.isNotEmpty ? _classificationCtrl.text : (_task.classification ?? '-'))),
                                   const SizedBox(width: 20),
                                   Expanded(child: _buildReadOnlyField('Root Cause', _selectedPenyebab ?? _task.rootcause ?? '-')),
                                 ],
                               ),
                               const SizedBox(height: 16),
                               _buildReadOnlyField('Counter Measure', _selectedPenanggulangan ?? _task.countermeasure ?? '-'),
                               const SizedBox(height: 16),
                               _buildReadOnlyField('Note', _task.subProblem ?? (_noteCtrl.text.isNotEmpty ? _noteCtrl.text : '-')),
                               const SizedBox(height: 16),
                               _buildReadOnlyField('Remark', _task.remark ?? '-'),
                             ] else ...[
                               Row(
                                 children: [
                                   Expanded(
                                     child: _buildFormDropdown(
                                       label: 'Problem Code',
                                       isRequired: true,
                                       hint: 'Select Problem Code',
                                       value: _selectedProblemCdAndName,
                                       items: _problemOptions.map((e) => "${e['system_cd']} - ${e['system_value']}").toList(),
                                       onChanged: isCompleted ? null : _onProblemCdChanged,
                                     ),
                                   ),
                                   const SizedBox(width: 20),
                                   Expanded(
                                     child: _buildFormTextField(
                                       label: 'Problem Name',
                                       isRequired: true,
                                       hint: 'Problem name',
                                       controller: _problemNameCtrl,
                                       enabled: _isProblemNameEditable && !isCompleted,
                                     ),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 16),

                               Row(
                                 children: [
                                   Expanded(
                                     child: _buildFormTextField(
                                       label: 'Classification',
                                       isRequired: true,
                                       hint: 'Input classification',
                                       controller: _classificationCtrl,
                                       enabled: !isCompleted,
                                     ),
                                     /*
                                     child: _buildFormDropdown(
                                       label: 'Classification',
                                       isRequired: true,
                                       hint: 'Select Classification',
                                       value: _selectedClassification,
                                       items: _classificationOptions.map((e) => e['system_value'].toString()).toList(),
                                       onChanged: isCompleted ? null : (v) => setState(() => _selectedClassification = v),
                                     ),
                                     */
                                   ),
                                   const SizedBox(width: 20),
                                   Expanded(
                                     child: _buildFormDropdown(
                                       label: 'Root Cause',
                                       isRequired: true,
                                       hint: 'Select Rootcause',
                                       value: _selectedPenyebab,
                                       items: _rootcauseOptions.map((e) => e['system_value'].toString()).toList(),
                                       onChanged: isCompleted ? null : (v) => setState(() => _selectedPenyebab = v),
                                     ),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 16),

                               _buildFormDropdown(
                                 label: 'Counter Measure',
                                 isRequired: true,
                                 hint: 'Select Countermeasure',
                                 value: _selectedPenanggulangan,
                                 items: _countermeasureOptions.map((e) => e['system_value'].toString()).toList(),
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
                             ],

                             const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Detail Change Part',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (_task.partOrders != null && _task.partOrders!.isNotEmpty && !isCompleted)
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                        final res = await Navigator.pushNamed(
                                          context,
                                          AppRoutes.inventory,
                                          arguments: {
                                            'taskId': _task.id,
                                          },
                                        );
                                        if (res == true) {
                                          _refreshTask();
                                        }
                                      },
                                    icon: const Icon(Icons.add, color: Color(0xFF10B981), size: 14),
                                    label: const Text(
                                      'New Order Part',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF10B981)),
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      backgroundColor: const Color(0xFFECFDF5),
                                    ),
                                  ),
                              ],
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
                                if (isCompleted)
                                  Text(
                                    _changePartVal,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                else ...[
                                  Radio<String>(
                                    value: 'Yes',
                                    groupValue: _changePartVal,
                                    activeColor: AppColors.green,
                                    onChanged: (v) => setState(() => _changePartVal = v!),
                                  ),
                                  const Text('Yes', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 16),
                                  Radio<String>(
                                    value: 'No',
                                    groupValue: _changePartVal,
                                    activeColor: AppColors.green,
                                    onChanged: (v) => setState(() => _changePartVal = v!),
                                  ),
                                  const Text('No', style: TextStyle(fontSize: 13)),
                                ],
                              ],
                            ),
                            if (_changePartVal == 'Yes') ...[
                              const SizedBox(height: 12),
                              if (_task.partOrders == null || _task.partOrders!.isEmpty)
                                if (isCompleted)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text('No part ordered', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Center(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final res = await Navigator.pushNamed(
                                            context,
                                            AppRoutes.inventory,
                                            arguments: {
                                              'taskId': _task.id,
                                            },
                                          );
                                          if (res == true) {
                                            _refreshTask();
                                          }
                                        },
                                        icon: const Icon(Icons.add, color: Color(0xFF10B981), size: 18),
                                        label: const Text(
                                          'Add Part',
                                          style: TextStyle(
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF10B981)),
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          backgroundColor: const Color(0xFFECFDF5),
                                        ),
                                      ),
                                    ),
                                  )
                              else
                                ..._task.partOrders!.map((order) {
                                  final isWaiting = order.status == 'Waiting Confirmation';
                                  final isCanceled = order.status == 'Canceled by WH';
                                  
                                  Color statusBg = const Color(0xFFFFF7ED);
                                  Color statusBorder = const Color(0xFFFFEDD5);
                                  Color statusText = const Color(0xFFEA580C);
                                  
                                  if (isCanceled) {
                                    statusBg = const Color(0xFFFEF2F2);
                                    statusBorder = const Color(0xFFFEE2E2);
                                    statusText = const Color(0xFFDC2626);
                                  } else if (order.status == 'Approved' || order.status == 'Completed') {
                                    statusBg = const Color(0xFFF0FDF4);
                                    statusBorder = const Color(0xFFDCFCE7);
                                    statusText = const Color(0xFF16A34A);
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Order #${order.id}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isWaiting && !isCompleted)
                                                OutlinedButton.icon(
                                                  onPressed: () async {
                                                    final res = await Navigator.pushNamed(
                                                      context,
                                                      AppRoutes.inventory,
                                                      arguments: {
                                                        'taskId': _task.id,
                                                        'editOrder': order,
                                                      },
                                                    );
                                                    if (res == true) {
                                                      _refreshTask();
                                                    }
                                                  },
                                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF10B981), size: 12),
                                                  label: const Text(
                                                    'Edit Order',
                                                    style: TextStyle(
                                                      color: Color(0xFF10B981),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    side: const BorderSide(color: Color(0xFF10B981)),
                                                    shape: const StadiumBorder(),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    backgroundColor: Colors.white,
                                                  ),
                                                ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: statusBg,
                                                  border: Border.all(color: statusBorder),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  order.status,
                                                  style: TextStyle(
                                                    color: statusText,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                        SizedBox(
                                          height: 110,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.all(12),
                                            itemCount: order.details.length,
                                            itemBuilder: (context, itemIdx) {
                                              final item = order.details[itemIdx];
                                              return Container(
                                                width: 160,
                                                margin: const EdgeInsets.only(right: 12),
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      item.partName,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      item.partCd,
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Qty : ${item.qty}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFEA580C),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
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
                                // Repair Duration content
                                if (isCompleted) ...[
                                  const Text(
                                    'Repair Duration',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'L/H :',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  '${_task.durationLs ?? 14}',
                                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Minute', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'M/H :',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  '${_task.durationMh ?? 28}',
                                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Minute', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(color: AppColors.divider),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Repair By :',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _task.repairedBy ?? '-',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
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
                                        _formatDuration(_secondsRemaining),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
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
                                  _SwipeToFinish(onFinished: _finishReparation),
                                ],
                                const SizedBox(height: 24),

                                // Documentation area
                                const Text(
                                  'Documentation',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Before Reparation :',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),

                                _task.documentationBefore != null
                                  ? Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.divider),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            '${ApiConstants.baseUrl.replaceAll('/api/v1', '')}${_task.documentationBefore!.filePath}',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'No documentation photo',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                
                                if (isCompleted) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'After Reparation :',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  _task.documentationAfter != null
                                    ? Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.divider),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              '${ApiConstants.baseUrl.replaceAll('/api/v1', '')}${_task.documentationAfter!.filePath}',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.divider),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'No documentation photo',
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                ],
                                const SizedBox(height: 24),
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
                                _loadingHistory
                                    ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                                    : _historyTasks.isEmpty
                                        ? const Center(
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
                                          )
                                        : Column(
                                            children: _historyTasks.map((t) {
                                              final isExpanded = _expandedHistoryIds.contains(t.id);
                                              final durationLabel = '${t.durationLs ?? 14} Minute Reparation';
                                              final dateStr = t.repairedDt != null
                                                  ? t.repairedDt!.split('T')[0]
                                                  : '4 Mar 2026';

                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 20),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Left avatar and timeline line
                                                    Column(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(2),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            border: Border.all(color: Colors.orange, width: 2),
                                                          ),
                                                          child: const CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor: Color(0xFFF1F5F9),
                                                            child: Icon(Icons.person, size: 16, color: Colors.grey),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 2,
                                                          height: isExpanded ? 260 : 100,
                                                          color: Colors.orange.shade100,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Timeline content card
                                                    Expanded(
                                                      child: Card(
                                                        color: const Color(0xFFF8FAFC),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // Header
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        t.repairedBy ?? '-',
                                                                        style: const TextStyle(
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: AppColors.textPrimary,
                                                                        ),
                                                                      ),
                                                                      const Text(
                                                                        'Operator',
                                                                        style: TextStyle(
                                                                          fontSize: 11,
                                                                          color: AppColors.textMuted,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        dateStr,
                                                                        style: const TextStyle(
                                                                          fontSize: 11,
                                                                          color: AppColors.textSecondary,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        durationLabel,
                                                                        style: const TextStyle(
                                                                          fontSize: 11,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.orange,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              
                                                              if (isExpanded) ...[
                                                                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                                                                // Detail Fields
                                                                _buildHistoryDetailRow('Pros', t.problem ?? 'Lorem Ipsum'),
                                                                const SizedBox(height: 8),
                                                                _buildHistoryDetailRow('Klasifikasi', 'Lorem Ipsum'),
                                                                const SizedBox(height: 8),
                                                                _buildHistoryDetailRow('Problem', t.problem ?? 'Lorem Ipsum'),
                                                                const SizedBox(height: 8),
                                                                _buildHistoryDetailRow('Penyebab', t.rootcause ?? 'Lorem Ipsum'),
                                                                const SizedBox(height: 8),
                                                                _buildHistoryDetailRow('Penanggulangan', t.countermeasure ?? 'Lorem Ipsum'),
                                                              ],

                                                              const Divider(height: 24, color: Color(0xFFE2E8F0)),
                                                              // Toggle Button
                                                              Center(
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setState(() {
                                                                      if (isExpanded) {
                                                                        _expandedHistoryIds.remove(t.id);
                                                                      } else {
                                                                        _expandedHistoryIds.add(t.id);
                                                                      }
                                                                    });
                                                                  },
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text(
                                                                        isExpanded ? 'Hide More Detail' : 'View View Detail',
                                                                        style: const TextStyle(
                                                                          fontSize: 12,
                                                                          color: Color(0xFF10B981),
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 4),
                                                                      Icon(
                                                                        isExpanded
                                                                            ? Icons.keyboard_arrow_up
                                                                            : Icons.keyboard_arrow_down,
                                                                        size: 16,
                                                                        color: const Color(0xFF10B981),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
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

  Widget _buildReadOnlyField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value != null && value.isNotEmpty ? value : '-',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(bool isCompleted) {
    final statusLabel = _task.status == '1'
        ? 'On Progress'
        : _task.status == '2'
            ? 'Waiting Approval'
            : _task.status == '3'
                ? 'Approved'
                : _task.status == '4'
                    ? 'Rejected'
                    : 'On Progress';
    final statusColor = _task.status == '3'
        ? Colors.green
        : _task.status == '4'
            ? Colors.red
            : _task.status == '2'
                ? Colors.orange
                : Colors.blue;
    final dateTimeStr = DateFormatter.display(_task.repairedDt ?? _task.createdDt);
    
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
              _infoVal(_task.description ?? '2/5 : TRIM&PIERCE'),
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
              _infoLabel('Model'),
              const SizedBox(height: 6),
              _infoVal(_task.model ?? '-'),
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
              const SizedBox(height: 16),
              _infoLabel('PIC'),
              const SizedBox(height: 6),
              _infoVal(
                (_task.picUsernames != null && _task.picUsernames!.isNotEmpty)
                    ? _task.picUsernames!.join(', ')
                    : '-',
              ),
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

  Widget _buildFormTextField({
    required String label,
    required bool isRequired,
    required String hint,
    required TextEditingController controller,
    required bool enabled,
    int maxLines = 1,
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
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.repair),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
          ),
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
