import 'dart:convert';
import 'dart:io';

class UserService {
  final String _filePath = 'users.json';

  Future<List<Map<String, String>>> _loadUsers() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        await file.writeAsString('[]'); // Crear archivo vacío si no existe
      }
      final content = await file.readAsString();
      // Asegurarse de que cada elemento de la lista se convierta en Map<String, String>
      final List<dynamic> decodedList = jsonDecode(content);
      return decodedList.map((user) => Map<String, String>.from(user)).toList();
    } catch (e) {
      throw Exception("Error al cargar usuarios: $e");
    }
  }

  Future<void> _saveUsers(List<Map<String, String>> users) async {
    try {
      final file = File(_filePath);
      final content = jsonEncode(users);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception("Error al guardar usuarios: $e");
    }
  }

  Future<bool> userExists(String username) async {
    final users = await _loadUsers();
    return users.any((user) => user['username'] == username);
  }

  Future<bool> validateUser(String username, String password) async {
    final users = await _loadUsers();
    return users.any((user) =>
        user['username'] == username && user['password'] == password);
  }

  Future<void> registerUser(String username, String password) async {
    if (await userExists(username)) {
      throw Exception('El usuario ya existe.');
    }
    final users = await _loadUsers();
    users.add({'username': username, 'password': password});
    await _saveUsers(users);
  }
}
