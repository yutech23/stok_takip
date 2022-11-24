class Kullanici {
  late String id;
  late String? email;
  late String? password;
  late String? name;
  late String? lastName;
  late String? role;
  late String? token;
  late String? refreshToken;

  Kullanici();

  Kullanici.withId(
      {required this.id,
      this.name,
      this.lastName,
      this.email,
      this.password,
      this.role});

  Kullanici.nameSurnameRole({this.name, this.lastName, this.role});
}
