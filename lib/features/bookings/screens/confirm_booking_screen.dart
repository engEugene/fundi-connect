import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/models/worker.dart';
import '../../../core/utils/formatters.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({super.key});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final _services = const [
    'Writing & Installation',
    'Repair & Maintenance',
    'Consultation',
  ];

  final _paymentMethods = const [
    _PaymentOption('MTN MoMo', Icons.phone_android),
    _PaymentOption('Airtel Money', Icons.phone_android),
    _PaymentOption('Cash', Icons.payments_outlined),
  ];

  late String _selectedService;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _locationController = TextEditingController(
    text: 'KG 14 Ave, Kacyiru, Kigali',
  );
  late String _selectedPayment;

  final _worker = Worker.nearby[0]; // Jean Pierre Habimana
  final double _serviceFee = 12000;
  final double _platformFee = 800;

  @override
  void initState() {
    super.initState();
    _selectedService = _services.first;
    _selectedDate = DateTime(2025, 7, 15);
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    _selectedPayment = _paymentMethods.first.name;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  double get _total => _serviceFee + _platformFee;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String get _formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final date = _selectedDate;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _formattedTime {
    final hour = _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WorkerHeader(worker: _worker),
              const SizedBox(height: 24),
              _SectionTitle('Service Type'),
              const SizedBox(height: 8),
              _ServiceDropdown(
                value: _selectedService,
                items: _services,
                onChanged: (value) => setState(() => _selectedService = value!),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: 'Date',
                      value: _formattedDate,
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerField(
                      label: 'Time',
                      value: _formattedTime,
                      icon: Icons.access_time,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle('Your Location'),
              const SizedBox(height: 8),
              _LocationField(controller: _locationController),
              const SizedBox(height: 24),
              _SectionTitle('Price Estimate'),
              const SizedBox(height: 8),
              _PriceCard(
                serviceFee: _serviceFee,
                platformFee: _platformFee,
                total: _total,
              ),
              const SizedBox(height: 24),
              _SectionTitle('Payment Method'),
              const SizedBox(height: 8),
              _PaymentMethodList(
                options: _paymentMethods,
                selected: _selectedPayment,
                onSelected: (value) => setState(() => _selectedPayment = value),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('${RouteNames.bookings}/b1'),
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerHeader extends StatelessWidget {
  const _WorkerHeader({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              worker.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64,
                height: 64,
                color: AppColors.primaryLight,
                child: const Icon(
                  Icons.person,
                  color: AppColors.onPrimary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Handyman',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star,
                      color: AppColors.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${worker.rating}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatNumber(worker.hourlyRate),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
              Text(
                'Rwf/hr',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.titleMedium);
  }
}

class _ServiceDropdown extends StatelessWidget {
  const _ServiceDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          style: AppTextStyles.bodyMedium,
          dropdownColor: AppColors.surface,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.serviceFee,
    required this.platformFee,
    required this.total,
  });

  final double serviceFee;
  final double platformFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Service fee (2 hrs)',
            value: '${Formatters.formatNumber(serviceFee)} Rwf',
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Platform fee',
            value: '${Formatters.formatNumber(platformFee)} Rwf',
          ),
          const Divider(height: 24),
          _PriceRow(
            label: 'Total',
            value: '${Formatters.formatNumber(total)} Rwf',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.titleMedium
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
      ],
    );
  }
}

class _PaymentOption {
  const _PaymentOption(this.name, this.icon);

  final String name;
  final IconData icon;
}

class _PaymentMethodList extends StatelessWidget {
  const _PaymentMethodList({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_PaymentOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = option.name == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onSelected(option.name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.inputFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      option.icon,
                      color: isSelected ? AppColors.onPrimary : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.onPrimary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
