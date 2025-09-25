import 'package:flutter/material.dart';
import '../i18n/strings.dart';

class ProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;
  final Color? activeColor;
  final Color? completedColor;
  final Color? pendingColor;
  final Function(int)? onStepTap;

  const ProgressBar({
    super.key,
    required this.currentStep,
    this.stepLabels = const [
      'Zona',
      'Matrícula', 
      'Tiempo',
      'Pago',
      'Ticket'
    ],
    this.activeColor,
    this.completedColor,
    this.pendingColor,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColorFinal = activeColor ?? const Color(0xFFE62144);
    final completedColorFinal = completedColor ?? const Color(0xFF4CAF50);
    final pendingColorFinal = pendingColor ?? Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.98),
            Colors.white.withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: activeColorFinal.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de progreso principal
          _buildProgressBar(activeColorFinal, completedColorFinal, pendingColorFinal),
          const SizedBox(height: 16),
          // Etiquetas de pasos
          _buildStepLabels(activeColorFinal, completedColorFinal, pendingColorFinal),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color activeColor, Color completedColor, Color pendingColor) {
    return Row(
      children: List.generate(stepLabels.length, (index) {
        bool isActive = index == currentStep;
        bool isCompleted = index < currentStep;
        bool isPending = index > currentStep;
        
        return Expanded(
          child: GestureDetector(
            onTap: onStepTap != null ? () => onStepTap!(index) : null,
            child: Container(
              height: 6,
              margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 3),
              decoration: BoxDecoration(
                gradient: isActive 
                    ? LinearGradient(
                        colors: [
                          activeColor,
                          activeColor.withOpacity(0.8),
                          activeColor.withOpacity(0.6),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : isCompleted
                        ? LinearGradient(
                            colors: [
                              completedColor,
                              completedColor.withOpacity(0.9),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                color: isPending ? pendingColor : null,
                borderRadius: BorderRadius.circular(4),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ] : isCompleted ? [
                  BoxShadow(
                    color: completedColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepLabels(Color activeColor, Color completedColor, Color pendingColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stepLabels.length, (index) {
        bool isActive = index == currentStep;
        bool isCompleted = index < currentStep;
        bool isPending = index > currentStep;
        
        return Expanded(
          child: GestureDetector(
            onTap: onStepTap != null ? () => onStepTap!(index) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive 
                    ? activeColor.withOpacity(0.1)
                    : isCompleted
                        ? completedColor.withOpacity(0.1)
                        : Colors.transparent,
              ),
              child: Column(
                children: [
                  // Icono del paso
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: isActive 
                          ? LinearGradient(
                              colors: [activeColor, activeColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : isCompleted
                              ? LinearGradient(
                                  colors: [completedColor, completedColor.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                      color: isPending ? pendingColor : null,
                      shape: BoxShape.circle,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ] : isCompleted ? [
                        BoxShadow(
                          color: completedColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      _getStepIcon(index),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Texto del paso
                  Text(
                    stepLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isActive 
                          ? activeColor
                          : isCompleted
                              ? completedColor
                              : pendingColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0: return Icons.location_on; // Zona
      case 1: return Icons.directions_car; // Matrícula
      case 2: return Icons.access_time; // Tiempo
      case 3: return Icons.payment; // Pago
      case 4: return Icons.receipt; // Ticket
      default: return Icons.circle;
    }
  }
}
