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

  @override
  void dispose() {
    tanggalControl.dispose();
    jumlahControl.dispose();
    catatanControl.dispose();
    super.dispose();
  }

  void save(
    BuildContext context,
    String tanggal,
    String kategori,
    String tipeTransaki,
    int jumlah,
    String catatan,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String existingData = prefs.getString('catatan_key') ?? '';
    if (existingData.isNotEmpty) {
      try {
        catatatItems = Catatan.decode(existingData);
      } catch (_) {
        catatatItems = [];
        await prefs.remove('catatan_key');
      }
    }

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
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        successMessage = 'Catatan berhasil disimpan!';
      });

      CustomSnackBar.showToast(
        this.context,
        'Transaksi berhasil disimpan.',
        type: ToastType.success,
      );
    });
  }

  Future<void> _selectDate() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickerDate != null) {
      String formatDate = DateFormat('dd MMMM yyyy').format(pickerDate);

      setState(() {
        tanggalControl.text = formatDate;
      });
    }
  }

  void _onSubmitPressed() {
    final String tanggal = tanggalControl.text.trim();
    final String jumlahText = jumlahControl.text.trim();
    final String note = catatanControl.text.trim();

    if (kategori.isEmpty ||
        tanggal.isEmpty ||
        jumlahText.isEmpty ||
        note.isEmpty) {
      CustomSnackBar.showToast(
        context,
        'Lengkapi semua input terlebih dahulu!',
        type: ToastType.warning,
      );
      return;
    }

    final int? jumlah = int.tryParse(jumlahText);
    if (jumlah == null || jumlah <= 0) {
      CustomSnackBar.showToast(
        context,
        'Jumlah harus berupa angka yang valid!',
        type: ToastType.warning,
      );
      return;
    }

    _showSaveConfirmation(jumlah);
  }

  Future<void> _showSaveConfirmation(int jumlah) async {
    final bool confirm = await CustomSnackBar.showConfirmDialog(
      context: context,
      title: 'Simpan Catatan?',
      message: 'Pastikan data transaksi sudah benar sebelum disimpan.',
      confirmLabel: 'Ya, Simpan',
      cancelLabel: 'Periksa Lagi',
      icon: Icons.task_alt_rounded,
      accentColor: birulangit,
    );

    if (!confirm) {
      return;
    }

    if (!mounted) {
      return;
    }

    save(
      context,
      tanggalControl.text.trim(),
      kategori,
      group?.name ?? TipeTransaksi.pemasukan.name,
      jumlah,
      catatanControl.text.trim(),
    );
  }

  void _resetForm() {
    setState(() {
      successMessage = '';
      tanggalControl.clear();
      jumlahControl.clear();
      catatanControl.clear();
      kategori = '';
      group = TipeTransaksi.pemasukan;
    });
  }

  Widget _buildTransactionTypeOption(
    String label,
    TipeTransaksi type,
    IconData icon,
  ) {
    final bool isSelected = group == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            group = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSelected ? blueLightColor : whiteColor,
            border: Border.all(
              color: isSelected ? birulangit : blueColor.withValues(alpha: 0.25),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? birulangit : greyBlackColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: blackTextStyle.copyWith(
                    fontWeight: isSelected ? semiBold : medium,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: birulangit,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        const _InputFormBackground(),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: birulangit.withValues(alpha: 0.1),
                  ),
                  child: SpinKitPumpingHeart(
                    size: 36,
                    color: birulangit,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Menyimpan Catatan',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tunggu sebentar ya, data transaksi sedang diproses.',
                  textAlign: TextAlign.center,
                  style: greyBlackTextStyle.copyWith(
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    backgroundColor: blueLightColor,
                    valueColor: AlwaysStoppedAnimation<Color>(birulangit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessActionButton({
    required String title,
    required VoidCallback onPressed,
    required bool filled,
    required IconData icon,
  }) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: birulangit,
          elevation: 0,
          foregroundColor: whiteColor,
          textStyle: whiteTextStyle.copyWith(fontWeight: semiBold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(
          color: blueColor.withValues(alpha: 0.45),
        ),
        foregroundColor: greyBlackColor,
        textStyle: blackTextStyle.copyWith(fontWeight: semiBold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Stack(
      children: [
        const _InputFormBackground(),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: greenColor.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: greenColor,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Berhasil Disimpan',
                  style: blackTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: extraBold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  successMessage,
                  style: greyBlackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: medium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildSuccessActionButton(
                        title: 'Tambah Lagi',
                        icon: Icons.add_rounded,
                        filled: false,
                        onPressed: _resetForm,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSuccessActionButton(
                        title: 'Ke Beranda',
                        icon: Icons.home_rounded,
                        filled: true,
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/menu',
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopActionIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: whiteColor.withValues(alpha: 0.2),
        ),
        child: Icon(
          icon,
          color: whiteColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: 16,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: birulangit,
          boxShadow: [
            BoxShadow(
              color: birulangit.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: whiteColor.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.note_add_outlined,
                color: whiteColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input Catatan Baru',
                    style: whiteTextStyle.copyWith(
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lengkapi detail transaksi harian kamu',
                    style: whiteTextStyle.copyWith(
                      fontSize: 12,
                      color: whiteColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            _buildTopActionIcon(
              icon: Icons.clear_rounded,
              onTap: _resetForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Stack(
      children: [
        const _InputFormBackground(),
        _buildTopHeader(),
        Positioned.fill(
          top: 130,
          child: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
                children: [
                  CustomFormField(
                    title: 'Tanggal',
                    hintText: 'Pilih tanggal transaksi',
                    controller: tanggalControl,
                    readOnly: true,
                    onTap: _selectDate,
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tipe Transaksi',
                    style: blackTextStyle.copyWith(
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTransactionTypeOption(
                        'Pengeluaran',
                        TipeTransaksi.pengeluaran,
                        Icons.trending_down_rounded,
                      ),
                      const SizedBox(width: 10),
                      _buildTransactionTypeOption(
                        'Pemasukan',
                        TipeTransaksi.pemasukan,
                        Icons.trending_up_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kategori',
                    style: blackTextStyle.copyWith(
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: blueLightColor.withValues(alpha: 0.35),
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: greyBlackColor.withValues(alpha: 0.75),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: blueColor.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: blueColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text(
                          kategori.isEmpty ? 'Pilih Kategori' : kategori,
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
                                fontWeight: medium,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            kategori = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    title: 'Jumlah',
                    hintText: 'Masukkan nominal',
                    controller: jumlahControl,
                    inputType: TextInputType.number,
                    prefixIcon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    title: 'Catatan',
                    hintText: 'Tulis catatan singkat transaksi',
                    controller: catatanControl,
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  CustomFillButton(
                    title: 'Simpan Catatan',
                    onPressed: _onSubmitPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              return;
            }

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/menu',
              (route) => false,
            );
          },
          icon: Icon(
            Icons.arrow_back,
            color: blackColor,
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? _buildLoadingState()
            : successMessage.isNotEmpty
                ? _buildSuccessState()
                : _buildFormState(),
      ),
    );
  }
}

class _InputFormBackground extends StatelessWidget {
  const _InputFormBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xffE8F6FF),
            lightBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    birulangit.withValues(alpha: 0.16),
                    birulangit.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

