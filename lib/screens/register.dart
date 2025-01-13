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
  final TextEditingController imgController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();

  bool _isButtonEnabled = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _userService.registerUser(
          _usernameController.text,
          _passwordController.text,
          imgController.text,
        );

        // Mostrar un AlertDialog de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('User registered successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    // Navegar a la pantalla principal sin permitir volver atrás
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      bool isLogged = false;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(
                            isLogged: isLogged,
                            userType: 'user',
                          ),
                        ),
                      );
                    });
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Mostrar un AlertDialog de error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Escucha cambios en los controladores
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    imgController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          imgController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void seleccionarImagen() async {
    final imagenSeleccionada = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a profile photo'),
          content: Container(
            height: 300.0, // Ajusta la altura según lo que necesites
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0, // Espaciado entre las imágenes
                runSpacing: 8.0, // Espaciado entre las filas
                children: [
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf1.jpg',
                        width: 40, height: 40),
                    title: Text('Photo1'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf1.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf2.jpg',
                        width: 40, height: 40),
                    title: Text('Photo2'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf2.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf3.jpg',
                        width: 40, height: 40),
                    title: Text('Photo3'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf3.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf4.jpg',
                        width: 40, height: 40),
                    title: Text('Photo4'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf4.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf5.jpg',
                        width: 40, height: 40),
                    title: Text('Photo5'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf5.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf6.jpg',
                        width: 40, height: 40),
                    title: Text('Photo6'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf6.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf7.jpg',
                        width: 40, height: 40),
                    title: Text('Photo7'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf7.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf8.jpg',
                        width: 40, height: 40),
                    title: Text('Photo8'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf8.jpg'),
                  ),
                  ListTile(
                    leading: Image.asset('assets/Profile_pictures/Prf9.jpg',
                        width: 40, height: 40),
                    title: Text('Photo9'),
                    onTap: () => Navigator.of(context)
                        .pop('assets/Profile_pictures/Prf9.jpg'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (imagenSeleccionada != null) {
      setState(() {
        imgController.text = imagenSeleccionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: Text(
            'Register',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              bool isLogged = false;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(
                          isLogged: isLogged,
                          userType: 'user',
                        )),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: seleccionarImagen,
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.green,
                    child: imgController.text.isEmpty
                        ? const Icon(Icons.person, size: 50.0, color: Colors.white)
                        : ClipOval(
                            child: Image.asset(
                              imgController.text,
                              fit: BoxFit.cover,
                              width: 100.0,
                              height: 100.0,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Tap to select an image',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Add an username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
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
                      return 'Add a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5.0,
                      ),
                      onPressed: _isButtonEnabled ? _register : null,
                      child: const Text('Register'),
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
