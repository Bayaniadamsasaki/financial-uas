import 'dart:convert';

class Catatan {
  final String? id, tanggal, tipeTransaksi, kategori, catatan;
  final int? jumlah;

  Catatan({
    this.id,
    this.tanggal,
    this.tipeTransaksi,
    this.kategori,
    this.jumlah,
    this.catatan,
  });

  factory Catatan.fromJson(Map<String, dynamic> jsonData) {
    return Catatan(
      id: jsonData['id'],
      tanggal: jsonData['tanggal'],
      tipeTransaksi: jsonData['tipeTransaksi'],
      kategori: jsonData['kategori'],
      jumlah: jsonData['jumlah'],
      catatan: jsonData['catatan'],
    );
  }

  static Map<String, dynamic> toMap(Catatan cat) => {
        'id': cat.id,
        'tanggal': cat.tanggal,
        'tipeTransaksi': cat.tipeTransaksi,
        'kategori': cat.kategori,
        'jumlah': cat.jumlah,
        'catatan': cat.catatan,
      };
  static String encode(List<Catatan> cats) => json.encode(
      cats.map<Map<String, dynamic>>((cat) => Catatan.toMap(cat)).toList());
      
  static List<Catatan> decode(String cats) =>
      (json.decode(cats) as List<dynamic>)
          .map((item) => Catatan.fromJson(item))
          .toList();
}
