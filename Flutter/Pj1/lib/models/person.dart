class Person {
  
  String _name;
  String _surname;

  Person({String name = '', String surname = ''})
      : _name = name,
        _surname = surname;

  Person.fromFullName(String fullName)
      : _name = fullName.split(' ').first,
        _surname = fullName.split(' ').skip(1).join(' ');

  String get name => _name;
  String get surname => _surname;
  String get fullName => '$_name $_surname';

  set name(String value) => _name = value;
  set surname(String value) => _surname = value;
}
