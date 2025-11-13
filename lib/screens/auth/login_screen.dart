import 'package:famai/providers/auth_provider.dart';
import 'package:famai/screens/auth/register_screen.dart';
import 'package:famai/widgets/custom_button.dart';
import 'package:famai/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to Famai',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your AI farming assistant',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CustomInput(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value?.isEmpty ?? true) ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    validator: (value) => (value?.isEmpty ?? true) ? 'Please enter your password' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(onPressed: _login, text: 'Login'),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () { /* TODO: Implement Google Sign-In */ },
                    text: 'Sign in with Google',
                    isOutline: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        ),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
