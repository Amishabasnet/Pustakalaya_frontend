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

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _savePassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(signInNotifierProvider.notifier)
        .signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInNotifierProvider);

    ref.listen(signInNotifierProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back! 📚'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(signInNotifierProvider.notifier).reset();
        // Navigate to home
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter Your Credentials to Access Your Account.',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 36),

                // Email
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

                // Password
                AuthTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 0,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Save password checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _savePassword,
                        onChanged: (v) =>
                            setState(() => _savePassword = v ?? false),
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: AppColors.textMedium.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Save Password',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Button
                AuthPrimaryButton(
                  label: 'SIGN IN',
                  onPressed: _onSignIn,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 20),

                // Create account link
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                      children: [
                        const TextSpan(text: 'New here? '),
                        TextSpan(
                          text: 'Create account',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
