import 'package:flutter/material.dart';

const String APP_NAME = "Cushier";
const String APP_TAGLINE = "Mesin Kasir di Smartphone Anda";
//TODO pake url web kalo udah dihosting
//const String APP_HOST = "http://192.168.1.12/cushier/public/";
const String APP_HOST = "http://192.168.42.242/cushier/public/";
//const String APP_HOST = "http://10.0.2.2/cushier/public/";
const String APP_AUTHOR = "Taufik Nur Rahmanda";

const String TOUR_TITLE1 = "Anda Seorang Pemilik Usaha?";
const String TOUR_TITLE2 = "Anda Adalah Karyawan?";
const String TOUR_DESC1 = "Klik tombol 'Daftar Baru' untuk mulai mengelola usaha, produk, promo, outlet, persediaan produk, serta karyawan Anda.";
const String TOUR_DESC2 = "Silakan login atau scan kode digital yang terdapat pada kartu karyawan, lalu masukkan nomor pin Anda.";

const String THEME_LIGHT = "tema_cerah";
const String THEME_DARK = "tema_gelap";
const Color THEME_COLOR = Colors.pink;

const double CARD_PADDING = 13.0;
const double CARD_ELEVATION = 12.0;
const double CARD_RADIUS = 15.0;

const double SPLASH_ICON_SIZE = 180.0;

const bool DEBUG_ONBOARDING = false;
const bool DEBUG_PERSON = true;
const DEBUG_PERSON_DATA = {
  'UID': "o03egapIUAYsLojGSufw2hht2n72",
  'ID_LEVEL': '1',
  'ID_USAHA': '1',
  'ID_OUTLET': null,
  'LEVEL': "Pemilik Usaha",
  'NAMA_LENGKAP': "Taufik Nur Rahmanda",
  'TANGGAL_LAHIR': "1993-07-26",
  'UMUR': '25',
  'JENIS_KELAMIN': "L",
  'JENIS_KELAMIN_LENGKAP': "Laki-Laki",
  'AVAILABILITY_CLASS': "SUCCESS",
  'AVAILABILITY_LABEL': "Available",
  'EMAIL': "admintest@cushier.io",
  'NO_HP': "085954479380",
  'FOTO': null,
  'LAST_LOGOUT': "2019-09-28 00:00:00",
};

enum ItemStatus {
  GOOD,
  WARNING,
  DANGER,
}
