import 'package:postgres/postgres.dart';

class DBHelper {
  late PostgreSQLConnection _connection;

  Future<void> initConnection() async {
    _connection = PostgreSQLConnection(
      '10.0.2.2', // host
      5432, // port
      'postgres', // database
      username: 'postgres',
      password: 'password',
    );

    await _connection.open();
  }

  Future<void> createUser(String name, int age) async {
    await _connection.query(
      'INSERT INTO users (name, age) VALUES (@name, @age)',
      substitutionValues: {
        'name': name,
        'age': age,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final result = await _connection.query('SELECT * FROM users');
    return result.map((row) {
      return {
        'id': row[0],
        'name': row[1],
        'age': row[2],
      };
    }).toList();
  }

  Future<void> updateUser(int id, String name, int age) async {
    await _connection.query(
      'UPDATE users SET name = @name, age = @age WHERE id = @id',
      substitutionValues: {
        'id': id,
        'name': name,
        'age': age,
      },
    );
  }

  Future<void> deleteUser(int id) async {
    await _connection.query(
      'DELETE FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }

  Future<void> closeConnection() async {
    await _connection.close();
  }
}
