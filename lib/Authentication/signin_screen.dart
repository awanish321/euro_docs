import 'package:euro_docs/Authentication/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'forgot_password.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _obscureText = true;
  bool _rememberMe = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameOrEmailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Pass the user's email to HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred during sign in')),
      );
    }
  }

  Future<void> _signInWithUsernameOrEmail(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        String usernameOrEmail = _usernameOrEmailController.text;
        String email;

        if (!_isEmail(usernameOrEmail)) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: usernameOrEmail)
              .get();

          if (querySnapshot.docs.isEmpty) {
            _showSnackbar(context, 'No user found for that username.');
            return;
          }

          email = querySnapshot.docs.first['email'];
        } else {
          email = usernameOrEmail; // Input is already an email
        }

        // Attempt to sign in with email and password
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );

        debugPrint('User signed in: ${userCredential.user!.uid}');
        _rememberUser();

        // Navigate to HomeScreen with email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e){
      if (e.code == 'user-not-found') {
        _showSnackbar(context, 'No user found for that email or username.');
      } else if (e.code == 'wrong-password') {
        _showSnackbar(context, 'Wrong password provided.');
      } else {
        _showSnackbar(context, 'Error signing in: ${e.message}');
      }
    } catch (e) {
      _showSnackbar(context, 'Error signing in: $e');
    }
  }

  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'username': user.displayName,
      'photoURL': user.photoURL,
    };
    await userRef.set(userData, SetOptions(merge: true));
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint('User signed in: ${userCredential.user!.uid}');
        _rememberUser();
        _saveUserToFirestore(userCredential.user!);

        // Navigate to HomeScreen with the user's email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _rememberUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setBool('rememberMe', true);
      prefs.setString('usernameOrEmail', _usernameOrEmailController.text);
      prefs.setString('password', _passwordController.text);
    } else {
      prefs.setBool('rememberMe', false);
      prefs.remove('usernameOrEmail');
      prefs.remove('password');
    }
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    if (_rememberMe) {
      _usernameOrEmailController.text = prefs.getString('usernameOrEmail') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Log in to',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Eurotech',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: SvgPicture.asset('assets/google-icon.svg', height: 24),
                    label: const Text('Login with Google'),
                    onPressed: () {
                      _signInWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white, backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(thickness: 1, color: Colors.black, indent: 50)),
                    SizedBox(width: 10),
                    Text("or login in with"),
                    SizedBox(width: 10),
                    Expanded(child: Divider(thickness: 1, color: Colors.black, endIndent: 50)),
                  ],
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameOrEmailController,
                        decoration: InputDecoration(
                          labelText: 'Username or E-mail',
                          hintText: 'Enter your username or email',
                          suffixIcon: const Icon(Iconsax.user),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your username or email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              color: Colors.grey,
                              _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                activeColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value!;
                                  });
                                },
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _signInWithUsernameOrEmail(context);
                    },
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
