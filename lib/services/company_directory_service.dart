import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_employee.dart';

class CompanyDirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _employeesCollection = FirebaseFirestore.instance.collection('company_directory');

  Future<List<CompanyEmployee>> getEmployees() async {
    try {
      final snapshot = await _employeesCollection
          .orderBy('last_name')
          .get();
      
      if (kDebugMode) {
        print('Firestore response: ${snapshot.docs.map((doc) => doc.data()).toList()}');
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CompanyEmployee.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting employees: $e');
      }
      rethrow;
    }
  }

  Future<CompanyEmployee> addEmployee(CompanyEmployee employee) async {
    try {
      final docRef = await _employeesCollection.add({
        ...employee.toMap(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      if (kDebugMode) {
        print('Firestore response: $data');
      }
      
      return CompanyEmployee.fromMap(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding employee: $e');
      }
      rethrow;
    }
  }

  Future<void> updateEmployee(CompanyEmployee employee) async {
    if (employee.id == null) {
      throw Exception('Cannot update employee without an ID');
    }
    
    try {
      await _employeesCollection.doc(employee.id).update({
        ...employee.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating employee: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _employeesCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting employee: $e');
      }
      rethrow;
    }
  }
} 