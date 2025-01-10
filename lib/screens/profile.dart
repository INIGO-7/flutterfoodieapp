import 'package:flutter/material.dart';
import '../util/user_service.dart';
import 'main_screen.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String nombre = "Loading...";
  String estado = "Loading...";
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  void cargarDatosUsuario() async {
    final username = LoginScreen.getUserName() ?? "Failure";
    final userEstado = await _userService.getEstadoUsuario(username);
    setState(() {
      nombre = username;
      estado = userEstado ?? "No estado";
    });
  }


void cambiarPassword() async {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current password'),
            ),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New password'),
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm new password'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Submit'),
          ),
        ],
      );
    },
  );

  if (resultado == true) {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    final username = LoginScreen.getUserName()!;

    // Validar contraseñas
    if (!await _userService.validateUser(username, currentPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current password is not correct')),
      );
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New password cannot be empty')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords are not the same')),
      );
      return;
    }

    // Actualizar contraseña en el archivo JSON
    await _userService.updatePassword(username, newPassword);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password updated correctly!')),
    );
  }
}



void editarEstado() async {
  final TextEditingController controller = TextEditingController(text: estado);

  final nuevoEstado = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit State'),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New state'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color de fondo
              foregroundColor: Colors.white, // Color del texto
            ),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color de fondo
              foregroundColor: Colors.white, // Color del texto
            ),
            child: Text('Submit'),
          ),
        ],
      );
    },
  );

  if (nuevoEstado != null && nuevoEstado.isNotEmpty) {
    final username = LoginScreen.getUserName()!;
    await _userService.updateEstadoUsuario(username, nuevoEstado);
    final updatedEstado = await _userService.getEstadoUsuario(username); // Recargar estado desde el servicio
    setState(() {
      estado = updatedEstado ?? "No estado";
    });
    print('New state: $estado');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50.0, color: Colors.white),
            ),
            SizedBox(height: 16.0),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: editarEstado,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    estado,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                  ),
                  Icon(Icons.edit, color: Colors.grey, size: 16.0),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            Divider(color: Colors.grey),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.green),
              title: Text('Edit profile'),
              onTap: editarEstado,
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.green),
              title: Text('Change password'),
              onTap: cambiarPassword,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.green),
              title: Text('Log out'),
              onTap: () async {
                // Llama a la función logoutUser para limpiar el estado de la sesión
                await _userService.logoutUser();

                // Redirigir al MainScreen con isLogged = false
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(isLogged: false),
                  ),
                  (Route<dynamic> route) => false, // Eliminar todas las rutas anteriores
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
