import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';
import '../services/websocket_service.dart';

class PaymentScreen extends StatefulWidget {
  final bool isExtend;
  final int minutes;
  final double price;
  final String zoneId;
  final String plate;

  const PaymentScreen({
    super.key,
    required this.isExtend,
    required this.minutes,
    required this.price,
    required this.zoneId,
    required this.plate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'cash';
  double _insertedAmount = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Inicializar contexto de pago
    AppState.currentPayment = PaymentContext(
      isExtend: widget.isExtend,
      plate: widget.plate,
      zoneId: widget.zoneId,
      minutes: widget.minutes,
      price: widget.price,
      insertedAmount: _insertedAmount,
      paymentMethod: _paymentMethod,
    );
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _paymentMethod = method;
      AppState.currentPayment = AppState.currentPayment?.copyWith(
        paymentMethod: method,
      );
    });
  }

  void _insertCoin(double amount) {
    setState(() {
      _insertedAmount += amount;
      AppState.currentPayment = AppState.currentPayment?.copyWith(
        insertedAmount: _insertedAmount,
      );
    });
  }

  void _payNow() {
    if (_canPay()) {
      setState(() {
        _isProcessing = true;
      });

      // Simular procesamiento de pago
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          // Crear sesión si no es extensión
          if (!widget.isExtend) {
            final session = Session(
              plate: widget.plate,
              zoneId: widget.zoneId,
              start: DateTime.now(),
              end: DateTime.now().add(Duration(minutes: widget.minutes)),
              totalPrice: widget.price,
              paymentMethod: _paymentMethod,
            );
            MockData.addSession(session);
          }

          // Ir al ticket
          context.push('/ticket', extra: {
            'extend': widget.isExtend,
            'matricula': widget.plate,
            'zonaId': widget.zoneId,
            'minutos': widget.minutes,
            'precio': widget.price,
          });
        }
      });
    }
  }

  bool _canPay() {
    if (_paymentMethod == 'cash') {
      return _insertedAmount >= widget.price;
    } else {
      return true; // Chip+PIN y Contactless siempre pueden pagar
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
    final zone = MockData.getZoneById(widget.zoneId);

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: AppStrings.t('pay.title'),
            showBackButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Información del pago
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.isExtend
                              ? AppStrings.t('pay.extend_session')
                              : AppStrings.t('pay.new_parking'),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t('pay.zone'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              zone?.name ?? '',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t('pay.duration'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              _formatDuration(widget.minutes),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t('pay.total'),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.price.toStringAsFixed(2)} €',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Métodos de pago
                  Text(
                    AppStrings.t('pay.select_method'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentMethodCard(
                          'cash',
                          Icons.monetization_on,
                          AppStrings.t('pay.method.cash'),
                          _paymentMethod == 'cash',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentMethodCard(
                          'chip',
                          Icons.credit_card,
                          AppStrings.t('pay.method.chip'),
                          _paymentMethod == 'chip',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentMethodCard(
                          'contactless',
                          Icons.tap_and_play,
                          AppStrings.t('pay.method.contactless'),
                          _paymentMethod == 'contactless',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Insertar monedas (solo para pago en efectivo)
                  if (_paymentMethod == 'cash') ...[
                    Text(
                      AppStrings.t('pay.insert_coins'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botones de monedas
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildCoinButton(0.10, '10c'),
                        _buildCoinButton(0.20, '20c'),
                        _buildCoinButton(0.50, '50c'),
                        _buildCoinButton(1.00, '1€'),
                        _buildCoinButton(2.00, '2€'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Cantidad insertada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _insertedAmount >= widget.price 
                            ? Colors.green[100]
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: _insertedAmount >= widget.price 
                              ? Colors.green
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.t('pay.inserted'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${_insertedAmount.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _insertedAmount >= widget.price
                                  ? Colors.green[800]
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Información de estado
                    if (_insertedAmount < widget.price) ...[
                      Text(
                        AppStrings.t('pay.remaining') + ': ${(widget.price - _insertedAmount).toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ] else if (_insertedAmount == widget.price) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.t('pay.exact_amount'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.t('pay.excess_amount').replaceAll('{change}', (_insertedAmount - widget.price).toStringAsFixed(2)),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  const Spacer(),
                  // Botón de pago
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton(
                      onPressed: _canPay() && !_isProcessing ? _payNow : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _canPay() 
                            ? (_insertedAmount == widget.price 
                                ? Colors.green 
                                : (_insertedAmount > widget.price 
                                    ? Colors.orange 
                                    : null))
                            : null,
                        foregroundColor: _canPay() 
                            ? Colors.white 
                            : null,
                      ),
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(AppStrings.t('pay.authorizing')),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_canPay()) ...[
                                  Icon(
                                    _insertedAmount == widget.price 
                                        ? Icons.check_circle
                                        : (_insertedAmount > widget.price 
                                            ? Icons.warning 
                                            : Icons.payment),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  _isProcessing 
                                      ? AppStrings.t('pay.authorizing')
                                      : (_insertedAmount == widget.price 
                                          ? AppStrings.t('pay.pay_exact')
                                          : (_insertedAmount > widget.price 
                                              ? AppStrings.t('pay.pay_change')
                                              : AppStrings.t('pay.pay_now'))),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón cancelar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(AppStrings.t('pay.cancel')),
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

  Widget _buildPaymentMethodCard(String method, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinButton(double amount, String label) {
    // Deshabilitar botón si al insertar esta moneda se excedería el precio
    final wouldExceed = _insertedAmount + amount > widget.price;
    final isDisabled = wouldExceed || _insertedAmount >= widget.price;
    
    return ElevatedButton(
      onPressed: isDisabled ? null : () => _insertCoin(amount),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(80, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: isDisabled 
            ? Colors.grey[300] 
            : (_insertedAmount >= widget.price ? Colors.green[100] : null),
        foregroundColor: isDisabled 
            ? Colors.grey[600] 
            : (_insertedAmount >= widget.price ? Colors.green[800] : null),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey[600] : null,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: 12,
              color: isDisabled ? Colors.grey[600] : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}