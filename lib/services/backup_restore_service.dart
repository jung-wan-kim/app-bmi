import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_record.dart';
import '../models/goal.dart';
import '../providers/notification_settings_provider.dart';

/// 백업 데이터 구조
class BackupData {
  final String version;
  final DateTime createdAt;
  final Map<String, dynamic> userData;
  final List<WeightRecord> weightRecords;
  final Goal? currentGoal;
  final NotificationSettings? notificationSettings;
  final Map<String, dynamic> metadata;

  BackupData({
    required this.version,
    required this.createdAt,
    required this.userData,
    required this.weightRecords,
    this.currentGoal,
    this.notificationSettings,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'userData': userData,
    'weightRecords': weightRecords.map((r) => r.toJson()).toList(),
    'currentGoal': currentGoal?.toJson(),
    'notificationSettings': notificationSettings?.toJson(),
    'metadata': metadata,
  };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'],
      createdAt: DateTime.parse(json['createdAt']),
      userData: json['userData'] ?? {},
      weightRecords: (json['weightRecords'] as List)
          .map((r) => WeightRecord.fromJson(r))
          .toList(),
      currentGoal: json['currentGoal'] != null 
          ? Goal.fromJson(json['currentGoal'])
          : null,
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'])
          : null,
      metadata: json['metadata'] ?? {},
    );
  }
}

/// 백업/복원 서비스
class BackupRestoreService {
  static final BackupRestoreService _instance = BackupRestoreService._internal();
  factory BackupRestoreService() => _instance;
  BackupRestoreService._internal();

  static const String _backupVersion = '1.0';
  static const String _backupFilePrefix = 'bmi_tracker_backup';

  /// 백업 생성
  Future<BackupResult> createBackup() async {
    try {
      debugPrint('백업 생성 시작');
      
      // SharedPreferences에서 데이터 로드
      final prefs = await SharedPreferences.getInstance();
      
      // 사용자 데이터
      final userData = {
        'userName': prefs.getString('demoUserName') ?? '사용자',
        'userHeight': prefs.getDouble('demoUserHeight') ?? 170.0,
        'userGender': prefs.getString('userGender') ?? 'male',
        'startWeight': prefs.getDouble('demoStartWeight'),
        'weightUnit': prefs.getString('weightUnit') ?? 'kg',
        'heightUnit': prefs.getString('heightUnit') ?? 'cm',
        'isDemoMode': prefs.getBool('isDemoMode') ?? false,
      };
      
      // 체중 기록
      final weightRecordsJson = prefs.getStringList('weight_records') ?? [];
      final weightRecords = weightRecordsJson
          .map((json) => WeightRecord.fromJson(jsonDecode(json)))
          .toList();
      
      // 현재 목표
      final goalJson = prefs.getString('current_goal');
      final currentGoal = goalJson != null 
          ? Goal.fromJson(jsonDecode(goalJson))
          : null;
      
      // 알림 설정
      final notificationJson = prefs.getString('notification_settings');
      final notificationSettings = notificationJson != null
          ? NotificationSettings.fromJson(jsonDecode(notificationJson))
          : null;
      
      // 메타데이터
      final metadata = {
        'appVersion': '1.0.0',
        'recordCount': weightRecords.length,
        'hasGoal': currentGoal != null,
        'hasNotificationSettings': notificationSettings != null,
      };
      
      // 백업 데이터 생성
      final backupData = BackupData(
        version: _backupVersion,
        createdAt: DateTime.now(),
        userData: userData,
        weightRecords: weightRecords,
        currentGoal: currentGoal,
        notificationSettings: notificationSettings,
        metadata: metadata,
      );
      
      // JSON 인코딩
      final jsonString = jsonEncode(backupData.toJson());
      
      // 파일 저장
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${_backupFilePrefix}_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      debugPrint('백업 생성 완료: $fileName');
      
      return BackupResult(
        success: true,
        fileName: fileName,
        filePath: file.path,
        recordCount: weightRecords.length,
      );
      
    } catch (e) {
      debugPrint('백업 생성 실패: $e');
      return BackupResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 백업 공유
  Future<void> shareBackup(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        subject: 'BMI Tracker 백업',
        text: 'BMI Tracker 데이터 백업 파일입니다.',
      );
    } catch (e) {
      debugPrint('백업 공유 실패: $e');
      rethrow;
    }
  }

  /// 백업 파일 선택
  Future<String?> selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'BMI Tracker 백업 파일 선택',
      );
      
      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
      
      return null;
    } catch (e) {
      debugPrint('백업 파일 선택 실패: $e');
      return null;
    }
  }

  /// 백업 복원
  Future<RestoreResult> restoreBackup(String filePath) async {
    try {
      debugPrint('백업 복원 시작: $filePath');
      
      // 파일 읽기
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('백업 파일을 찾을 수 없습니다');
      }
      
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      // 백업 데이터 파싱
      final backupData = BackupData.fromJson(jsonData);
      
      // 버전 확인
      if (backupData.version != _backupVersion) {
        debugPrint('백업 버전 불일치: ${backupData.version} != $_backupVersion');
        // 하위 호환성을 위해 경고만 표시하고 계속 진행
      }
      
      // SharedPreferences에 복원
      final prefs = await SharedPreferences.getInstance();
      
      // 기존 데이터 백업 (복원 실패 시 롤백용)
      final rollbackData = await _createRollbackData(prefs);
      
      try {
        // 사용자 데이터 복원
        final userData = backupData.userData;
        await prefs.setString('demoUserName', userData['userName'] ?? '사용자');
        await prefs.setDouble('demoUserHeight', userData['userHeight'] ?? 170.0);
        await prefs.setString('userGender', userData['userGender'] ?? 'male');
        if (userData['startWeight'] != null) {
          await prefs.setDouble('demoStartWeight', userData['startWeight']);
        }
        await prefs.setString('weightUnit', userData['weightUnit'] ?? 'kg');
        await prefs.setString('heightUnit', userData['heightUnit'] ?? 'cm');
        await prefs.setBool('isDemoMode', userData['isDemoMode'] ?? false);
        
        // 체중 기록 복원
        final weightRecordsJson = backupData.weightRecords
            .map((r) => jsonEncode(r.toJson()))
            .toList();
        await prefs.setStringList('weight_records', weightRecordsJson);
        
        // 현재 목표 복원
        if (backupData.currentGoal != null) {
          await prefs.setString('current_goal', jsonEncode(backupData.currentGoal!.toJson()));
        } else {
          await prefs.remove('current_goal');
        }
        
        // 알림 설정 복원
        if (backupData.notificationSettings != null) {
          await prefs.setString('notification_settings', jsonEncode(backupData.notificationSettings!.toJson()));
        } else {
          await prefs.remove('notification_settings');
        }
        
        debugPrint('백업 복원 완료');
        
        return RestoreResult(
          success: true,
          recordCount: backupData.weightRecords.length,
          backupDate: backupData.createdAt,
        );
        
      } catch (e) {
        // 복원 실패 시 롤백
        debugPrint('복원 중 오류 발생, 롤백 시작: $e');
        await _rollback(prefs, rollbackData);
        rethrow;
      }
      
    } catch (e) {
      debugPrint('백업 복원 실패: $e');
      return RestoreResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 롤백용 데이터 생성
  Future<Map<String, dynamic>> _createRollbackData(SharedPreferences prefs) async {
    return {
      'demoUserName': prefs.getString('demoUserName'),
      'demoUserHeight': prefs.getDouble('demoUserHeight'),
      'userGender': prefs.getString('userGender'),
      'demoStartWeight': prefs.getDouble('demoStartWeight'),
      'weightUnit': prefs.getString('weightUnit'),
      'heightUnit': prefs.getString('heightUnit'),
      'isDemoMode': prefs.getBool('isDemoMode'),
      'weight_records': prefs.getStringList('weight_records'),
      'current_goal': prefs.getString('current_goal'),
      'notification_settings': prefs.getString('notification_settings'),
    };
  }

  /// 롤백 수행
  Future<void> _rollback(SharedPreferences prefs, Map<String, dynamic> rollbackData) async {
    for (final entry in rollbackData.entries) {
      if (entry.value == null) {
        await prefs.remove(entry.key);
      } else if (entry.value is String) {
        await prefs.setString(entry.key, entry.value);
      } else if (entry.value is double) {
        await prefs.setDouble(entry.key, entry.value);
      } else if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value);
      } else if (entry.value is List<String>) {
        await prefs.setStringList(entry.key, entry.value);
      }
    }
  }

  /// 백업 파일 목록 가져오기
  Future<List<BackupFileInfo>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.contains(_backupFilePrefix) && file.path.endsWith('.json'))
          .toList();
      
      final backupFiles = <BackupFileInfo>[];
      
      for (final file in files) {
        try {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;
          
          backupFiles.add(BackupFileInfo(
            fileName: fileName,
            filePath: file.path,
            createdAt: stat.modified,
            fileSize: stat.size,
          ));
        } catch (e) {
          debugPrint('파일 정보 읽기 실패: ${file.path}');
        }
      }
      
      // 최신 순으로 정렬
      backupFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return backupFiles;
    } catch (e) {
      debugPrint('백업 파일 목록 조회 실패: $e');
      return [];
    }
  }

  /// 백업 파일 삭제
  Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('백업 파일 삭제 실패: $e');
      return false;
    }
  }
}

/// 백업 결과
class BackupResult {
  final bool success;
  final String? fileName;
  final String? filePath;
  final int? recordCount;
  final String? error;

  BackupResult({
    required this.success,
    this.fileName,
    this.filePath,
    this.recordCount,
    this.error,
  });
}

/// 복원 결과
class RestoreResult {
  final bool success;
  final int? recordCount;
  final DateTime? backupDate;
  final String? error;

  RestoreResult({
    required this.success,
    this.recordCount,
    this.backupDate,
    this.error,
  });
}

/// 백업 파일 정보
class BackupFileInfo {
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final int fileSize;

  BackupFileInfo({
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.fileSize,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}