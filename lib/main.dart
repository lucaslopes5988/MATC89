import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividade Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Tela 1 — Login
// ---------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _obscureSenha = true;
  bool _loginOk = false;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  String? _validarUsuario(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe o usuário';
    if (t.length < 3) return 'Mínimo de 3 caracteres';
    return null;
  }

  String? _validarSenha(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Informe a senha';
    if (t.length < 4) return 'Mínimo de 4 caracteres';
    return null;
  }

  void _entrar() {
    setState(() => _loginOk = false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loginOk = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login confirmado! Redirecionando…'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ImcScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Entrar na conta',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use seus dados para acessar o app',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: scheme.primary.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _usuarioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validarUsuario,
                        onChanged: (_) => setState(() => _loginOk = false),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaCtrl,
                        obscureText: _obscureSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscureSenha ? 'Mostrar senha' : 'Ocultar senha',
                            onPressed: () {
                              setState(() => _obscureSenha = !_obscureSenha);
                            },
                            icon: Icon(
                              _obscureSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _entrar(),
                        validator: _validarSenha,
                        onChanged: (_) => setState(() => _loginOk = false),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _entrar,
                        icon: const Icon(Icons.login_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Login'),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _loginOk
                            ? Row(
                                key: const ValueKey('ok'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: scheme.tertiary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dados válidos — confirmação OK',
                                    style: TextStyle(
                                      color: scheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Tela 2 — IMC
// ---------------------------------------------------------------------------

class ImcScreen extends StatefulWidget {
  const ImcScreen({super.key});

  @override
  State<ImcScreen> createState() => _ImcScreenState();
}

class _ImcScreenState extends State<ImcScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();

  double? _imc;
  String? _classificacao;
  Color? _corClassificacao;

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    super.dispose();
  }

  String? _validarPeso(String? v) {
    final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
    if (n == null) return 'Informe um número válido';
    if (n <= 0) return 'Peso deve ser maior que zero';
    if (n > 500) return 'Peso fora do intervalo esperado';
    return null;
  }

  String? _validarAltura(String? v) {
    final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
    if (n == null) return 'Informe um número válido';
    if (n <= 0) return 'Altura deve ser maior que zero';
    if (n > 3) {
      return 'Use metros (ex.: 1,75)';
    }
    if (n < 0.5) return 'Altura muito baixa — verifique o valor';
    return null;
  }


  double _alturaEmMetros(double bruto) {
    if (bruto > 3) return bruto / 100;
    return bruto;
  }

  ({String label, Color color}) _classificar(double imc) {
    if (imc < 18.5) {
      return (label: 'Magreza', color: const Color(0xFF1E88E5));
    }
    if (imc < 25) {
      return (label: 'Peso normal', color: const Color(0xFF2E7D32));
    }
    if (imc < 30) {
      return (label: 'Sobrepeso', color: const Color(0xFFF9A825));
    }
    if (imc < 35) {
      return (label: 'Obesidade grau I', color: const Color(0xFFEF6C00));
    }
    if (imc < 40) {
      return (label: 'Obesidade grau II', color: const Color(0xFFC62828));
    }
    return (label: 'Obesidade grau III', color: const Color(0xFF4A148C));
  }

  void _calcular() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final peso = double.parse(_pesoCtrl.text.replaceAll(',', '.'));
    final alturaBruta = double.parse(_alturaCtrl.text.replaceAll(',', '.'));
    final altura = _alturaEmMetros(alturaBruta);
    final imc = peso / (altura * altura);
    final c = _classificar(imc);

    setState(() {
      _imc = imc;
      _classificacao = c.label;
      _corClassificacao = c.color;
    });
  }

  void _limpar() {
    _formKey.currentState?.reset();
    _pesoCtrl.clear();
    _alturaCtrl.clear();
    setState(() {
      _imc = null;
      _classificacao = null;
      _corClassificacao = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de IMC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: scheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 72,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Informe peso (kg) e altura (m ou cm)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.scale_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validarPeso,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alturaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Altura (m ou cm)',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                  helperText: 'Ex.: 1,75',
                ),
                validator: _validarAltura,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _calcular,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calcular'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _limpar,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpar'),
                  ),
                ],
              ),
              if (_imc != null && _classificacao != null && _corClassificacao != null) ...[
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _corClassificacao!.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _corClassificacao!, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IMC: ${_imc!.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _corClassificacao,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Classificação: $_classificacao',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _corClassificacao,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
