import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  bool _obscurePassword = true;

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        
        Navigator.popAndPushNamed(context, "/bottomnav");
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Login failed. Please try again.";

        if (e.code == "user-not-found") {
          errorMessage = "No user found for this email.";
        } else if (e.code == "wrong-password") {
          errorMessage = "Incorrect password.";
        } else if (e.code == "invalid-email") {
          errorMessage = "Invalid email format.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred. Try again."),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Welcome Back!",
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/earth.json', 
                      height: 220, 
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.endsWith("@rit.ac.in")) {
                        return 'Use your @rit.ac.in email';
                      }
                      return null;
                    },
                    style: TextStyle(fontFamily: 'Gilroy', fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(fontFamily: 'Gilroy'),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  
                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    obscureText:
                        _obscurePassword, 
                    style: TextStyle(fontFamily: 'Gilroy', fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(fontFamily: 'Gilroy'),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      
                      suffixIcon: IconButton(
                        icon: Icon(
                          
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  
                  GestureDetector(
                    onTap: isLoading ? null : loginUser,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 37, 232, 154),
                            Color.fromARGB(255, 42, 254, 169),
                            Color.fromARGB(255, 29, 213, 140),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Log In",
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/register');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
