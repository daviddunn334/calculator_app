import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show sqrt, pow;
import '../theme/app_theme.dart';

class B31GCalculator extends StatefulWidget {
  const B31GCalculator({super.key});

  @override
  State<B31GCalculator> createState() => _B31GCalculatorState();
}

class _B31GCalculatorState extends State<B31GCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _pitDepthController = TextEditingController();
  final _pitLengthController = TextEditingController();
  
  String? _result;
  String? _errorMessage;
  double? _allowableLength;

  // Hard-coded B31G tables for 30" OD
  static Map<String, Map<double, dynamic>> b31gTables = {
    '0.312': {
      0.0: 'Unlimited', 1.6: 'Unlimited', 3.2: 'Unlimited', 4.8: 'Unlimited', 6.4: 'Unlimited', 8.0: 'Unlimited', 9.6: 'Unlimited', 11.2: 13.71, 12.8: 13.71, 14.4: 13.71, 16.0: 13.71, 17.6: 13.32, 19.2: 10.41, 20.8: 8.34, 22.4: 7.17, 24.0: 6.33, 25.6: 5.70, 27.2: 5.21, 28.8: 4.81, 30.4: 4.48, 32.1: 4.20, 33.7: 3.96, 35.3: 3.75, 36.9: 3.56, 38.5: 3.40, 40.1: 3.25, 41.7: 3.11, 43.3: 2.99, 44.9: 2.88, 46.5: 2.77, 48.1: 2.68, 49.7: 2.59, 51.3: 2.50, 52.9: 2.42, 54.5: 2.35, 56.1: 2.28, 57.7: 2.21, 59.3: 2.15, 60.9: 2.09, 62.5: 2.03, 64.1: 1.98, 65.7: 1.93, 67.3: 1.88, 68.9: 1.83, 70.5: 1.78, 72.1: 1.74, 73.7: 1.69, 75.3: 1.65, 76.9: 1.61, 78.5: 1.57
    },
    '0.325': {
      0.0: 'Unlimited', 1.5: 'Unlimited', 3.1: 'Unlimited', 4.6: 'Unlimited', 6.2: 'Unlimited', 7.7: 'Unlimited', 9.2: 'Unlimited', 10.8: 13.99, 12.3: 13.99, 13.8: 13.99, 15.4: 13.99, 16.9: 13.99, 18.5: 13.99, 20.0: 11.65, 21.5: 9.73, 23.1: 6.94, 24.6: 6.21, 26.2: 5.65, 27.7: 5.20, 29.2: 4.83, 30.8: 4.51, 32.3: 4.25, 33.8: 4.01, 35.4: 3.81, 36.9: 3.63, 38.5: 3.47, 40.0: 3.32, 41.5: 3.19, 43.1: 3.07, 44.6: 2.96, 46.2: 2.85, 47.7: 2.76, 49.2: 2.67, 50.8: 2.58, 52.3: 2.50, 53.8: 2.43, 55.4: 2.36, 56.9: 2.29, 58.5: 2.23, 60.0: 2.17, 61.5: 2.11, 63.1: 2.05, 64.6: 2.00, 66.2: 1.95, 67.7: 1.90, 69.2: 1.86, 70.8: 1.81, 72.3: 1.77, 73.8: 1.72, 75.4: 1.68, 76.9: 1.64, 78.5: 1.61, 80.0: 1.57
    },
    '0.375': {
      0.0: 'Unlimited', 1.3: 'Unlimited', 2.7: 'Unlimited', 4.0: 'Unlimited', 5.3: 'Unlimited', 6.7: 'Unlimited', 8.0: 'Unlimited', 9.3: 'Unlimited', 10.7: 15.03, 12.0: 15.03, 13.3: 15.03, 14.7: 15.03, 16.0: 15.03, 17.3: 15.03, 18.7: 12.10, 20.0: 10.05, 21.3: 8.69, 22.7: 7.71, 24.0: 6.96, 25.3: 6.37, 26.7: 5.89, 28.0: 5.50, 29.3: 5.16, 30.7: 4.87, 32.0: 4.62, 33.3: 4.39, 34.7: 4.19, 36.0: 4.01, 37.3: 3.85, 38.7: 3.70, 40.0: 3.57, 41.3: 3.44, 42.7: 3.33, 44.0: 3.22, 45.3: 3.12, 46.7: 3.03, 48.0: 2.94, 49.3: 2.86, 50.7: 2.78, 52.0: 2.70, 53.3: 2.63, 54.7: 2.57, 56.0: 2.50, 57.3: 2.44, 58.7: 2.38, 60.0: 2.33, 61.3: 2.27, 62.7: 2.22, 64.0: 2.17, 65.3: 2.12, 66.7: 2.08, 68.0: 2.03, 69.3: 1.99, 70.7: 1.95, 72.0: 1.91, 73.3: 1.87, 74.7: 1.83, 76.0: 1.79, 77.3: 1.75, 78.7: 1.72, 80.0: 1.68
    },
    '0.406': {
      0.0: 'Unlimited', 1.2: 'Unlimited', 2.5: 'Unlimited', 3.7: 'Unlimited', 4.9: 'Unlimited', 6.2: 'Unlimited', 7.4: 'Unlimited', 8.6: 'Unlimited', 9.9: 'Unlimited', 11.1: 15.64, 12.3: 15.64, 13.5: 15.64, 14.8: 15.64, 16.0: 15.64, 17.2: 15.64, 18.5: 13.00, 19.7: 10.86, 20.9: 9.41, 22.2: 8.37, 23.4: 7.57, 24.6: 6.94, 25.9: 6.42, 27.1: 5.99, 28.3: 5.63, 29.6: 5.31, 30.8: 5.04, 32.0: 4.80, 33.3: 4.58, 34.5: 4.39, 35.7: 4.21, 36.9: 4.06, 38.2: 3.91, 39.4: 3.77, 40.6: 3.65, 41.9: 3.53, 43.1: 3.43, 44.3: 3.33, 45.6: 3.23, 46.8: 3.14, 48.0: 3.06, 49.3: 2.98, 50.5: 2.90, 51.7: 2.83, 53.0: 2.76, 54.2: 2.70, 55.4: 2.63, 56.7: 2.57, 57.9: 2.52, 59.1: 2.46, 60.3: 2.41, 61.6: 2.36, 62.8: 2.31, 64.0: 2.26, 65.3: 2.21, 66.5: 2.17, 67.7: 2.13, 69.0: 2.09, 70.2: 2.04, 71.4: 2.00, 72.7: 1.96, 73.9: 1.93, 75.1: 1.89, 76.4: 1.85, 77.6: 1.82, 78.8: 1.78
    },
    '0.344': {
      0.0: 'Unlimited', 1.5: 'Unlimited', 2.9: 'Unlimited', 4.4: 'Unlimited', 5.8: 'Unlimited', 7.3: 'Unlimited', 8.7: 'Unlimited', 10.2: 14.39, 11.6: 14.39, 13.1: 14.39, 14.5: 14.39, 16.0: 14.39, 17.4: 14.39, 18.9: 11.94, 20.3: 9.92, 21.8: 7.96, 23.3: 7.04, 24.7: 6.35, 26.2: 5.81, 27.6: 5.37, 29.1: 5.00, 30.5: 4.69, 32.0: 4.42, 33.4: 4.19, 34.9: 3.99, 36.3: 3.80, 37.8: 3.64, 39.2: 3.49, 40.7: 3.35, 42.2: 3.23, 43.6: 3.12, 45.1: 3.01, 46.5: 2.91, 48.0: 2.82, 49.4: 2.73, 50.9: 2.65, 52.3: 2.57, 53.8: 2.50, 55.2: 2.43, 56.7: 2.37, 58.1: 2.31, 59.6: 2.25, 61.0: 2.19, 62.5: 2.13, 64.0: 2.08, 65.4: 2.03, 66.9: 1.98, 68.3: 1.94, 69.8: 1.89, 71.2: 1.85, 72.7: 1.81, 74.1: 1.77, 75.6: 1.73, 77.0: 1.69, 78.5: 1.65, 79.9: 1.61
    },
    '0.365': {
      0.0: 'Unlimited', 1.4: 'Unlimited', 2.7: 'Unlimited', 4.1: 'Unlimited', 5.5: 'Unlimited', 6.8: 'Unlimited', 8.2: 'Unlimited', 9.6: 'Unlimited', 11.0: 14.82, 12.3: 14.82, 13.7: 14.82, 15.1: 14.82, 16.4: 14.82, 17.8: 13.90, 19.2: 11.06, 20.5: 9.31, 21.9: 8.11, 23.3: 7.24, 24.7: 6.56, 26.0: 6.03, 27.4: 5.59, 28.8: 5.22, 30.1: 4.91, 31.5: 4.64, 32.9: 4.41, 34.2: 4.20, 35.6: 4.01, 37.0: 3.84, 38.4: 3.69, 39.7: 3.55, 41.1: 3.42, 42.5: 3.30, 43.8: 3.19, 45.2: 3.09, 46.6: 2.99, 47.9: 2.90, 49.3: 2.82, 50.7: 2.74, 52.1: 2.67, 53.4: 2.59, 54.8: 2.53, 56.2: 2.46, 57.5: 2.40, 58.9: 2.34, 60.3: 2.29, 61.6: 2.23, 63.0: 2.18, 64.4: 2.13, 65.8: 2.08, 67.1: 2.04, 68.5: 1.99, 69.9: 1.95, 71.2: 1.91, 72.6: 1.86, 74.0: 1.82, 75.3: 1.79, 76.7: 1.75, 78.1: 1.71, 79.5: 1.68
    }
  };

  // Add new table for 36" OD, 0.344" wall thickness
  static Map<double, dynamic> b31gTable_36_0344 = {
    0.0: 'Unlimited', 1.5: 'Unlimited', 2.9: 'Unlimited', 4.4: 'Unlimited', 5.8: 'Unlimited', 7.3: 'Unlimited', 8.7: 'Unlimited', 10.2: 15.77, 11.6: 15.77, 13.1: 15.77, 14.5: 15.77, 16.0: 15.77, 17.4: 15.77, 18.9: 13.90, 20.3: 11.06, 21.8: 9.31, 23.3: 8.11, 24.7: 7.24, 26.2: 6.56, 27.6: 6.03, 29.1: 5.59, 30.5: 5.14, 32.0: 4.85, 33.4: 4.59, 34.9: 4.37, 36.3: 4.17, 37.8: 3.99, 39.2: 3.82, 40.7: 3.67, 42.2: 3.54, 43.6: 3.41, 45.1: 3.30, 46.5: 3.19, 48.0: 3.09, 49.4: 2.99, 50.9: 2.90, 52.3: 2.82, 53.8: 2.74, 55.2: 2.66, 56.7: 2.59, 58.1: 2.53, 59.6: 2.46, 61.0: 2.40, 62.5: 2.34, 64.0: 2.28, 65.4: 2.23, 66.9: 2.17, 68.3: 2.12, 69.8: 2.07, 71.2: 2.03, 72.7: 1.98, 74.1: 1.94, 75.6: 1.89, 77.0: 1.85, 78.5: 1.81, 79.9: 1.77
  };

  // Add new table for 36" OD, 0.406" wall thickness
  static Map<double, dynamic> b31gTable_36_0406 = {
    0.0: 'Unlimited', 1.2: 'Unlimited', 2.5: 'Unlimited', 3.7: 'Unlimited', 4.9: 'Unlimited', 6.2: 'Unlimited', 7.4: 'Unlimited', 8.6: 'Unlimited', 9.9: 'Unlimited', 11.1: 17.13, 12.3: 17.13, 13.5: 17.13, 14.8: 17.13, 16.0: 17.13, 17.2: 17.13, 18.5: 14.24, 19.7: 11.89, 20.9: 10.31, 22.2: 9.16, 23.4: 8.29, 24.6: 7.60, 25.9: 7.03, 27.1: 6.56, 28.3: 6.17, 29.6: 5.82, 30.8: 5.52, 32.0: 5.26, 33.3: 5.02, 34.5: 4.81, 35.7: 4.62, 36.9: 4.44, 38.2: 4.28, 39.4: 4.13, 40.6: 3.99, 41.9: 3.87, 43.1: 3.75, 44.3: 3.64, 45.6: 3.54, 46.8: 3.44, 48.0: 3.35, 49.3: 3.26, 50.5: 3.18, 51.7: 3.10, 53.0: 3.02, 54.2: 2.95, 55.4: 2.88, 56.7: 2.82, 57.9: 2.76, 59.1: 2.70, 60.3: 2.64, 61.6: 2.58, 62.8: 2.53, 64.0: 2.48, 65.3: 2.42, 66.5: 2.38, 67.7: 2.33, 69.0: 2.28, 70.2: 2.24, 71.4: 2.19, 72.7: 2.15, 73.9: 2.11, 75.1: 2.07, 76.4: 2.03, 77.6: 1.99, 78.8: 1.95
  };

  // Add new table for 36" OD, 0.412" wall thickness
  static Map<double, dynamic> b31gTable_36_0412 = {
    0.0: 'Unlimited', 1.2: 'Unlimited', 2.4: 'Unlimited', 3.6: 'Unlimited', 4.9: 'Unlimited', 6.1: 'Unlimited', 7.3: 'Unlimited', 8.5: 'Unlimited', 9.7: 17.25, 10.9: 17.25, 12.1: 17.25, 13.3: 17.25, 14.6: 17.25, 15.8: 17.25, 17.0: 17.25, 18.2: 15.02, 19.4: 12.44, 20.6: 10.73, 21.8: 9.50, 23.1: 8.57, 24.3: 7.84, 25.5: 7.25, 26.7: 6.76, 27.9: 6.34, 29.1: 5.98, 30.3: 5.67, 31.6: 5.39, 32.8: 5.15, 34.0: 4.93, 35.2: 4.73, 36.4: 4.55, 37.6: 4.38, 38.8: 4.23, 40.0: 4.09, 41.3: 3.96, 42.5: 3.84, 43.7: 3.73, 44.9: 3.62, 46.1: 3.52, 47.3: 3.43, 48.5: 3.34, 49.8: 3.25, 51.0: 3.17, 52.2: 3.09, 53.4: 3.02, 54.6: 2.95, 55.8: 2.88, 57.0: 2.82, 58.3: 2.76, 59.5: 2.70, 60.7: 2.64, 61.9: 2.59, 63.1: 2.53, 64.3: 2.48, 65.5: 2.43, 66.7: 2.38, 68.0: 2.34, 69.2: 2.29, 70.4: 2.25, 71.6: 2.20, 72.8: 2.16, 74.0: 2.12, 75.2: 2.08, 76.5: 2.04, 77.7: 2.00, 78.9: 1.97
  };

  // Add new table for 42" OD, 0.625" wall thickness
  static Map<double, dynamic> b31gTable_42_0625 = {
    0.0: 'Unlimited', 0.8: 'Unlimited', 1.6: 'Unlimited', 2.4: 'Unlimited', 3.2: 'Unlimited', 4.0: 'Unlimited', 4.8: 'Unlimited', 5.6: 'Unlimited', 6.4: 'Unlimited', 7.2: 'Unlimited', 8.0: 'Unlimited', 8.8: 'Unlimited', 9.6: 22.95, 10.4: 22.95, 11.2: 22.95, 12.0: 22.95, 12.8: 22.95, 13.6: 22.95, 14.4: 22.95, 15.2: 22.95, 16.0: 22.95, 16.8: 22.95, 17.6: 22.95, 18.4: 19.32, 19.2: 17.06, 20.0: 15.36, 20.8: 14.02, 21.6: 12.91, 22.4: 12.04, 23.2: 11.28, 24.0: 10.63, 24.8: 10.07, 25.6: 9.57, 26.4: 9.14, 27.2: 8.75, 28.0: 8.40, 28.8: 8.08, 29.6: 7.79, 30.4: 7.52, 31.2: 7.28, 32.0: 7.05, 32.8: 6.84, 33.6: 6.66, 34.4: 6.49, 35.2: 6.33, 36.0: 6.19, 36.8: 6.06, 37.6: 5.94, 38.4: 5.83, 39.2: 5.72, 40.0: 5.61, 40.8: 5.51, 41.6: 5.41, 42.4: 5.34, 43.2: 5.22, 44.0: 5.12, 44.8: 5.02, 45.6: 4.92, 46.4: 4.83, 47.2: 4.74, 48.0: 4.66, 48.8: 4.57, 49.6: 4.49, 50.4: 4.41, 51.2: 4.34, 52.0: 4.27, 52.8: 4.20, 53.6: 4.13, 54.4: 4.07, 55.2: 4.01, 56.0: 3.95, 56.8: 3.88, 57.6: 3.82, 58.4: 3.77, 59.2: 3.71, 60.0: 3.66, 60.8: 3.61, 61.6: 3.56, 62.4: 3.51, 63.2: 3.46, 64.0: 3.41, 64.8: 3.37, 65.6: 3.32, 66.4: 3.28, 67.2: 3.23, 68.0: 3.19, 68.8: 3.15, 69.6: 3.11, 70.4: 3.07, 71.2: 3.03, 72.0: 2.99, 72.8: 2.95, 73.6: 2.91, 74.4: 2.88, 75.2: 2.84, 76.0: 2.81, 76.8: 2.77, 77.6: 2.74, 78.4: 2.70, 79.2: 2.67, 80.0: 2.57
  };

  // Add new table for 48" OD, 0.750" wall thickness
  static Map<double, dynamic> b31gTable_48_0750 = {
    0.0: 'Unlimited', 0.7: 'Unlimited', 1.3: 'Unlimited', 2.0: 'Unlimited', 2.7: 'Unlimited', 3.3: 'Unlimited', 4.0: 'Unlimited', 4.7: 'Unlimited', 5.3: 'Unlimited', 6.0: 'Unlimited', 6.7: 'Unlimited', 7.3: 'Unlimited', 8.0: 26.88, 8.7: 26.88, 9.3: 26.88, 10.0: 26.88, 10.7: 26.88, 11.3: 26.88, 12.0: 26.88, 12.7: 26.88, 13.3: 26.88, 14.0: 26.88, 14.7: 26.88, 15.3: 26.88, 16.0: 26.88, 16.7: 26.88, 17.3: 26.88, 18.0: 24.29, 18.7: 21.66, 19.3: 19.61, 20.0: 17.99, 20.7: 16.65, 21.3: 15.54, 22.0: 14.60, 22.7: 13.78, 23.3: 13.04, 24.0: 12.45, 24.7: 11.89, 25.3: 11.40, 26.0: 10.95, 26.7: 10.54, 27.3: 10.17, 28.0: 9.83, 28.7: 9.51, 29.3: 9.23, 30.0: 8.96, 30.7: 8.71, 31.3: 8.48, 32.0: 8.26, 32.7: 8.05, 33.3: 7.86, 34.0: 7.67, 34.7: 7.50, 35.3: 7.34, 36.0: 7.18, 36.7: 7.03, 37.3: 6.89, 38.0: 6.76, 38.7: 6.63, 39.3: 6.50, 40.0: 6.38, 40.7: 6.27, 41.3: 6.16, 42.0: 6.06, 42.7: 5.95, 43.3: 5.86, 44.0: 5.76, 44.7: 5.67, 45.3: 5.58, 46.0: 5.50, 46.7: 5.42, 47.3: 5.34, 48.0: 5.26, 48.7: 5.18, 49.3: 5.11, 50.0: 5.04, 50.7: 4.97, 51.3: 4.90, 52.0: 4.84, 52.7: 4.77, 53.3: 4.71, 54.0: 4.65, 54.7: 4.59, 55.3: 4.54, 56.0: 4.48, 56.7: 4.42, 57.3: 4.37, 58.0: 4.32, 58.7: 4.26, 59.3: 4.21, 60.0: 4.16, 60.7: 4.12, 61.3: 4.07, 62.0: 4.03, 62.7: 3.98, 63.3: 3.94, 64.0: 3.89, 64.7: 3.84, 65.3: 3.80, 66.0: 3.76, 66.7: 3.71, 67.3: 3.66, 68.0: 3.61
  };

  // Add new table for 36" OD, 0.562" wall thickness
  static Map<double, dynamic> b31gTable_36_0562 = {
    0.0: 'Unlimited', 0.9: 'Unlimited', 1.8: 'Unlimited', 2.7: 'Unlimited', 3.6: 'Unlimited', 4.4: 'Unlimited', 5.3: 'Unlimited', 6.2: 'Unlimited', 7.1: 'Unlimited', 8.0: 'Unlimited', 8.9: 'Unlimited', 9.8: 'Unlimited', 10.7: 20.15, 11.6: 20.15, 12.5: 20.15, 13.4: 20.15, 14.3: 20.15, 15.1: 20.15, 16.0: 20.15, 16.9: 20.15, 17.8: 18.94, 18.7: 16.19, 19.6: 14.23, 20.5: 12.77, 21.4: 11.63, 22.2: 10.71, 23.1: 9.95, 24.0: 9.32, 24.9: 8.78, 25.8: 8.31, 26.7: 7.89, 27.6: 7.53, 28.5: 7.20, 29.4: 6.91, 30.3: 6.65, 31.1: 6.40, 32.0: 6.18, 32.9: 5.98, 33.8: 5.79, 34.7: 5.62, 35.6: 5.45, 36.5: 5.30, 37.4: 5.16, 38.3: 5.03, 39.1: 4.90, 40.0: 4.78, 40.9: 4.67, 41.8: 4.56, 42.7: 4.46, 43.6: 4.36, 44.5: 4.27, 45.4: 4.18, 46.3: 4.10, 47.2: 4.02, 48.0: 3.94, 48.9: 3.86, 49.8: 3.79, 50.7: 3.72, 51.6: 3.66, 52.5: 3.59, 53.4: 3.53, 54.3: 3.47, 55.2: 3.41, 56.0: 3.36, 56.9: 3.30, 57.8: 3.25, 58.7: 3.20, 59.6: 3.14, 60.5: 3.09, 61.4: 3.05, 62.3: 3.00, 63.2: 2.95, 64.1: 2.91, 65.0: 2.87, 65.8: 2.83, 66.7: 2.78, 67.6: 2.74, 68.5: 2.70, 69.4: 2.67, 70.3: 2.63, 71.2: 2.59, 72.1: 2.56, 73.0: 2.52, 73.8: 2.48, 74.7: 2.45, 75.6: 2.42, 76.5: 2.38, 77.4: 2.35, 78.3: 2.32, 79.2: 2.29
  };

  // Add new table for 42" OD, 0.420" wall thickness
  static Map<double, dynamic> b31gTable_42_0420 = {
    0.0: 'Unlimited', 1.2: 'Unlimited', 2.4: 'Unlimited', 3.6: 'Unlimited', 4.8: 'Unlimited', 6.0: 'Unlimited', 7.1: 'Unlimited', 8.3: 'Unlimited', 9.5: 'Unlimited', 10.7: 18.82, 11.9: 18.82, 13.1: 18.82, 14.3: 18.82, 15.5: 18.82, 16.7: 18.82, 17.9: 17.47, 19.0: 14.30, 20.2: 12.24, 21.4: 10.78, 22.6: 9.69, 23.8: 8.83, 25.0: 8.15, 26.2: 7.58, 27.4: 7.10, 28.6: 6.69, 29.8: 6.34, 31.0: 6.03, 32.1: 5.75, 33.3: 5.50, 34.5: 5.28, 35.7: 5.07, 36.9: 4.89, 38.1: 4.72, 39.3: 4.56, 40.5: 4.41, 41.7: 4.28, 42.9: 4.15, 44.0: 4.03, 45.2: 3.92, 46.4: 3.81, 47.6: 3.71, 48.8: 3.62, 50.0: 3.53, 51.2: 3.44, 52.4: 3.36, 53.6: 3.28, 54.8: 3.21, 56.0: 3.14, 57.1: 3.07, 58.3: 3.00, 59.5: 2.94, 60.7: 2.88, 61.9: 2.82, 63.1: 2.76, 64.3: 2.71, 65.5: 2.65, 66.7: 2.60, 67.9: 2.55, 69.0: 2.50, 70.2: 2.46, 71.4: 2.41, 72.6: 2.36, 73.8: 2.32, 75.0: 2.28, 76.2: 2.24, 77.4: 2.20, 78.6: 2.16, 79.8: 2.12
  };

  // Map OD to available wall thicknesses
  static const Map<String, List<String>> odToWallThickness = {
    '30"': ['0.312"', '0.325"', '0.344"', '0.365"', '0.375"', '0.406"'],
    '36"': ['0.344"', '0.406"', '0.412"', '0.562"'],
    '42"': ['0.625"', '0.420"'],
    '48"': ['0.750"'],
  };

  final List<String> _odOptions = ['30"', '36"', '42"', '48"'];

  String? _selectedOD;
  String? _selectedWallThickness;

  @override
  void dispose() {
    _pitDepthController.dispose();
    _pitLengthController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = null;
      _errorMessage = null;
      _allowableLength = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final wallThickness = double.parse(_selectedWallThickness!.replaceAll('"', ''));
        final pitDepth = double.parse(_pitDepthController.text);
        final pitLength = double.parse(_pitLengthController.text);
        final wallKey = _selectedWallThickness!.replaceAll('"', '');

        // Calculate % Depth
        final percentDepth = (pitDepth / wallThickness) * 100;
        Map<double, dynamic>? table;
        if (_selectedOD == '36"' && wallKey == '0.344') {
          table = b31gTable_36_0344;
        } else if (_selectedOD == '36"' && wallKey == '0.406') {
          table = b31gTable_36_0406;
        } else if (_selectedOD == '36"' && wallKey == '0.412') {
          table = b31gTable_36_0412;
        } else if (_selectedOD == '36"' && wallKey == '0.562') {
          table = b31gTable_36_0562;
        } else if (_selectedOD == '42"' && wallKey == '0.625') {
          table = b31gTable_42_0625;
        } else if (_selectedOD == '42"' && wallKey == '0.420') {
          table = b31gTable_42_0420;
        } else if (_selectedOD == '48"' && wallKey == '0.750') {
          table = b31gTable_48_0750;
        } else {
          table = b31gTables[wallKey];
        }
        if (table == null) {
          setState(() {
            _errorMessage = 'No table for selected wall thickness.';
          });
          return;
        }
        // Find the smallest % Depth key >= percentDepth
        final sortedKeys = table.keys.toList()..sort();
        double? lookupKey;
        for (final k in sortedKeys) {
          if (percentDepth <= k) {
            lookupKey = k;
            break;
          }
        }
        if (lookupKey == null) {
          setState(() {
            _errorMessage = 'Pit depth exceeds table range.';
          });
          return;
        }
        final allowable = table[lookupKey];
        setState(() {
          if (allowable == 'Unlimited') {
            _result = 'Pass';
            _allowableLength = double.infinity;
          } else {
            _allowableLength = allowable;
            _result = pitLength <= _allowableLength! ? 'Pass' : 'Fail';
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Please enter valid numbers';
          _allowableLength = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get wall thickness options for selected OD
    final wallThicknessOptions = _selectedOD != null
        ? odToWallThickness[_selectedOD!] ?? []
        : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              side: const BorderSide(color: AppTheme.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textPrimary,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'B31G Calculator',
                                style: AppTheme.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    DropdownButtonFormField<String>(
                      value: _selectedOD,
                      decoration: const InputDecoration(
                        labelText: 'Pipe OD',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _odOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOD = newValue;
                          _selectedWallThickness = null; // Reset wall thickness when OD changes
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select pipe OD';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedWallThickness,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Wall Thickness',
                        prefixIcon: Icon(Icons.height),
                      ),
                      items: wallThicknessOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedWallThickness = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select wall thickness';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _pitDepthController,
                      decoration: const InputDecoration(
                        labelText: 'Pit Depth',
                        hintText: 'Enter pit depth',
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.vertical_align_bottom),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pit depth';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _pitLengthController,
                      decoration: const InputDecoration(
                        labelText: 'Pit Length',
                        hintText: 'Enter pit length',
                        suffixText: 'inches',
                        prefixIcon: Icon(Icons.arrow_forward),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pit length';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppTheme.paddingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.paddingLarge),
                    if (_result != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - (AppTheme.paddingLarge * 6),
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: _result == 'Pass' 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Result',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: _result == 'Pass' ? Colors.green : Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.paddingMedium),
                                Text(
                                  _result!,
                                  style: AppTheme.headlineLarge.copyWith(
                                    color: _result == 'Pass' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_allowableLength != null) ...[
                                  const SizedBox(height: AppTheme.paddingMedium),
                                  Text(
                                    _allowableLength == double.infinity
                                        ? 'Allowable Length: Unlimited'
                                        : 'Allowable Length:\n${_allowableLength!.toStringAsFixed(2)} inches',
                                    style: AppTheme.titleLarge.copyWith(
                                      color: AppTheme.accent1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Calculate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.paddingMedium,
                      horizontal: AppTheme.paddingLarge,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 