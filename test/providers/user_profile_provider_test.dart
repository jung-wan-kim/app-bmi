import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_bmi/models/user_profile.dart';

// Mock provider for testing
final mockUserProfileProvider = StateNotifierProvider<MockUserProfileNotifier, UserProfile?>((ref) {
  return MockUserProfileNotifier();
});

class MockUserProfileNotifier extends StateNotifier<UserProfile?> {
  MockUserProfileNotifier() : super(null);

  Future<void> loadProfile() async {
    // Simulate loading from storage
    state = UserProfile(
      id: 'test-user',
      name: 'Test User',
      age: 25,
      height: 170,
      currentWeight: 70,
      targetWeight: 65,
      activityLevel: 'moderate',
      gender: 'male',
    );
  }

  Future<void> updateProfile({
    String? name,
    int? age,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? activityLevel,
    String? gender,
  }) async {
    if (state == null) return;

    state = UserProfile(
      id: state!.id,
      name: name ?? state!.name,
      age: age ?? state!.age,
      height: height ?? state!.height,
      currentWeight: currentWeight ?? state!.currentWeight,
      targetWeight: targetWeight ?? state!.targetWeight,
      activityLevel: activityLevel ?? state!.activityLevel,
      gender: gender ?? state!.gender,
    );
  }

  Future<void> clearProfile() async {
    state = null;
  }

  double? calculateBMI() {
    if (state == null || state!.height == 0) return null;
    return state!.currentWeight / ((state!.height / 100) * (state!.height / 100));
  }

  double? calculateWeightToLose() {
    if (state == null || state!.targetWeight == null) return null;
    return state!.currentWeight - state!.targetWeight!;
  }

  String getActivityLevelDescription() {
    if (state == null) return '';
    
    switch (state!.activityLevel) {
      case 'sedentary':
        return 'Little or no exercise';
      case 'light':
        return 'Light exercise 1-3 days/week';
      case 'moderate':
        return 'Moderate exercise 3-5 days/week';
      case 'active':
        return 'Hard exercise 6-7 days/week';
      case 'very_active':
        return 'Very hard exercise & physical job';
      default:
        return '';
    }
  }
}

void main() {
  group('MockUserProfileProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with null profile', () {
      final profile = container.read(mockUserProfileProvider);
      expect(profile, isNull);
    });

    group('loadProfile', () {
      test('should load a default profile', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();

        final profile = container.read(mockUserProfileProvider);
        expect(profile, isNotNull);
        expect(profile!.name, 'Test User');
        expect(profile.age, 25);
        expect(profile.height, 170);
        expect(profile.currentWeight, 70);
        expect(profile.targetWeight, 65);
        expect(profile.activityLevel, 'moderate');
        expect(profile.gender, 'male');
      });
    });

    group('updateProfile', () {
      test('should update profile fields', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        await notifier.updateProfile(
          name: 'Updated User',
          age: 30,
          height: 175,
          currentWeight: 75,
          targetWeight: 68,
          activityLevel: 'active',
          gender: 'female',
        );

        final profile = container.read(mockUserProfileProvider);
        expect(profile!.name, 'Updated User');
        expect(profile.age, 30);
        expect(profile.height, 175);
        expect(profile.currentWeight, 75);
        expect(profile.targetWeight, 68);
        expect(profile.activityLevel, 'active');
        expect(profile.gender, 'female');
      });

      test('should update partial fields', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        await notifier.updateProfile(
          currentWeight: 68,
          targetWeight: 63,
        );

        final profile = container.read(mockUserProfileProvider);
        expect(profile!.name, 'Test User'); // Unchanged
        expect(profile.age, 25); // Unchanged
        expect(profile.currentWeight, 68); // Updated
        expect(profile.targetWeight, 63); // Updated
      });

      test('should not update if profile is null', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.updateProfile(name: 'Should Not Update');

        final profile = container.read(mockUserProfileProvider);
        expect(profile, isNull);
      });
    });

    group('clearProfile', () {
      test('should clear the profile', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        expect(container.read(mockUserProfileProvider), isNotNull);
        
        await notifier.clearProfile();
        expect(container.read(mockUserProfileProvider), isNull);
      });
    });

    group('calculateBMI', () {
      test('should calculate BMI correctly', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        final bmi = notifier.calculateBMI();
        
        expect(bmi, isNotNull);
        expect(bmi, closeTo(24.22, 0.01));
      });

      test('should return null if profile is null', () {
        final notifier = container.read(mockUserProfileProvider.notifier);
        final bmi = notifier.calculateBMI();
        
        expect(bmi, isNull);
      });

      test('should handle zero height', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        await notifier.updateProfile(height: 0);
        
        final bmi = notifier.calculateBMI();
        expect(bmi, isNull);
      });
    });

    group('calculateWeightToLose', () {
      test('should calculate weight to lose correctly', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        final weightToLose = notifier.calculateWeightToLose();
        
        expect(weightToLose, isNotNull);
        expect(weightToLose, 5.0); // 70 - 65
      });

      test('should return null if profile is null', () {
        final notifier = container.read(mockUserProfileProvider.notifier);
        final weightToLose = notifier.calculateWeightToLose();
        
        expect(weightToLose, isNull);
      });

      test('should handle null target weight', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        await notifier.updateProfile(targetWeight: null);
        
        final weightToLose = notifier.calculateWeightToLose();
        expect(weightToLose, isNull);
      });

      test('should handle negative weight difference', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        await notifier.updateProfile(targetWeight: 75);
        
        final weightToLose = notifier.calculateWeightToLose();
        expect(weightToLose, -5.0); // 70 - 75
      });
    });

    group('getActivityLevelDescription', () {
      test('should return correct descriptions', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        await notifier.loadProfile();
        
        // Test each activity level
        await notifier.updateProfile(activityLevel: 'sedentary');
        expect(notifier.getActivityLevelDescription(), 'Little or no exercise');
        
        await notifier.updateProfile(activityLevel: 'light');
        expect(notifier.getActivityLevelDescription(), 'Light exercise 1-3 days/week');
        
        await notifier.updateProfile(activityLevel: 'moderate');
        expect(notifier.getActivityLevelDescription(), 'Moderate exercise 3-5 days/week');
        
        await notifier.updateProfile(activityLevel: 'active');
        expect(notifier.getActivityLevelDescription(), 'Hard exercise 6-7 days/week');
        
        await notifier.updateProfile(activityLevel: 'very_active');
        expect(notifier.getActivityLevelDescription(), 'Very hard exercise & physical job');
      });

      test('should return empty string for null profile', () {
        final notifier = container.read(mockUserProfileProvider.notifier);
        expect(notifier.getActivityLevelDescription(), '');
      });

      test('should return empty string for unknown activity level', () async {
        final notifier = container.read(mockUserProfileProvider.notifier);
        
        await notifier.loadProfile();
        await notifier.updateProfile(activityLevel: 'unknown');
        
        expect(notifier.getActivityLevelDescription(), '');
      });
    });
  });
}