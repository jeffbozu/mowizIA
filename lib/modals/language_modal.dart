import 'dart:ui';
import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../services/local_storage_service.dart';

class LanguageModal extends StatefulWidget {
  const LanguageModal({super.key});

  @override
  State<LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<LanguageModal> {
  String _selectedLanguage = AppState.currentLanguage;
  
  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }
  
  void _loadSavedLanguage() async {
    try {
      // Cargar configuración guardada
      await LocalStorageService.loadConfig();
      
      // Actualizar el idioma seleccionado
      setState(() {
        _selectedLanguage = AppState.currentLanguage;
      });
      
      print('Idioma cargado: ${AppState.currentLanguage}');
    } catch (e) {
      print('Error al cargar idioma: $e');
    }
  }

  // Lista de idiomas con su información
  final List<Map<String, dynamic>> _languages = [
    // IDIOMAS REGIONALES DE ESPAÑA (PRIMERO)
    {
      'code': 'es-ES',
      'name': 'Español',
      'flag': '🇪🇸',
      'available': true,
      'category': 'regional',
    },
    {
      'code': 'ca-ES',
      'name': 'Catalán',
      'flag': '🏴',
      'available': true,
      'category': 'regional',
    },
    {
      'code': 'gl-ES',
      'name': 'Gallego',
      'flag': '🏴',
      'available': true,
      'category': 'regional',
    },
    {
      'code': 'eu-ES',
      'name': 'Euskera',
      'flag': '🏴',
      'available': true,
      'category': 'regional',
    },
    // IDIOMAS EUROPEOS (DESPUÉS)
    {
      'code': 'en',
      'name': 'Inglés',
      'flag': '🇬🇧',
      'available': true,
      'category': 'european',
    },
    {
      'code': 'fr-FR',
      'name': 'Francés',
      'flag': '🇫🇷',
      'available': true,
      'category': 'european',
    },
    {
      'code': 'de-DE',
      'name': 'Alemán',
      'flag': '🇩🇪',
      'available': true,
      'category': 'european',
    },
    {
      'code': 'it-IT',
      'name': 'Italiano',
      'flag': '🇮🇹',
      'available': true,
      'category': 'european',
    },
    {
      'code': 'pt-PT',
      'name': 'Portugués',
      'flag': '🇵🇹',
      'available': true,
      'category': 'european',
    },
  ];

  void _selectLanguage(String languageCode) {
    final language = _languages.firstWhere((lang) => lang['code'] == languageCode);
    
    // Lista de idiomas que realmente funcionan
    final workingLanguages = ['es-ES', 'en'];
    
    if (workingLanguages.contains(languageCode)) {
      setState(() {
        _selectedLanguage = languageCode;
      });
      
      // Solo actualizar la selección visual, no guardar aún
    } else {
      // Mostrar mensaje de "En desarrollo" dentro del modal
      _showDevelopmentMessage(language['name']);
    }
  }
  
  void _showDevelopmentMessage(String languageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.schedule,
                color: const Color(0xFFE62144),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.t('lang.modal.development'),
                style: const TextStyle(
                  color: Color(0xFFE62144),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            AppStrings.t('lang.modal.development.message', params: {'language': languageName}),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.t('lang.modal.understood'),
                style: const TextStyle(
                  color: Color(0xFFE62144),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _saveLanguageSelection(String languageCode) async {
    try {
      // Actualizar el estado global
      AppState.currentLanguage = languageCode;
      AppStrings.changeLanguage(languageCode);
      
      // Guardar en almacenamiento local
      await LocalStorageService.saveConfig();
      
      print('Idioma guardado: $languageCode');
    } catch (e) {
      print('Error al guardar idioma: $e');
    }
  }

  void _confirm() async {
    // Confirmar la selección del idioma
    _saveLanguageSelection(_selectedLanguage);
    
    // Notificar el cambio de idioma
    AppState.notifyLanguageChange(_selectedLanguage);
    
    Navigator.of(context).pop();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título optimizado
                Text(
                  AppStrings.t('lang.modal.title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE62144),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Grid de todos los idiomas
                _buildLanguageGrid(),
                const SizedBox(height: 32),
                
                // Botón confirmar con estilo glassmorphism
                _buildConfirmButton(),
                const SizedBox(height: 16),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildLanguageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final language = _languages[index];
        return _buildLanguageButton(language);
      },
    );
  }

  Widget _buildLanguageButton(Map<String, dynamic> language) {
    final isSelected = _selectedLanguage == language['code'];
    final isAvailable = language['available'] as bool;
    
    return GestureDetector(
      onTap: () => _selectLanguage(language['code']),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isAvailable ? Colors.white : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFE62144)
                : isAvailable 
                    ? Colors.grey.shade300
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? const Color(0xFFE62144).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.05),
              blurRadius: isSelected ? 6 : 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => _selectLanguage(language['code']),
            borderRadius: BorderRadius.circular(20),
            splashColor: isAvailable 
                ? const Color(0xFFE62144).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            highlightColor: isAvailable 
                ? const Color(0xFFE62144).withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bandera
                  Flexible(
                    child: Text(
                      language['flag'],
                      style: TextStyle(
                        fontSize: isAvailable ? 40 : 36,
                        color: isAvailable ? null : Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 1),
                  // Nombre del idioma
                  Flexible(
                    child: Text(
                      language['name'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isAvailable 
                            ? (isSelected ? const Color(0xFFE62144) : Colors.grey.shade700)
                            : Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 1),
                  // Estado
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFE62144),
                      size: 18,
                    )
                  else if (!isAvailable)
                    Icon(
                      Icons.schedule,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: 250,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE62144),
            Color(0xFFC41E3A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _confirm,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.4),
          highlightColor: Colors.white.withOpacity(0.2),
          onTapDown: (_) {
            // Efecto de sombra al presionar
            setState(() {});
          },
          onTapUp: (_) {
            // Restaurar sombra al soltar
            setState(() {});
          },
          onTapCancel: () {
            // Restaurar sombra al cancelar
            setState(() {});
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.t('lang.modal.confirm'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}