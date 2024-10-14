import 'package:flutter/material.dart';
import '../models/player_model.dart';

class EditProfileDialog extends StatefulWidget {
  final PlayerModel player;

  EditProfileDialog({required this.player});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.player.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _displayName,
          decoration: InputDecoration(labelText: 'Display Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Display name cannot be empty';
            }
            return null;
          },
          onSaved: (value) {
            _displayName = value ?? _displayName;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog without saving
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              setState(() {
                widget.player.displayName = _displayName;
              });
              widget.player.notifyListeners(); // Notify listeners of the change
              Navigator.pop(context); // Close the dialog after saving
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
