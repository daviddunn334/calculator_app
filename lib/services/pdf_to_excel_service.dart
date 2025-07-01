import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html show Blob, Url, document, AnchorElement;

class PdfToExcelService {
  /// Picks a PDF file from device storage
  Future<PdfFileData?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        // For web platform, use bytes directly
        if (kIsWeb) {
          return PdfFileData(
            bytes: result.files.single.bytes!,
            name: result.files.single.name,
          );
        } 
        // For mobile/desktop platforms, use file path
        else if (result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final bytes = await file.readAsBytes();
          return PdfFileData(
            bytes: bytes,
            name: result.files.single.name,
            file: file,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error picking PDF file: $e');
      return null;
    }
  }

  /// Extracts hardness values from PDF file data
  Future<List<HardnessValue>> extractHardnessValues(PdfFileData pdfData) async {
    try {
      // Read PDF file from bytes
      final PdfDocument document = PdfDocument(inputBytes: pdfData.bytes);
      
      List<HardnessValue> hardnessValues = [];
      
      // Extract text from all pages
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String text = extractor.extractText(startPageIndex: i, endPageIndex: i);
        
        // Parse hardness values from extracted text
        final pageValues = _parseHardnessValues(text, i + 1);
        hardnessValues.addAll(pageValues);
      }
      
      // Close the document
      document.dispose();
      
      // Sort by sequence number to maintain order
      hardnessValues.sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
      
      return hardnessValues;
    } catch (e) {
      print('Error extracting hardness values: $e');
      rethrow;
    }
  }

  /// Parses hardness values from text using regex patterns
  List<HardnessValue> _parseHardnessValues(String text, int pageNumber) {
    List<HardnessValue> values = [];
    
    // Common patterns for hardness values in PDFs
    // Pattern 1: "1 188.2" (number followed by HB value)
    final RegExp pattern1 = RegExp(r'(\d+)\s+(\d+\.?\d*)\s*(?:HB|hb)?', multiLine: true);
    
    // Pattern 2: "1. 188.2" (number with dot followed by HB value)
    final RegExp pattern2 = RegExp(r'(\d+)\.\s+(\d+\.?\d*)\s*(?:HB|hb)?', multiLine: true);
    
    // Pattern 3: "HB1: 188.2" (HB prefix with number)
    final RegExp pattern3 = RegExp(r'(?:HB|hb)(\d+):\s*(\d+\.?\d*)', multiLine: true);
    
    // Pattern 4: Table format with multiple values per line
    final RegExp pattern4 = RegExp(r'(\d+\.?\d+)\s+(\d+\.?\d+)\s+(\d+\.?\d+)', multiLine: true);
    
    // Try pattern 1
    final matches1 = pattern1.allMatches(text);
    for (final match in matches1) {
      final sequenceStr = match.group(1);
      final valueStr = match.group(2);
      
      if (sequenceStr != null && valueStr != null) {
        final sequence = int.tryParse(sequenceStr);
        final value = double.tryParse(valueStr);
        
        if (sequence != null && value != null && value > 50 && value < 1000) {
          // Reasonable range for hardness values
          values.add(HardnessValue(
            sequenceNumber: sequence,
            hardnessValue: value,
            pageNumber: pageNumber,
            rawText: match.group(0) ?? '',
          ));
        }
      }
    }
    
    // Try pattern 2 if no values found
    if (values.isEmpty) {
      final matches2 = pattern2.allMatches(text);
      for (final match in matches2) {
        final sequenceStr = match.group(1);
        final valueStr = match.group(2);
        
        if (sequenceStr != null && valueStr != null) {
          final sequence = int.tryParse(sequenceStr);
          final value = double.tryParse(valueStr);
          
          if (sequence != null && value != null && value > 50 && value < 1000) {
            values.add(HardnessValue(
              sequenceNumber: sequence,
              hardnessValue: value,
              pageNumber: pageNumber,
              rawText: match.group(0) ?? '',
            ));
          }
        }
      }
    }
    
    // Try pattern 3 if still no values found
    if (values.isEmpty) {
      final matches3 = pattern3.allMatches(text);
      for (final match in matches3) {
        final sequenceStr = match.group(1);
        final valueStr = match.group(2);
        
        if (sequenceStr != null && valueStr != null) {
          final sequence = int.tryParse(sequenceStr);
          final value = double.tryParse(valueStr);
          
          if (sequence != null && value != null && value > 50 && value < 1000) {
            values.add(HardnessValue(
              sequenceNumber: sequence,
              hardnessValue: value,
              pageNumber: pageNumber,
              rawText: match.group(0) ?? '',
            ));
          }
        }
      }
    }
    
    // Try to extract values from table format if still no values
    if (values.isEmpty) {
      final lines = text.split('\n');
      int sequenceCounter = 1;
      
      for (final line in lines) {
        // Look for lines with multiple numeric values
        final numbers = RegExp(r'\d+\.?\d*').allMatches(line);
        final numberList = numbers.map((m) => double.tryParse(m.group(0) ?? '')).where((n) => n != null).cast<double>().toList();
        
        // If we find 2-3 numbers in a line, they might be hardness values
        if (numberList.length >= 2) {
          for (final number in numberList) {
            if (number > 50 && number < 1000) {
              values.add(HardnessValue(
                sequenceNumber: sequenceCounter++,
                hardnessValue: number,
                pageNumber: pageNumber,
                rawText: line.trim(),
              ));
            }
          }
        }
      }
    }
    
    return values;
  }

  /// Converts hardness values to Excel file matching the exact format from the provided example
  Future<ExcelFileData> convertToExcel(List<HardnessValue> hardnessValues, String originalFileName) async {
    try {
      // Create a new Excel workbook
      final excel = Excel.createExcel();
      
      // Get the default sheet without trying to rename or delete
      final sheet = excel.sheets.values.first;
      
      // Add the header rows to match the exact format
      // Row 1: "Equotip measurement report" across all columns
      for (int col = 0; col < 15; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).value = 'Equotip measurement report';
      }
      
      // Row 2: "Table View" across all columns
      for (int col = 0; col < 15; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1)).value = 'Table View';
      }
      
      // Row 3: Column headers for the data sections
      // First section (columns A-G)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = '#';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2)).value = '#';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2)).value = 'HB';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 2)).value = 'HB';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 2)).value = '---';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 2)).value = '---';
      
      // Second section (columns H-N)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 2)).value = '#';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 2)).value = '#';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 2)).value = 'HB';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 2)).value = 'HB';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 2)).value = '---';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 2)).value = '---';
      
      // Define the layout properties
      const int valuesPerSection = 42;
      const int columnOffset = 7;
      int startRow = 3; // Start from row 4 (index 3)

      // Fill the first 84 values in the two-column format
      int twoColumnLimit = hardnessValues.length > 84 ? 84 : hardnessValues.length;
      for (int i = 0; i < twoColumnLimit; i++) {
        final value = hardnessValues[i];
        int sectionIndex = i ~/ valuesPerSection;
        int rowInSection = i % valuesPerSection;
        int actualRow = startRow + rowInSection;
        int colOffset = sectionIndex * columnOffset;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1 + colOffset, rowIndex: actualRow)).value = value.sequenceNumber;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2 + colOffset, rowIndex: actualRow)).value = value.sequenceNumber;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3 + colOffset, rowIndex: actualRow)).value = value.hardnessValue;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4 + colOffset, rowIndex: actualRow)).value = value.hardnessValue;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5 + colOffset, rowIndex: actualRow)).value = '---';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6 + colOffset, rowIndex: actualRow)).value = '---';
      }

      // Fill the rest of the values in a single column format from row 49
      if (hardnessValues.length > 84) {
        int singleColumnStartRow = 48; // Start from row 49 (index 48)
        for (int i = 84; i < hardnessValues.length; i++) {
          final value = hardnessValues[i];
          int actualRow = singleColumnStartRow + (i - 84);

          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: actualRow)).value = value.sequenceNumber;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: actualRow)).value = value.hardnessValue;
        }
      }
      
      // Generate Excel bytes
      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('Failed to generate Excel file');
      }
      
      final fileName = '${originalFileName.replaceAll('.pdf', '')}_hardness_data.xlsx';
      
      // For web platform, return bytes directly
      if (kIsWeb) {
        return ExcelFileData(
          bytes: Uint8List.fromList(excelBytes),
          name: fileName,
        );
      } 
      // For mobile/desktop platforms, save to file
      else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(excelBytes);
        
        return ExcelFileData(
          bytes: Uint8List.fromList(excelBytes),
          name: fileName,
          file: file,
        );
      }
    } catch (e) {
      print('Error converting to Excel: $e');
      rethrow;
    }
  }

  /// Shares the Excel file
  Future<void> shareExcelFile(ExcelFileData excelData) async {
    try {
      if (kIsWeb) {
        // On web, trigger download
        await _downloadFileOnWeb(excelData.bytes, excelData.name);
      } else if (excelData.file != null) {
        // On mobile/desktop, use share functionality
        await Share.shareXFiles(
          [XFile(excelData.file!.path)],
          subject: 'Hardness Data Excel File',
          text: 'Converted hardness data from PDF to Excel format.',
        );
      } else {
        throw Exception('No file available for sharing');
      }
    } catch (e) {
      print('Error sharing Excel file: $e');
      rethrow;
    }
  }

  /// Downloads file on web platform
  Future<void> _downloadFileOnWeb(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // Use web-specific download functionality
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Gets a preview of extracted values for user confirmation
  String getPreviewText(List<HardnessValue> values) {
    if (values.isEmpty) {
      return 'No hardness values found in the PDF file.';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Found ${values.length} hardness values:');
    buffer.writeln('');
    
    // Show first 10 values as preview
    final previewCount = values.length > 10 ? 10 : values.length;
    for (int i = 0; i < previewCount; i++) {
      final value = values[i];
      buffer.writeln('${value.sequenceNumber}. ${value.hardnessValue} HB (Page ${value.pageNumber})');
    }
    
    if (values.length > 10) {
      buffer.writeln('... and ${values.length - 10} more values');
    }
    
    buffer.writeln('');
    if (values.isNotEmpty) {
      final hardnessData = values.map((v) => v.hardnessValue).toList();
      final total = hardnessData.reduce((a, b) => a + b);
      final average = total / hardnessData.length;
      final highest = hardnessData.reduce((a, b) => a > b ? a : b);
      final lowest = hardnessData.reduce((a, b) => a < b ? a : b);
      final range = highest - lowest;

      buffer.writeln('Total Values: ${hardnessData.length}');
      buffer.writeln('Average: ${average.toStringAsFixed(2)} HB');
      buffer.writeln('Highest: ${highest.toStringAsFixed(2)} HB');
      buffer.writeln('Range: ${range.toStringAsFixed(2)} HB');
    }
    
    return buffer.toString();
  }
}

/// Model class for PDF file data that works on both web and mobile
class PdfFileData {
  final Uint8List bytes;
  final String name;
  final File? file; // Only available on mobile/desktop platforms

  PdfFileData({
    required this.bytes,
    required this.name,
    this.file,
  });
}

/// Model class for Excel file data that works on both web and mobile
class ExcelFileData {
  final Uint8List bytes;
  final String name;
  final File? file; // Only available on mobile/desktop platforms

  ExcelFileData({
    required this.bytes,
    required this.name,
    this.file,
  });
}

/// Model class for hardness values
class HardnessValue {
  final int sequenceNumber;
  final double hardnessValue;
  final int pageNumber;
  final String rawText;

  HardnessValue({
    required this.sequenceNumber,
    required this.hardnessValue,
    required this.pageNumber,
    required this.rawText,
  });

  @override
  String toString() {
    return 'HardnessValue(seq: $sequenceNumber, value: $hardnessValue, page: $pageNumber)';
  }
}
