import 'package:finalcial_records/models/scheduled_bill.dart';
import 'package:finalcial_records/shared/shared_methods.dart';
import 'package:finalcial_records/shared/shared_preferences.dart';
import 'package:finalcial_records/shared/snackbar.dart';
import 'package:finalcial_records/shared/theme.dart';
import 'package:finalcial_records/ui/widgets/buttons.dart';
import 'package:finalcial_records/ui/widgets/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ScheduledBillDetailPage extends StatefulWidget {
  const ScheduledBillDetailPage({
    super.key,
    required this.billType,
    this.initialBill,
  });

  final String billType;
  final ScheduledBill? initialBill;

  @override
  State<ScheduledBillDetailPage> createState() => _ScheduledBillDetailPageState();
}

class _ScheduledBillDetailPageState extends State<ScheduledBillDetailPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _dueDateController;

  DateTime? _selectedDueDate;
  bool _reminderEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.initialBill?.amount.toString() ?? '',
    );

    _selectedDueDate = widget.initialBill?.dueDate;
    _dueDateController = TextEditingController(
      text: _selectedDueDate != null
          ? DateFormat('dd MMMM yyyy').format(_selectedDueDate!)
          : '',
    );

    _reminderEnabled = widget.initialBill?.reminderEnabled ?? true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final DateTime initialDate = _selectedDueDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: 'Pilih jatuh tempo',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDueDate = pickedDate;
      _dueDateController.text = DateFormat('dd MMMM yyyy').format(pickedDate);
    });
  }

  Future<void> _saveScheduledBill() async {
    final int? amount = int.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      CustomSnackBar.showToast(
        context,
        'Nominal harus angka dan lebih dari 0.',
        type: ToastType.warning,
      );
      return;
    }

    if (_selectedDueDate == null) {
      CustomSnackBar.showToast(
        context,
        'Tanggal jatuh tempo wajib dipilih.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final ScheduledBill bill = ScheduledBill(
      type: widget.billType,
      amount: amount,
      dueDateIso: _selectedDueDate!.toIso8601String(),
      reminderEnabled: _reminderEnabled,
    );

    await SharedPrefUtils.upsertScheduledBill(bill);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    CustomSnackBar.showToast(
      context,
      'Tagihan ${widget.billType} berhasil disimpan.',
      type: ToastType.success,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tagihan ${widget.billType}'),
      ),
      body: Stack(
        children: [
          const _DetailBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atur jadwal pembayaran ${widget.billType}.',
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data ini tersimpan lokal dan tetap ada saat aplikasi dibuka kembali.',
                        style: greyTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: medium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomFormField(
                        title: 'Nominal Tagihan',
                        hintText: 'Contoh: 250000',
                        controller: _amountController,
                        inputType: TextInputType.number,
                        prefixIcon: Icons.payments_rounded,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomFormField(
                        title: 'Tanggal Jatuh Tempo',
                        hintText: 'Pilih tanggal',
                        controller: _dueDateController,
                        readOnly: true,
                        onTap: _pickDueDate,
                        prefixIcon: Icons.calendar_month_rounded,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: greyColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: blueLightColor.withValues(alpha: 0.52),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _reminderEnabled
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_off_rounded,
                                color: birulangit,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengingat Pembayaran',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 13,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _reminderEnabled
                                        ? 'Aktif, kamu akan diingatkan sebelum jatuh tempo.'
                                        : 'Nonaktif, tidak ada pengingat untuk tagihan ini.',
                                    style: greyTextStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _reminderEnabled,
                              activeThumbColor: birulangit,
                              activeTrackColor: birulangit.withValues(
                                alpha: 0.38,
                              ),
                              onChanged: (bool value) {
                                setState(() {
                                  _reminderEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: blueColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview Tagihan',
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jenis: ${widget.billType}',
                        style: greyBlackTextStyle.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nominal: ${formatCurrency(int.tryParse(_amountController.text.trim()) ?? 0)}',
                        style: greyBlackTextStyle.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jatuh tempo: ${_dueDateController.text.isEmpty ? '-' : _dueDateController.text}',
                        style: greyBlackTextStyle.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (_isSaving)
                  Center(
                    child: CircularProgressIndicator(
                      color: birulangit,
                    ),
                  )
                else
                  CustomFillButton(
                    title: 'Simpan Tagihan',
                    height: 52,
                    onPressed: _saveScheduledBill,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBackground extends StatelessWidget {
  const _DetailBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xffEAF7FF),
            lightBackgroundColor,
            whiteColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -100,
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
          Positioned(
            top: 320,
            left: -120,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    blueColor.withValues(alpha: 0.1),
                    blueColor.withValues(alpha: 0.01),
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
