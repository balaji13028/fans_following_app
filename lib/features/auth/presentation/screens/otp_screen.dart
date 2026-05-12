import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String mobileNumber;
  final Map<String, dynamic>? userDetails;
  final bool isLogin;
  final String? serverOtp;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    this.userDetails,
    this.isLogin = false,
    this.serverOtp,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.serverOtp != null && widget.serverOtp!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your OTP is: ${widget.serverOtp}'),
            duration: const Duration(minutes: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.isLogin) {
          // Handle Login Flow
          await ref
              .read(authNotifierProvider.notifier)
              .verifyOtpAndUpdateDetails(
                mobileNumber: widget.mobileNumber,
                otp: _otpController.text.trim(),
                userDetails: {}, // Empty details for login
              );
        } else {
          // Handle Signup Flow
          await ref
              .read(authNotifierProvider.notifier)
              .verifyOtpAndUpdateDetails(
                mobileNumber: widget.mobileNumber,
                otp: _otpController.text.trim(),
                userDetails: widget.userDetails ?? {},
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isLogin
                    ? 'Sign in successful!'
                    : 'Account created successfully!',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification failed: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(8),
    );

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
                  'OTP Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A verification code has been sent to\n+91 ** ** **${widget.mobileNumber.length >= 4 ? widget.mobileNumber.substring(widget.mobileNumber.length - 4) : widget.mobileNumber}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (pin) => _handleVerify(),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: authState.isLoading
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
                      : Text(
                          widget.isLogin
                              ? 'Sign In'
                              : 'Verify & Create Account',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
