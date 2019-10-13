import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CompanyField {
  CompanyField({this.id, this.kategori});
  final int id;
  final String kategori;

  factory CompanyField.fromJson(Map<String, dynamic> res) {
    return res == null ? CompanyField() : CompanyField(
      id: int.parse(res['ID']),
      kategori: res['KATEGORI'],
    );
  }
}

class OutletApi {
  final int id;
  final String nama;
  final String alamat;
  final String telp;
  final int jumlahPOS;

  OutletApi({
    this.id,
    this.nama,
    this.alamat,
    this.telp,
    this.jumlahPOS,
  });

  factory OutletApi.fromJson(Map<String, dynamic> res) {
    return res == null ? OutletApi() : OutletApi(
      id: int.parse(res['ID']),
      nama: res['NAMA'],
      alamat: res['ALAMAT'],
      telp: res['TELEPON'],
      jumlahPOS: int.parse(res['JUMLAH_POS']),
    );
  }
}

class OutletPOSApi {
  final int id;
  final int idOutlet;
  final String nama;

  OutletPOSApi({
    this.id,
    this.idOutlet,
    this.nama,
  });

  factory OutletPOSApi.fromJson(Map<String, dynamic> res) {
    return res == null ? OutletPOSApi() : OutletPOSApi(
      id: int.parse(res['ID']),
      idOutlet: int.parse(res['ID_OUTLET']),
      nama: res['NAMA'],
    );
  }
}

class CompanyApi {
  final int id;
  final int idJenisUsaha;
  final int  idBadanUsaha;
  final int idPemilik;
  final String nama;
  final String deskripsi;
  final String logo;
  final String npwp;
  final String website;
  final String email;
  final String cs;

  CompanyApi({
    this.id,
    this.idJenisUsaha,
    this.idBadanUsaha,
    this.idPemilik,
    this.nama,
    this.deskripsi,
    this.logo,
    this.npwp,
    this.website,
    this.email,
    this.cs,
  });

  factory CompanyApi.fromJson(Map<String, dynamic> res) {
    return res == null ? CompanyApi() : CompanyApi(
      id: int.parse(res['ID']),
      idJenisUsaha: int.parse(res['ID_JENIS_USAHA'] ?? '0'),
      idBadanUsaha: int.parse(res['ID_BADAN_USAHA'] ?? '0'),
      idPemilik: int.parse(res['ID_PEMILIK']),
      nama: res['NAMA'],
      deskripsi: res['DESKRIPSI'],
      logo: res['LOGO'],
      npwp: res['NPWP'],
      website: res['WEBSITE'],
      email: res['EMAIL'],
      cs: res['LAYANAN_KONSUMEN'],
    );
  }
}

Future<CompanyApi> getCompany(int id) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/company?id=$id"),
      headers: {"Accept": "application/json"}
    );
    print(json.decode(response.body));
    final responseJson = json.decode(response.body)['result'];
    return CompanyApi.fromJson(responseJson);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> getListCompany({String uid}) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/company?uid=$uid"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> getListCompanyField() async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/company_field"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> getListOutlet({int idCompany}) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/outlet?cid=$idCompany"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<dynamic> getListOutletPOS({int idOutlet}) async {
  try {
    final http.Response response = await http.get(
      Uri.encodeFull(APP_HOST + "api/get/outlet_pos?oid=$idOutlet"),
      headers: {"Accept": "application/json"}
    );
    return json.decode(response.body);
  } catch (e) {
    print(e);
    return null;
  }
}