import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

// ─── Model ─────────────────────────────────────────────────────────

class DiesTask {
  final int id;
  final String taskType;
  final String? noreg;
  final String? partNo;
  final String? description;
  final String status;
  final String createdAt;

  const DiesTask({
    required this.id,
    required this.taskType,
    this.noreg,
    this.partNo,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory DiesTask.fromJson(Map<String, dynamic> json) => DiesTask(
        id: json['id'] as int,
        taskType: json['task_type'] as String,
        noreg: json['noreg'] as String?,
        partNo: json['part_no'] as String?,
        description: json['description'] as String?,
        status: json['status'] as String,
        createdAt: json['created_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'task_type': taskType,
        if (noreg != null) 'noreg': noreg,
        if (partNo != null) 'part_no': partNo,
        if (description != null) 'description': description,
        'status': status,
      };
}

// ─── Service ───────────────────────────────────────────────────────

/// Contoh penggunaan [ApiClient].
///
/// Tidak perlu set token — sudah dihandle otomatis oleh ApiClient
/// yang membaca dari SessionStore.
///
/// Contoh di UI:
/// ```dart
/// final tasks = await LineStopService.getAll();
/// await LineStopService.create(newTask);
/// ```
class LineStopService {
  LineStopService._();

  static const _endpoint = ApiConstants.lineStop;

  /// GET /api/v1/line-stop → List<DiesTask>
  static Future<List<DiesTask>> getAll() async {
    final data = await ApiClient.get(_endpoint) as List<dynamic>;
    return data.map((e) => DiesTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/line-stop/{id} → DiesTask
  static Future<DiesTask> getById(int id) async {
    final data = await ApiClient.get('$_endpoint/$id') as Map<String, dynamic>;
    return DiesTask.fromJson(data);
  }

  /// POST /api/v1/line-stop → DiesTask baru
  static Future<DiesTask> create(DiesTask task) async {
    final data = await ApiClient.post(_endpoint, body: task.toJson()) as Map<String, dynamic>;
    return DiesTask.fromJson(data);
  }

  /// PUT /api/v1/line-stop/{id} → DiesTask yang diupdate
  static Future<DiesTask> update(int id, Map<String, dynamic> payload) async {
    final data = await ApiClient.put('$_endpoint/$id', body: payload) as Map<String, dynamic>;
    return DiesTask.fromJson(data);
  }

  /// DELETE /api/v1/line-stop/{id}
  static Future<void> delete(int id) async {
    await ApiClient.delete('$_endpoint/$id');
  }
}
