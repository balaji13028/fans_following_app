import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:csc_picker/csc_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _fbController;
  late TextEditingController _igController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameController = TextEditingController(text: user?.name);
    _dobController = TextEditingController(
      text: user?.dob != null ? _formatDate(user!.dob!) : '',
    );
    _fbController = TextEditingController(text: user?.facebookId);
    _igController = TextEditingController(text: user?.instagramId);
    _selectedCountry = user?.country;
    _selectedState = user?.state;
    _selectedDistrict = user?.district;
    _mobileController = TextEditingController(text: user?.mobile);
    _emailController = TextEditingController(text: user?.email);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _fbController.dispose();
    _igController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) return;

      // Convert date back to ISO format for API
      String? isoDob;
      if (_dobController.text.isNotEmpty) {
        final date = DateFormat('dd/MM/yyyy').parse(_dobController.text);
        isoDob = date.toIso8601String();
      }

      await ref.read(authNotifierProvider.notifier).updateProfile({
        'name': _nameController.text,
        'dob': isoDob,
        'facebookId': _fbController.text,
        'instagramId': _igController.text,
        'country': _selectedCountry,
        'state': _selectedState,
        'district': _selectedDistrict,
        'email': _emailController.text,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField('Full Name', _nameController),
            const SizedBox(height: 20),
            _buildTextField(
              'Date of Birth',
              _dobController,
              readOnly: true,
              onTap: _selectDate,
              suffixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              'Mobile Number',
              _mobileController,
              readOnly: true,
              labelColor: Colors.white38,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              'Email Address',
              _emailController,
              hint: 'example@email.com',
            ),
            const SizedBox(height: 20),
            _buildTextField('Instagram ID', _igController, hint: '@username'),
            const SizedBox(height: 20),
            _buildTextField(
              'Facebook ID',
              _fbController,
              hint: 'profile link or ID',
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Location Details',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CSCPicker(
              showStates: true,
              showCities: true,
              flagState: CountryFlag.disable,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1A1A1A),
              ),
              disabledDropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
              ),
              countrySearchPlaceholder: "Search Country",
              stateSearchPlaceholder: "Search State",
              citySearchPlaceholder: "Search City",
              countryDropdownLabel: "Select Country",
              stateDropdownLabel: "Select State",
              cityDropdownLabel: "Select City",
              currentCountry: _selectedCountry,
              currentState: _selectedState,
              currentCity: _selectedDistrict,
              selectedItemStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
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
              dropdownDialogRadius: 12.0,
              searchBarRadius: 12.0,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? hint,
    Color labelColor = Colors.white70,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            color: readOnly ? Colors.white38 : Colors.white,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.white38, size: 18)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
