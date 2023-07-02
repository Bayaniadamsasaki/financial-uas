import 'package:finalcial_records/models/catatan.dart';
import 'package:finalcial_records/shared/separator.dart';
import 'package:finalcial_records/shared/shared_methods.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/history_transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Future<List<Catatan>> readCatatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String catatanString = prefs.getString('catatan_key') ?? '';
    if (catatanString.isNotEmpty) {
      return Catatan.decode(catatanString);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          buildProfile(context),
          buildWallet(context),
          buildHistory(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        backgroundColor: birulangit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildProfile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 40,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang!',
                style: greyTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              FutureBuilder(
                future: SharedPrefUtils.readNama(),
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data}',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: semiBold,
                    ),
                  );
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: FutureBuilder(
              future: SharedPrefUtils.readNameImage(),
              builder: (context, snapshot) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: snapshot.data == null
                          ? const AssetImage('assets/image-1.png')
                          : AssetImage('assets/${snapshot.data}.png'),
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
      height: 200,
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/card.png'),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo',
              style: whiteTextStyle,
            ),
            FutureBuilder(
              future: SharedPrefUtils.readSaldo(),
              builder: (context, snapshot) {
                return Text(
                  '${formatCurrency(snapshot.data)}',
                  style: whiteTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: semiBold,
                  ),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Separator(
              color: Colors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemasukan',
                      style: whiteTextStyle,
                    ),
                    FutureBuilder(
                      future: SharedPrefUtils.readPemasukan(),
                      builder: (context, snapshot) {
                        return Text(
                          '${formatCurrency(snapshot.data)}',
                          style: whiteTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        );
                      },
                    )
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran',
                      style: whiteTextStyle,
                    ),
                    FutureBuilder(
                      future: SharedPrefUtils.readPengeluaran(),
                      builder: (context, snapshot) {
                        return Text(
                          formatCurrency(snapshot.data),
                          style: whiteTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistory(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histori Transaksi',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(22),
            margin: const EdgeInsets.only(
              top: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: FutureBuilder(
              future: readCatatan(),
              builder: (context, snapshot) {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) => HistoryTransactionItem(
                    iconUrl: snapshot.data!
                                .elementAt(index)
                                .tipeTransaksi
                                .toString() ==
                            'pemasukan'
                        ? 'assets/transaksi_pemasukan.png'
                        : 'assets/transaksi_pengeluaran.png',
                    title: snapshot.data!.elementAt(index).kategori.toString(),
                    date: snapshot.data!.elementAt(index).tanggal.toString(),
                    value: snapshot.data!
                                .elementAt(index)
                                .tipeTransaksi
                                .toString() ==
                            'pemasukan'
                        ? '+ ${formatCurrency(snapshot.data!.elementAt(index).jumlah, symbol: '')}'
                        : '- ${formatCurrency(snapshot.data!.elementAt(index).jumlah, symbol: '')}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
