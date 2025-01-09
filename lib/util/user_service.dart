import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String _filePath = 'users.json';

  // Carga la lista de usuarios desde el archivo JSON
  Future<List<Map<String, dynamic>>> _loadUsers() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        await file.writeAsString('[]'); // Crear archivo vacío si no existe
      }
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(jsonDecode(content));
    } catch (e) {
      throw Exception("Error al cargar usuarios: $e");
    }
  }

  // Guarda la lista de usuarios en el archivo JSON
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    try {
      final file = File(_filePath);
      final content = jsonEncode(users);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception("Error al guardar usuarios: $e");
    }
  }

  // Verifica si un usuario existe
  Future<bool> userExists(String username) async {
    final users = await _loadUsers();
    return users.any((user) => user['username'] == username);
  }

  // Valida las credenciales del usuario
  Future<bool> validateUser(String username, String password) async {
    final users = await _loadUsers();
    return users.any((user) =>
        user['username'] == username && user['password'] == password);
  }

  // Registra un nuevo usuario
  Future<void> registerUser(String username, String password) async {
    if (await userExists(username)) {
      throw Exception('El usuario ya existe.');
    }
    final users = await _loadUsers();
    users.add({'username': username, 'password': password, 'estado': 'Bronze Member'});
    await _saveUsers(users);
  }

  // Obtiene el estado del usuario
  Future<String?> getEstadoUsuario(String username) async {
    final users = await _loadUsers();
    final user = users.firstWhere((user) => user['username'] == username, orElse: () => {});
    return user['estado'];
  }

  // Actualiza el estado del usuario
  Future<void> updateEstadoUsuario(String username, String nuevoEstado) async {
    final users = await _loadUsers();
    bool encontrado = false;
    for (var user in users) {
      if (user['username'] == username) {
        user['estado'] = nuevoEstado;
        encontrado = true;
        print('Estado de $username actualizado a: $nuevoEstado');
        break;
      }
    }

    if (!encontrado) {
      print('Usuario $username no encontrado.');
    }

    await _saveUsers(users);
  }

Future<void> updatePassword(String username, String newPassword) async {
  // Carga la lista de usuarios desde el archivo JSON
  final users = await _loadUsers();
  bool userFound = false;

  // Busca al usuario por su username
  for (var user in users) {
    if (user['username'] == username) {
      user['password'] = newPassword; // Actualiza la contraseña
      userFound = true;
      print('Contraseña de $username actualizada a: $newPassword');
      break;
    }
  }

  // Si no se encontró el usuario, lanza un error
  if (!userFound) {
    throw Exception('Usuario no encontrado: $username');
  }

  // Guarda los cambios en el archivo JSON
  await _saveUsers(users);
}


  // Métodos para manejar el estado de login
  Future<void> setUserLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', value);
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogged') ?? false;
  }
}
