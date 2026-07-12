import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:pustakalaya/features/support/domain/entities/support_issue_type.dart';
import 'package:pustakalaya/features/support/presentation/providers/support_provider.dart';

class ReturnSupportScreen extends ConsumerStatefulWidget {
  const ReturnSupportScreen({super.key});

  @override
  ConsumerState<ReturnSupportScreen> createState() =>
      _ReturnSupportScreenState();
}

class _ReturnSupportScreenState extends ConsumerState<ReturnSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  SupportIssueType? _selectedIssue;
  String? _attachedFileName;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: isError
            ? const Color(0xFFC0392B)
            : const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // There's no file-upload endpoint on the backend yet, so this just lets
  // the person acknowledge they'd attach something — nothing is uploaded.
  void _onChooseFile() {
    setState(() => _attachedFileName = 'evidence_photo.jpg');
    _showSnack('File attachment noted (upload isn\'t wired up yet).');
  }

  Future<void> _onSubmit() async {
    if (_selectedIssue == null) {
      _showSnack('Please select an issue type.', isError: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(supportSubmitProvider.notifier)
        .submit(
          issueType: _selectedIssue!,
          description: _descriptionCtrl.text,
          email: _emailCtrl.text,
          phoneNumber: _phoneCtrl.text,
        );

    if (!mounted) return;

    if (ok) {
      _showSnack('Your request has been submitted.');
      Navigator.of(context).maybePop();
    } else {
      final error = ref.read(supportSubmitProvider).error;
      _showSnack(
        error ?? 'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW > 600 ? 32.0 : 20.0;
    final isSubmitting = ref.watch(
      supportSubmitProvider.select((s) => s.isSubmitting),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      'Return & Support',
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
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need help with your order?',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select an issue type below.',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _IssueTypeGrid(
                        selected: _selectedIssue,
                        onSelect: (type) =>
                            setState(() => _selectedIssue = type),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Describe Your Issue',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionCtrl,
                        maxLines: 4,
                        minLines: 4,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty)
                            return 'Please describe your issue.';
                          if (text.length < 10) {
                            return 'Please add a few more details (min 10 characters).';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Please provide details about your issue...',
                          hintStyle: GoogleFonts.lato(
                            fontSize: 14,
                            color: AppColors.textMedium.withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.textMedium.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.textMedium.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Attach Evidence (Optional)',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _onChooseFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.textMedium.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 18,
                                color: AppColors.textMedium,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _attachedFileName ?? 'Choose file',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: _attachedFileName != null
                                        ? AppColors.textDark
                                        : AppColors.textMedium.withValues(
                                            alpha: 0.7,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        label: 'Email Address',
                        controller: _emailCtrl,
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty) return 'Email is required.';
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(text)) {
                            return 'Enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Phone Number (Optional)',
                        controller: _phoneCtrl,
                        hint: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.of(context).maybePop(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFC0392B),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.lato(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFC0392B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: isSubmitting ? null : _onSubmit,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF27AE60),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFF27AE60),
                                        ),
                                      )
                                    : Text(
                                        'Submit Request',
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF27AE60),
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueTypeGrid extends StatelessWidget {
  final SupportIssueType? selected;
  final ValueChanged<SupportIssueType> onSelect;

  const _IssueTypeGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: SupportIssueType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onSelect(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFDDD5CC),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  type.icon,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textMedium,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type.displayName,
                    style: GoogleFonts.lato(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDark,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
