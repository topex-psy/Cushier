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

class CompanyApi {
  final int id;
  final int idJenisUsaha;
  final int  idBadanUsaha;
  final int idPemilik;
  final String judul;
  final String deskripsi;
  final String logo;
  final String npwp;

  CompanyApi({
    this.id,
    this.idJenisUsaha,
    this.idBadanUsaha,
    this.idPemilik,
    this.judul,
    this.deskripsi,
    this.logo,
    this.npwp,
  });

  factory CompanyApi.fromJson(Map<String, dynamic> res) {
    return res == null ? CompanyApi() : CompanyApi(
      id: int.parse(res['ID']),
      idJenisUsaha: int.parse(res['ID_JENIS_USAHA'] ?? '0'),
      idBadanUsaha: int.parse(res['ID_BADAN_USAHA'] ?? '0'),
      idPemilik: int.parse(res['ID_PEMILIK']),
      judul: res['JUDUL'],
      deskripsi: res['DESKRIPSI'],
      logo: res['LOGO'],
      npwp: res['NPWP'],
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