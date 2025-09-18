import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../i18n/strings.dart';
import '../../services/centralized_websocket_service.dart';
import '../../modals/language_modal.dart';

class WebCompanySelection extends StatefulWidget {
  const WebCompanySelection({super.key});

  @override
  State<WebCompanySelection> createState() => _WebCompanySelectionState();
}

class _WebCompanySelectionState extends State<WebCompanySelection> {
  bool _isLoading = true;
  String? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    
    // Escuchar cambios en los datos del WebSocket
    AppState.websocketStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadCompanies() async {
    // Conectar al WebSocket si no está conectado
    if (!CentralizedWebSocketService.isConnected) {
      await CentralizedWebSocketService.connect('WEB_KIOSCO_${DateTime.now().millisecondsSinceEpoch}');
    }
    
    // Solicitar datos del backend
    CentralizedWebSocketService.requestFullData();
    
    // Esperar a que se carguen los datos del backend
    int attempts = 0;
    while (AppState.companies.isEmpty && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    setState(() {
      _isLoading = false;
    });
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
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barra superior
              _buildTopBar(),
              // Contenido principal
              Expanded(
                child: _isLoading ? _buildLoadingState() : _buildCompanySelection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo
          Text(
            'MEYPARK',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          // Botón de idioma
          IconButton(
            onPressed: _showLanguageModal,
            icon: const Text('🌐', style: TextStyle(fontSize: 24)),
            tooltip: 'Cambiar idioma',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando empresas...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySelection() {
    if (AppState.companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay empresas disponibles',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica la conexión con el servidor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadCompanies();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Selecciona tu empresa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige la empresa para la que trabajas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          // Lista de empresas
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: AppState.companies.length,
              itemBuilder: (context, index) {
                final company = AppState.companies.values.elementAt(index);
                final isSelected = _selectedCompanyId == company.id;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCompanyId = company.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo de la empresa
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(int.parse(company.primaryColor.replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                company.name.substring(0, 1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Nombre de la empresa
                          Text(
                            company.name,
                            style: TextStyle(
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Botón continuar
          if (_selectedCompanyId != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _continueToZones,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _continueToZones() {
    if (_selectedCompanyId != null) {
      // Establecer la empresa actual
      final company = AppState.companies[_selectedCompanyId];
      if (company != null) {
        AppState.setCurrentCompany(company);
        // Ir a la pantalla de zonas
        context.go('/zona');
      }
    }
  }

  void _showLanguageModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const LanguageModal(),
      ),
    );
  }
}
