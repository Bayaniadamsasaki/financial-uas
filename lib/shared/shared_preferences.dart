import 'package:finalcial_records/models/scheduled_bill.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtils {
  static const String _scheduledBillsKey = 'scheduled_bills_key';

  static Future<void> saveNama(String nama) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('nama', nama);
  }

  static Future<String> readNama() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('nama') ?? '';
  }

  static Future<void> saveEmail(String email) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('email', email);
  }

  static Future<String> readEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('email') ?? '';
  }

  static Future<void> savePassword(String pass) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('password', pass);
  }

  static Future<String> readPassword() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('password') ?? '';
  }

  static Future<void> saveTanggalGabung(String tanggalGabung) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('tanggalGabung', tanggalGabung);
  }

  static Future<String> readTanggalGabung() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('tanggalGabung') ?? '';
  }

  static Future<void> saveNameImage(String nameImage) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('nameImage', nameImage);
  }

  static Future<String> readNameImage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('nameImage') ?? '';
  }

  static Future<void> saveSaldo(int saldo) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt('saldo', saldo);
  }

  static Future<int> readSaldo() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt('saldo') ?? 0;
  }

  static Future<void> savePemasukan(int pemasukan) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt('pemasukan', pemasukan);
  }

  static Future<int> readPemasukan() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt('pemasukan') ?? 0;
  }

  static Future<void> savePengeluaran(int pengeluaran) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt('pengeluaran', pengeluaran);
  }

  static Future<int> readPengeluaran() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt('pengeluaran') ?? 0;
  }

  static Future<void> saveScheduledBills(List<ScheduledBill> bills) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    if (bills.isEmpty) {
      await pref.remove(_scheduledBillsKey);
      return;
    }

    await pref.setString(_scheduledBillsKey, ScheduledBill.encode(bills));
  }

  static Future<List<ScheduledBill>> readScheduledBills() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String encoded = pref.getString(_scheduledBillsKey) ?? '';

    if (encoded.isEmpty) {
      return [];
    }

    try {
      return ScheduledBill.decode(encoded);
    } catch (_) {
      await pref.remove(_scheduledBillsKey);
      return [];
    }
  }

  static Future<void> upsertScheduledBill(ScheduledBill bill) async {
    final List<ScheduledBill> existingBills = await readScheduledBills();
    final int existingIndex = existingBills.indexWhere(
      (item) => item.type.toLowerCase() == bill.type.toLowerCase(),
    );

    if (existingIndex < 0) {
      existingBills.add(bill);
    } else {
      existingBills[existingIndex] = bill;
    }

    await saveScheduledBills(existingBills);
  }

  static Future<void> updateScheduledBillReminder(
    String billType,
    bool reminderEnabled,
  ) async {
    final List<ScheduledBill> existingBills = await readScheduledBills();
    final int existingIndex = existingBills.indexWhere(
      (item) => item.type.toLowerCase() == billType.toLowerCase(),
    );

    if (existingIndex < 0) {
      return;
    }

    existingBills[existingIndex] = existingBills[existingIndex].copyWith(
      reminderEnabled: reminderEnabled,
    );
    await saveScheduledBills(existingBills);
  }
}
