import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mile_entry.dart';

class MileTrackerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<List<MileEntry>> getMileEntries() async {
    try {
      if (kDebugMode) {
        print('Fetching mile entries...');
      }
      
      final response = await _supabase
          .from('mile_entries')
          .select()
          .eq('user_id', _currentUserId)
          .order('date', ascending: false);
      
      if (kDebugMode) {
        print('Supabase response: $response');
      }
      
      return (response as List)
          .map((json) => MileEntry.fromMap(json))
          .toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching mile entries: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<MileEntry?> getMileEntryForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      if (kDebugMode) {
        print('Fetching entry for date: $startOfDay');
      }

      final response = await _supabase
          .from('mile_entries')
          .select()
          .eq('user_id', _currentUserId)
          .gte('date', startOfDay.toIso8601String())
          .lt('date', endOfDay.toIso8601String())
          .maybeSingle();
      
      if (kDebugMode) {
        print('Supabase response: $response');
      }
      
      if (response == null) return null;
      return MileEntry.fromMap(response);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching entry for date: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<MileEntry> addMileEntry(MileEntry entry) async {
    try {
      if (kDebugMode) {
        print('Adding mile entry: ${entry.toMap()}');
      }

      // Ensure the entry has the current user's ID
      final entryWithUserId = entry.copyWith(userId: _currentUserId);
      
      final response = await _supabase
          .from('mile_entries')
          .insert(entryWithUserId.toMap())
          .select()
          .single();
      
      if (kDebugMode) {
        print('Supabase response: $response');
      }
      
      return MileEntry.fromMap(response);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error adding mile entry: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> updateMileEntry(MileEntry entry) async {
    if (entry.id == null) {
      throw Exception('Cannot update entry without an ID');
    }
    
    try {
      if (kDebugMode) {
        print('Updating mile entry: ${entry.toMap()}');
      }

      await _supabase
          .from('mile_entries')
          .update(entry.toMap())
          .eq('id', entry.id!)
          .eq('user_id', _currentUserId);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error updating mile entry: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> deleteMileEntry(String id) async {
    try {
      if (kDebugMode) {
        print('Deleting mile entry with ID: $id');
      }

      await _supabase
          .from('mile_entries')
          .delete()
          .eq('id', id)
          .eq('user_id', _currentUserId);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error deleting mile entry: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Get daily totals for the current user
  Future<List<Map<String, dynamic>>> getDailyTotals() async {
    try {
      final response = await _supabase
          .from('daily_mile_totals')
          .select()
          .eq('user_id', _currentUserId)
          .order('date', ascending: false);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching daily totals: $e');
      }
      rethrow;
    }
  }

  // Get monthly totals for the current user
  Future<List<Map<String, dynamic>>> getMonthlyTotals() async {
    try {
      final response = await _supabase
          .from('monthly_mile_totals')
          .select()
          .eq('user_id', _currentUserId)
          .order('month', ascending: false);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching monthly totals: $e');
      }
      rethrow;
    }
  }
} 