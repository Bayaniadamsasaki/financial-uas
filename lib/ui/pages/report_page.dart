import 'package:finalcial_records/models/catatan.dart';
import 'package:finalcial_records/shared/shared_methods.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _ReportWindow { thisMonth, lastMonth, threeMonths }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<List<Catatan>> _transactionFuture;

  @override
  void initState() {
    super.initState();
    _transactionFuture = _readTransactions();
  }

  Future<List<Catatan>> _readTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String payload = prefs.getString('catatan_key') ?? '';

    if (payload.isEmpty) {
      return [];
    }

    try {
      return Catatan.decode(payload);
    } catch (_) {
      await prefs.remove('catatan_key');
      return [];
    }
  }

  Future<void> _reload() async {
    setState(() {
      _transactionFuture = _readTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _ReportWindow.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Keuangan'),
          actions: [
            IconButton(
              onPressed: _reload,
              tooltip: 'Refresh laporan',
              icon: Icon(
                Icons.refresh_rounded,
                color: blackColor,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: birulangit,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: whiteColor,
                unselectedLabelColor: greyBlackColor,
                labelStyle: whiteTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: semiBold,
                ),
                unselectedLabelStyle: blackTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: medium,
                ),
                tabs: const [
                  Tab(text: 'Bulan Ini'),
                  Tab(text: 'Bulan Lalu'),
                  Tab(text: '3 Bulan'),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Catatan>>(
                future: _transactionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: birulangit,
                      ),
                    );
                  }

                  final List<Catatan> items = snapshot.data ?? [];

                  return TabBarView(
                    children: _ReportWindow.values.map((window) {
                      return _ReportWindowView(
                        window: window,
                        transactions: items,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowInfo {
  const _WindowInfo({
    required this.title,
    required this.start,
    required this.end,
  });

  final String title;
  final DateTime start;
  final DateTime end;
}

class _ReportWindowView extends StatelessWidget {
  const _ReportWindowView({
    required this.window,
    required this.transactions,
  });

  final _ReportWindow window;
  final List<Catatan> transactions;

  _WindowInfo _resolveWindow() {
    final DateTime now = DateTime.now();
    switch (window) {
      case _ReportWindow.thisMonth:
        return _WindowInfo(
          title: 'Siklus laporan bulan ini',
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
        );
      case _ReportWindow.lastMonth:
        final DateTime previous = DateTime(now.year, now.month - 1, 1);
        return _WindowInfo(
          title: 'Siklus laporan bulan lalu',
          start: DateTime(previous.year, previous.month, 1),
          end: DateTime(previous.year, previous.month + 1, 0, 23, 59, 59, 999),
        );
      case _ReportWindow.threeMonths:
        final DateTime start = DateTime(now.year, now.month - 2, 1);
        return _WindowInfo(
          title: 'Siklus laporan 3 bulan',
          start: start,
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
        );
    }
  }

  DateTime? _parseDate(String? rawDate) {
    final String source = (rawDate ?? '').trim();
    if (source.isEmpty) {
      return null;
    }

    final DateTime? direct = DateTime.tryParse(source);
    if (direct != null) {
      return DateTime(direct.year, direct.month, direct.day);
    }

    final List<DateFormat> formats = [
      DateFormat('dd MMMM yyyy', 'id_ID'),
      DateFormat('d MMMM yyyy', 'id_ID'),
      DateFormat('dd MMMM yyyy', 'en_US'),
      DateFormat('d MMMM yyyy', 'en_US'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];

    for (final DateFormat format in formats) {
      try {
        final DateTime parsed = format.parseStrict(source);
        return DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {}
    }

    return null;
  }

  bool _isIncome(Catatan item) {
    final String type = (item.tipeTransaksi ?? '').toLowerCase();
    return type.contains('pemasukan');
  }

  int _sumAmount(List<Catatan> items) {
    return items.fold<int>(0, (total, item) => total + (item.jumlah ?? 0));
  }

  String _periodText(DateTime start, DateTime end) {
    final DateFormat formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  String _compactDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return DateFormat('dd MMM yyyy', 'id_ID').format(value);
  }

  Widget _metricCard({
    required String label,
    required int amount,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                formatCurrency(amount),
                style: blackTextStyle.copyWith(
                  fontSize: 15,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceCard(int difference) {
    final bool positive = difference >= 0;
    final Color accent = positive ? greenColor : readColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: positive
              ? [
                  const Color(0xff0EA979),
                  const Color(0xff24C28F),
                ]
              : [
                  const Color(0xffD9476C),
                  const Color(0xffEB6380),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor.withValues(alpha: 0.2),
            ),
            child: Icon(
              positive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: whiteColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selisih saat ini',
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                    color: whiteColor.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${positive ? '+' : '-'} ${formatCurrency(difference.abs())}',
                    style: whiteTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: extraBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart({
    required double expensePercent,
    required double incomePercent,
    required int expense,
    required int income,
  }) {
    final String expenseText = '${(expensePercent * 100).toStringAsFixed(1)}%';
    final String incomeText = '${(incomePercent * 100).toStringAsFixed(1)}%';

    const double chartSize = 132;
    final Widget chartWidget = Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: chartSize,
              height: chartSize,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 12,
                color: blueLightColor,
              ),
            ),
            SizedBox(
              width: chartSize,
              height: chartSize,
              child: CircularProgressIndicator(
                value: expensePercent.clamp(0, 1),
                strokeWidth: 12,
                color: readColor,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expenseText,
                  style: blackTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: extraBold,
                    color: readColor,
                  ),
                ),
                Text(
                  'Pengeluaran',
                  style: greyTextStyle.copyWith(
                    fontSize: 11,
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final Widget summaryWidget = Column(
      children: [
        _metricCard(
          label: 'Porsi Pemasukan',
          amount: income,
          icon: Icons.trending_up_rounded,
          accent: greenColor,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Porsi Pengeluaran',
          amount: expense,
          icon: Icons.trending_down_rounded,
          accent: readColor,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: blueLightColor.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Income: $incomeText',
                  style: blackTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                    color: greenColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Expense: $expenseText',
                  textAlign: TextAlign.end,
                  style: blackTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                    color: readColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Persentase Pengeluaran',
            style: blackTextStyle.copyWith(
              fontSize: 15,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Persentase dihitung dari total arus kas pemasukan dan pengeluaran.',
            style: greyTextStyle.copyWith(
              fontSize: 12,
              fontWeight: medium,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 430;

              if (isCompact) {
                return Column(
                  children: [
                    chartWidget,
                    const SizedBox(height: 14),
                    summaryWidget,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: chartWidget),
                  const SizedBox(width: 12),
                  Expanded(child: summaryWidget),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection({
    required String title,
    required Color accent,
    required List<Catatan> items,
    required String emptyMessage,
    required bool isIncome,
  }) {
    final List<Catatan> visibleItems = items.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome
                    ? Icons.call_received_rounded
                    : Icons.call_made_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (visibleItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: blueLightColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                emptyMessage,
                style: greyBlackTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: medium,
                ),
              ),
            )
          else
            ...visibleItems.map((item) {
              final DateTime? parsedDate = _parseDate(item.tanggal);
              final int amount = item.jumlah ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: blueLightColor.withValues(alpha: 0.45),
                  border: Border.all(
                    color: blueColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.kategori ?? '-',
                            style: blackTextStyle.copyWith(
                              fontWeight: semiBold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'} ${formatCurrency(amount)}',
                          style: blackTextStyle.copyWith(
                            fontWeight: semiBold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (item.catatan ?? '-').trim().isEmpty
                          ? '-'
                          : item.catatan!.trim(),
                      style: greyBlackTextStyle.copyWith(
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _compactDate(parsedDate),
                      style: greyTextStyle.copyWith(
                        fontSize: 11,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _WindowInfo info = _resolveWindow();

    final List<Catatan> inWindow = transactions.where((item) {
      final DateTime? parsed = _parseDate(item.tanggal);
      if (parsed == null) {
        return false;
      }
      return !parsed.isBefore(info.start) && !parsed.isAfter(info.end);
    }).toList()
      ..sort((a, b) {
        final DateTime dateA = _parseDate(a.tanggal) ?? DateTime(1970);
        final DateTime dateB = _parseDate(b.tanggal) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

    final List<Catatan> incomeItems =
        inWindow.where((item) => _isIncome(item)).toList();
    final List<Catatan> expenseItems =
        inWindow.where((item) => !_isIncome(item)).toList();

    final int totalIncome = _sumAmount(incomeItems);
    final int totalExpense = _sumAmount(expenseItems);
    final int difference = totalIncome - totalExpense;

    final int totalFlow = totalIncome + totalExpense;
    final double expensePercent = totalFlow == 0 ? 0 : totalExpense / totalFlow;
    final double incomePercent = totalFlow == 0 ? 0 : totalIncome / totalFlow;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.title,
                style: blackTextStyle.copyWith(
                  fontSize: 15,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _periodText(info.start, info.end),
                style: greyBlackTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: medium,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: blueLightColor,
                ),
                child: Text(
                  '${inWindow.length} transaksi tercatat',
                  style: blueTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final Widget incomeCard = _metricCard(
              label: 'Pemasukan',
              amount: totalIncome,
              icon: Icons.trending_up_rounded,
              accent: greenColor,
            );

            final Widget expenseCard = _metricCard(
              label: 'Pengeluaran',
              amount: totalExpense,
              icon: Icons.trending_down_rounded,
              accent: readColor,
            );

            if (constraints.maxWidth < 380) {
              return Column(
                children: [
                  incomeCard,
                  const SizedBox(height: 10),
                  expenseCard,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: incomeCard),
                const SizedBox(width: 10),
                Expanded(child: expenseCard),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        _buildDifferenceCard(difference),
        const SizedBox(height: 12),
        _buildExpenseChart(
          expensePercent: expensePercent,
          incomePercent: incomePercent,
          expense: totalExpense,
          income: totalIncome,
        ),
        const SizedBox(height: 12),
        _buildNoteSection(
          title: 'Catatan Pemasukan',
          accent: greenColor,
          items: incomeItems,
          emptyMessage: 'Belum ada catatan pemasukan di periode ini.',
          isIncome: true,
        ),
        const SizedBox(height: 12),
        _buildNoteSection(
          title: 'Catatan Pengeluaran',
          accent: readColor,
          items: expenseItems,
          emptyMessage: 'Belum ada catatan pengeluaran di periode ini.',
          isIncome: false,
        ),
      ],
    );
  }
}
