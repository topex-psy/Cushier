import 'package:flutter/material.dart';

const String APP_NAME = "Cushier";
const String APP_TAGLINE = "Mesin Kasir di Smartphone Anda";
const String APP_HOST = "http://192.168.1.65/cushier/public/"; //TODO pake url web kalo udah dihosting

const String TOUR_TITLE1 = "Anda Seorang Pemilik Usaha?";
const String TOUR_TITLE2 = "Anda Adalah Karyawan?";
const String TOUR_DESC1 = "Klik tombol 'Daftar Baru' untuk mulai mengelola produk, promo, outlet, persediaan produk, serta karyawan Anda.";
const String TOUR_DESC2 = "Silakan login atau scan kode digital yang terdapat pada kartu karyawan, lalu masukkan nomor pin Anda.";

class MenuBar {
  MenuBar({this.icon, @required this.teks, this.value, this.isNonGuest = false});
  final IconData icon;
  final String teks;
  final String value;
  final bool isNonGuest;
}