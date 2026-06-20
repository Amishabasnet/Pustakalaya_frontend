import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/cart/presentation/providers/cart_provider.dart';


enum DeliveryOption { standard, express }

enum PaymentMethod { esewa, khalti, card, cod }

class CheckoutState {
  final DeliveryOption delivery;
  final PaymentMethod? payment;
  final String address;

  const CheckoutState({
    this.delivery = DeliveryOption.standard,
    this.payment,
    this.address = '',
  });

  CheckoutState copyWith({
    DeliveryOption? delivery,
    PaymentMethod? payment,
    String? address,
  }) =>
      CheckoutState(
        delivery: delivery ?? this.delivery,
        payment: payment ?? this.payment,
        address: address ?? this.address,
      );
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutState());

  void setDelivery(DeliveryOption d) => state = state.copyWith(delivery: d);
  void setPayment(PaymentMethod p) => state = state.copyWith(payment: p);
  void setAddress(String a) => state = state.copyWith(address: a);
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(),
);

class CheckoutScreen extends ConsumerStatefulWidget {
  final double grandTotal;
  const CheckoutScreen({super.key, required this.grandTotal});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final hPad = screenW > 600 ? 40.0 : 20.0;
    final isTablet = screenW > 600;

    // Delivery fee
    final deliveryFee = state.delivery == DeliveryOption.standard ? 120.0 : 200.0;
    final cartTotal = widget.grandTotal - 120.0; // strip old standard fee
    final orderTotal = cartTotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  _BackBtn(onTap: () => Navigator.of(context).maybePop()),
                  Expanded(
                    child: Text(
                      'Checkout',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // balance back btn
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8E0)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
                child: isTablet
                    ? _TabletLayout(
                        state: state,
                        addressController: _addressController,
                        hPad: hPad,
                        orderTotal: orderTotal,
                        deliveryFee: deliveryFee,
                      )
                    : _PhoneLayout(
                        state: state,
                        addressController: _addressController,
                        orderTotal: orderTotal,
                        deliveryFee: deliveryFee,
                      ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
            hPad, 12, hPad, mq.padding.bottom + 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () =>
                _onConfirmPressed(context, ref, orderTotal),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'CONFIRM ORDER',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirmPressed(
      BuildContext context, WidgetRef ref, double total) {
    final state = ref.read(checkoutProvider);

    // Guard: address required
    if (state.address.trim().isEmpty) {
      _showSnack(context, 'Please enter your delivery address');
      return;
    }
    // Guard: payment required
    if (state.payment == null) {
      _showSnack(context, 'Please select a payment method');
      return;
    }

    _showConfirmDialog(context, ref, total);
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showConfirmDialog(
      BuildContext context, WidgetRef ref, double total) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              // Title
              Text(
                'Confirm Order?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Are you sure you want to place this order?\nTotal: NRs. ${total.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 26),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // close dialog
                        _placeOrder(context, ref, total);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Yes, Order!',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder(
      BuildContext context, WidgetRef ref, double total) {
    final checkoutState = ref.read(checkoutProvider);

    // Generate order ID
    final rand = Random();
    final orderId =
        '#FS-${(10000 + rand.nextInt(90000)).toString()}';

    // Map enum to display label
    final paymentLabel = switch (checkoutState.payment) {
      PaymentMethod.esewa  => 'eSewa',
      PaymentMethod.khalti => 'Khalti',
      PaymentMethod.card   => 'Card',
      PaymentMethod.cod    => 'Cash on Delivery',
      null                 => '',
    };

    // Clear cart then navigate
    ref.read(cartProvider.notifier).clear();

    context.go(
      AppRouter.confirmation,
      extra: {
        'orderId': orderId,
        'total': total,
        'paymentMethod': paymentLabel,
      },
    );
  }
}

class _PhoneLayout extends ConsumerWidget {
  final CheckoutState state;
  final TextEditingController addressController;
  final double orderTotal;
  final double deliveryFee;

  const _PhoneLayout({
    required this.state,
    required this.addressController,
    required this.orderTotal,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddressField(controller: addressController, ref: ref),
        const SizedBox(height: 16),
        _DeliveryCard(selected: state.delivery),
        const SizedBox(height: 16),
        _PaymentCard(selected: state.payment),
        const SizedBox(height: 16),
        _OrderSummaryCard(
            total: orderTotal, deliveryFee: deliveryFee),
        const SizedBox(height: 16),
        _SecurityBanner(),
      ],
    );
  }
}

class _TabletLayout extends ConsumerWidget {
  final CheckoutState state;
  final TextEditingController addressController;
  final double hPad;
  final double orderTotal;
  final double deliveryFee;

  const _TabletLayout({
    required this.state,
    required this.addressController,
    required this.hPad,
    required this.orderTotal,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _AddressField(controller: addressController, ref: ref),
              const SizedBox(height: 16),
              _DeliveryCard(selected: state.delivery),
              const SizedBox(height: 16),
              _PaymentCard(selected: state.payment),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _OrderSummaryCard(
                  total: orderTotal, deliveryFee: deliveryFee),
              const SizedBox(height: 16),
              _SecurityBanner(),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final WidgetRef ref;
  const _AddressField(
      {required this.controller, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (v) =>
            ref.read(checkoutProvider.notifier).setAddress(v),
        style: GoogleFonts.lato(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Delivery Address',
          hintStyle: GoogleFonts.lato(
              fontSize: 14, color: AppColors.textMedium),
          prefixIcon: const Icon(Icons.location_on_outlined,
              color: AppColors.textMedium, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEEE8E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEEE8E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  final DeliveryOption selected;
  const _DeliveryCard({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery option',
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          _DeliveryTile(
            label: 'Standard delivery : 2-4 days',
            price: 'NRs. 120',
            isSelected: selected == DeliveryOption.standard,
            onTap: () => ref
                .read(checkoutProvider.notifier)
                .setDelivery(DeliveryOption.standard),
          ),
          const SizedBox(height: 8),
          _DeliveryTile(
            label: 'Express delivery: 1 day',
            price: 'NRs. 200',
            isSelected: selected == DeliveryOption.express,
            onTap: () => ref
                .read(checkoutProvider.notifier)
                .setDelivery(DeliveryOption.express),
          ),
        ],
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final String label;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryTile({
    required this.label,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : const Color(0xFFF9F5F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : const Color(0xFFEEE8E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFCCCCC0),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.circle,
                      size: 8, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.textDark)),
            ),
            Text(price,
                style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends ConsumerWidget {
  final PaymentMethod? selected;
  const _PaymentCard({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = [
      _PaymentMethodData(
        method: PaymentMethod.esewa,
        label: 'eSewa',
        icon: Icons.smartphone_outlined,
      ),
      _PaymentMethodData(
        method: PaymentMethod.khalti,
        label: 'Khalti',
        icon: Icons.account_balance_wallet_outlined,
      ),
      _PaymentMethodData(
        method: PaymentMethod.card,
        label: 'Card',
        icon: Icons.credit_card_outlined,
      ),
      _PaymentMethodData(
        method: PaymentMethod.cod,
        label: 'Cash On\nDelivery',
        icon: Icons.payments_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment method',
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: methods.map((m) {
              final isSel = selected == m.method;
              return GestureDetector(
                onTap: () => ref
                    .read(checkoutProvider.notifier)
                    .setPayment(m.method),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : const Color(0xFFF9F5F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : const Color(0xFFEEE8E0),
                      width: isSel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m.icon,
                        size: 18,
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        m.label,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: isSel
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSel
                              ? AppColors.primary
                              : AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodData {
  final PaymentMethod method;
  final String label;
  final IconData icon;
  const _PaymentMethodData(
      {required this.method,
      required this.label,
      required this.icon});
}

class _OrderSummaryCard extends StatelessWidget {
  final double total;
  final double deliveryFee;
  const _OrderSummaryCard(
      {required this.total, required this.deliveryFee});

  @override
  Widget build(BuildContext context) {
    final subtotal = total - deliveryFee;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          _SummaryRow(
              label: 'Subtotal',
              value: 'NRs. ${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _SummaryRow(
              label: 'Delivery',
              value: 'NRs. ${deliveryFee.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEEEEEE)),
          ),
          _SummaryRow(
            label: 'Total',
            value: 'NRs. ${total.toStringAsFixed(0)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: bold ? 15 : 13,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w500,
                color: bold
                    ? AppColors.textDark
                    : AppColors.textMedium)),
        Text(value,
            style: GoogleFonts.lato(
                fontSize: bold ? 15 : 13,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w600,
                color: bold
                    ? AppColors.primary
                    : AppColors.textDark)),
      ],
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined,
              size: 20, color: Color(0xFF27AE60)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Secure checkout & saved payment options',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF27AE60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
