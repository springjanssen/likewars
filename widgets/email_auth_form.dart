import 'package:flutter/material.dart';

class EmailAuthForm extends StatefulWidget {
  final bool isLogin;
  final Function(String, String) onSubmit; // Callback for form submission

  const EmailAuthForm({
    Key? key,
    required this.isLogin,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _EmailAuthFormState createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Call the onSubmit callback with email and password
                widget.onSubmit(_emailController.text, _passwordController.text);
              }
            },
            child: Text(widget.isLogin ? 'Login' : 'Sign Up'),
          ),
        ],
      ),
    );
  }
}