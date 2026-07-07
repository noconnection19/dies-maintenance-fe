import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

// ─── Attachment Model ──────────────────────────────────────────────

class Attachment {
  final int id;
  final String attachmentName;
  final String? mimetype;
  final int? size;
  final String filePath;

  const Attachment({
    required this.id,
    required this.attachmentName,
    this.mimetype,
    this.size,
    required this.filePath,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: json['id'] as int,
        attachmentName: (json['attachment_name'] ?? '').toString(),
        mimetype: json['mimetype'] as String?,
        size: json['size'] as int?,
        filePath: (json['file_path'] ?? '').toString(),
      );
}

class PartOrderItem {
  final String partCd;
  final String partName;
  final String? location;
  final int qty;

  const PartOrderItem({
    required this.partCd,
    required this.partName,
    this.location,
    required this.qty,
  });

  factory PartOrderItem.fromJson(Map<String, dynamic> json) => PartOrderItem(
        partCd: (json['part_cd'] ?? '').toString(),
        partName: (json['part_name'] ?? '').toString(),
        location: json['location'] as String?,
        qty: json['qty'] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'part_cd': partCd,
        'part_name': partName,
        if (location != null) 'location': location,
        'qty': qty,
      };
}

class PartOrder {
  final String id;
  final String diesReffId;
  final String status;
  final List<PartOrderItem> details;

  const PartOrder({
    required this.id,
    required this.diesReffId,
    required this.status,
    required this.details,
  });

  factory PartOrder.fromJson(Map<String, dynamic> json) {
    final list = json['details'] as List<dynamic>? ?? [];
    final details = list.map((e) => PartOrderItem.fromJson(e as Map<String, dynamic>)).toList();
    return PartOrder(
      id: (json['id'] ?? '').toString(),
      diesReffId: (json['dies_reff_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      details: details,
    );
  }
}

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
  final String? classification;
  final String? problemCd;
  final String? problem;
  final String? rootcause;
  final String? countermeasure;
  final String? remark;
  final String? subProblem;
  final String? repairedBy;
  final String? repairedDt;
  final String? noreg;
  final String? description;
  final String? createdBy;
  final String? createdDt;
  final int? documentationBeforeId;
  final int? documentationAfterId;
  final Attachment? documentationBefore;
  final Attachment? documentationAfter;
  final List<PartOrder>? partOrders;
  final String? operationSeq;
  final List<String>? picUsernames;

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
    this.classification,
    this.problemCd,
    this.problem,
    this.rootcause,
    this.countermeasure,
    this.remark,
    this.subProblem,
    this.repairedBy,
    this.repairedDt,
    this.noreg,
    this.description,
    this.createdBy,
    this.createdDt,
    this.documentationBeforeId,
    this.documentationAfterId,
    this.documentationBefore,
    this.documentationAfter,
    this.partOrders,
    this.operationSeq,
    this.picUsernames,
  });

  factory DiesTask.fromJson(Map<String, dynamic> json) {
    final ordersList = json['part_orders'] as List<dynamic>? ?? [];
    final partOrders = ordersList.map((e) => PartOrder.fromJson(e as Map<String, dynamic>)).toList();

    return DiesTask(
      id: (json['id'] ?? '').toString(),
      partNo: json['part_no'] as String?,
      lineCd: json['line_cd'] as String?,
      machineCd: json['machine_cd'] as String?,
      shift: json['shift'] as String?,
      status: json['status'] as String?,
      model: json['model'] as String?,
      durationLs: json['duration_ls'] as int?,
      durationMh: json['duration_mh'] as int?,
      classification: json['classification'] as String?,
      problemCd: json['problem_cd'] as String?,
      problem: json['problem'] as String?,
      rootcause: json['rootcause'] as String?,
      countermeasure: json['countermeasure'] as String?,
      remark: json['remark'] as String?,
      subProblem: json['sub_problem'] as String?,
      repairedBy: json['repaired_by'] as String?,
      repairedDt: json['repaired_dt'] as String?,
      noreg: json['noreg'] as String?,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String?,
      createdDt: json['created_dt'] as String?,
      documentationBeforeId: json['documentation_before_id'] as int?,
      documentationAfterId: json['documentation_after_id'] as int?,
      documentationBefore: json['documentation_before'] != null
          ? Attachment.fromJson(json['documentation_before'] as Map<String, dynamic>)
          : null,
      documentationAfter: json['documentation_after'] != null
          ? Attachment.fromJson(json['documentation_after'] as Map<String, dynamic>)
          : null,
      partOrders: partOrders,
      operationSeq: json['operation_seq'] as String?,
      picUsernames: json['pic_usernames'] != null
          ? (json['pic_usernames'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (partNo != null) 'part_no': partNo,
        if (lineCd != null) 'line_cd': lineCd,
        if (machineCd != null) 'machine_cd': machineCd,
        if (shift != null) 'shift': shift,
        if (status != null) 'status': status,
        if (model != null) 'model': model,
        if (durationLs != null) 'duration_ls': durationLs,
        if (durationMh != null) 'duration_mh': durationMh,
        if (classification != null) 'classification': classification,
        if (problemCd != null) 'problem_cd': problemCd,
        if (problem != null) 'problem': problem,
        if (rootcause != null) 'rootcause': rootcause,
        if (countermeasure != null) 'countermeasure': countermeasure,
        if (remark != null) 'remark': remark,
        if (subProblem != null) 'sub_problem': subProblem,
        if (repairedBy != null) 'repaired_by': repairedBy,
        if (noreg != null) 'noreg': noreg,
        if (description != null) 'description': description,
        if (documentationBeforeId != null) 'documentation_before_id': documentationBeforeId,
        if (documentationAfterId != null) 'documentation_after_id': documentationAfterId,
        if (operationSeq != null) 'operation_seq': operationSeq,
        if (picUsernames != null) 'pic_usernames': picUsernames,
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
    final response = await ApiClient.get('$_endpoint/$id') as Map<String, dynamic>;
    final taskData = response.containsKey('data') ? response['data'] as Map<String, dynamic> : response;
    return DiesTask.fromJson(taskData);
  }

  /// POST /api/v1/line-stop → DiesTask baru
  static Future<DiesTask> create(DiesTask task) async {
    final response = await ApiClient.post(_endpoint, body: task.toJson()) as Map<String, dynamic>;
    final taskData = response.containsKey('data') ? response['data'] as Map<String, dynamic> : response;
    return DiesTask.fromJson(taskData);
  }

  /// PUT /api/v1/line-stop/{id} → DiesTask yang diupdate
  static Future<DiesTask> update(String id, Map<String, dynamic> payload) async {
    final response = await ApiClient.put('$_endpoint/$id', body: payload) as Map<String, dynamic>;
    final taskData = response.containsKey('data') ? response['data'] as Map<String, dynamic> : response;
    return DiesTask.fromJson(taskData);
  }

  /// DELETE /api/v1/line-stop/{id}
  static Future<void> delete(String id) async {
    await ApiClient.delete('$_endpoint/$id');
  }

  /// POST /api/v1/attachments/upload → Upload Attachment
  static Future<Map<String, dynamic>> uploadAttachment(XFile file) async {
    final bytes = await file.readAsBytes();
    final response = await ApiClient.upload(
      '/attachments/upload',
      bytes: bytes,
      filename: file.name,
      mimeType: file.mimeType ?? 'image/jpeg',
    );
    return response as Map<String, dynamic>;
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

  /// GET /api/v1/line-stop/dies/{partNo}/operations → Ambil proses/operations berdasarkan part number
  static Future<List<Map<String, dynamic>>> getOperations(String partNo) async {
    final response = await ApiClient.get('$_endpoint/dies/$partNo/operations') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// GET /api/v1/line-stop/dies/{partNo}/machines → Ambil machines berdasarkan part number
  static Future<List<Map<String, dynamic>>> getMachinesForPart(String partNo) async {
    final response = await ApiClient.get('$_endpoint/dies/$partNo/machines') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// GET /api/v1/line-stop/dies/{partNo}/machines/{machineCd}/operations → Ambil proses berdasarkan part number dan machine
  static Future<List<Map<String, dynamic>>> getOperationsForMachine(String partNo, String machineCd) async {
    final response = await ApiClient.get('$_endpoint/dies/$partNo/machines/$machineCd/operations') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// POST /api/v1/line-stop/{taskId}/orders → Buat order part baru
  static Future<PartOrder> createPartOrder(String taskId, List<Map<String, dynamic>> items) async {
    final response = await ApiClient.post('$_endpoint/$taskId/orders', body: items) as Map<String, dynamic>;
    return PartOrder.fromJson(response);
  }

  /// PUT /api/v1/line-stop/orders/{orderId} → Update order part
  static Future<PartOrder> updatePartOrder(String orderId, List<Map<String, dynamic>> items) async {
    final response = await ApiClient.put('$_endpoint/orders/$orderId', body: items) as Map<String, dynamic>;
    return PartOrder.fromJson(response);
  }

  /// GET /api/v1/line-stop/systems?system_type={systemType} → Ambil master systems
  static Future<List<Map<String, dynamic>>> getSystems(String systemType) async {
    final response = await ApiClient.get('$_endpoint/systems?system_type=$systemType') as Map<String, dynamic>;
    final list = response['data'] as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
