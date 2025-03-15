import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:wordbridge/screens/admin_home.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPass = false;
  var keyForm = GlobalKey<FormState>();
  void showPassword() {
    setState(() {
      showPass = !showPass;
    });
  }

  void login(BuildContext context) async {
    if (!keyForm.currentState!.validate()) {
      return;
    }
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((userCredential) async {
        String userId = userCredential.user!.uid;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged In as an Admin!'),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AdminHome(userId: userId),
          ),
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (ex) {
      print(ex.code);
      if (ex.code == "invalid-credential") {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: 'Invalid Credentials',
                btnOkColor: Colors.red,
                btnOkOnPress: () {})
            .show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login as Admin'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: keyForm,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Email'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email Required";
                  }
                },
              ),
              const Gap(12),
              TextFormField(
                obscureText: showPass ? false : true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Password'),
                  suffixIcon: IconButton(
                    onPressed: () {
                      showPassword();
                    },
                    icon: Icon(showPass
                        ? Icons.remove_red_eye_outlined
                        : Icons.remove_red_eye),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password Required';
                  }
                },
              ),
              const Gap(12),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: IconButton(
                        onPressed: () {
                          login(context);
                        },
                        icon: Icon(Icons.login),
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
