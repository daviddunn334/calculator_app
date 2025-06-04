import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_item.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the tasks collection reference for the current user
  CollectionReference get _tasksCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print('Error: User not authenticated');
      throw Exception('User not authenticated');
    }
    print('Getting tasks collection for user: $userId');
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Add a new task
  Future<String> addTask(TodoItem task) async {
    try {
      print('Adding task: ${task.toJson()}');
      final docRef = await _tasksCollection.add({
        ...task.toJson(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Task added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding task: $e');
      throw Exception('Failed to add task: $e');
    }
  }

  // Get all tasks for the current user
  Stream<List<TodoItem>> getTasks() {
    try {
      print('Getting tasks for user: ${_auth.currentUser?.uid}');
      return _tasksCollection
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
            print('Received ${snapshot.docs.length} tasks');
            return snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return TodoItem.fromJson(data);
            }).toList();
          });
    } catch (e) {
      print('Error getting tasks: $e');
      throw Exception('Failed to get tasks: $e');
    }
  }

  // Update a task
  Future<void> updateTask(String id, TodoItem task) async {
    try {
      print('Updating task with ID: $id');
      await _tasksCollection.doc(id).update({
        ...task.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Task updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      print('Deleting task with ID: $id');
      await _tasksCollection.doc(id).delete();
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }
} 