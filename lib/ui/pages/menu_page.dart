import 'package:finalcial_records/models/catatan.dart';
import 'package:finalcial_records/shared/shared_methods.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/snackbar.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/history_transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _HistoryFilter {
  all,
  income,
  expense,
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  _HistoryFilter _selectedHistoryFilter = _HistoryFilter.all;

  Future<List<Catatan>> readCatatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String catatanString = prefs.getString('catatan_key') ?? '';
    if (catatanString.isNotEmpty) {
      try {
        return Catatan.decode(catatanString);
      } catch (_) {
        await prefs.remove('catatan_key');
      }
    }
    return [];
  }

  int _subtractFloorZero(int source, int delta) {
    final int result = source - delta;
    return result < 0 ? 0 : result;
  }

  Future<void> _openAddPage() async {
    await Navigator.pushNamed(context, '/add');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onDeletePressed(Catatan item) async {
    final bool confirm = await CustomSnackBar.showConfirmDialog(
      context: context,
      title: 'Hapus Catatan?',
      message:
          'Catatan ini akan dihapus permanen dan ringkasan saldo akan diperbarui.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      icon: Icons.delete_forever_outlined,
      accentColor: readColor,
    );

    if (!confirm) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String existing = prefs.getString('catatan_key') ?? '';

    if (existing.isEmpty) {
      return;
    }

    List<Catatan> items;
    try {
      items = Catatan.decode(existing);
    } catch (_) {
      await prefs.remove('catatan_key');
      if (!mounted) {
        return;
      }
      setState(() {});
      CustomSnackBar.showToast(
        context,
        'Data catatan rusak dan berhasil dibersihkan.',
        type: ToastType.warning,
      );
      return;
    }

    final int beforeLength = items.length;
    items.removeWhere((catatan) {
      if ((item.id ?? '').isNotEmpty) {
        return catatan.id == item.id;
      }

      return catatan.tanggal == item.tanggal &&
          catatan.kategori == item.kategori &&
          catatan.tipeTransaksi == item.tipeTransaksi &&
          catatan.jumlah == item.jumlah &&
          catatan.catatan == item.catatan;
    });

    if (items.length == beforeLength) {
      if (!mounted) {
        return;
      }
      CustomSnackBar.showToast(
        context,
        'Catatan tidak ditemukan.',
        type: ToastType.warning,
      );
      return;
    }

    if (items.isEmpty) {
      await prefs.remove('catatan_key');
    } else {
      await prefs.setString('catatan_key', Catatan.encode(items));
    }

    final int jumlah = item.jumlah ?? 0;
    final String tipe = (item.tipeTransaksi ?? '').toLowerCase();
    final int saldo = await SharedPrefUtils.readSaldo();

    if (jumlah > 0) {
      if (tipe.contains('pemasukan')) {
        final int pemasukan = await SharedPrefUtils.readPemasukan();
        await SharedPrefUtils.saveSaldo(_subtractFloorZero(saldo, jumlah));
        await SharedPrefUtils.savePemasukan(
          _subtractFloorZero(pemasukan, jumlah),
        );
      } else {
        final int pengeluaran = await SharedPrefUtils.readPengeluaran();
        await SharedPrefUtils.saveSaldo(saldo + jumlah);
        await SharedPrefUtils.savePengeluaran(
          _subtractFloorZero(pengeluaran, jumlah),
        );
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {});
    CustomSnackBar.showToast(
      context,
      'Catatan berhasil dihapus.',
      type: ToastType.success,
    );
  }

  String _greetingMessage() {
    final int hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat pagi';
    }
    if (hour < 15) {
      return 'Selamat siang';
    }
    if (hour < 19) {
      return 'Selamat sore';
    }
    return 'Selamat malam';
  }

  bool _isIncomeTransaction(Catatan item) {
    final String type = (item.tipeTransaksi ?? '').toLowerCase();
    return type.contains('pemasukan');
  }

  List<Catatan> _applyHistoryFilter(List<Catatan> items) {
    switch (_selectedHistoryFilter) {
      case _HistoryFilter.all:
        return items;
      case _HistoryFilter.income:
        return items.where(_isIncomeTransaction).toList();
      case _HistoryFilter.expense:
        return items.where((item) => !_isIncomeTransaction(item)).toList();
    }
  }

  String _activeFilterLabel() {
    switch (_selectedHistoryFilter) {
      case _HistoryFilter.all:
        return 'Semua';
      case _HistoryFilter.income:
        return 'Pemasukan';
      case _HistoryFilter.expense:
        return 'Pengeluaran';
    }
  }

  Widget _buildHistoryFilterChip({
    required _HistoryFilter filter,
    required String label,
  }) {
    final bool isSelected = _selectedHistoryFilter == filter;

    return ChoiceChip(
      label: Text(
        label,
        style: (isSelected ? whiteTextStyle : blueTextStyle).copyWith(
          fontSize: 12,
          fontWeight: semiBold,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: birulangit,
      backgroundColor: blueLightColor,
      side: BorderSide(
        color: isSelected ? birulangit : blueColor.withOpacity(0.2),
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      onSelected: (_) {
        setState(() {
          _selectedHistoryFilter = filter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 120),
              children: [
                buildProfile(context),
                buildWallet(context),
                buildHistory(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: birulangit.withOpacity(0.36),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openAddPage,
          tooltip: 'Tambah Catatan Baru',
          backgroundColor: birulangit,
          icon: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: whiteColor.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_rounded,
              color: whiteColor,
              size: 18,
            ),
          ),
          label: Text(
            'Tambah Catatan',
            style: whiteTextStyle.copyWith(
              fontWeight: semiBold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget buildProfile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingMessage(),
                  style: greyTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(height: 2),
                FutureBuilder(
                  future: SharedPrefUtils.readNama(),
                  builder: (context, snapshot) {
                    final String displayName =
                        (snapshot.data ?? '').toString().trim();
                    return Text(
                      displayName.isEmpty ? 'Pengguna' : displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: blackTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: extraBold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: FutureBuilder(
              future: SharedPrefUtils.readNameImage(),
              builder: (context, snapshot) {
                final String avatarName =
                    (snapshot.data ?? '').toString().trim();
                return Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: birulangit.withOpacity(0.25),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: avatarName.isEmpty
                            ? const AssetImage('assets/image-1.png')
                            : AssetImage('assets/$avatarName.png'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWallet(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: blueLightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: birulangit,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Saldo',
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: medium,
                    ),
                  ),
                  Text(
                    'Ringkasan Keuanganmu',
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<int>(
            future: SharedPrefUtils.readSaldo(),
            builder: (context, snapshot) {
              return Text(
                formatCurrency(snapshot.data ?? 0),
                style: blackTextStyle.copyWith(
                  fontSize: 30,
                  fontWeight: extraBold,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAmountTile(
                  title: 'Pemasukan',
                  futureAmount: SharedPrefUtils.readPemasukan(),
                  icon: Icons.trending_up_rounded,
                  accent: greenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountTile(
                  title: 'Pengeluaran',
                  futureAmount: SharedPrefUtils.readPengeluaran(),
                  icon: Icons.trending_down_rounded,
                  accent: readColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountTile({
    required String title,
    required Future<int> futureAmount,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: blueLightColor.withOpacity(0.45),
      ),
      child: FutureBuilder<int>(
        future: futureAmount,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: accent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: greyBlackTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatCurrency(snapshot.data ?? 0),
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildHistory(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Histori Transaksi',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: blueLightColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Filter: ${_activeFilterLabel()}',
                  style: blueTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHistoryFilterChip(
                  filter: _HistoryFilter.all,
                  label: 'Semua',
                ),
                const SizedBox(width: 8),
                _buildHistoryFilterChip(
                  filter: _HistoryFilter.income,
                  label: 'Pemasukan',
                ),
                const SizedBox(width: 8),
                _buildHistoryFilterChip(
                  filter: _HistoryFilter.expense,
                  label: 'Pengeluaran',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FutureBuilder<List<Catatan>>(
              future: readCatatan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: birulangit,
                      ),
                    ),
                  );
                }

                final List<Catatan> items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: blueLightColor.withOpacity(0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: birulangit,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Belum ada transaksi. Yuk tambah catatan pertamamu.',
                            style: greyBlackTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final List<Catatan> filteredItems = _applyHistoryFilter(items);
                if (filteredItems.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: blueLightColor.withOpacity(0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_off_outlined,
                          color: birulangit,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tidak ada transaksi untuk filter ${_activeFilterLabel().toLowerCase()}.',
                            style: greyBlackTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                  itemBuilder: (context, index) {
                    final Catatan item = filteredItems[index];
                    final bool isPemasukan = _isIncomeTransaction(item);

                    return HistoryTransactionItem(
                      iconUrl: isPemasukan
                          ? 'assets/transaksi_pemasukan.png'
                          : 'assets/transaksi_pengeluaran.png',
                      title: item.kategori.toString(),
                      date: item.tanggal.toString(),
                      note: item.catatan ?? '',
                      value: isPemasukan
                          ? '+ ${formatCurrency(item.jumlah, symbol: '')}'
                          : '- ${formatCurrency(item.jumlah, symbol: '')}',
                      onDelete: () {
                        _onDeletePressed(item);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

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
            whiteColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    birulangit.withOpacity(0.18),
                    birulangit.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    blueColor.withOpacity(0.12),
                    blueColor.withOpacity(0.01),
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
