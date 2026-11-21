import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/tutor_profile.dart';
import '../services/firestore_service.dart';

/// Prefer `Selector<CatalogProvider, List<TutorProfile>>((p) => p.tutors)` for
/// the list body and `context.select<CatalogProvider, bool>((p) => p.isLoading)`
/// for the spinner; filter chips only need `selectedSubjects`/`minRating`.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._firestoreService);

  final FirestoreService _firestoreService;
  final List<TutorProfile> _allTutors = <TutorProfile>[];
  final List<TutorProfile> _visibleTutors = <TutorProfile>[];
  final Set<String> _selectedSubjects = <String>{};

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  Timer? _searchDebounce;
  String _searchQuery = '';
  double? _maxRate;
  double _minRating = 0;
  bool _availableOnly = false;
  bool _isGridView = false;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  bool _disposed = false;

  List<TutorProfile> get tutors => _visibleTutors;
  String get searchQuery => _searchQuery;
  Set<String> get selectedSubjects => Set<String>.unmodifiable(_selectedSubjects);
  double? get maxRate => _maxRate;
  double get minRating => _minRating;
  bool get availableOnly => _availableOnly;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  List<String> get availableSubjects {
    final Set<String> subjects = <String>{};
    for (final TutorProfile tutor in _allTutors) {
      subjects.addAll(tutor.subjects);
    }
    final List<String> sorted = subjects.toList()..sort();
    return sorted;
  }

  Future<void> loadInitial() async {
    _searchDebounce?.cancel();
    _isLoading = true;
    _error = null;
    _notify();

    try {
      final TutorPage page = await _firestoreService.fetchVerifiedTutors(
        limit: AppConstants.catalogPageSize,
      );
      _allTutors
        ..clear()
        ..addAll(page.tutors);
      _lastDocument = page.lastDocument;
      _hasMore = page.tutors.length >= AppConstants.catalogPageSize;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      _applyFilters();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    _isLoading = true;
    _notify();
    try {
      final TutorPage page = await _firestoreService.fetchVerifiedTutors(
        limit: AppConstants.catalogPageSize,
        startAfter: _lastDocument,
      );
      _allTutors.addAll(page.tutors);
      _lastDocument = page.lastDocument ?? _lastDocument;
      _hasMore = page.tutors.length >= AppConstants.catalogPageSize;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      _applyFilters();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _applyFilters);
    _notify();
  }

  void toggleSubject(String subject) {
    if (_selectedSubjects.contains(subject)) {
      _selectedSubjects.remove(subject);
    } else {
      _selectedSubjects.add(subject);
    }
    _applyFilters();
  }

  void setMaxRate(double? rate) {
    _maxRate = rate;
    _applyFilters();
  }

  void setMinRating(double rating) {
    _minRating = rating;
    _applyFilters();
  }

  void setAvailableOnly(bool value) {
    _availableOnly = value;
    _applyFilters();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    _notify();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedSubjects.clear();
    _maxRate = null;
    _minRating = 0;
    _availableOnly = false;
    _searchDebounce?.cancel();
    _applyFilters();
  }

  void _applyFilters() {
    final String query = _searchQuery.trim().toLowerCase();
    final DateTime now = DateTime.now();
    _visibleTutors
      ..clear()
      ..addAll(
        _allTutors.where((TutorProfile tutor) {
          if (query.isNotEmpty) {
            final bool nameMatch = tutor.displayName.toLowerCase().contains(query);
            final bool subjectMatch = tutor.subjects.any(
              (String subject) => subject.toLowerCase().contains(query),
            );
            if (!nameMatch && !subjectMatch) return false;
          }
          if (_selectedSubjects.isNotEmpty &&
              !tutor.subjects.any(_selectedSubjects.contains)) {
            return false;
          }
          if (_maxRate != null && tutor.hourlyRate > _maxRate!) return false;
          if (tutor.rating < _minRating) return false;
          if (_availableOnly &&
              !tutor.slots.any((slot) => slot.isAvailable(now))) {
            return false;
          }
          return true;
        }),
      );
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _disposed = true;
    super.dispose();
  }
}
