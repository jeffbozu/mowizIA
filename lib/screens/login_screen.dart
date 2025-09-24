import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../widgets/top_bar.dart';
import '../services/local_storage_service.dart';
import '../services/websocket_service.dart';

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

  @override
  void initState() {
    super.initState();
    // Enviar datos de pantalla al dashboard
    WebSocketService.sendScreenUpdate('login', user: 'Sin usuario', action: 'Pantalla de login cargada');
    
    // Añadir listeners para los efectos de foco
    _usernameFocus.addListener(() {
      setState(() {});
    });
    _passwordFocus.addListener(() {
      setState(() {});
    });
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
        (op) => op.username == username && op.password == password,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingrese usuario y contraseña'),
          backgroundColor: Colors.red.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingrese el nombre de usuario'),
          backgroundColor: Colors.orange.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingrese la contraseña'),
          backgroundColor: Colors.orange.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
      
      // Guardar configuración
      await LocalStorageService.saveConfig();
      
      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.t('login.welcome')} ${operator.name}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navegar después de un breve delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
    } else {
      // Credenciales inválidas
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('login.error')),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
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
    return StreamBuilder<void>(
      stream: AppState.accessibilityStream,
      builder: (context, snapshot) {
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente blanco, gris y metal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                  Colors.grey.shade200,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          
          // Capa de efecto vidrio global
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo con efecto vidrio intensificado
                      _buildIntenseGlassLogo(),
                      const SizedBox(height: 40),
                      
                      // Título con efecto vidrio
                      _buildGlassTitle(),
                      const SizedBox(height: 16),
                      
                      // Subtítulo con efecto vidrio
                      _buildGlassSubtitle(),
                      const SizedBox(height: 60),
                      
                      // Formulario de login con efecto vidrio intensificado
                      _buildIntenseGlassLoginForm(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntenseGlassLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        // FONDO TRANSPARENTE
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(70),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 2,
        ),
        // SIN SOMBRAS
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(70),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.4),  // Más transparente
                  Colors.white.withOpacity(0.1),  // Más transparente
                  Colors.white.withOpacity(0.2),  // Efecto 3D
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              // EFECTO 3D
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(-3, -3),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(3, 3),
                  spreadRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.circular(70),
            ),
            child: const Icon(
              Icons.local_parking,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        // GRADIENTE METAL BRILLANTE MÁXIMO
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),  // Color puro máximo
            const Color(0xFFE62144),  // Color puro máximo
            const Color(0xFFE62144),  // Color puro máximo
            const Color(0xFFE62144),  // Color puro máximo
            const Color(0xFFE62144),  // Color puro máximo
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        // SIN SOMBRAS - SOLO COLOR BRILLANTE
        // boxShadow: [], // Sin sombras
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'MEYPARK',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3.0,
              // EFECTO 3D CON MÚLTIPLES SOMBRAS
              // SIN SOMBRAS EN EL TEXTO - SOLO COLOR BRILLANTE
              // shadows: [], // Sin sombras en el texto
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildGlassSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        // GRADIENTE METAL BRILLANTE MÁXIMO
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),  // Color puro máximo
            const Color(0xFFE62144),  // Color puro máximo
            const Color(0xFFE62144),  // Color puro máximo
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        // SIN SOMBRAS - SOLO COLOR BRILLANTE
        // boxShadow: [], // Sin sombras
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Text(
            AppStrings.t('login.subtitle'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              // SIN SOMBRAS EN EL TEXTO - SOLO COLOR BRILLANTE
              // shadows: [], // Sin sombras en el texto
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildIntenseGlassLoginForm() {
    return Container(
      decoration: BoxDecoration(
        // GRADIENTE GLASSMORPHISM MÁS OSCURO
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.6),  // Más opaco
            Colors.white.withOpacity(0.3),  // Más opaco
            Colors.white.withOpacity(0.4),  // Más opaco
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),  // Borde más visible
          width: 2,
        ),
        // SOMBRAS GLASSMORPHISM MÁS INTENSAS
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),  // Más intensa
            blurRadius: 35,  // Más difusa
            offset: const Offset(0, 18),
            spreadRadius: 8,  // Más extendida
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),  // Más intensa
            blurRadius: 50,  // Más difusa
            offset: const Offset(0, 25),
            spreadRadius: 15,  // Más extendida
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),  // Más blur
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Campo de usuario con efecto vidrio intensificado
                _buildIntenseGlassTextField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  labelText: AppStrings.t('login.username'),
                  icon: Icons.person,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) {
                    _passwordFocus.requestFocus();
                  },
                ),
                const SizedBox(height: 20),
                
                // Campo de contraseña con efecto vidrio intensificado
                _buildIntenseGlassTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  labelText: AppStrings.t('login.password'),
                  icon: Icons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 32),
                
                // Botón de login con efecto vidrio intensificado y hover
                _buildIntenseGlassButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntenseGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required FocusNode focusNode,
    bool obscureText = false,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focusNode.hasFocus 
            ? const Color(0xFFE62144)  // Color corporativo puro y brillante
            : Colors.white.withOpacity(0.8),  // Borde blanco por defecto
          width: focusNode.hasFocus ? 3 : 2,
        ),
        // SIN SOMBRAS - SOLO COLOR BRILLANTE
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: MouseRegion(
            cursor: SystemMouseCursors.text,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: const TextStyle(
                  color: Color(0xFFE62144),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                floatingLabelStyle: const TextStyle(
                  color: Color(0xFFE62144),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    color: focusNode.hasFocus
                      ? const Color(0xFFE62144)  // Color corporativo puro y brillante
                      : const Color(0xFFE62144).withOpacity(0.8),  // Más brillante por defecto
                    size: focusNode.hasFocus ? 26 : 24,
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                hintText: labelText,
                hintStyle: TextStyle(
                  color: const Color(0xFFE62144).withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              onTap: () {
                setState(() {});
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntenseGlassButton() {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE62144),
              const Color(0xFFE62144),
              const Color(0xFFE62144),
              const Color(0xFFE62144),
            ],
            stops: const [0.0, 0.25, 0.75, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2,
          ),
          // SIN SOMBRAS - SOLO COLOR BRILLANTE
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: _isLoading ? null : _login,
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.5),
                highlightColor: Colors.white.withOpacity(0.4),
                hoverColor: Colors.white.withOpacity(0.2),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()..scale(1.05),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            child: Text(AppStrings.t('login.submit')),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
  }


}