import 'dart:io';
import 'dart:convert';

/// 의존성 분석 및 최적화 스크립트
/// 사용하지 않는 패키지를 찾아내고 앱 크기를 줄이는 데 도움
void main(List<String> args) async {
  print('📦 Dependency Analyzer');
  print('=====================\n');

  final showDetails = args.contains('--verbose');
  final removeUnused = args.contains('--remove-unused');

  // pubspec.yaml 읽기
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ pubspec.yaml을 찾을 수 없습니다.');
    exit(1);
  }

  final pubspecContent = await pubspecFile.readAsString();
  final dependencies = _extractDependencies(pubspecContent);
  
  print('📋 현재 의존성 (${dependencies.length}개):');
  for (final dep in dependencies) {
    print('  • $dep');
  }
  print('');

  // 사용된 import 분석
  final usedImports = await _analyzeUsedImports();
  
  // 사용되지 않는 의존성 찾기
  final unusedDeps = await _findUnusedDependencies(dependencies, usedImports);
  
  if (unusedDeps.isEmpty) {
    print('✅ 모든 의존성이 사용되고 있습니다!');
  } else {
    print('⚠️  사용되지 않는 의존성 (${unusedDeps.length}개):');
    for (final dep in unusedDeps) {
      print('  ❌ $dep');
    }
    
    if (removeUnused) {
      print('\n🔧 사용되지 않는 의존성 제거 중...');
      await _removeUnusedDependencies(unusedDeps);
      print('✅ 제거 완료!');
    } else {
      print('\n💡 --remove-unused 플래그로 자동 제거 가능합니다.');
    }
  }

  // 중복 의존성 분석
  await _analyzeDuplicateDependencies();
  
  // 크기 영향 분석
  await _analyzeSizeImpact(dependencies, showDetails);
  
  // 대안 제안
  _suggestAlternatives(dependencies);
}

List<String> _extractDependencies(String pubspecContent) {
  final dependencies = <String>[];
  final lines = pubspecContent.split('\n');
  bool inDependencies = false;
  
  for (final line in lines) {
    if (line.trim() == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    
    if (line.trim() == 'dev_dependencies:') {
      inDependencies = false;
      continue;
    }
    
    if (inDependencies && line.trim().isNotEmpty && !line.startsWith('#')) {
      if (line.contains(':') && !line.startsWith('  flutter')) {
        final depName = line.split(':')[0].trim();
        if (depName.isNotEmpty && !depName.contains('sdk')) {
          dependencies.add(depName);
        }
      }
    }
  }
  
  return dependencies;
}

Future<Map<String, List<String>>> _analyzeUsedImports() async {
  final usedImports = <String, List<String>>{};
  
  await for (final file in Directory('lib').list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = await file.readAsString();
      final imports = _extractImports(content);
      
      for (final import in imports) {
        final package = _extractPackageName(import);
        if (package != null) {
          usedImports.putIfAbsent(package, () => []).add(file.path);
        }
      }
    }
  }
  
  return usedImports;
}

List<String> _extractImports(String content) {
  final imports = <String>[];
  final lines = content.split('\n');
  
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('import \'package:') && trimmed.endsWith('\';')) {
      imports.add(trimmed);
    }
  }
  
  return imports;
}

String? _extractPackageName(String import) {
  final match = RegExp(r'''import ['"]package:([^/]+)/''').firstMatch(import);
  return match?.group(1);
}

Future<List<String>> _findUnusedDependencies(
  List<String> dependencies,
  Map<String, List<String>> usedImports,
) async {
  final unused = <String>[];
  
  for (final dep in dependencies) {
    if (!usedImports.containsKey(dep)) {
      // Flutter 및 기본 패키지는 제외
      if (!['cupertino_icons', 'flutter', 'flutter_test'].contains(dep)) {
        unused.add(dep);
      }
    }
  }
  
  return unused;
}

Future<void> _removeUnusedDependencies(List<String> unusedDeps) async {
  final pubspecFile = File('pubspec.yaml');
  var content = await pubspecFile.readAsString();
  
  for (final dep in unusedDeps) {
    // 의존성 라인 제거
    final lines = content.split('\n');
    final filteredLines = lines.where((line) {
      return !line.contains('$dep:') || line.trim().startsWith('#');
    }).toList();
    content = filteredLines.join('\n');
  }
  
  await pubspecFile.writeAsString(content);
}

Future<void> _analyzeDuplicateDependencies() async {
  print('\n🔍 중복 기능 분석:');
  
  final duplicateGroups = {
    'HTTP 클라이언트': ['http', 'dio'],
    '상태 관리': ['provider', 'riverpod', 'bloc'],
    '로컬 저장소': ['shared_preferences', 'hive', 'sqflite'],
    '이미지 처리': ['image', 'image_picker', 'cached_network_image'],
    '네비게이션': ['go_router', 'auto_route'],
  };
  
  for (final group in duplicateGroups.entries) {
    final found = <String>[];
    for (final dep in group.value) {
      final pubspec = await File('pubspec.yaml').readAsString();
      if (pubspec.contains('$dep:')) {
        found.add(dep);
      }
    }
    
    if (found.length > 1) {
      print('  ⚠️  ${group.key}: ${found.join(', ')} (중복 가능성)');
    }
  }
}

Future<void> _analyzeSizeImpact(List<String> dependencies, bool showDetails) async {
  print('\n📏 크기 영향 분석:');
  
  // 크기가 큰 것으로 알려진 패키지들
  final heavyPackages = {
    'camera': '높음 (카메라 기능)',
    'video_player': '높음 (비디오 코덱)',
    'firebase_core': '중간 (Firebase SDK)',
    'google_maps_flutter': '높음 (지도 데이터)',
    'webview_flutter': '중간 (웹뷰 엔진)',
    'lottie': '중간 (애니메이션 파일)',
    'fl_chart': '낮음 (차트 라이브러리)',
  };
  
  bool hasHeavyPackages = false;
  for (final dep in dependencies) {
    if (heavyPackages.containsKey(dep)) {
      print('  📦 $dep: ${heavyPackages[dep]}');
      hasHeavyPackages = true;
    }
  }
  
  if (!hasHeavyPackages) {
    print('  ✅ 크기에 큰 영향을 주는 패키지가 없습니다.');
  }
}

void _suggestAlternatives(List<String> dependencies) {
  print('\n💡 최적화 제안:');
  
  final suggestions = {
    'http': 'dio로 통합 고려 (더 많은 기능)',
    'shared_preferences': '단순한 데이터만 저장한다면 유지',
    'lottie': '정적 이미지로 대체 가능한지 검토',
    'cached_network_image': '이미지 캐싱이 필요한 경우만 사용',
  };
  
  bool hasSuggestions = false;
  for (final dep in dependencies) {
    if (suggestions.containsKey(dep)) {
      print('  💡 $dep: ${suggestions[dep]}');
      hasSuggestions = true;
    }
  }
  
  if (!hasSuggestions) {
    print('  ✅ 현재 의존성 구성이 적절합니다.');
  }
  
  print('\n🎯 추가 최적화 팁:');
  print('  • flutter build apk --split-per-abi (ABI별 분할)');
  print('  • flutter build appbundle (Play Store 동적 전송)');
  print('  • 사용하지 않는 언어 리소스 제거');
  print('  • 이미지 압축 및 WebP 형식 사용');
}