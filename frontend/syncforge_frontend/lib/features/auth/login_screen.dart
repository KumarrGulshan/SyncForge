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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Card(
                elevation: 6,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text(
                        "SyncForge Login",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
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

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,

                        child: ElevatedButton(
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
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Text("Don't have an account?"),

                          TextButton(
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );

                            },

                            child: const Text("Register"),
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
    );
  }
}