import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool isEnabled;
  final NotificationTime reminderTime;
  final List<bool> selectedDays; // 월화수목금토일

  NotificationSettings({
    required this.isEnabled,
    required this.reminderTime,
    required this.selectedDays,
  });

  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
    'reminderHour': reminderTime.hour,
    'reminderMinute': reminderTime.minute,
    'selectedDays': selectedDays,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
    isEnabled: json['isEnabled'] ?? false,
    reminderTime: NotificationTime(
      hour: json['reminderHour'] ?? 9,
      minute: json['reminderMinute'] ?? 0,
    ),
    selectedDays: List<bool>.from(json['selectedDays'] ?? List.filled(7, true)),
  );

  NotificationSettings copyWith({
    bool? isEnabled,
    NotificationTime? reminderTime,
    List<bool>? selectedDays,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}

class NotificationTime {
  final int hour;
  final int minute;

  const NotificationTime({required this.hour, required this.minute});

  String format() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(
    NotificationSettings(
      isEnabled: false,
      reminderTime: const NotificationTime(hour: 9, minute: 0),
      selectedDays: List.filled(7, true),
    )
  ) {
    _loadSettings();
  }

  static const String _storageKey = 'notification_settings';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      state = NotificationSettings.fromJson(json.decode(jsonString));
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state.toJson()));
  }

  Future<void> toggleEnabled() async {
    state = state.copyWith(isEnabled: !state.isEnabled);
    await _saveSettings();
  }

  Future<void> updateReminderTime(NotificationTime time) async {
    state = state.copyWith(reminderTime: time);
    await _saveSettings();
  }

  Future<void> toggleDay(int dayIndex) async {
    final newDays = List<bool>.from(state.selectedDays);
    newDays[dayIndex] = !newDays[dayIndex];
    state = state.copyWith(selectedDays: newDays);
    await _saveSettings();
  }

  // 실시간 동기화를 위한 메서드들

  /// 실시간 동기화로부터 설정 업데이트
  void updateFromRealtime(NotificationSettings settings) {
    state = settings;
    // SharedPreferences에는 자동으로 저장됨 (RealtimeSyncService에서 처리)
  }

  /// 스토리지에서 설정을 새로고침 (실시간 동기화 초기화 시 사용)
  Future<void> refreshFromStorage() async {
    await _loadSettings();
  }
}