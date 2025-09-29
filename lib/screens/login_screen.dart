import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../services/local_storage_service.dart';
import '../services/websocket_service.dart';
import '../services/centralized_websocket_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    WebSocketService.sendScreenUpdate('login', user: 'Sin usuario', action: 'Pantalla de login cargada');
    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Operator? getOperatorByCredentials(String username, String password) {
    try {
      return AppState.operators.values.firstWhere(
        (op) => op.username == username && op.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular delay de autenticación
    await Future.delayed(const Duration(milliseconds: 800));

    final operator = getOperatorByCredentials(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (operator != null) {
      AppState.currentOperatorId = operator.id;
      final operatorCompany = operator.companyId;
      if (AppState.companies.containsKey(operatorCompany)) {
        AppState.setCurrentCompany(AppState.companies[operatorCompany]!);
      }

      // 🔄 CARGAR DATOS DEL BACKEND DESPUÉS DEL LOGIN
      print('🔄 Cargando datos del backend para empresa: ${operatorCompany}');
      
      // Solicitar datos completos del backend
      CentralizedWebSocketService.sendMessage({
        'type': 'get_data',
        'company_id': operatorCompany,
      });
      
      // Esperar a que lleguen los datos del backend
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Verificar que se cargaron las zonas
      final zones = AppState.getZonesForCompany(operatorCompany);
      print('📍 Zonas cargadas: ${zones.length}');
      zones.forEach((zone) {
        print('  - ${zone.name}: ${zone.pricePerHour}€/h');
      });

      await LocalStorageService.saveConfig();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.t('login.welcome')} ${operator.name}! Zonas cargadas: ${zones.length}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildSubtitle(),
                  const SizedBox(height: 60),
                  _buildLoginForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),
            const Color(0xFFE62144).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_parking,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'MEYPARK',
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFFE62144),
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Sistema de Gestión de Parquímetros',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Iniciar Sesión',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE62144),
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            label: 'Usuario',
            icon: Icons.person,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'Contraseña',
            icon: Icons.lock,
            keyboardType: TextInputType.text,
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE62144),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Iniciar Sesión',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCredentialHints(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final isFocused = focusNode.hasFocus;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFFE62144) : Colors.grey.shade300,
          width: isFocused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: isFocused ? const Color(0xFFE62144) : Colors.grey.shade600),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: isFocused ? const Color(0xFFE62144) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialHints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credenciales de Prueba:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MOWIZ: mowiz_admin / Mo2025!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            'EYPSA: eysa_admin / Ey2025!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}