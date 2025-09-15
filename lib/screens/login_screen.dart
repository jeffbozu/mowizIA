import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';
import '../data/mock_data.dart';
import '../data/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedOperator;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectOperator(String operatorId) {
    setState(() {
      _selectedOperator = operatorId;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  void _login() async {
    if (_selectedOperator == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simular delay de login
    await Future.delayed(const Duration(milliseconds: 500));

    final operator = MockData.validateCredentials(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (operator != null && operator.id == _selectedOperator) {
      AppState.setCurrentOperator(operator);
      if (mounted) {
        context.go('/zona');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Credenciales incorrectas'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Logo y título
            const SizedBox(height: 40),
            const Text(
              'MEYPARK',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE62144),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kiosco de Parquímetro',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF7F7F7F),
              ),
            ),
            const SizedBox(height: 40),

            // Selección de operador
            Text(
              AppStrings.t('login.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Tarjetas de operadores
            Row(
              children: [
                Expanded(
                  child: _buildOperatorCard('mowiz', 'MOWIZ'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOperatorCard('eypsa', 'EYPSA'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Formulario de login
            if (_selectedOperator != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Iniciar sesión como ${_selectedOperator!.toUpperCase()}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.t('login.username'),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: AppStrings.t('login.password'),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(AppStrings.t('login.submit')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),
            
            Text(
              'Hello MEYPARK - Etapa 3',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorCard(String operatorId, String name) {
    final isSelected = _selectedOperator == operatorId;
    
    return Card(
      elevation: isSelected ? 8 : 4,
      child: InkWell(
        onTap: () => _selectOperator(operatorId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                Icons.business,
                size: 48,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
