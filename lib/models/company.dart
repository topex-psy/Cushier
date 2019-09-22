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