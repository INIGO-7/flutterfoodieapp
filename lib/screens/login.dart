import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/register.dart';
import '../util/user_service.dart';
import 'main_screen.dart';
import 'RestaurantRegister.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();

  static String? _userName;

  static String? getUserName() {
    return _userName;
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final isValid = await _userService.validateUser(
        _usernameController.text,
        _passwordController.text,
      );

      if (isValid) {
        final user = await _userService.getUser(
          _usernameController.text,
          _passwordController.text,
        );

        if (user != null) {
          final userType = user['type'];
          LoginScreen._userName = _usernameController.text;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                isLogged: true,
                userType: userType,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _registerRestaurant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LOGIN'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true, // Centra el texto
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Campos de texto para login
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Add your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Add your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Botón Sign In
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% del ancho de la pantalla
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: _login,
                    child: Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 24),
                // Barra divisoria con "OR" en el medio
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                  ],
                ),
                SizedBox(height: 24),
                // Botones de registro con borde verde y fondo blanco
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% del ancho de la pantalla
                  child: OutlinedButton(
                    onPressed: _goToRegister,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5.0,
                    ),
                    child: Text(
                      'Register as user',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% del ancho de la pantalla
                  child: OutlinedButton(
                    onPressed: _registerRestaurant,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5.0,
                    ),
                    child: Text(
                      'Register as restaurant',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
