import 'package:finalcial_records/models/catatan.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/snackbar.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/buttons.dart';
import 'package:finalcial_records/ui/widgets/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddFinancialPage extends StatefulWidget {
  const AddFinancialPage({super.key});

  @override
  State<AddFinancialPage> createState() => _AddFinancialPageState();
}

enum TipeTransaksi { pengeluaran, pemasukan }

class _AddFinancialPageState extends State<AddFinancialPage> {
  final TextEditingController tanggalControl = TextEditingController();
  final TextEditingController jumlahControl = TextEditingController();
  final TextEditingController catatanControl = TextEditingController();
  bool isLoading = false;
  String successMessage = '';

  List<Catatan> catatatItems = [];
  final formKey = GlobalKey<FormState>();
  TipeTransaksi? group = TipeTransaksi.pemasukan;

  String kategori = '';

  void save(BuildContext context, String tanggal, String kategori,
      String tipeTransaki, int jumlah, String catatan) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = const Uuid().v1();

    catatatItems.add(Catatan(
      id: id,
      tanggal: tanggal,
      tipeTransaksi: tipeTransaki,
      kategori: kategori,
      jumlah: jumlah,
      catatan: catatan,
    ));

    final String encodeData = Catatan.encode(catatatItems);
    await prefs.setString('catatan_key', encodeData);

    if (tipeTransaki.contains('pengeluaran')) {
      int saldo = await SharedPrefUtils.readSaldo() - jumlah;
      SharedPrefUtils.saveSaldo(saldo);

      int pengeluaran = await SharedPrefUtils.readPengeluaran() + jumlah;
      SharedPrefUtils.savePengeluaran(pengeluaran);
    } else {
      int saldo = await SharedPrefUtils.readSaldo() + jumlah;
      SharedPrefUtils.saveSaldo(saldo);

      int pemasukan = await SharedPrefUtils.readPemasukan() + jumlah;
      SharedPrefUtils.savePemasukan(pemasukan);
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        successMessage = 'Pesanan berhasil!';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/menu');
          },
          icon: Icon(
            Icons.arrow_back,
            color: blackColor,
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? SpinKitCubeGrid(
                size: 140,
                color: purpleLight2Color,
              )
            : successMessage.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        successMessage,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Form(
                    key: formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: whiteColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomFormField(
                                title: 'Tanggal',
                                controller: tanggalControl,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickerDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );

                                  if (pickerDate != null) {
                                    String formatDate =
                                        DateFormat('dd MMMM yyyy')
                                            .format(pickerDate);

                                    setState(() {
                                      tanggalControl.text = formatDate;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                'TIpe Transaki',
                                style: blackTextStyle.copyWith(
                                  fontWeight: medium,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Pengeluaran',
                                  style: blackTextStyle.copyWith(
                                    fontWeight: regular,
                                  ),
                                ),
                                leading: Radio<TipeTransaksi>(
                                  value: TipeTransaksi.pengeluaran,
                                  groupValue: group,
                                  onChanged: (value) {
                                    setState(() {
                                      group = value;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Pemasukan',
                                  style: blackTextStyle.copyWith(
                                    fontWeight: regular,
                                  ),
                                ),
                                leading: Radio<TipeTransaksi>(
                                  value: TipeTransaksi.pemasukan,
                                  groupValue: group,
                                  onChanged: (value) {
                                    setState(() {
                                      group = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                'Kategori',
                                style: blackTextStyle.copyWith(
                                  fontWeight: medium,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                  hint: kategori == ''
                                      ? Text(
                                          'Pilih Kategori',
                                          style: blackTextStyle.copyWith(
                                            fontWeight: medium,
                                          ),
                                        )
                                      : Text(
                                          kategori,
                                          style: blackTextStyle.copyWith(
                                            fontWeight: medium,
                                          ),
                                        ),
                                  isDense: true,
                                  isExpanded: true,
                                  items: [
                                    'Gajian',
                                    'Bonus',
                                    'Hiburan',
                                    'Tagihan',
                                    'Lain-Lain',
                                  ].map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: blackTextStyle.copyWith(
                                            fontWeight: medium),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      kategori = value.toString();
                                    });
                                  },
                                )),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              CustomFormField(
                                title: 'Jumlah',
                                controller: jumlahControl,
                                inputType: TextInputType.number,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              CustomFormField(
                                title: 'Catatan',
                                controller: catatanControl,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              CustomFillButton(
                                title: 'Simpan',
                                onPressed: () {
                                  if (kategori.isEmpty &&
                                      tanggalControl.text.isEmpty &&
                                      jumlahControl.text.isEmpty &&
                                      catatanControl.text.isEmpty) {
                                    CustomSnackBar.showToast(
                                        context, 'Inputan masih kosong!');
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Info'),
                                          content:
                                              const Text('Yakin ingin simpan!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                save(
                                                    context,
                                                    tanggalControl.text,
                                                    kategori,
                                                    group
                                                        .toString()
                                                        .split('.')
                                                        .last,
                                                    int.parse(
                                                        jumlahControl.text),
                                                    catatanControl.text);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Ya'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
