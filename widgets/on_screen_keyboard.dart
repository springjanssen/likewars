import 'package:flutter/material.dart';

class OnScreenKeyboard extends StatefulWidget {
  final Function(String) onKeyPressed;

  const OnScreenKeyboard({
    Key? key,
    required this.onKeyPressed,
  }) : super(key: key);

  @override
  _OnScreenKeyboardState createState() => _OnScreenKeyboardState();
}

class _OnScreenKeyboardState extends State<OnScreenKeyboard> {
  bool _isShiftPressed = false;
  bool _isCapsLockOn = false;

  void _handleKeyPress(String key) {
    if (key == 'Shift') {
      setState(() {
        _isShiftPressed = !_isShiftPressed;
        _isCapsLockOn = false; // Turn off Caps Lock when Shift is pressed
      });
    } else if (key == 'Caps') {
      setState(() {
        _isCapsLockOn = !_isCapsLockOn;
        _isShiftPressed = false; // Turn off Shift when Caps Lock is pressed
      });
    } else if (key == 'Space') {
      widget.onKeyPressed(' '); // Send a space character instead of "Space"
    } else {
      widget.onKeyPressed(_getFinalKey(key));
      if (_isShiftPressed) {
        setState(() {
          _isShiftPressed = false; // Reset Shift after a letter is pressed
        });
      }
    }
  }

  String _getFinalKey(String key) {
    if (_isCapsLockOn || _isShiftPressed) {
      return key.toUpperCase();
    }
    return key.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']),
        _buildRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']),
        _buildRow(['Shift', 'Caps', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Space']),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        double width;
        if (key == 'Space') {
          width = 150;
        } else if (key == 'Shift' || key == 'Caps') {
          width = 60; // Increased width for Shift and Caps
        } else {
          width = 40;
        }
        return Container(
          width: width,
          margin: EdgeInsets.all(2),
          child: _KeyboardKey(
            label: key == 'Space' ? '␣' : _getDisplayedLabel(key),
            isActive: key == 'Caps' ? _isCapsLockOn : key == 'Shift' ? _isShiftPressed : false,
            onPressed: () => _handleKeyPress(key),
          ),
        );
      }).toList(),
    );
  }

  String _getDisplayedLabel(String key) {
    return _isCapsLockOn || _isShiftPressed ? key.toUpperCase() : key.toLowerCase();
  }
}

class _KeyboardKey extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _KeyboardKey({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  _KeyboardKeyState createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<_KeyboardKey> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 30), // Reduced from 50ms to 30ms
        vsync: this,
      );

      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isActive ? Colors.blue.shade700 : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.label == 'Shift' || widget.label == 'Caps' ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: widget.isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
