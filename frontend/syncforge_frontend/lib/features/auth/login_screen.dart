import 'package:flutter/material.dart';
import '../../core/widgets/custom_textfield.dart';
import 'auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {

    print("LOGIN BUTTON CLICKED");

    setState(() {
      loading = true;
    });

    bool success = await AuthService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    print("LOGIN RESULT: $success");

    setState(() {
      loading = false;
    });

    if (success) {

      print("NAVIGATING TO PROJECTS");

      Navigator.pushReplacementNamed(context, "/projects");

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF06B6D4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),

                child: Card(
                  elevation: 12,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: Color(0xFF2563EB),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "SyncForge",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Team Collaboration Platform",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 30),

                        CustomTextField(
                          controller: emailController,
                          label: "Email",
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: passwordController,
                          label: "Password",
                          obscure: true,
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            onPressed: loading ? null : login,

                            child: loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            const Text(
                              "Don't have an account?",
                              style: TextStyle(fontSize: 13),
                            ),

                            TextButton(

                              onPressed: () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );

                              },

                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )

                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}