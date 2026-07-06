import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

// ─── Model ─────────────────────────────────────────────────────────

class DiesTask {
  final String id;
  final String? partNo;
  final String? lineCd;
  final String? machineCd;
  final String? shift;
  final String? status;
  final String? model;
  final int? durationLs;
  final int? durationMh;
  final String? problem;
  final String? rootcause;
  final String? countermeasure;
  final String? repairedBy;
  final String? repairedDt;
  final String? noreg;
  final String? description;
  final String? createdBy;
  final String? createdDt;

  const DiesTask({
    required this.id,
    this.partNo,
    this.lineCd,
    this.machineCd,
    this.shift,
    this.status,
    this.model,
    this.durationLs,
    this.durationMh,
    this.problem,
    this.rootcause,
    this.countermeasure,
    this.repairedBy,
    this.repairedDt,
    this.noreg,
    this.description,
    this.createdBy,
    this.createdDt,
  });

  factory DiesTask.fromJson(Map<String, dynamic> json) => DiesTask(
        id: (json['id'] ?? '').toString(),
        partNo: json['part_no'] as String?,
        lineCd: json['line_cd'] as String?,
        machineCd: json['machine_cd'] as String?,
        shift: json['shift'] as String?,
        status: json['status'] as String?,
        model: json['model'] as String?,
        durationLs: json['duration_ls'] as int?,
        durationMh: json['duration_mh'] as int?,
        problem: json['problem'] as String?,
        rootcause: json['rootcause'] as String?,
        countermeasure: json['countermeasure'] as String?,
        repairedBy: json['repaired_by'] as String?,
        repairedDt: json['repaired_dt'] as String?,
        noreg: json['noreg'] as String?,
        description: json['description'] as String?,
        createdBy: json['created_by'] as String?,
        createdDt: json['created_dt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (partNo != null) 'part_no': partNo,
        if (lineCd != null) 'line_cd': lineCd,
        if (machineCd != null) 'machine_cd': machineCd,
        if (shift != null) 'shift': shift,
        if (status != null) 'status': status,
        if (model != null) 'model': model,
        if (durationLs != null) 'duration_ls': durationLs,
        if (durationMh != null) 'duration_mh': durationMh,
        if (problem != null) 'problem': problem,
        if (rootcause != null) 'rootcause': rootcause,
        if (countermeasure != null) 'countermeasure': countermeasure,
        if (repairedBy != null) 'repaired_by': repairedBy,
        if (noreg != null) 'noreg': noreg,
        if (description != null) 'description': description,
      };
}

// ─── Service ───────────────────────────────────────────────────────

class LineStopService {
  LineStopService._();

  static const _endpoint = ApiConstants.lineStop;

  /// GET /api/v1/line-stop → Ambil data terpaginasi beserta total record
  static Future<Map<String, dynamic>> getPaginated({int page = 1, int size = 20, String? status}) async {
    String url = '$_endpoint?page=$page&size=$size';
    if (status != null) {
      url += '&status=$status';
    }
    final response = await ApiClient.get(url) as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    final items = list.map((e) => DiesTask.fromJson(e as Map<String, dynamic>)).toList();
    return {
      'items': items,
      'total': response['pagination']['total'] as int,
    };
  }

  /// GET /api/v1/line-stop/{id} → DiesTask
  static Future<DiesTask> getById(String id) async {
    final data = await ApiClient.get('$_endpoint/$id') as Map<String, dynamic>;
    return DiesTask.fromJson(data);
  }

  /// POST /api/v1/line-stop → DiesTask baru
  static Future<DiesTask> create(DiesTask task) async {
    final data = await ApiClient.post(_endpoint, body: task.toJson()) as Map<String, dynamic>;
    return DiesTask.fromJson(data);
  }

  /// PUT /api/v1/line-stop/{id} → DiesTask yang diupdate
  static Future<DiesTask> update(String id, Map<String, dynamic> payload) async {
    final data = await ApiClient.put('$_endpoint/$id', body: payload) as Map<String, dynamic>;
    return DiesTask.fromJson(data);
  }

  /// DELETE /api/v1/line-stop/{id}
  static Future<void> delete(String id) async {
    await ApiClient.delete('$_endpoint/$id');
  }

  // ── Master data helpers ────────────────────────────────────────────

  /// GET /api/v1/line-stop/lines → Ambil semua master lines
  static Future<List<Map<String, dynamic>>> getLines() async {
    final response = await ApiClient.get('$_endpoint/lines') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// GET /api/v1/line-stop/machines → Ambil semua master machines
  static Future<List<Map<String, dynamic>>> getMachines() async {
    final response = await ApiClient.get('$_endpoint/machines') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// GET /api/v1/line-stop/dies → Ambil semua master dies
  static Future<List<Map<String, dynamic>>> getDies() async {
    final response = await ApiClient.get('$_endpoint/dies') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// GET /api/v1/line-stop/pics → Ambil semua user/PIC
  static Future<List<Map<String, dynamic>>> getPics() async {
    final response = await ApiClient.get('$_endpoint/pics') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
