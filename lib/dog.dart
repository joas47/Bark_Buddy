import 'package:cross_platform_test/Owner.dart';

class Dog {
  final String _name;
  int _age;
  final String _breed;
  final Owner _owner;

  Dog(this._name, this._age, this._breed, this._owner);
// test Fredrik
  String get breed => _breed;

  int get age => _age;
//Test Cassandra
  String get name => _name;

  Owner get owner => _owner;

  void birthday() {
    _age++;
  }

  @override
  String toString() {
    return 'Dog{_name: $_name, _age: $_age, _breed: $_breed, _owner: $owner}';
  }
}
