import 'package:flutter/material.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String nombre = "Loading..."; // Valor predeterminado en caso de que no se obtenga nada

  @override
  void initState() {
    super.initState();
    // Se llama a getUserName() en initState para obtener el nombre del usuario.
    nombre = LoginScreen.getUserName() ?? "Failure";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 50.0,
                color: Colors.white,
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
            Text(
              'Foodie Tier',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.0),
            Divider(color: Colors.grey),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.green),
              title: Text('Edit profile'),
              onTap: () {
                // Acción para editar perfil
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.green),
              title: Text('Change password'),
              onTap: () {
                // Acción para cambiar contraseña
              },
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
