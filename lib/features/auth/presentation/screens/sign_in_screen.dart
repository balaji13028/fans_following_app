import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'sign_up_screen.dart';
import 'otp_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(authNotifierProvider);
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleGetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final mobileNumber = _mobileController.text.trim().replaceAll(' ', '');

        final serverOtp = await ref.read(authNotifierProvider.notifier).sendOtp(mobileNumber);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                mobileNumber: mobileNumber,
                isLogin: true, // Passing flag to indicate it's a login flow
                serverOtp: serverOtp,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),

                // Mobile Number Field
                CustomTextField(
                  labelText: 'Mobile Number',
                  hintText: '+91 99 99 999999',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    if (!RegExp(
                      r'^[0-9]{10,}$',
                    ).hasMatch(value.replaceAll(' ', ''))) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Get A Code Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleGetCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          'Get A Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const Spacer(),

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
