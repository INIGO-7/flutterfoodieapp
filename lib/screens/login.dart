import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/register.dart';
import '../util/user_service.dart';
import 'main_screen.dart'; // Asegúrate de importar MainScreen
import 'RestaurantRegister.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();

  // Propiedad estática para almacenar el nombre de usuario
  static String? _userName;

  // Método estático para obtener el nombre de usuario
  static String? getUserName() {
    return _userName;
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();

/*   void _login() async {
    if (_formKey.currentState!.validate()) {
      final isValid = await _userService.validateUser(
        _usernameController.text,
        _passwordController.text,
      );
      if (isValid) {
        _userService
            .setUserLoggedIn(true); // Establecer el estado de "logueado"
        LoginScreen._userName = _usernameController
            .text; // Guardar el nombre de usuario en la propiedad estática
        print(LoginScreen._userName);
        // Navegar al MainScreen, pasando el valor de isLogged como 'true'
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(isLogged: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }
 */
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
          final userType = user['type']; // Aquí obtienes el tipo de usuario
          LoginScreen._userName = _usernameController.text;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                isLogged: true,
                userType: userType, // Pasamos el tipo de usuario
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

  void _registerRestaurant(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
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
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Add your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _login,
                child: Text('Sign In'),
              ),
              SizedBox(height: 8), // Espacio entre botones
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _goToRegister,
                child: Text('Register new user'),
              ),
               SizedBox(height: 8), // Espacio entre botones
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _registerRestaurant,
                child: Text('Register new restaurant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
