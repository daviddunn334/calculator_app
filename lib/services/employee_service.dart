import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_employee.dart';
import 'package:firebase_core/firebase_core.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
  );
  final CollectionReference _employeesCollection;

  EmployeeService()
      : _employeesCollection = FirebaseFirestore.instance.collection('directory');

  // Add a new employee
  Future<String> addEmployee(CompanyEmployee employee) async {
    try {
      final docRef = await _employeesCollection.add({
        ...employee.toMap(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }

  // Get all employees
  Stream<List<CompanyEmployee>> getEmployees() {
    return _employeesCollection
        .orderBy('department')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;  // Add the document ID to the data
            return CompanyEmployee.fromMap(data);
          }).toList();
        });
  }

  // Update an employee
  Future<void> updateEmployee(String id, CompanyEmployee employee) async {
    try {
      await _employeesCollection.doc(id).update({
        ...employee.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  // Delete an employee
  Future<void> deleteEmployee(String id) async {
    try {
      await _employeesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // Get employees by department
  Stream<List<CompanyEmployee>> getEmployeesByDepartment(String department) {
    return _employeesCollection
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return CompanyEmployee.fromMap(data);
          }).toList();
        });
  }
} 