import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Perfil',
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
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Nombre de Usuario',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'usuario@example.com',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.0),
            Divider(color: Colors.grey),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Editar Perfil'),
              onTap: () {
                // Acción para editar perfil
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text('Cambiar Contraseña'),
              onTap: () {
                // Acción para cambiar contraseña
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
              title: Text('Cerrar Sesión'),
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
