class Kullanici {
  late String id;
  String? email;
  String? password;
  String? name;
  String? lastName;
  String? role;
  String? token;
  String? refreshToken;
  bool? isPartner;
  bool? status;
  String? isActiveUser;

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
