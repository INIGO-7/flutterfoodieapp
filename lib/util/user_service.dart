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
      throw Exception("Error loading users: $e");
    }
  }

  // Guarda la lista de usuarios en el archivo JSON
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    try {
      final file = File(_filePath);
      final content = jsonEncode(users);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception("Error saving users: $e");
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
  final isValid = users.any((user) =>
      user['username'] == username && user['password'] == password);

  if (isValid) {
    // Si las credenciales son válidas, guardar el usuario logueado
    await setLoggedUserName(username);
  }

  return isValid;
}

  // Registra un nuevo usuario
  Future<void> registerUser(String username, String password) async {
    if (await userExists(username)) {
      throw Exception('User already exists.');
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
        print('State of $username changed to: $nuevoEstado');
        break;
      }
    }

    if (!encontrado) {
      print('User $username could not be found.');
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
      print('Password of $username changed to: $newPassword');
      break;
    }
  }

  // Si no se encontró el usuario, lanza un error
  if (!userFound) {
    throw Exception('User not found: $username');
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

  //Guarda el nombre de usuario loggeado
  Future<void> setLoggedUserName(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedUserName', username);
  }

  //Recupera el nombre de usuario loggeado
  Future<String?> getLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedUserName');
  }

  //Cierra la sesión del usuario
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedUserName'); // Borra el nombre del usuario
    await prefs.setBool('isLogged', false); // Marca la sesión como cerrada
  }

}



