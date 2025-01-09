import 'package:flutter/material.dart';
import '../util/user_service.dart';
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
        title: Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña actual'),
            ),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Nueva contraseña'),
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirmar nueva contraseña'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar'),
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
        SnackBar(content: Text('La contraseña actual no es correcta')),
      );
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La nueva contraseña no puede estar vacía')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // Actualizar contraseña en el archivo JSON
    await _userService.updatePassword(username, newPassword);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contraseña actualizada exitosamente')),
    );
  }
}



void editarEstado() async {
  final TextEditingController controller = TextEditingController(text: estado);

  final nuevoEstado = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Editar Estado'),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Nuevo estado'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color de fondo
              foregroundColor: Colors.white, // Color del texto
            ),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color de fondo
              foregroundColor: Colors.white, // Color del texto
            ),
            child: Text('Guardar'),
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
    print('Nuevo estado cargado: $estado');
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
              onTap: () {
                // Acción para cerrar sesión
              },
            ),
          ],
        ),
      ),
    );
  }
}
