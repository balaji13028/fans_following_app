import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:country_picker/country_picker.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final PageController _pageController = PageController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  // Step 2 Controllers
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  Country _selectedPhoneCountry = Country.parse('IN'); // Default to India

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      // Validate DOB
      if (_selectedDateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date of birth'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_formKeyStep1.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 1);
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 0);
    }
  }

  Future<void> _handleSignUp() async {
    if (_selectedCountry == null ||
        _selectedState == null ||
        _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Country, State, and District'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKeyStep2.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final mobile = '+${_selectedPhoneCountry.phoneCode}${_mobileController.text.trim().replaceAll(' ', '')}';

        // Prepare user details
        final userDetails = {
          'name': _nameController.text.trim(),
          'dob': _selectedDateOfBirth?.toIso8601String(),
          'country': _selectedCountry,
          'state': _selectedState,
          'district': _selectedDistrict,
          'mobile': mobile,
          'email': _emailController.text.trim(),
          'instagramId': _instagramController.text.trim(),
          'facebookId': _facebookController.text.trim(),
          'twitterId': _twitterController.text.trim(),
          'password': _passwordController.text,
        };

        // Sign Up
        await ref.read(authNotifierProvider.notifier).userSignUp(userDetails: userDetails);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed: ${e.toString()}'),
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

  // Step 1 Validators
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Sign Up'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Step Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step 1',
                      style: TextStyle(
                        color: _currentStep >= 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Step 2',
                      style: TextStyle(
                        color: _currentStep >= 1
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress Bar
                Row(
                  children: [
                    // Step 1 Bar
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentStep >= 0
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Step 2 Bar
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentStep >= 1
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(2),
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
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Step 1: Personal Information
            _buildStep1(),
            // Step 2: Location & Social Media
            _buildStep2(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // const SizedBox(height: 20),

            // Name Field
            CustomTextField(
              labelText: 'Name',
              hintText: 'Enter your full name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: _validateName,
              isRequired: true,
            ),

            const SizedBox(height: 20),

            // Mobile Number Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Mobile Number',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          '*',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
                              _selectedPhoneCountry = country;
                            });
                          },
                          countryListTheme: CountryListThemeData(
                            backgroundColor: AppColors.surface,
                            textStyle: const TextStyle(color: Colors.white),
                            searchTextStyle: const TextStyle(color: Colors.white),
                            inputDecoration: InputDecoration(
                              hintText: 'Search country',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.search, color: Colors.white54),
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
                        height: 50, // Adjusted to match the dense TextFormField height
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedPhoneCountry.flagEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${_selectedPhoneCountry.phoneCode}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white54),
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
                        validator: _validateMobile,
                        isRequired: false, // Label handled above
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Email Field
            CustomTextField(
              labelText: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              isRequired: true,
            ),

            const SizedBox(height: 20),

            // Password Field
            CustomTextField(
              labelText: 'Password',
              hintText: 'Enter your password (min 6 characters)',
              controller: _passwordController,
              obscureText: true,
              validator: _validatePassword,
              isRequired: true,
            ),

            const SizedBox(height: 20),

            // Date of Birth Field
            DatePickerField(
              labelText: 'Date of Birth',
              hintText: 'Select your date of birth',
              initialDate: _selectedDateOfBirth,
              lastDate: DateTime.now(),
              onDateSelected: (date) {
                setState(() => _selectedDateOfBirth = date);
              },
              isRequired: true,
            ),

            const SizedBox(height: 30),

            // Next Button
            ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Location Details',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            CSCPicker(
              showStates: true,
              showCities: true,
              flagState: CountryFlag.disable,
              dropdownDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: AppColors.surfaceVariant,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              disabledDropdownDecoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              countrySearchPlaceholder: "Search Country",
              stateSearchPlaceholder: "Search State",
              citySearchPlaceholder: "Search City",
              countryDropdownLabel: "Select Country",
              stateDropdownLabel: "Select State",
              cityDropdownLabel: "Select City",
              selectedItemStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              dropdownHeadingStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              dropdownItemStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              dropdownDialogRadius: 8.0,
              searchBarRadius: 8.0,
              onCountryChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
              onStateChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Instagram ID (Optional)
            CustomTextField(
              labelText: 'Instagram ID (Optional)',
              hintText: 'Enter your Instagram ID',
              controller: _instagramController,
            ),

            const SizedBox(height: 20),

            // Facebook ID (Optional)
            CustomTextField(
              labelText: 'Facebook ID (Optional)',
              hintText: 'Enter your Facebook ID',
              controller: _facebookController,
            ),

            const SizedBox(height: 20),

            // Twitter ID (Optional)
            CustomTextField(
              labelText: 'Twitter ID (Optional)',
              hintText: 'Enter your Twitter ID',
              controller: _twitterController,
            ),

            const SizedBox(height: 30),

            // Back and Create Buttons
            Row(
              children: [
                // Back Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Create Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            'Create',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
