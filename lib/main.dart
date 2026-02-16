import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LotSizeCalculatorApp());
}

class LotSizeCalculatorApp extends StatelessWidget {
  const LotSizeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forex Lot Size Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const LotSizeCalculatorScreen(),
    );
  }
}

class LotSizeCalculatorScreen extends StatefulWidget {
  const LotSizeCalculatorScreen({super.key});

  @override
  State<LotSizeCalculatorScreen> createState() =>
      _LotSizeCalculatorScreenState();
}

class _LotSizeCalculatorScreenState extends State<LotSizeCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountBalanceController = TextEditingController();
  final _riskPercentageController = TextEditingController();
  final _stopLossPipsController = TextEditingController();

  String _selectedCurrency = 'EUR/USD';
  String _accountCurrency = 'USD';

  double? _calculatedLotSize;
  double? _riskAmount;
  double? _positionValue;

  final List<String> _currencyPairs = [
    'EUR/USD',
    'GBP/USD',
    'USD/JPY',
    'USD/CHF',
    'AUD/USD',
    'USD/CAD',
    'NZD/USD',
    'EUR/GBP',
    'EUR/JPY',
    'GBP/JPY',
    'XAU/USD', 
    'XAG/USD', 
  ];

  final List<String> _accountCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'NZD',
  ];

  final Map<String, double> _pipValues = {
    'EUR/USD': 10.0,
    'GBP/USD': 10.0,
    'USD/JPY': 9.09,
    'USD/CHF': 10.0,
    'AUD/USD': 10.0,
    'USD/CAD': 9.09,
    'NZD/USD': 10.0,
    'EUR/GBP': 10.0,
    'EUR/JPY': 9.09,
    'GBP/JPY': 9.09,
    'XAU/USD': 1.0,   
    'XAG/USD': 0.01,  
  };

  @override
  void dispose() {
    _accountBalanceController.dispose();
    _riskPercentageController.dispose();
    _stopLossPipsController.dispose();
    super.dispose();
  }

  void _calculateLotSize() {
    if (_formKey.currentState!.validate()) {
      final accountBalance = double.parse(_accountBalanceController.text);
      final riskPercentage = double.parse(_riskPercentageController.text);
      final stopLossPips = double.parse(_stopLossPipsController.text);

      final riskAmount = accountBalance * (riskPercentage / 100);
      final pipValue = _pipValues[_selectedCurrency] ?? 10.0;
      final lotSize = riskAmount / (stopLossPips * pipValue);
      final positionValue = lotSize * 100000;

      setState(() {
        _calculatedLotSize = lotSize;
        _riskAmount = riskAmount;
        _positionValue = positionValue;
      });
    }
  }

  void _resetForm() {
    _accountBalanceController.clear();
    _riskPercentageController.clear();
    _stopLossPipsController.clear();

    setState(() {
      _calculatedLotSize = null;
      _riskAmount = null;
      _positionValue = null;
      _selectedCurrency = 'EUR/USD';
      _accountCurrency = 'USD';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forex Lot Size Calculator'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/trading.webp',
              fit: BoxFit.cover,
            ),
          ),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0), // Needed for BackdropFilter
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCard(
                      child: DropdownButtonFormField<String>(
                        value: _accountCurrency,
                        decoration: InputDecoration(
                          labelText: 'Account Currency',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.account_balance_wallet,
                              color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white70),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownColor: Colors.black87,
                        style: const TextStyle(color: Colors.white),
                        items: _accountCurrencies
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _accountCurrency = value!),
                      ),
                    ),
                    _buildTextField(
                      controller: _accountBalanceController,
                      label: 'Account Balance',
                      icon: Icons.attach_money,
                      suffix: _accountCurrency,
                    ),
                    _buildTextField(
                      controller: _riskPercentageController,
                      label: 'Risk Percentage',
                      icon: Icons.percent,
                      suffix: '%',
                    ),
                    _buildCard(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: InputDecoration(
                          labelText: 'Currency Pair',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.currency_exchange,
                              color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white70),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownColor: Colors.black87,
                        style: const TextStyle(color: Colors.white),
                        items: _currencyPairs
                            .map((pair) => DropdownMenuItem(
                                  value: pair,
                                  child: Text(pair),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCurrency = value!),
                      ),
                    ),
                    _buildTextField(
                      controller: _stopLossPipsController,
                      label: 'Stop Loss',
                      icon: Icons.show_chart,
                      suffix: 'pips',
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _calculateLotSize,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate Lot Size'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _resetForm,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    const SizedBox(height: 24),
                    if (_calculatedLotSize != null) _buildResults(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: Colors.black.withOpacity(0.35),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildResults() {
    return Card(
      color: Colors.black.withOpacity(0.35),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Results',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Lot Size', _calculatedLotSize!.toStringAsFixed(2),
                'lots'),
            _buildResultRow(
                'Risk Amount', _riskAmount!.toStringAsFixed(2), _accountCurrency),
            _buildResultRow('Position Value', _positionValue!.toStringAsFixed(2),
                'units'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            '$value $suffix',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
   