import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum CardStatus { good, bad, excellet }

class CardProvider extends ChangeNotifier {
  List<String> _urlImages = [];
  bool _isDragging = false;
  double _angle = 0;
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;

  List<String> get urlImages => _urlImages;
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  CardProvider() {
    resetUser();
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;
    notifyListeners();
  }

  void endPosition() {
    _isDragging = false;
    notifyListeners();

    final status = getStatus();

    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: status.toString().split('.').last.toUpperCase(),
        fontSize: 36,
      );
    }

    switch (status) {
      case CardStatus.good:
        good();
        break;
      case CardStatus.bad:
        bad();
        break;
      case CardStatus.excellet:
        excellet();
        break;
      default:
        resetPosition();
    }
  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0;
    notifyListeners();
  }

  CardStatus? getStatus() {
    final x = _position.dx;
    final y = _position.dy;
    final forceExcellet = x.abs() < 20;
    final delta = 100;

    if (x >= delta) {
      return CardStatus.good;
    } else if (x <= -delta) {
      return CardStatus.bad;
    } else if (y <= -delta / 2 && forceExcellet) {
      return CardStatus.excellet;
    }
  }

  void good() {
    _angle = 20;
    _position += Offset(2 * _screenSize.width / 2, 0);
    _nextCard();
    notifyListeners();
  }

  void bad() {
    _angle = -20;
    _position -= Offset(2 * _screenSize.width, 0);
    _nextCard();
    notifyListeners();
  }

  void excellet() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    _nextCard();
    notifyListeners();
  }

  Future _nextCard() async {
    if (_urlImages.isEmpty) return;

    await Future.delayed(Duration(milliseconds: 200));
    _urlImages.removeLast();
    resetPosition();
  }

  void resetUser() {
    _urlImages = <String>[
      'https://www.psdstack.com/wp-content/uploads/2019/08/copyright-free-images-750x420.jpg',
      'https://www.psdstack.com/wp-content/uploads/2016/10/pixabay-1.jpg',
      'https://www.psdstack.com/wp-content/uploads/2016/10/pexels-7.jpg',
      'https://www.psdstack.com/wp-content/uploads/2016/10/stocksnap-5.jpg',
      'https://www.psdstack.com/wp-content/uploads/2016/10/morguefile-3.jpg'
    ].reversed.toList();
    notifyListeners();
  }
}
