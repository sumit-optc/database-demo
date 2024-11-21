import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    await _dbHelper.initConnection();
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await _dbHelper.getUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final ageController =
        TextEditingController(text: user?['age']?.toString() ?? '');

    final isEditing = user != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User' : 'Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final age = int.tryParse(ageController.text) ?? 0;

                if (name.isNotEmpty && age > 0) {
                  if (isEditing) {
                    await _dbHelper.updateUser(user!['id'], name, age);
                  } else {
                    await _dbHelper.createUser(name, age);
                  }
                  await _fetchUsers();
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(int id) async {
    await _dbHelper.deleteUser(id);
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Demo')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user['name']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showUserDialog(user: user),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteUser(user['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _dbHelper.closeConnection();
    super.dispose();
  }
}
