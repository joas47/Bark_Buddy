import 'package:cross_platform_test/dog.dart';

class Owner {
  final String _name;
  int _age;
  final String _email;
  final String _password;

  List<Dog> dogs = [];

  Owner(this._name, this._age, this._email, this._password);

  void addDog(Dog dog) {
    dogs.add(dog);
  }

  String get password => _password;

  String get email => _email;

  int get age => _age;

  String get name => _name;

  void birthday() {
    _age++;
  }

  @override
  String toString() {
    return 'Owner{_name: $_name, _age: $_age, _email: $_email, _password: $_password, dog: $dogs}';
  }
}
