import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para cargar imágenes de los assets
import '../util/user_service.dart'; // Tu clase de servicio de usuario
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
  String? imagenPerfil; // Para almacenar la ruta de la imagen seleccionada
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  void cargarDatosUsuario() async {
    final username = LoginScreen.getUserName() ?? "Failure";
    final userEstado = await _userService.getEstadoUsuario(username);
    final userImagenPerfil = await _userService.getImagenPerfil(username);
    setState(() {
      nombre = username;
      estado = userEstado ?? "No estado";
      imagenPerfil = userImagenPerfil;
    });
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
                  leading: Image.asset('assets/Profile_pictures/Prf1.jpg', width: 40, height: 40),
                  title: Text('Photo1'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf1.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf2.jpg', width: 40, height: 40),
                  title: Text('Photo2'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf2.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf3.jpg', width: 40, height: 40),
                  title: Text('Photo3'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf3.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf4.jpg', width: 40, height: 40),
                  title: Text('Photo4'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf4.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf5.jpg', width: 40, height: 40),
                  title: Text('Photo5'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf5.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf6.jpg', width: 40, height: 40),
                  title: Text('Photo6'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf6.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf7.jpg', width: 40, height: 40),
                  title: Text('Photo7'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf7.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf8.jpg', width: 40, height: 40),
                  title: Text('Photo8'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf8.jpg'),
                ),
                ListTile(
                  leading: Image.asset('assets/Profile_pictures/Prf9.jpg', width: 40, height: 40),
                  title: Text('Photo9'),
                  onTap: () => Navigator.of(context).pop('assets/Profile_pictures/Prf9.jpg'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (imagenSeleccionada != null) {
    // Guarda la imagen seleccionada en el archivo JSON
    final username = LoginScreen.getUserName()!;
    await _userService.updateImagenPerfil(username, imagenSeleccionada);

    // Actualiza el estado con la imagen seleccionada
    setState(() {
      imagenPerfil = imagenSeleccionada;
    });
  }
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 5.0
            ),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 5.0
            ),
            child: Text('Update'),
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
        SnackBar(content: Text('Current password incorrect')),
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
        SnackBar(content: Text('Passwords are not equal')),
      );
      return;
    }
    // Actualizar contraseña en el archivo JSON
    await _userService.updatePassword(username, newPassword);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password changed successfully')),
    );
  }
}




  // Actualiza el estado del usuario
  void editarEstado() async {
    final TextEditingController controller = TextEditingController(text: estado);

    final nuevoEstado = await showDialog<String>(context: context, builder: (context) {
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
    });

    if (nuevoEstado != null && nuevoEstado.isNotEmpty) {
      final username = LoginScreen.getUserName()!;
      await _userService.updateEstadoUsuario(username, nuevoEstado);
      final updatedEstado = await _userService.getEstadoUsuario(username); // Recargar estado desde el servicio
      setState(() {
        estado = updatedEstado ?? "No estado";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: Text('PROFILE', style: TextStyle(color: Colors.white)),
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
              child: GestureDetector(
                onTap: seleccionarImagen, // Permite al usuario seleccionar una imagen
                child: imagenPerfil == null
                    ? Icon(Icons.person, size: 50.0, color: Colors.white) // Icono por defecto
                    : ClipOval(
                        child: Image.asset(
                          imagenPerfil!,
                          fit: BoxFit.cover,
                          width: 100.0,
                          height: 100.0,
                        ),
                      ),
              ),
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
              onTap: (cambiarPassword)
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.green),
              title: Text('Log out'),
              onTap: () async {
                await _userService.logoutUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(isLogged: false, userType: 'user',),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
