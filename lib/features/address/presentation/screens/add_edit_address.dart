import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/address/domain/entities/address_entity.dart';
import 'package:pustakalaya/features/address/presentation/providers/address_provider.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_text_field.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final AddressEntity? existing;

  const AddEditAddressScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late AddressLabel _selectedLabel;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: e?.phoneNumber ?? '');
    _addressCtrl = TextEditingController(text: e?.addressLine ?? '');
    _cityCtrl = TextEditingController(text: e?.city ?? '');
    _selectedLabel = e?.label ?? AddressLabel.home;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final notifier = ref.read(addressProvider.notifier);
    if (_isEditing) {
      notifier.update(
        widget.existing!.copyWith(
          label: _selectedLabel,
          recipientName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          addressLine: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
        ),
      );
    } else {
      notifier.add(
        AddressEntity(
          id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
          label: _selectedLabel,
          recipientName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          addressLine: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Address updated' : 'Address added',
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
                      _isEditing ? 'Edit Address' : 'Add Address',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
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
                        'Label',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: AddressLabel.values.map((label) {
                          final selected = label == _selectedLabel;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedLabel = label),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: label != AddressLabel.values.last
                                      ? 8
                                      : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.12,
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : const Color(0xFFDDD5CC),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      label.icon,
                                      size: 18,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      label.displayName,
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? AppColors.primary
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
                      AuthTextField(
                        label: 'Recipient Name',
                        controller: _nameCtrl,
                        hint: 'Who will receive this?',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Phone Number',
                        controller: _phoneCtrl,
                        hint: '+977 98XXXXXXXX',
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().length < 7)
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Address',
                        controller: _addressCtrl,
                        hint: 'Street, ward, landmark',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'City',
                        controller: _cityCtrl,
                        hint: 'e.g. Kathmandu',
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 32),
                      AuthPrimaryButton(
                        label: _isEditing ? 'SAVE CHANGES' : 'ADD ADDRESS',
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
