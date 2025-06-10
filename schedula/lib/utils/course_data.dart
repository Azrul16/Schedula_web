// Course Code Enum
// ignore_for_file: constant_identifier_names

enum CourseCode {
  PHY111,
  PHY112,
  CHE111,
  CHE112,
  MAT111,
  EEE111,
  EEE112,
  CIT111,
  CIT112,
  CCE112, // Semester 1
  PHY121,
  PHY122,
  MAT121,
  CIT121,
  LCM121,
  EEE121,
  EEE122,
  CCE121,
  CCE122,
  CCE124, // Semester 2
  CIT211,
  CIT212,
  CIT213,
  CCE211,
  MAT211,
  EEE211,
  EEE212,
  AIS211, // Semester 3
  CCE221,
  CCE222,
  CCE223,
  CCE224,
  AES221,
  MAT221,
  CIT220,
  CIT221,
  CIT222,
  CIT224, // Semester 4
  CIT311,
  CIT312,
  CIT313,
  CIT315,
  CIT316,
  CCE310,
  CCE311,
  CCE312,
  CCE313,
  CCE314, // Semester 5
  CIT320,
  CIT321,
  CIT322,
  CIT323,
  CIT324,
  EEE321,
  EEE322,
  CCE320,
  CCE321,
  CCE322,
  CCE323, // Semester 6
  CSE410,
  CSE412,
  CCE411,
  CCE413,
  CCE415,
  CCE416,
  CCE417,
  CIT411,
  CIT412, // Semester 7
  CSE420,
  CSE421,
  CCE421,
  CCE423,
  CIT421,
  CIT422,
  CIT423 // Semester 8
}

class Course {
  final CourseCode code;
  final String title;
  final int semester;

  const Course({
    required this.code,
    required this.title,
    required this.semester,
  });

  String get courseCode => code.toString().split('.').last;
}

class CourseData {
  static const List<Course> courses = [
    // Semester 1
    Course(code: CourseCode.PHY111, title: 'Physics-I', semester: 1),
    Course(code: CourseCode.PHY112, title: 'Physics-I Sessional', semester: 1),
    Course(code: CourseCode.CHE111, title: 'Chemistry', semester: 1),
    Course(code: CourseCode.CHE112, title: 'Chemistry Sessional', semester: 1),
    Course(code: CourseCode.MAT111, title: 'Mathematics-I', semester: 1),
    Course(
        code: CourseCode.EEE111,
        title: 'Basic Electrical Engineering',
        semester: 1),
    Course(
        code: CourseCode.EEE112,
        title: 'Basic Electrical Engineering Sessional',
        semester: 1),
    Course(code: CourseCode.CIT111, title: 'Programming Language', semester: 1),
    Course(
        code: CourseCode.CIT112,
        title: 'Programming Language Sessional',
        semester: 1),
    Course(code: CourseCode.CCE112, title: 'Engineering Drawing', semester: 1),

    // Semester 2
    Course(code: CourseCode.PHY121, title: 'Physics-II', semester: 2),
    Course(code: CourseCode.PHY122, title: 'Physics-II Sessional', semester: 2),
    Course(code: CourseCode.MAT121, title: 'Mathematics-II', semester: 2),
    Course(code: CourseCode.CIT121, title: 'Discrete Mathematics', semester: 2),
    Course(
        code: CourseCode.LCM121, title: 'Communicative English', semester: 2),
    Course(
        code: CourseCode.EEE121,
        title: 'Electronic Device and Circuits',
        semester: 2),
    Course(
        code: CourseCode.EEE122,
        title: 'Electronic Device and Circuits Sessional',
        semester: 2),
    Course(
        code: CourseCode.CCE121,
        title: 'Object Oriented Programming',
        semester: 2),
    Course(
        code: CourseCode.CCE122,
        title: 'Object Oriented Programming Sessional',
        semester: 2),
    Course(
        code: CourseCode.CCE124,
        title: 'Computer Programming Contest-I',
        semester: 2),

    // Semester 3
    Course(
        code: CourseCode.CIT211,
        title: 'Data Structure and Algorithms',
        semester: 3),
    Course(
        code: CourseCode.CIT212,
        title: 'Data Structure and Algorithms Sessional',
        semester: 3),
    Course(code: CourseCode.CIT213, title: 'Software Engineering', semester: 3),
    Course(
        code: CourseCode.CCE221,
        title: 'Data Communication and Engineering',
        semester: 3),
    Course(code: CourseCode.MAT211, title: 'Mathematics-III', semester: 3),
    Course(
        code: CourseCode.EEE211, title: 'Electrical Technology', semester: 3),
    Course(
        code: CourseCode.EEE212,
        title: 'Electrical Technology Sessional',
        semester: 3),
    Course(
        code: CourseCode.AIS211,
        title: 'Accounting and Management',
        semester: 3),

    // Semester 4
    Course(code: CourseCode.CCE221, title: 'Digital Logic Design', semester: 4),
    Course(
        code: CourseCode.CCE222,
        title: 'Digital Logic Design Sessional',
        semester: 4),
    Course(code: CourseCode.CCE223, title: 'Database System', semester: 4),
    Course(
        code: CourseCode.CCE224,
        title: 'Database System Sessional',
        semester: 4),
    Course(
        code: CourseCode.AES221,
        title: 'Government and Economics',
        semester: 4),
    Course(code: CourseCode.MAT221, title: 'Mathematics-IV', semester: 4),
    Course(
        code: CourseCode.CIT220, title: 'Web Programming Project', semester: 4),
    Course(
        code: CourseCode.CIT221,
        title: 'Information System Analysis and Design',
        semester: 4),
    Course(
        code: CourseCode.CIT222,
        title: 'Information System Analysis and Design Sessional',
        semester: 4),
    Course(
        code: CourseCode.CIT224,
        title: 'Computer Programming Contest-II',
        semester: 4),

    // Semester 5
    Course(
        code: CourseCode.CIT311,
        title: 'Microprocessors and Assembly Language',
        semester: 5),
    Course(
        code: CourseCode.CIT312,
        title: 'Microprocessors and Assembly Language Sessional',
        semester: 5),
    Course(
        code: CourseCode.CIT313,
        title: 'Computer Organization and Architecture',
        semester: 5),
    Course(
        code: CourseCode.CIT315, title: 'Artificial Intelligence', semester: 5),
    Course(
        code: CourseCode.CIT316,
        title: 'Artificial Intelligence Sessional',
        semester: 5),
    Course(
        code: CourseCode.CCE310,
        title: 'Software Development Project',
        semester: 5),
    Course(code: CourseCode.CCE311, title: 'Numerical Methods', semester: 5),
    Course(
        code: CourseCode.CCE312,
        title: 'Numerical Methods Sessional',
        semester: 5),
    Course(code: CourseCode.CCE313, title: 'Computer Networks', semester: 5),
    Course(
        code: CourseCode.CCE314,
        title: 'Computer Networks Sessional',
        semester: 5),

    // Semester 6
    Course(
        code: CourseCode.CIT320,
        title: 'Software Development Project',
        semester: 6),
    Course(code: CourseCode.CIT321, title: 'Operating System', semester: 6),
    Course(
        code: CourseCode.CIT322,
        title: 'Operating System Sessional',
        semester: 6),
    Course(
        code: CourseCode.CIT323, title: 'Simulation and Modeling', semester: 6),
    Course(
        code: CourseCode.CIT324,
        title: 'Simulation and Modeling Sessional',
        semester: 6),
    Course(
        code: CourseCode.EEE321,
        title: 'Digital Electronics and Pulse Techniques',
        semester: 6),
    Course(
        code: CourseCode.EEE322,
        title: 'Digital Electronics and Pulse Techniques Sessional',
        semester: 6),
    Course(
        code: CourseCode.CCE320,
        title: 'Computer Programming Contest',
        semester: 6),
    Course(
        code: CourseCode.CCE321,
        title: 'Computer Peripheral and Interfacing',
        semester: 6),
    Course(
        code: CourseCode.CCE322,
        title: 'Computer Peripheral and Interfacing Sessional',
        semester: 6),
    Course(
        code: CourseCode.CCE323,
        title: 'Optical Fiber Communication',
        semester: 6),

    // Semester 7
    Course(code: CourseCode.CSE410, title: 'Project/Thesis', semester: 7),
    Course(code: CourseCode.CSE412, title: 'Industrial Training', semester: 7),
    Course(
        code: CourseCode.CCE411, title: 'Algorithm Engineering', semester: 7),
    Course(code: CourseCode.CCE413, title: 'VLSI Design', semester: 7),
    Course(
        code: CourseCode.CCE415,
        title: 'Network Routing and Switching',
        semester: 7),
    Course(
        code: CourseCode.CCE416,
        title: 'Network Routing and Switching Sessional',
        semester: 7),
    Course(
        code: CourseCode.CCE417,
        title: 'Data Warehousing and Mining',
        semester: 7),
    Course(
        code: CourseCode.CIT411,
        title: 'Compiler Design and Automata Theory',
        semester: 7),
    Course(
        code: CourseCode.CIT412,
        title: 'Compiler Design and Automata Theory Sessional',
        semester: 7),

    // Semester 8
    Course(code: CourseCode.CSE420, title: 'Project/Thesis', semester: 8),
    Course(code: CourseCode.CSE421, title: 'Seminar', semester: 8),
    Course(
        code: CourseCode.CCE421,
        title: 'Cryptography and Network Security',
        semester: 8),
    Course(
        code: CourseCode.CCE423,
        title: 'Wireless and Cellular Communication',
        semester: 8),
    Course(
        code: CourseCode.CIT421,
        title: 'Computer Graphics and Image Processing',
        semester: 8),
    Course(
        code: CourseCode.CIT422,
        title: 'Computer Graphics and Image Processing Sessional',
        semester: 8),
    Course(code: CourseCode.CIT423, title: 'OPTIONAL', semester: 8),
  ];

  static List<Course> getCoursesBySemester(String semester) {
    final semesterNumber = int.tryParse(semester);
    if (semesterNumber == null) return [];
    return courses
        .where((course) => course.semester == semesterNumber)
        .toList();
  }

  static Course? getCourseByCode(CourseCode code) {
    try {
      return courses.firstWhere((course) => course.code == code);
    } catch (e) {
      return null;
    }
  }

  static Course? getCourseByTitle(String title) {
    try {
      return courses.firstWhere((course) => course.title == title);
    } catch (e) {
      return null;
    }
  }

  static String getFormattedCode(CourseCode code) {
    return code.toString().split('.').last;
  }
}
