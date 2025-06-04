import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_item.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the tasks collection reference for the current user
  CollectionReference get _tasksCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Add a new task
  Future<String> addTask(TodoItem task) async {
    try {
      final docRef = await _tasksCollection.add({
        ...task.toJson(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Get all tasks for the current user
  Stream<List<TodoItem>> getTasks() {
    return _tasksCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return TodoItem.fromJson(data);
          }).toList();
        });
  }

  // Update a task
  Future<void> updateTask(String id, TodoItem task) async {
    try {
      await _tasksCollection.doc(id).update({
        ...task.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
} 