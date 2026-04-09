import 'package:flutter/material.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool loading = false;

  Future<void> register() async {

    setState(() {
      loading = true;
    });

    await AuthService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passController.text.trim(),
    );

    setState(() {
      loading = false;
    });

    Navigator.pop(context);
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
                  color: const Color(0xFF1E293B),
                  elevation: 8,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // LOGO
                        Image.asset(
                          "assets/images/syncforge_logo.png",
                          height: 80,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "SyncForge",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Create your account",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),

                          decoration: const InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),

                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),

                          decoration: const InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 48,

                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            onPressed: loading ? null : register,

                            child: loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                         onPressed: () {
                           Navigator.pushReplacementNamed(context, "/");
                          },
                         child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.white70),
                         ),
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