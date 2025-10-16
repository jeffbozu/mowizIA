import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../services/local_storage_service.dart';
import '../services/websocket_service.dart';
import '../services/centralized_websocket_service.dart';

class LoginScreenClean extends StatefulWidget {
  const LoginScreenClean({super.key});

  @override
  State<LoginScreenClean> createState() => _LoginScreenCleanState();
}

class _LoginScreenCleanState extends State<LoginScreenClean> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Enviar datos de pantalla al dashboard
    WebSocketService.sendScreenUpdate('login', user: 'Sin usuario', action: 'Pantalla de login cargada');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // Obtener operador por credenciales
  Operator? getOperatorByCredentials(String username, String password) {
    try {
      return AppState.operators.values.firstWhere(
        (op) => op.username == username && op.passwordHash == password,
      );
    } catch (e) {
      return null;
    }
  }

  void _login() async {
    // Enviar datos de pantalla al dashboard
    WebSocketService.sendScreenUpdate('login', 
      user: _usernameController.text.isNotEmpty ? _usernameController.text : 'Sin usuario',
      action: 'Intentando iniciar sesión'
    );
    
    // Validación mejorada con mensajes específicos
    if (_usernameController.text.isEmpty && _passwordController.text.isEmpty) {
      _showSnackBar('Por favor, ingrese usuario y contraseña', Colors.red);
      return;
    }
    
    if (_usernameController.text.isEmpty) {
      _showSnackBar('Por favor, ingrese el nombre de usuario', Colors.orange);
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Por favor, ingrese la contraseña', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular delay de login
    await Future.delayed(const Duration(seconds: 1));

    final operator = getOperatorByCredentials(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (operator != null) {
      // Login exitoso
      AppState.currentOperatorId = operator.id;
      
      // Establecer la empresa del operador
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
      
      // Guardar configuración
      await LocalStorageService.saveConfig();
      
      if (mounted) {
        // Mostrar mensaje de éxito con datos cargados
        _showSnackBar('${AppStrings.t('login.welcome')} ${operator.name}! Zonas cargadas: ${zones.length}', Colors.green);
        
        // Navegar después de un breve delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
    } else {
      // Credenciales inválidas
      if (mounted) {
        _showSnackBar(AppStrings.t('login.error'), Theme.of(context).colorScheme.error);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                  const SizedBox(height: 40),
                  
                  // Logo optimizado
                  _buildOptimizedLogo(),
                  const SizedBox(height: 40),
                  
                  // Título optimizado
                  _buildOptimizedTitle(),
                  const SizedBox(height: 16),
                  
                  // Subtítulo optimizado
                  _buildOptimizedSubtitle(),
                  const SizedBox(height: 60),
                  
                  // Formulario de login optimizado
                  _buildOptimizedLoginForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedLogo() {
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

  Widget _buildOptimizedTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),
            const Color(0xFFE62144).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'Iniciar Sesión',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 3.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptimizedSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144).withOpacity(0.9),
            const Color(0xFFE62144).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        'Ingrese sus credenciales para continuar',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptimizedLoginForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE62144).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Campo Usuario
          _buildOptimizedTextField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            label: 'Usuario',
            icon: Icons.person,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 24),
          
          // Campo Contraseña
          _buildOptimizedTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'Contraseña',
            icon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFFE62144),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Botón Login
          _buildOptimizedLoginButton(),
        ],
      ),
    );
  }

  Widget _buildOptimizedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: focusNode.hasFocus 
              ? const Color(0xFFE62144) 
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: focusNode.hasFocus ? [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus 
                ? const Color(0xFFE62144) 
                : Colors.grey.shade600,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          labelStyle: TextStyle(
            color: focusNode.hasFocus 
                ? const Color(0xFFE62144) 
                : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedLoginButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),
            const Color(0xFFE62144).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _login,
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
