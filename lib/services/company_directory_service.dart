import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_employee.dart';

class CompanyDirectoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CompanyEmployee>> getEmployees() async {
    try {
      final response = await _supabase
          .from('company_directory')
          .select()
          .order('last_name');
      
      if (kDebugMode) {
        print('Supabase response: $response');
      }
      
      return (response as List)
          .map((json) => CompanyEmployee.fromMap(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting employees: $e');
      }
      rethrow;
    }
  }

  Future<CompanyEmployee> addEmployee(CompanyEmployee employee) async {
    try {
      final response = await _supabase
          .from('company_directory')
          .insert(employee.toMap())
          .select()
          .single();
      
      if (kDebugMode) {
        print('Supabase response: $response');
      }
      
      return CompanyEmployee.fromMap(response);
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
      await _supabase
          .from('company_directory')
          .update(employee.toMap())
          .eq('id', employee.id!);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating employee: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await _supabase
          .from('company_directory')
          .delete()
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting employee: $e');
      }
      rethrow;
    }
  }
} 