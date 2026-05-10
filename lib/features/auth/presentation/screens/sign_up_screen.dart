import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/country_state_data.dart';
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
    if (_formKeyStep2.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // await ref.read(authNotifierProvider.notifier).signUp(
        //       email: email,
        //       password: password,
        //       name: name,
        //     );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign up successful!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate to dashboard and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
            (route) => false, // Remove all previous routes
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


  // Step 2 Validators
  String? _validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select country';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select state';
    }
    return null;
  }

  String? _validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select district';
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
            const SizedBox(height: 20),
            
            // Name Field
            CustomTextField(
              labelText: 'Name',
              hintText: 'Enter your full name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: _validateName,
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // Mobile Number Field
            CustomTextField(
              labelText: 'Mobile Number',
              hintText: 'Enter your mobile number',
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              validator: _validateMobile,
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // Email Field
            CustomTextField(
              labelText: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // Password Field
            CustomTextField(
              labelText: 'Password',
              hintText: 'Enter your password (min 6 characters)',
              controller: _passwordController,
              obscureText: true,
              validator: _validatePassword,
              isRequired: true,
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 40),

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
    // Get states and districts based on selected country
    final states = _selectedCountry != null
        ? CountryStateData.getStates(_selectedCountry!)
        : <String>[];
    
    final districts = _selectedCountry != null && _selectedState != null
        ? CountryStateData.getDistricts(_selectedCountry!, _selectedState!)
        : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Country Dropdown
            CustomDropdown<String>(
              labelText: 'Country',
              hintText: 'Select country',
              value: _selectedCountry,
              items: CountryStateData.getCountries().map((country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _selectedState = null; // Reset state when country changes
                  _selectedDistrict = null; // Reset district when country changes
                });
              },
              validator: (value) => _validateCountry(value),
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // State Dropdown
            CustomDropdown<String>(
              labelText: 'State',
              hintText: 'Select state',
              value: _selectedState,
              items: states.map((state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: _selectedCountry != null
                  ? (value) {
                      setState(() {
                        _selectedState = value;
                        _selectedDistrict = null; // Reset district when state changes
                      });
                    }
                  : null,
              enabled: _selectedCountry != null,
              validator: (value) => _validateState(value),
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // District Dropdown
            CustomDropdown<String>(
              labelText: 'District',
              hintText: 'Select district',
              value: _selectedDistrict,
              items: districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: _selectedState != null
                  ? (value) {
                      setState(() => _selectedDistrict = value);
                    }
                  : null,
              enabled: _selectedState != null,
              validator: (value) => _validateDistrict(value),
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // Instagram ID (Optional)
            CustomTextField(
              labelText: 'Instagram ID (Optional)',
              hintText: 'Enter your Instagram ID',
              controller: _instagramController,
            ),

            const SizedBox(height: 24),

            // Facebook ID (Optional)
            CustomTextField(
              labelText: 'Facebook ID (Optional)',
              hintText: 'Enter your Facebook ID',
              controller: _facebookController,
            ),

            const SizedBox(height: 24),

            // Twitter ID (Optional)
            CustomTextField(
              labelText: 'Twitter ID (Optional)',
              hintText: 'Enter your Twitter ID',
              controller: _twitterController,
            ),

            const SizedBox(height: 40),

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
