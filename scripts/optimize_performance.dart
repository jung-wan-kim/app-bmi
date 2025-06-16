import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🚀 Flutter Performance Optimizer');
  print('================================\n');

  final dryRun = args.contains('--dry-run');
  final backup = !args.contains('--no-backup');
  
  if (dryRun) {
    print('🔍 Running in dry-run mode (no files will be modified)\n');
  }

  final stats = {
    'withOpacity': 0,
    'const': 0,
    'asyncContext': 0,
    'files': 0,
  };

  // Process all Dart files in lib/
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    print('❌ Error: lib directory not found');
    exit(1);
  }

  await for (final file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      await processFile(file, dryRun, backup, stats);
    }
  }

  // Print summary
  print('\n📊 Optimization Summary:');
  print('  Files processed: ${stats['files']}');
  print('  withOpacity → withValues: ${stats['withOpacity']}');
  print('  const keywords added: ${stats['const']}');
  print('  async context fixes: ${stats['asyncContext']}');
  
  if (dryRun) {
    print('\n💡 Run without --dry-run to apply changes');
  } else {
    print('\n✅ Optimization complete!');
  }
}

Future<void> processFile(File file, bool dryRun, bool backup, Map<String, int> stats) async {
  try {
    final content = await file.readAsString();
    var modified = content;
    var changesMade = false;

    // 1. Replace withOpacity() with withValues(alpha:)
    final withOpacityRegex = RegExp(r'\.withOpacity\(([^)]+)\)');
    final withOpacityMatches = withOpacityRegex.allMatches(modified);
    if (withOpacityMatches.isNotEmpty) {
      modified = modified.replaceAllMapped(
        withOpacityRegex,
        (match) {
          stats['withOpacity'] = (stats['withOpacity'] ?? 0) + 1;
          changesMade = true;
          return '.withValues(alpha: ${match.group(1)})';
        },
      );
    }

    // 2. Add const keywords to constructors
    // Common widgets that should be const
    final constPatterns = [
      // SizedBox without const
      (RegExp(r'(\s+)SizedBox\('), r'\1const SizedBox('),
      // EdgeInsets without const
      (RegExp(r'(\s+)EdgeInsets\.'), r'\1const EdgeInsets.'),
      // Padding without const
      (RegExp(r'(\s+)Padding\('), r'\1const Padding('),
      // Icon without const
      (RegExp(r'(\s+)Icon\('), r'\1const Icon('),
      // Text with literal string
      (RegExp(r'''(\s+)Text\(['"]'''), r'\1const Text('),
      // CircularProgressIndicator without parameters
      (RegExp(r'(\s+)CircularProgressIndicator\(\)'), r'\1const CircularProgressIndicator()'),
      // Divider without parameters
      (RegExp(r'(\s+)Divider\(\)'), r'\1const Divider()'),
      // Empty Container
      (RegExp(r'(\s+)Container\(\)'), r'\1const SizedBox()'),
    ];

    for (final (pattern, replacement) in constPatterns) {
      final matches = pattern.allMatches(modified);
      if (matches.isNotEmpty) {
        // Check if const is not already present
        for (final match in matches) {
          final lineStart = modified.lastIndexOf('\n', match.start) + 1;
          final line = modified.substring(lineStart, match.end);
          if (!line.contains('const ')) {
            modified = modified.replaceFirst(pattern, replacement, match.start);
            stats['const'] = (stats['const'] ?? 0) + 1;
            changesMade = true;
          }
        }
      }
    }

    // 3. Fix BuildContext usage across async gaps
    final asyncContextRegex = RegExp(
      r'await[^;]+;[^}]*context\.',
      multiLine: true,
    );
    final asyncContextMatches = asyncContextRegex.allMatches(modified);
    if (asyncContextMatches.isNotEmpty) {
      // Add mounted check
      for (final match in asyncContextMatches) {
        final beforeContext = modified.lastIndexOf('context.', match.end);
        if (beforeContext > 0) {
          final lineStart = modified.lastIndexOf('\n', beforeContext) + 1;
          final indent = modified.substring(lineStart, beforeContext).replaceAll(RegExp(r'[^\s]'), '');
          
          if (!modified.substring(match.start, beforeContext).contains('mounted')) {
            modified = modified.replaceRange(
              beforeContext,
              beforeContext,
              'if (!mounted) return;\n$indent',
            );
            stats['asyncContext'] = (stats['asyncContext'] ?? 0) + 1;
            changesMade = true;
          }
        }
      }
    }

    // Save changes
    if (changesMade) {
      stats['files'] = (stats['files'] ?? 0) + 1;
      
      if (!dryRun) {
        // Create backup
        if (backup) {
          final backupPath = '${file.path}.backup';
          await File(backupPath).writeAsString(content);
        }
        
        // Write modified content
        await file.writeAsString(modified);
        print('✅ ${file.path}');
      } else {
        print('📝 Would modify: ${file.path}');
      }
    }
  } catch (e) {
    print('❌ Error processing ${file.path}: $e');
  }
}