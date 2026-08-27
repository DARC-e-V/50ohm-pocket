import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:smart_calculator/smart_calculator.dart';
import 'package:smart_calculator/src/models/calculator_provider.dart';

const _piInput = '3.141592653589793';
const _eInput = '2.718281828459045';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkMode = theme.brightness == Brightness.dark;
    final calculatorTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: darkMode ? const Color(0xFF263238) : const Color(0xFFE1E8ED),
        onSurface: darkMode ? Colors.white : const Color(0xFF172126),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taschenrechner'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ChangeNotifierProvider(
            create: (_) => CalculatorProvider(
              allowedModes: const [CalculatorMode.scientific],
            ),
            child: Theme(
              data: calculatorTheme,
              child: const Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _CalculatorDisplay(),
                  ),
                  Expanded(
                    flex: 3,
                    child: _ScientificCalculatorKeypad(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorDisplay extends StatelessWidget {
  const _CalculatorDisplay();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.all(16),
      child: Consumer<CalculatorProvider>(
        builder: (context, provider, _) => FittedBox(
          alignment: Alignment.centerRight,
          fit: BoxFit.scaleDown,
          child: Text(
            provider.output
                .replaceAll(_piInput, 'π')
                .replaceAll(_eInput, 'e')
                .replaceAll('log(10,', 'log₁₀('),
            style: const TextStyle(fontSize: 34),
          ),
        ),
      ),
    );
  }
}

class _ScientificCalculatorKeypad extends StatelessWidget {
  const _ScientificCalculatorKeypad();

  static const rows = [
    ['sin', 'cos', 'tan', 'sqrt'],
    ['xʸ', 'π', 'log₁₀', 'e'],
    ['7', '8', '9', '(', ')'],
    ['4', '5', '6', '+', '-'],
    ['1', '2', '3', '/', '*'],
    ['.', '0', 'C', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalculatorProvider>();
    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final button in row)
                  Expanded(
                    flex: button == '=' ? 2 : 1,
                    child: _CalculatorButton(
                      label: button,
                      onPressed: () => provider.buttonPressed(
                        switch (button) {
                          'sin' => 'sin(',
                          'cos' => 'cos(',
                          'tan' => 'tan(',
                          'π' => _piInput,
                          'e' => _eInput,
                          'log₁₀' => 'log(10,',
                          'xʸ' => '^',
                          _ => button,
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CalculatorButton({
    required this.label,
    required this.onPressed,
  });

  String get _texLabel => switch (label) {
        'sin' => r'\sin(x)',
        'cos' => r'\cos(x)',
        'tan' => r'\tan(x)',
        'sqrt' => r'\sqrt{x}',
        'xʸ' => r'x^y',
        'π' => r'\pi',
        'log₁₀' => r'\log_{10}(x)',
        '*' => r'\times',
        '/' => r'\div',
        'C' => r'\mathrm{C}',
        _ => label,
      };

  String get _semanticLabel => switch (label) {
        'sin' => 'Sinus',
        'cos' => 'Kosinus',
        'tan' => 'Tangens',
        'sqrt' => 'Quadratwurzel',
        'xʸ' => 'Potenz',
        'π' => 'Pi',
        'log₁₀' => 'Zehnerlogarithmus',
        'e' => 'Eulersche Zahl',
        '*' => 'Mal',
        '/' => 'Geteilt',
        '-' => 'Minus',
        '+' => 'Plus',
        '=' => 'Ergebnis',
        'C' => 'Löschen',
        _ => label,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFunction = const {
      'sin',
      'cos',
      'tan',
      'sqrt',
      'xʸ',
      'π',
      'log₁₀',
      'e',
    }.contains(label);
    final isOperator = const {'/', '*', '-', '+', '(', ')'}.contains(label);

    final Color background;
    final Color foreground;
    if (label == '=') {
      background = colors.primary;
      foreground = colors.onPrimary;
    } else if (label == 'C') {
      background = colors.errorContainer;
      foreground = colors.onErrorContainer;
    } else if (isOperator) {
      background = colors.primaryContainer;
      foreground = colors.onPrimaryContainer;
    } else if (isFunction) {
      background = colors.secondaryContainer;
      foreground = colors.onSecondaryContainer;
    } else {
      background = colors.surface;
      foreground = colors.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.expand(
        child: MaterialButton(
          key: ValueKey('calculator-button-$label'),
          onPressed: onPressed,
          color: background,
          textColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Semantics(
            label: _semanticLabel,
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Math.tex(
                  _texLabel,
                  key: ValueKey('calculator-label-$label'),
                  mathStyle: MathStyle.text,
                  textStyle: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
