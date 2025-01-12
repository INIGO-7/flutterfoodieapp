import 'package:flutter/material.dart';
import '../util/user_service.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _userService.registerUser(
          _usernameController.text,
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );

        // Navegar a la pantalla principal sin permitir volver atrás
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bool isLogged = false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(isLogged: isLogged)),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Previene regresar atrás
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0), // Altura estándar de AppBar
          child: AppBar(
            backgroundColor: Colors.green,
            centerTitle: true,
            title: Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false, // Elimina la flecha hacia atrás
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Regresar a la pantalla principal
                bool isLogged = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen(isLogged: isLogged)),
                );
              },
            ),
          ),
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
                      return 'Add an username';
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
                      return 'Add a password';
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
                  onPressed: _register,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
