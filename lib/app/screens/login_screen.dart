import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_for_amir/app/screens/signup_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  final Dio dio;

  const LoginScreen({super.key, required this.dio});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  // Constants
  static const Color primaryColor = Color(0xFFff1415);
  static const TextStyle gilroyStyle = TextStyle(fontFamily: 'Gilroy');

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await widget.dio.post(
        '/login',
        data: {
          'phone': _phoneController.text,
          'password': _passwordController.text,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _handleSuccessfulLogin();
      } else {
        _showError('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (_rememberMe) {
      await prefs.setString('phone', _phoneController.text);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful!')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleDioError(DioException e) {
    debugPrint('Dio error: ${e.response?.statusCode} - ${e.response?.data}');
    _showError(e.response?.data?['message'] ??
        'Network error occurred. Please try again.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Авторизация',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSignUpText(),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Номер телефона',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Пароль',
                    obscure: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  _buildRememberMeAndForgotPassword(),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Divider(),
                      Center(
                          child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.1,
                              decoration: BoxDecoration(
                                  color: Theme
                                      .of(context)
                                      .scaffoldBackgroundColor),
                              child: Center(
                                child: Text(
                                  'или',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 16),
                                ),
                              )))
                    ],
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    height: 50,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/google.svg', height: 50,),
                            Text('Войти с Google')
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Если у вас еще нет аккаунта - ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: 'зарегистрируйтесь',
            style: const TextStyle(
              color: primaryColor,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignupScreen(dio: widget.dio),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
          BorderSide(color: primaryColor.withOpacity(0.7), width: 2),
          borderRadius: BorderRadius.circular(0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(0),
        ),
        filled: true,
        fillColor: const Color(0xFFf6f6f8),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value!),
            ),
            const Text('Запомнить меня', style: gilroyStyle),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password functionality
          },
          child: const Text('Забыл пароль', style: gilroyStyle),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.9,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginUser,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _isLoading ? Colors.grey[400] : primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Войти',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy',
          ),
        ),
      ),
    );
  }
}
