import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_employee.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _employeesCollection;

  EmployeeService() : _employeesCollection = FirebaseFirestore.instance.collection('directory');

  // Add a new employee
  Future<String> addEmployee(CompanyEmployee employee) async {
    try {
      print('Adding employee: ${employee.toMap()}');
      final docRef = await _employeesCollection.add({
        ...employee.toMap(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Employee added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding employee: $e');
      throw Exception('Failed to add employee: $e');
    }
  }

  // Get all employees
  Stream<List<CompanyEmployee>> getEmployees() {
    try {
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
    } catch (e) {
      print('Error getting employees: $e');
      throw Exception('Failed to get employees: $e');
    }
  }

  // Update an employee
  Future<void> updateEmployee(String id, CompanyEmployee employee) async {
    try {
      print('Updating employee with ID: $id');
      await _employeesCollection.doc(id).update({
        ...employee.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Employee updated successfully');
    } catch (e) {
      print('Error updating employee: $e');
      throw Exception('Failed to update employee: $e');
    }
  }

  // Delete an employee
  Future<void> deleteEmployee(String id) async {
    try {
      print('Deleting employee with ID: $id');
      await _employeesCollection.doc(id).delete();
      print('Employee deleted successfully');
    } catch (e) {
      print('Error deleting employee: $e');
      throw Exception('Failed to delete employee: $e');
    }
  }

  // Get employees by department
  Stream<List<CompanyEmployee>> getEmployeesByDepartment(String department) {
    try {
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
    } catch (e) {
      print('Error getting employees by department: $e');
      throw Exception('Failed to get employees by department: $e');
    }
  }
} 