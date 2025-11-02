import 'package:flutter/foundation.dart';

class ExpandableController extends ChangeNotifier {
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void expand() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  void collapse() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}