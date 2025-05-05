import 'package:erestro/Screen/Authentication/login.dart';
import 'package:erestro/Screen/membership.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Helper/Color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../home.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String? jwtToken;

  @override
  void initState() {
    super.initState();
    getToken();
print("vgbhnjm ${jwtToken}");

  }

  getToken() async {
    jwtToken = await getPrefrence(token);
    print("vgbhnjm ${jwtToken}");
    Future.delayed(const Duration(seconds: 2), () {
      jwtToken != null && jwtToken != ""
          ? Navigator.pop(context,true)
          : Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => const Login(), // Your login screen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with green circle background
              Container(
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(30),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              // Thank You Text
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'Payment done Successfully',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              // Instructional Text
              jwtToken != null && jwtToken != ""? SizedBox() :Text(
                ' click here to return to home page',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 30),
              // Home Button
              ElevatedButton(
                onPressed: () async {
                  print("gvhbjnkm $jwtToken");
                  jwtToken != null && jwtToken != ""
                      ? Navigator.pop(context,true)
                      : Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                const Login(), // Your login screen
                          ),
                        );
                  // Navigator.pushReplacement(
                  //   context,
                  //   CupertinoPageRoute(
                  //     builder: (BuildContext context) => MembershipScreen(mobile: "9876543211"),
                  //   ),
                  // );
                  // Navigate to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child:    jwtToken != null && jwtToken != "" ? Text(
                  'Back',
                  style: TextStyle(fontSize: 16),
                ):Text(
                  'Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
