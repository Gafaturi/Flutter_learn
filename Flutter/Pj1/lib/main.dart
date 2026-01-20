import 'package:flutter/material.dart';
import 'models/person.dart';

void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PersonPage(), // головний екран
    );
  }
}

/// СТОРІНКА PERSON
class PersonPage extends StatefulWidget {
  const PersonPage({super.key});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  // Обʼєкт класу Person
  Person _person = Person(name: 'Імʼя', surname: 'Прізвище');

  // Контролери для текстових полів
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();

  /// Метод викликається при створенні сторінки
  @override
  void initState() {
    super.initState();

    _nameCtrl.text = _person.name;
    _surnameCtrl.text = _person.surname;
  }

  // Звільняємо памʼять
  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    super.dispose();
  }

  // Зберігаємо нові дані
  void _save() {
    setState(() {
      // Використовуємо сетери класу Person
      _person.name = _nameCtrl.text;
      _person.surname = _surnameCtrl.text;
    });
  }

  // Інтерфейс сторінки
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Person')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Відображення повного імені
            Text(
              _person.fullName,
              style: const TextStyle(fontSize: 24),
            ),
            // Поле для введення імені
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Імʼя'),
            ),

            // Поле для введення прізвища
            TextField(
              controller: _surnameCtrl,
              decoration: const InputDecoration(labelText: 'Прізвище'),
            ),

            const SizedBox(height: 12),

            // Кнопка збереження
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
