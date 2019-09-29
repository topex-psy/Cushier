import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../utils/constants.dart';

final Map<int, PersonLevelInfo> listPersonLevel = {
  1: PersonLevelInfo(
    level: PersonLevel.USER_ADMIN,
    judul: "Pemilik Usaha",
    deskripsi: "Kelola usaha, outlet, produk, promo, voucher, karyawan, konsumen, dan laporan",
    icon: MdiIcons.accountTie,
    warna: Colors.purple,
  ),
  2: PersonLevelInfo(
    level: PersonLevel.USER_OPERATOR,
    judul: "Karyawan (Operator)",
    deskripsi: "Kelola gudang, kasir, laporan, dan cetak label harga pada outlet",
    icon: MdiIcons.faceAgent,
    warna: Colors.blue,
  ),
  3: PersonLevelInfo(
    level: PersonLevel.USER_KASIR,
    judul: "Karyawan (Kasir)",
    deskripsi: "Catat konsumen dan transaksi penjualan pada outlet",
    icon: MdiIcons.accountBadge,
    warna: Colors.green,
  ),
  4: PersonLevelInfo(
    level: PersonLevel.USER_LAIN,
    judul: "Lainnya",
    deskripsi: "Kurir, dan sebagainya",
    icon: MdiIcons.accountSupervisor,
    warna: Colors.orange,
  ),
};

class PersonLevelInfo {
  PersonLevel level;
  String judul;
  String deskripsi;
  IconData icon;
  Color warna;

  PersonLevelInfo({
    this.level,
    this.judul,
    this.deskripsi,
    this.icon,
    this.warna,
  });
}

enum PersonLevel {
  USER_ADMIN,
  USER_OPERATOR,
  USER_KASIR,
  USER_LAIN,
}

class PersonApi {
  final String uid;
  final int idLevel;
  final int idUsaha;
  final int idOutlet;
  final String level;
  final String namaLengkap;
  final String tanggalLahir;
  final int umur;
  final String gender;
  final String jenisKelamin;
  final String availabilityColor;
  final String availabilityLabel;
  final String email;
  final String noHP;
  final String foto;
  final String terakhir;

  PersonApi({
    @required this.uid,
    @required this.idLevel,
    this.idUsaha,
    this.idOutlet,
    this.level,
    this.namaLengkap,
    this.tanggalLahir,
    this.umur,
    this.gender,
    this.jenisKelamin,
    this.availabilityColor,
    this.availabilityLabel,
    this.email,
    this.noHP,
    this.foto,
    this.terakhir,
  });

  factory PersonApi.fromJson(Map<String, dynamic> res) {
    return res == null ? PersonApi(uid: null, idLevel: null) : PersonApi(
      uid: res['UID'],
      idLevel: int.parse(res['ID_LEVEL']),
      idUsaha: int.parse(res['ID_USAHA'] ?? '0'),
      idOutlet: int.parse(res['ID_OUTLET'] ?? '0'),
      level: res['LEVEL'],
      namaLengkap: res['NAMA_LENGKAP'],
      tanggalLahir: res['TANGGAL_LAHIR'],
      umur: int.parse(res['UMUR']),
      gender: res['JENIS_KELAMIN'],
      jenisKelamin: res['JENIS_KELAMIN_LENGKAP'],
      availabilityColor: res['AVAILABILITY_CLASS'],
      availabilityLabel: res['AVAILABILITY_LABEL'],
      email: res['EMAIL'],
      noHP: res['NO_HP'],
      foto: res['FOTO'],
      terakhir: res['LAST_LOGOUT'] ?? res['LAST_LOGIN'],
    );
  }
}

class PostRegister {
  PostRegister({
    @required this.namaLengkap,
    @required this.gender,
    @required this.tanggalLahir,
    @required this.noHP,
    @required this.namaUsaha,
    @required this.idKategoriUsaha,
    @required this.email,
    @required this.pin,
    this.uid,
  });

  final String namaLengkap;
  final String gender;
  final String tanggalLahir;
  final String noHP;
  final String namaUsaha;
  final int idKategoriUsaha;
  final String email;
  final String pin;
  String uid;

  Map toMap() {
    var map = Map<String, String>();
    map["namaLengkap"] = namaLengkap;
    map["gender"] = gender;
    map["tanggalLahir"] = tanggalLahir;
    map["noHP"] = noHP;
    map["namaUsaha"] = namaUsaha;
    map["idKategoriUsaha"] = idKategoriUsaha.toString();
    map["email"] = email;
    map["pin"] = pin;
    map["uid"] = uid;
    return map;
  }
}

class StatusApi {
  StatusApi({@required this.status, this.message, this.result});
  final int status;
  final String message;
  final dynamic result;

  factory StatusApi.fromJson(Map<String, dynamic> res) {
    return res == null ? StatusApi(status: 0) : StatusApi(
      status: res['status'],
      message: res['message'],
      result: res['result'],
    );
  }
}

Future<dynamic> getListPersons({String uids = ""}) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/person?uids=$uids"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<PersonApi> getPerson(String uid) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/person?uid=$uid"),
      headers: {"Accept": "application/json"}
    );
    final responseJson = json.decode(response.body)['result'];
    return PersonApi.fromJson(responseJson);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<StatusApi> register(Map body) async {
  try {
    final http.Response response = await http.post(Uri.encodeFull(APP_HOST + "api/post/register"), body: body);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw Exception("register STATUS CODE = $statusCode");
    }
    final responseJson = json.decode(response.body);
    return StatusApi.fromJson(responseJson);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<StatusApi> login(Map body) async {
  try {
    final http.Response response = await http.post(Uri.encodeFull(APP_HOST + "api/post/login"), body: body);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw Exception("login STATUS CODE = $statusCode");
    }
    final responseJson = json.decode(response.body);
    return StatusApi.fromJson(responseJson);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<StatusApi> logout(Map body) async {
  try {
    final http.Response response = await http.post(Uri.encodeFull(APP_HOST + "api/post/logout"), body: body);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw Exception("logout STATUS CODE = $statusCode");
    }
    final responseJson = json.decode(response.body);
    return StatusApi.fromJson(responseJson);
  } catch (e) {
    print(e);
    return null;
  }
}