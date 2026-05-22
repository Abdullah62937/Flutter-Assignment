// lib/services/course_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

/// Service layer responsible for all Course-related API calls.
///
/// Uses the JSONPlaceholder fake REST API: https://jsonplaceholder.typicode.com
/// The /posts endpoint is treated as our /courses resource.
///
/// Note: JSONPlaceholder is a fake API. POST/PUT/PATCH/DELETE responses are
/// successful but the server doesn't actually persist changes — this is the
/// expected/documented behavior. We still reflect changes in the UI locally
/// for a realistic CRUD experience.
///
/// Since JSONPlaceholder returns generic Latin (lorem ipsum) content, we
/// remap the fetched data to academic course names/descriptions so the UI
/// stays on-theme. The API call, response handling, and CRUD flow remain
/// 100% real — only the displayed strings are themed.
class CourseService {
  static const String _baseUrl =
      'https://jsonplaceholder.typicode.com/posts';

  static const Duration _timeout = Duration(seconds: 15);

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ─── Theme overlay: realistic course catalog ────────────────────────────────
  // Each API "post" id is mapped to a real-sounding course so the dashboard
  // looks like an academic app, not a lorem-ipsum dump.
  static const List<Map<String, String>> _catalog = [
    {
      'title': 'Mobile App Development with Flutter',
      'body':
          'Build cross-platform Android and iOS apps using Flutter and Dart. Covers widgets, state management, navigation, and REST API integration with real-world projects.',
    },
    {
      'title': 'Data Structures and Algorithms',
      'body':
          'Master arrays, linked lists, trees, graphs, sorting, and searching. Strong focus on problem-solving patterns used in coding interviews and competitive programming.',
    },
    {
      'title': 'Object Oriented Programming',
      'body':
          'Core OOP principles — encapsulation, inheritance, polymorphism, and abstraction — using Java and C++. Includes UML, SOLID principles, and design patterns.',
    },
    {
      'title': 'Database Management Systems',
      'body':
          'Relational model, SQL, normalization, transactions, indexing, and ER diagrams. Hands-on projects using MySQL and PostgreSQL.',
    },
    {
      'title': 'Operating Systems',
      'body':
          'Processes, threads, scheduling, memory management, file systems, and concurrency. Practical labs in Linux with shell scripting and system calls.',
    },
    {
      'title': 'Software Engineering',
      'body':
          'Software development life cycle, Agile and Scrum, requirement engineering, UML, testing strategies, and version control with Git.',
    },
    {
      'title': 'Computer Networks',
      'body':
          'OSI and TCP/IP models, routing, switching, sockets, HTTP, DNS, and network security fundamentals. Includes Wireshark and Cisco Packet Tracer labs.',
    },
    {
      'title': 'Web Development',
      'body':
          'Frontend and backend basics — HTML, CSS, JavaScript, React, Node.js, and Express. Build and deploy a full-stack web app from scratch.',
    },
    {
      'title': 'Artificial Intelligence',
      'body':
          'Search algorithms, knowledge representation, machine learning intro, and neural networks. Hands-on with Python, NumPy, and scikit-learn.',
    },
    {
      'title': 'Machine Learning',
      'body':
          'Supervised and unsupervised learning, regression, classification, clustering, and model evaluation. Projects using pandas, scikit-learn, and TensorFlow.',
    },
    {
      'title': 'Cyber Security Fundamentals',
      'body':
          'CIA triad, cryptography basics, network attacks, web vulnerabilities (OWASP Top 10), and ethical hacking with hands-on Kali Linux exercises.',
    },
    {
      'title': 'Cloud Computing',
      'body':
          'IaaS, PaaS, SaaS, virtualization, and containers. Practical exposure to AWS, Azure, and Docker for deploying scalable applications.',
    },
    {
      'title': 'Management Information Systems',
      'body':
          'Strategic role of IT in organizations — ERP, CRM, business intelligence, data-driven decision making, and digital transformation case studies.',
    },
    {
      'title': 'Discrete Mathematics',
      'body':
          'Logic, sets, relations, functions, combinatorics, graph theory, and proofs. Foundation for algorithms, cryptography, and theoretical CS.',
    },
    {
      'title': 'Software Re-engineering',
      'body':
          'Analyzing and modernizing legacy systems. Covers reverse engineering, refactoring patterns, technical debt, and migration strategies.',
    },
    {
      'title': 'Human Computer Interaction',
      'body':
          'Usability principles, user research, wireframing, prototyping, and accessibility. Design thinking applied to real digital products.',
    },
    {
      'title': 'Compiler Construction',
      'body':
          'Lexical analysis, parsing, syntax-directed translation, semantic analysis, and code generation. Build a mini compiler from scratch.',
    },
    {
      'title': 'Project Management',
      'body':
          'Planning, scheduling, risk management, and team leadership. PMI/PMBOK basics plus Agile, Scrum, and Kanban workflows.',
    },
    {
      'title': 'Digital Logic Design',
      'body':
          'Boolean algebra, logic gates, combinational and sequential circuits, flip-flops, and finite state machines. Lab work with Verilog.',
    },
    {
      'title': 'Theory of Automata',
      'body':
          'Finite automata, regular expressions, context-free grammars, pushdown automata, and Turing machines. Foundations of computation.',
    },
  ];

  /// Returns a themed course based on the API id. Falls back to the original
  /// API content if the id is outside our catalog (e.g. id = 101 after POST).
  CourseModel _themedFromApi(Map<String, dynamic> apiJson) {
    final raw = CourseModel.fromJson(apiJson);
    if (raw.id >= 1 && raw.id <= _catalog.length) {
      final entry = _catalog[raw.id - 1];
      return CourseModel(
        id: raw.id,
        title: entry['title']!,
        body: entry['body']!,
      );
    }
    return raw;
  }

  // ─── READ (GET) ─────────────────────────────────────────────────────────────
  Future<List<CourseModel>> fetchCourses() async {
    try {
      final response =
          await http.get(Uri.parse(_baseUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        // Only show the first 20 — keeps the list focused and matches our catalog.
        return data
            .take(_catalog.length)
            .map((e) => _themedFromApi(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to load courses (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Could not fetch courses: $e');
    }
  }

  // ─── CREATE (POST) ──────────────────────────────────────────────────────────
  /// Returns the newly-created course (with the id assigned by the API).
  Future<CourseModel> addCourse({
    required String title,
    required String body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: _jsonHeaders,
            body: jsonEncode({
              'title': title,
              'body': body,
              'userId': 1,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        // JSONPlaceholder echoes our payload back with a fresh id (usually 101).
        // We construct the result from the user's input so the UI shows
        // exactly what they typed.
        return CourseModel(
          id: data['id'] is int
              ? data['id'] as int
              : int.tryParse('${data['id']}') ?? 101,
          title: title,
          body: body,
        );
      } else {
        throw Exception(
            'Failed to add course (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Could not add course: $e');
    }
  }

  // ─── UPDATE (PUT) ───────────────────────────────────────────────────────────
  Future<CourseModel> updateCourse({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$id'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'id': id,
              'title': title,
              'body': body,
              'userId': 1,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // PUT echoes our payload back. We trust the user's input as the
        // source of truth so the UI shows exactly what they edited.
        return CourseModel(id: id, title: title, body: body);
      } else {
        throw Exception(
            'Failed to update course (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Could not update course: $e');
    }
  }

  // ─── DELETE (DELETE) ────────────────────────────────────────────────────────
  Future<void> deleteCourse(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$_baseUrl/$id')).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete course (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Could not delete course: $e');
    }
  }
}