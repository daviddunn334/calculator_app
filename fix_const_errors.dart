import 'dart:io';

void main() async {
  // Get all Dart files in the lib directory
  final libDir = Directory('lib');
  final files = await _getAllDartFiles(libDir);
  
  int fixedFiles = 0;
  int totalFixes = 0;
  
  for (final file in files) {
    final content = await File(file).readAsString();
    
    // Look for patterns like "const ... AppTheme."
    final newContent = content.replaceAllMapped(
      RegExp(r'const\s+([^;]*AppTheme\.[^;]*)', multiLine: true),
      (match) {
        // Replace const with nothing, keeping the rest of the expression
        return match.group(1)!;
      }
    );
    
    if (content != newContent) {
      await File(file).writeAsString(newContent);
      final fixes = content.split('const').length - newContent.split('const').length;
      totalFixes += fixes;
      fixedFiles++;
      print('Fixed $fixes const issues in $file');
    }
  }
  
  print('\nSummary: Fixed $totalFixes const issues in $fixedFiles files');
}

Future<List<String>> _getAllDartFiles(Directory dir) async {
  final files = <String>[];
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity.path);
    }
  }
  
  return files;
}
