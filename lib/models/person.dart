import 'package:hive/hive.dart';
part 'person.g.dart';

@HiveType(typeId: 0)
class Person {
  @HiveField(0)
  String? email;
  @HiveField(1)
  String? firstName;
  @HiveField(2)
  String? lastName;
  @HiveField(3)
  double? purse;
  @HiveField(4)
  String? username;
  @HiveField(5)
  List<dynamic>? contestsCreated;
  @HiveField(6)
  List<dynamic>? contestsJoined;

  Person(
      {this.email,
      this.firstName,
      this.lastName,
      this.username,
      this.purse,
      this.contestsCreated,
      this.contestsJoined});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> person = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'purse': this.purse,
      'username': this.username,
      'contestsCreated': this.contestsCreated,
      'contestsJoined': this.contestsJoined,
    };
    return person;
  }

  static Person fromMap(Map<String, dynamic> map) {
    Person p = Person();
    p.email = map['email'];
    p.firstName = map['firstName'];
    p.lastName = map['lastName'];
    p.purse = map['purse'] + 0.0;
    p.username = map['username'];
    p.contestsCreated = map['contestsCreated'];
    p.contestsJoined = map['contestsJoined'];
    return p;
  }
}
