import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lending.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? "User";
          });
        } else {
          setState(() {
            userName = "User";
          });
        }
      }
    } catch (e) {
      setState(() {
        userName = "User";
      });
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola!',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            fontFamily: 'Gilroy'),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            fontFamily: 'Gilroy'),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Logged out successfully!')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logout failed: $e')),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: const Text(
                  'Access your campus features quickly',
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF777777),
                      fontFamily: 'Gilroy'),
                ),
              ),
              const SizedBox(height: 40),
              FeatureButton(
                icon: Icons.calendar_today,
                title: 'Calendar',
                description:
                    'View and manage your academic schedule and request rooms',
              ),
              const SizedBox(height: 20),
              FeatureButton(
                icon: Icons.assignment_outlined,
                title: 'Project Help',
                description: 'Lend project components',
              ),
              const SizedBox(height: 20),
              FeatureButton(
                icon: Icons.account_balance_wallet,
                title: 'Pocket Money',
                description:
                    'Manage your campus wallet and expenses through proper disposal of plastic',
                //
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 37, 232, 154)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Color.fromARGB(255, 37, 232, 154),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Did you know?',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Gilroy'),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'You can now access all your campus services from this interactive app!',
                            style: TextStyle(
                                color: Color(0xFF666666), fontFamily: 'Gilroy'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 37, 232, 154),
                  Color.fromARGB(255, 42, 254, 169),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF333333),
                      fontFamily: 'Gilroy'),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 14,
                      fontFamily: 'Gilroy'),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFCCCCCC),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const GradientButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 37, 232, 154),
            Color.fromARGB(255, 42, 254, 169),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 37, 232, 154).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(child: child),
        ),
      ),
    );
  }
}
