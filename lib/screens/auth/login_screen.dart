import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Limpiar error residual al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError(); 
    });

    // Limpiar error en tiempo real al escribir
    _emailController.addListener(_clearErrorOnType);       
    _passwordController.addListener(_clearErrorOnType);    
  }

  void _clearErrorOnType() {                              
    if (context.read<AuthProvider>().error != null) {
      context.read<AuthProvider>().clearError();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Inicio de sesión', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      text: 'Inicia sesión con tu cuenta de ',
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                      children: [TextSpan(text: 'Viannd.', style: TextStyle(fontWeight: FontWeight.bold))],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,        
                    enableSuggestions: false, 
                    decoration: InputDecoration(
                      hintText: 'hey@tuemail.com',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Introduce tu contraseña',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : () async {
                        final ok = await auth.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (ok && context.mounted) context.go('/home');
                        // Si ok == false, el error ya aparece en pantalla y NO navegamos
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Inicia sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/register'),
                      child: RichText(
                        text: const TextSpan(
                          text: '¿No tienes cuenta? ',
                          style: TextStyle(color: Colors.black87),
                          children: [TextSpan(text: 'Regístrate', style: TextStyle(fontWeight: FontWeight.bold))],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
