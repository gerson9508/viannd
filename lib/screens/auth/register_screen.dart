import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'Mujer';
  bool _submitted = false;
  bool _acceptedTerms = false;
  bool _termsError = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _ageError;

  bool get _isFormValid =>
      _nameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _confirmPasswordError == null &&
      _ageError == null &&
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      _ageController.text.isNotEmpty &&
      _acceptedTerms;

  Map<String, dynamic>? _pendingRegistration;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(() {
      _validatePassword();
      _validateConfirmPassword();
    });
    _confirmPasswordController.addListener(_validateConfirmPassword);
    _ageController.addListener(_validateAge);
  }

  void _validateName() {
    final value = _nameController.text.trim();
    final nameRegex = RegExp(r'^[a-zA-Z]+( [a-zA-Z]+)*$');
    setState(() {
      if (value.isEmpty) {
        _nameError = 'El nombre es obligatorio';
      } else if (!nameRegex.hasMatch(value)) {
        _nameError = 'Solo letras y un espacio entre palabras';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail() {
    final value = _emailController.text;
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    setState(() {
      if (value.isEmpty) {
        _emailError = 'El correo es obligatorio';
      } else if (!emailRegex.hasMatch(value)) {
        _emailError = 'Ingresa un correo válido (ej: usuario@correo.com)';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final value = _passwordController.text;
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'La contraseña es obligatoria';
      } else if (value.length < 8) {
        _passwordError = 'Mínimo 8 caracteres';
      } else if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
        _passwordError = 'Debe contener al menos una letra';
      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
        _passwordError = 'Debe contener al menos un número';
      } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\+=/\\]').hasMatch(value)) {
        _passwordError = 'Debe contener al menos un carácter especial (!@#\$%...)';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    final value = _confirmPasswordController.text;
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Confirma tu contraseña';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _validateAge() {
    final value = _ageController.text;
    final age = int.tryParse(value);
    setState(() {
      if (value.isEmpty) {
        _ageError = 'La edad es obligatoria';
      } else if (age == null || age < 1 || age > 120) {
        _ageError = 'Ingresa una edad válida (1-120)';
      } else {
        _ageError = null;
      }
    });
  }

  void _onSubmit() async {
    setState(() {
      _submitted = true;
      _termsError = !_acceptedTerms;
    });
    _validateName(); _validateEmail(); _validatePassword();
    _validateConfirmPassword(); _validateAge();
    if (!_isFormValid) return;

    final auth = context.read<AuthProvider>();
    // Paso 1: enviar código
    final result = await auth.sendVerificationCode(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      age: int.parse(_ageController.text),
      gender: _selectedGender,
    );

    if (!context.mounted) return;

    if (result['error'] != null) return; // auth.error ya tiene el mensaje

    // Guardar datos y mostrar pantalla de código
    _pendingRegistration = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'age': int.parse(_ageController.text),
      'gender': _selectedGender,
    };

    _showVerificationDialog();
  }

  void _showVerificationDialog() {
  final codeController = TextEditingController();
  final theme = Theme.of(context);

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verifica tu correo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enviamos un código de 6 dígitos a ${_pendingRegistration!['email']}',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Column(
                    children: [
                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  final ok = await auth.register(
                                    _pendingRegistration!['name'],
                                    _pendingRegistration!['email'],
                                    _pendingRegistration!['password'],
                                    _pendingRegistration!['age'],
                                    _pendingRegistration!['gender'],
                                    code: codeController.text,
                                  );
                                  if (ok && context.mounted) {
                                    Navigator.pop(context);
                                    context.go('/food-plan/create');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: auth.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Verificar y crear cuenta',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsModal() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Términos y condiciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _termSection(
                      theme,
                      '1. Aceptación de los términos',
                      'Al registrarte en Viannd, aceptas quedar vinculado por estos Términos y Condiciones. Si no estás de acuerdo con alguna parte de los términos, no podrás acceder al servicio.',
                    ),
                    _termSection(
                      theme,
                      '2. Uso del servicio',
                      'Viannd es una plataforma de seguimiento nutricional. Te comprometes a usar el servicio únicamente para fines legales y de manera que no infrinja los derechos de terceros ni restrinja su uso.',
                    ),
                    _termSection(
                      theme,
                      '3. Privacidad y datos personales',
                      'Recopilamos y procesamos tus datos personales conforme a nuestra Política de Privacidad. Al registrarte, consientes el tratamiento de tus datos para los fines descritos en dicha política.',
                    ),
                    _termSection(
                      theme,
                      '4. Responsabilidad',
                      'La información nutricional proporcionada por Viannd es de carácter orientativo y no sustituye el consejo de un profesional de la salud. No nos hacemos responsables de decisiones tomadas en base al contenido de la app.',
                    ),
                    _termSection(
                      theme,
                      '5. Cuenta de usuario',
                      'Eres responsable de mantener la confidencialidad de tu contraseña y de todas las actividades que ocurran bajo tu cuenta. Notifícanos inmediatamente ante cualquier uso no autorizado.',
                    ),
                    _termSection(
                      theme,
                      '6. Modificaciones',
                      'Nos reservamos el derecho de modificar estos términos en cualquier momento. Las modificaciones entrarán en vigor al publicarse en la aplicación. El uso continuado del servicio implica la aceptación de los nuevos términos.',
                    ),
                    _termSection(
                      theme,
                      '7. Contacto',
                      'Si tienes preguntas sobre estos Términos y Condiciones, puedes contactarnos en soporte@viannd.com.',
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _acceptedTerms = true;
                      _termsError = false;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Aceptar términos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termSection(ThemeData theme, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  InputDecoration _buildDecoration({
    required BuildContext context,
    required String hint,
    String? errorText,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = _submitted && errorText != null;

    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    );

    return InputDecoration(
      filled: true,
      fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
      errorText: hasError ? errorText : null,
      suffixIcon: suffixIcon,
      border: normalBorder,
      enabledBorder: hasError ? errorBorder : normalBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFF4CAF50),
          width: 2,
        ),
      ),
      errorBorder: errorBorder,
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => context.go('/'),
              child: Icon(Icons.arrow_back, size: 28, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text(
              'Registro',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Date de alta llenando los siguientes datos.',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            _label(context, 'Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: _buildDecoration(
                context: context,
                hint: 'hey@tuemail.com',
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 8),
            _label(context, 'Contraseña'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: _buildDecoration(
                context: context,
                hint: 'Introduce tu contraseña',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _label(context, 'Confirmar contraseña'),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: _buildDecoration(
                context: context,
                hint: 'Repite tu contraseña',
                errorText: _confirmPasswordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _label(context, 'Nombre'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 100,
              keyboardType: TextInputType.name,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.startsWith(' ')) return oldValue;
                  if (newValue.text.contains('  ')) return oldValue;
                  return newValue;
                }),
              ],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: _buildDecoration(
                context: context,
                hint: 'Andrea Cisneros',
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 8),
            _label(context, 'Edad'),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: _buildDecoration(
                context: context,
                hint: '18',
                errorText: _ageError,
              ),
            ),
            const SizedBox(height: 16),
            _label(context, 'Género'),
            const SizedBox(height: 8),
            Row(
              children: ['Mujer', 'Hombre', 'Otro'].map((g) {
                final selected = _selectedGender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = g),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF4CAF50)
                            : (isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white),
                        border: Border.all(
                          color: selected ? const Color(0xFF4CAF50) : theme.dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        g,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _acceptedTerms,
                    activeColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(
                      color: _termsError ? Colors.red : theme.dividerColor,
                      width: 1.5,
                    ),
                    onChanged: (val) => setState(() {
                      _acceptedTerms = val ?? false;
                      if (_acceptedTerms) _termsError = false;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'He leído y acepto los ',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showTermsModal,
                        child: const Text(
                          'Términos y condiciones',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_termsError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 34),
                child: Text(
                  'Debes aceptar los términos y condiciones',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            if (auth.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  disabledBackgroundColor: theme.disabledColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear cuenta',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => context.go('/login'),
                child: RichText(
                  text: TextSpan(
                    text: '¿Ya tienes cuenta? ',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
    );
  }
}