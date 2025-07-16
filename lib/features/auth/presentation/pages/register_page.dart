import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user.dart' as app_models;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingL),
                  
                  // Welcome text
                  const Text(
                    'Join the Movement',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingS),
                  
                  const Text(
                    'Create your account and start supporting Palestinian voices',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.paddingXL),
                  
                  // Registration form
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          // User type selection
                          FormBuilderRadioGroup<app_models.UserType>(
                            name: 'userType',
                            decoration: const InputDecoration(
                              labelText: 'Account Type',
                              border: InputBorder.none,
                            ),
                            initialValue: app_models.UserType.individual,
                            options: const [
                              FormBuilderFieldOption(
                                value: app_models.UserType.individual,
                                child: Text('Individual'),
                              ),
                              FormBuilderFieldOption(
                                value: app_models.UserType.organization,
                                child: Text('Organization'),
                              ),
                            ],
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Name fields
                          FormBuilderTextField(
                            name: 'firstName',
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          FormBuilderTextField(
                            name: 'lastName',
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Organization name (conditional)
                          FormBuilderTextField(
                            name: 'organizationName',
                            decoration: const InputDecoration(
                              labelText: 'Organization Name (if applicable)',
                              prefixIcon: Icon(Icons.business_outlined),
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Email field
                          FormBuilderTextField(
                            name: 'email',
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ]),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Phone field
                          FormBuilderTextField(
                            name: 'phoneNumber',
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Password field
                          FormBuilderTextField(
                            name: 'password',
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(6),
                            ]),
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Confirm password field
                          FormBuilderTextField(
                            name: 'confirmPassword',
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              (value) {
                                final password = _formKey.currentState?.fields['password']?.value;
                                if (value != password) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ]),
                          ),
                          const SizedBox(height: AppTheme.paddingL),
                          
                          // Register button
                          GetBuilder<AuthController>(
                            builder: (authController) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authController.isLoading
                                      ? null
                                      : () => _handleRegister(authController),
                                  child: authController.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text('Create Account'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingM),
                          
                          // Error message
                          GetBuilder<AuthController>(
                            builder: (authController) {
                              if (authController.error != null) {
                                return Container(
                                  padding: const EdgeInsets.all(AppTheme.paddingS),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                  ),
                                  child: Text(
                                    authController.error!,
                                    style: const TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: AppTheme.fontSizeS,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingL),
                  
                  // Sign in link
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(AuthController authController) async {
    if (_formKey.currentState?.saveAndValidate() == true) {
      final values = _formKey.currentState!.value;
      
      // Build full name from first and last name
      final fullName = '${values['firstName']} ${values['lastName']}';
      
      final success = await authController.signUp(
        email: values['email'],
        password: values['password'],
        fullName: fullName,
        phoneNumber: values['phoneNumber'],
        userType: values['userType'].toString(),
      );
      
      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please check your email for verification.'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Navigate to login with a slight delay to ensure the message is shown
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/login');
        }
      }
    }
  }
}
