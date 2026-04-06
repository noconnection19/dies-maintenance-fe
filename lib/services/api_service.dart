import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskModel {
  final int? id;
  final String taskType;
  final String? noreg;
  final String? partNo;
  final String? description;
  final String status;

  TaskModel({
    this.id,
    required this.taskType,
    this.noreg,
    this.partNo,
    this.description,
    required this.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      taskType: json['task_type'],
      noreg: json['noreg'],
      partNo: json['part_no'],
      description: json['description'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_type': taskType,
      'noreg': noreg,
      'part_no': partNo,
      'description': description,
      'status': status,
    };
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Function to get tasks by endpoint (e.g., 'line-stop')
  static Future<List<TaskModel>> getTasks(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Create Task
  static Future<TaskModel> createTask(String endpoint, TaskModel task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  // Update Task
  static Future<TaskModel> updateTask(String endpoint, int id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  // Delete Task
  static Future<void> deleteTask(String endpoint, int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
