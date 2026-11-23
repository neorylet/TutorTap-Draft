import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/cloudinary_config.dart';
import '../models/assignment.dart';
import '../models/classroom_module.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

enum UploadPurpose { avatar, credential, module, assignmentAttachment, submission }

class PendingUpload {
  const PendingUpload({
    required this.filePath,
    required this.fileName,
    required this.folder,
    required this.purpose,
    required this.ownerId,
    this.assignmentId,
    this.error,
  });

  final String filePath;
  final String fileName;
  final String folder;
  final UploadPurpose purpose;
  final String ownerId;
  final String? assignmentId;
  final String? error;

  PendingUpload copyWith({String? error}) => PendingUpload(
    filePath: filePath,
    fileName: fileName,
    folder: folder,
    purpose: purpose,
    ownerId: ownerId,
    assignmentId: assignmentId,
    error: error ?? this.error,
  );
}

/// Keep the picked file in `pendingUpload` so a failed upload is retryable
/// with one tap. A Cloudinary widget only needs `context.select<ClassroomProvider, bool>((p) => p.isUploading)`.
class ClassroomProvider extends ChangeNotifier {
  ClassroomProvider(this._firestoreService, this._cloudinaryService);

  final FirestoreService _firestoreService;
  final CloudinaryService _cloudinaryService;
  StreamSubscription<List<ClassroomModule>>? _modulesSubscription;
  StreamSubscription<List<Assignment>>? _assignmentsSubscription;
  StreamSubscription<List<Exam>>? _examsSubscription;
  StreamSubscription<List<Course>>? _coursesSubscription;

  List<ClassroomModule> _modules = <ClassroomModule>[];
  List<Assignment> _assignments = <Assignment>[];
  List<Exam> _exams = <Exam>[];
  List<Course> _courses = <Course>[];
  PendingUpload? _pendingUpload;
  bool _isUploading = false;
  String? _error;
  bool _disposed = false;

  List<ClassroomModule> get modules => _modules;
  List<Assignment> get assignments => _assignments;
  List<Exam> get exams => _exams;
  List<Course> get courses => _courses;
  PendingUpload? get pendingUpload => _pendingUpload;
  bool get isUploading => _isUploading;
  String? get error => _error;

  void watchTutorClassroom(String tutorId) {
    _cancelSubscriptions();
    watchCoursesForTutor(tutorId);
    _modulesSubscription = _firestoreService
        .watchModules(tutorId)
        .listen(
          (items) {
            _modules = items;
            _notify();
          },
          onError: (Object error) {
            _error = error.toString();
            _notify();
            debugPrint('watchModules error: $error');
          },
        );
    _assignmentsSubscription = _firestoreService
        .watchAssignmentsForTutor(tutorId)
        .listen(
          (items) {
            _assignments = items;
            _notify();
          },
          onError: (Object error) {
            _error = error.toString();
            _notify();
            debugPrint('watchAssignmentsForTutor error: $error');
          },
        );
    _examsSubscription = _firestoreService
        .watchExams(tutorId)
        .listen(
          (items) {
            _exams = items;
            _notify();
          },
          onError: (Object error) {
            _error = error.toString();
            _notify();
            debugPrint('watchExams error: $error');
          },
        );
  }

  void watchStudentAssignments(String studentId) {
    _assignmentsSubscription?.cancel();
    _assignmentsSubscription = _firestoreService
        .watchAssignmentsForStudent(studentId)
        .listen(
          (items) {
            _assignments = items;
            _notify();
          },
          onError: (Object error) {
            _error = error.toString();
            _notify();
            debugPrint('watchAssignmentsForStudent error: $error');
          },
        );
  }

  void watchCoursesForTutor(String tutorId) {
    _coursesSubscription?.cancel();
    _coursesSubscription = _firestoreService
        .watchCoursesForTutor(tutorId)
        .listen(
          (items) {
            _courses = items;
            _notify();
          },
          onError: (Object error) {
            _error = error.toString();
            _notify();
            debugPrint('watchCoursesForTutor error: $error');
          },
        );
  }

  Future<CloudinaryUploadResult?> uploadFile({
    required String filePath,
    required UploadPurpose purpose,
    required String ownerId,
    String? assignmentId,
    String? fileName,
  }) async {
    final String folder = switch (purpose) {
      UploadPurpose.avatar => CloudinaryConfig.avatarFolder(ownerId),
      UploadPurpose.credential => CloudinaryConfig.credentialFolder(ownerId),
      UploadPurpose.module => CloudinaryConfig.moduleFolder(ownerId),
      UploadPurpose.assignmentAttachment =>
        CloudinaryConfig.assignmentAttachmentFolder(ownerId),
      UploadPurpose.submission => CloudinaryConfig.submissionFolder(
        assignmentId ?? ownerId,
      ),
    };

    final PendingUpload pending = PendingUpload(
      filePath: filePath,
      fileName: fileName ?? filePath.split(RegExp(r'[\\/]')).last,
      folder: folder,
      purpose: purpose,
      ownerId: ownerId,
      assignmentId: assignmentId,
    );

    _pendingUpload = pending;
    _isUploading = true;
    _error = null;
    _notify();

    try {
      final CloudinaryUploadResult result = await _cloudinaryService.uploadFile(
        path: filePath,
        folder: folder,
      );
      _pendingUpload = null;
      return result;
    } catch (error) {
      _error = error.toString();
      _pendingUpload = pending.copyWith(error: error.toString());
      return null;
    } finally {
      _isUploading = false;
      _notify();
    }
  }

  Future<CloudinaryUploadResult?> retryPendingUpload() async {
    final PendingUpload? pending = _pendingUpload;
    if (pending == null) return null;
    return uploadFile(
      filePath: pending.filePath,
      purpose: pending.purpose,
      ownerId: pending.ownerId,
      assignmentId: pending.assignmentId,
      fileName: pending.fileName,
    );
  }

  void discardPendingUpload() {
    _pendingUpload = null;
    _error = null;
    _notify();
  }

  Future<void> createModule({
    required String tutorId,
    required String title,
    required String description,
    required String fileUrl,
    required String fileType,
  }) async {
    final DateTime now = DateTime.now();
    await _firestoreService.addModule(
      ClassroomModule(
        id: '',
        tutorId: tutorId,
        title: title,
        description: description,
        fileUrl: fileUrl,
        fileType: fileType,
        createdAt: now,
      ),
    );
  }

  Future<void> createCourse({
    required String tutorId,
    required String title,
    required String description,
    required String subject,
  }) async {
    try {
      await _firestoreService.createCourse(
        tutorId: tutorId,
        title: title,
        description: description,
        subject: subject,
      );
      _error = null;
      _notify();
    } catch (error) {
      _error = error.toString();
      _notify();
    }
  }

  Future<void> createModuleInCourse({
    required String tutorId,
    required String courseId,
    required String title,
    required String description,
    String fileUrl = '',
    String fileType = '',
    required int orderIndex,
  }) async {
    try {
      final DateTime now = DateTime.now();
      await _firestoreService.addModule(
        ClassroomModule(
          id: '',
          tutorId: tutorId,
          title: title,
          description: description,
          fileUrl: fileUrl,
          fileType: fileType,
          createdAt: now,
          courseId: courseId,
          orderIndex: orderIndex,
        ),
      );
      _error = null;
      _notify();
    } catch (error) {
      _error = error.toString();
      _notify();
    }
  }

  Future<bool> deleteCourse({required String courseId}) async {
    try {
      await _firestoreService.deleteCourse(courseId);
      _error = null;
      _notify();
      return true;
    } catch (error) {
      _error = error.toString();
      _notify();
      return false;
    }
  }

  Future<bool> deleteModule({required String moduleId}) async {
    try {
      await _firestoreService.deleteModule(moduleId);
      _error = null;
      _notify();
      return true;
    } catch (error) {
      _error = error.toString();
      _notify();
      return false;
    }
  }

  Future<void> createAssignment({
    required String tutorId,
    required String studentId,
    required String title,
    required String instructions,
    required DateTime dueDate,
    double maxScore = 10,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    await _firestoreService.addAssignment(
      Assignment(
        id: '',
        tutorId: tutorId,
        studentId: studentId,
        title: title,
        instructions: instructions,
        dueDate: dueDate,
        maxScore: maxScore,
        status: AssignmentStatus.assigned,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      ),
    );
  }

  Future<void> submitAssignment({
    required Assignment assignment,
    String? submissionText,
    String? submissionUrl,
  }) async {
    await _firestoreService.updateAssignment(assignment.id, <String, dynamic>{
      'submissionText': submissionText ?? assignment.submissionText,
      'submissionUrl': submissionUrl ?? assignment.submissionUrl,
      'submittedAt': DateTime.now().toIso8601String(),
      'status': AssignmentStatus.submitted.value,
    });
  }

  Future<void> gradeAssignment({
    required String assignmentId,
    required double grade,
    required String feedback,
  }) async {
    await _firestoreService.updateAssignment(assignmentId, <String, dynamic>{
      'grade': grade,
      'feedback': feedback,
      'status': AssignmentStatus.graded.value,
    });
  }

  Future<void> createExam(Exam exam) => _firestoreService.addExam(exam);

  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  void _cancelSubscriptions() {
    _modulesSubscription?.cancel();
    _assignmentsSubscription?.cancel();
    _examsSubscription?.cancel();
    _coursesSubscription?.cancel();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _disposed = true;
    super.dispose();
  }
}
