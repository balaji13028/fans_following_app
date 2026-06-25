import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'sign_up_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/legal_acceptance_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'package:country_picker/country_picker.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  Country _selectedCountry = Country.parse('IN'); // Default to India

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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final mobileNumber =
        '+${_selectedCountry.phoneCode}${_mobileController.text.trim().replaceAll(' ', '')}';
    final password = _passwordController.text;

    // Password based login. Only navigate on success; on failure we stay on
    // this screen and surface the error message to the user.
    final success = await ref
        .read(authNotifierProvider.notifier)
        .userLogin(mobileNumber: mobileNumber, password: password);

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      final error = ref.read(authNotifierProvider).error;
      _showErrorSnackBar(error ?? 'Login failed. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    // Server/connectivity failures show a warning-style bar with an icon.
    final isServerIssue =
        message.contains('server may be down') ||
        message.contains('server is currently unavailable') ||
        message.contains('taking too long') ||
        message.contains('No internet connection');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isServerIssue
                  ? Icons.cloud_off_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isServerIssue ? AppColors.warning : AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Mobile Number',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Code Picker
                        GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              favorite: ['IN'],
                              onSelect: (Country country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },
                              countryListTheme: CountryListThemeData(
                                backgroundColor: AppColors.surface,
                                textStyle: const TextStyle(color: Colors.white),
                                searchTextStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                inputDecoration: InputDecoration(
                                  hintText: 'Search country',
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.white54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height:
                                50, // Adjusted to match the dense TextFormField height
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedCountry.flagEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${_selectedCountry.phoneCode}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Mobile Number Input
                        Expanded(
                          child: CustomTextField(
                            hintText: 'Enter mobile number',
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              if (!RegExp(
                                r'^[0-9]{8,15}$',
                              ).hasMatch(value.replaceAll(' ', ''))) {
                                return 'Please enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Sign In Button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
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
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                const LegalAcceptanceText(action: 'signing in'),

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
