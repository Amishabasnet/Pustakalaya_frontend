import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:pustakalaya/features/payment_methods/domain/entities/saved_payment_method.dart';
import 'package:pustakalaya/features/payment_methods/presentation/providers/saved_payment_provider.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  SavedPaymentType _selectedType = SavedPaymentType.esewa;

  final _phoneCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cardNumberCtrl.dispose();
    _holderNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final method = _selectedType == SavedPaymentType.card
        ? SavedPaymentMethod(
            id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
            type: SavedPaymentType.card,
            identifier: () {
              final digitsOnly = _cardNumberCtrl.text.replaceAll(
                RegExp(r'\s+'),
                '',
              );
              return digitsOnly.substring(digitsOnly.length - 4);
            }(),
            holderName: _holderNameCtrl.text.trim(),
            expiry: _expiryCtrl.text.trim(),
          )
        : SavedPaymentMethod(
            id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
            type: _selectedType,
            identifier: _phoneCtrl.text.trim(),
          );

    ref.read(savedPaymentProvider.notifier).add(method);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment method added',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Add Payment Method',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8E0)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: SavedPaymentType.values.map((type) {
                          final selected = type == _selectedType;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedType = type),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: type != SavedPaymentType.values.last
                                      ? 8
                                      : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? type.color.withValues(alpha: 0.12)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? type.color
                                        : const Color(0xFFDDD5CC),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      type.icon,
                                      size: 18,
                                      color: selected
                                          ? type.color
                                          : AppColors.textMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      type.displayName,
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? type.color
                                            : AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Conditional fields
                      if (_selectedType == SavedPaymentType.card) ...[
                        AuthTextField(
                          label: 'Card Number',
                          controller: _cardNumberCtrl,
                          hint: '1234 5678 9012 3456',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              (v == null ||
                                  v.replaceAll(RegExp(r'\s+'), '').length < 12)
                              ? 'Enter a valid card number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: 'Cardholder Name',
                          controller: _holderNameCtrl,
                          hint: 'Name on card',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AuthTextField(
                                label: 'Expiry (MM/YY)',
                                controller: _expiryCtrl,
                                hint: '12/28',
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    (v == null ||
                                        !RegExp(
                                          r'^\d{2}/\d{2}$',
                                        ).hasMatch(v.trim()))
                                    ? 'MM/YY'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AuthTextField(
                                label: 'CVV',
                                controller: _cvvCtrl,
                                hint: '123',
                                isPassword: true,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                validator: (v) =>
                                    (v == null || v.trim().length < 3)
                                    ? 'CVV'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        AuthTextField(
                          label: '${_selectedType.displayName} Phone Number',
                          controller: _phoneCtrl,
                          hint: '+977 98XXXXXXXX',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: (v) => (v == null || v.trim().length < 7)
                              ? 'Enter a valid phone number'
                              : null,
                        ),
                      ],

                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF27AE60,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 18,
                              color: Color(0xFF27AE60),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your payment details are encrypted and never shared.',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF27AE60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      AuthPrimaryButton(
                        label: 'SAVE PAYMENT METHOD',
                        onPressed: _onSave,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
