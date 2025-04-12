import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neocaresmileapp/services/bloc/auth_bloc.dart';
import 'package:neocaresmileapp/services/bloc/auth_event.dart';
import 'package:neocaresmileapp/services/bloc/auth_state.dart';

class CreateUserWidget extends StatefulWidget {
  const CreateUserWidget({super.key});

  @override
  State<CreateUserWidget> createState() => _CreateUserWidgetState();
}

class _CreateUserWidgetState extends State<CreateUserWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createUser(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Dispatch the AuthEventCreateUser event to the AuthBloc
      context.read<AuthBloc>().add(
            AuthEventCreateUser(email: email, password: password),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateRegistering && state.isLoading) {
          // Show a loading indicator while registering
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthStateRegistering && state.exception != null) {
          // Handle error
          Navigator.of(context).pop(); // Close the loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to create user: ${state.exception}')),
          );
        } else if (state is AuthStateLoggedOut && state.exception == null) {
          // Handle success
          Navigator.of(context).pop(); // Close the loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'User created successfully. Verification email sent.')),
          );
          Navigator.pop(context); // Optionally close the CreateUserWidget
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New User'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration:
                      const InputDecoration(labelText: 'Temporary Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password should be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _createUser(context),
                  child: const Text('Create User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
