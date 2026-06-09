import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';
import 'package:pustakalaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:pustakalaya/features/auth/presentation/widgets/password_match_indicator.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _passwordsMatch = false;
  bool _confirmTouched = false;

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(_checkMatch);
    _passwordCtrl.addListener(_checkMatch);
  }

  void _checkMatch() {
    setState(() {
      _confirmTouched = _confirmCtrl.text.isNotEmpty;
      _passwordsMatch =
          _confirmCtrl.text == _passwordCtrl.text &&
          _confirmCtrl.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_passwordsMatch) return;

    await ref
        .read(signUpNotifierProvider.notifier)
        .signUp(
          fullName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signUpNotifierProvider);

    // React to success / failure
    ref.listen(signUpNotifierProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Welcome to Pustakalaya 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(signUpNotifierProvider.notifier).reset();
        context.go(AppRouter.signIn);
      } else if (next.status == AuthStatus.failure && next.failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure!.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.textMedium.withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Heading
                Text(
                  'Create Account',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                    children: [
                      const TextSpan(text: 'Welcome, '),
                      TextSpan(
                        text: 'new reader.',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in your details to get started',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 24),

                // Fields
                AuthTextField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  hint: 'Amisha Basnet',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Phone Number',
                  controller: _phoneCtrl,
                  hint: '9874563210',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Enter a valid phone number'
                      : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  hint: 'amishabasnet@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Confirm Password',
                  controller: _confirmCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v != _passwordCtrl.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 8),
                PasswordMatchIndicator(
                  isMatch: _passwordsMatch,
                  isVisible: _confirmTouched,
                ),
                const SizedBox(height: 28),

                // Button
                AuthPrimaryButton(
                  label: 'SIGN UP',
                  onPressed: _onSignUp,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Terms
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                      children: [
                        const TextSpan(
                          text: 'By creating an account you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: '. We never sell your data.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sign in link
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.go(AppRouter.signIn),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
