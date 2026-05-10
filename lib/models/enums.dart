// lib/models/enums.dart

enum Gender { male, female, other, preferNotToSay }

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

enum AuthState { idle, loading, success, error }

enum Subject { mobileAppDevelopment, softwareReEngineering, mis }

extension SubjectExtension on Subject {
  String get title {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Mobile App Development';
      case Subject.softwareReEngineering:
        return 'Software Re-engineering';
      case Subject.mis:
        return 'Management Information Systems';
    }
  }

  String get code {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'CS-471';
      case Subject.softwareReEngineering:
        return 'CS-452';
      case Subject.mis:
        return 'MIS-301';
    }
  }

  String get description {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Comprehensive study of mobile application development using Flutter framework. Topics include widget-based UI development, state management patterns, navigation, API integration, and deployment to Android & iOS platforms. Students will build real-world projects demonstrating industry best practices.';
      case Subject.softwareReEngineering:
        return 'Advanced methodologies for analyzing, redesigning, and restructuring legacy software systems. Covers reverse engineering, refactoring techniques, design patterns, technical debt management, and migration strategies for modernizing enterprise applications.';
      case Subject.mis:
        return 'Strategic use of information systems in organizational decision-making. Topics include database management, enterprise systems, business intelligence, data analytics, cybersecurity, and digital transformation frameworks for modern organizations.';
    }
  }

  String get schedule {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Mon & Wed — 9:00 AM to 10:30 AM';
      case Subject.softwareReEngineering:
        return 'Tue & Thu — 11:00 AM to 12:30 PM';
      case Subject.mis:
        return 'Friday — 2:00 PM to 5:00 PM';
    }
  }

  String get instructor {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 'Dr. Ahsan Raza';
      case Subject.softwareReEngineering:
        return 'Prof. Sana Malik';
      case Subject.mis:
        return 'Dr. Tariq Hussain';
    }
  }

  String get credits {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return '3 Credit Hours';
      case Subject.softwareReEngineering:
        return '3 Credit Hours';
      case Subject.mis:
        return '3 Credit Hours';
    }
  }

  int get colorIndex {
    switch (this) {
      case Subject.mobileAppDevelopment:
        return 0;
      case Subject.softwareReEngineering:
        return 1;
      case Subject.mis:
        return 2;
    }
  }
}
