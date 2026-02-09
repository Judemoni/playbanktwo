import 'package:chasebank/widgets/constants.dart';
import 'package:chasebank/services/auth_services.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool rememberMe = false;
  bool useToken = false;
  bool obscurePassword = true;
  bool isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await AuthServices().signIn(email, password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A4AA6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Chase Logo
            const Text(
              'CHASE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 30),

            // White Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      const Text(
                        'Enter your email',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0A4AA6)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF0A4AA6), width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Password
                      const Text(
                        'Enter your password',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0A4AA6)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF0A4AA6), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF0A4AA6),
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Remember Me
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                        title: const Text('Remember me'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      // Use Token
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: useToken,
                        onChanged: (value) {
                          setState(() {
                            useToken = value!;
                          });
                        },
                        title: const Text('Use token'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      const SizedBox(height: 16),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A4AA6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: isLoading ? null : _signIn,
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot username or password?',
                            style: TextStyle(
                              color: Color(0xFF0A4AA6),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                  color: Color(0xFF0A4AA6), fontSize: 12),
                            ),
                          ),
                          const Text(
                            'Open an account',
                            style: TextStyle(
                                color: Color(0xFF0A4AA6), fontSize: 12),
                          ),
                          const Text(
                            'Privacy',
                            style: TextStyle(
                                color: Color(0xFF0A4AA6), fontSize: 12),
                          ),
                          const Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: Color(0xFF0A4AA6),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Legal Text
                      const Text(
                        'Equal Housing Opportunity\n'
                        'Deposit products provided by JPMorgan Chase Bank, N.A. Member FDIC\n'
                        'Credit cards are issued by JPMorgan Chase Bank, N.A. Member FDIC\n'
                        '© 2025 JPMorgan Chase & Co.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
