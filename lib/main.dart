import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bcrypt/bcrypt.dart'; // Ensure this is in pubspec.yaml

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthenticationGate(),
    );
  }
}

// --- Authentication Gate ---

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({Key? key}) : super(key: key);

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate> {
  bool _isLoggedIn = false;

  void _loginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return MyHomePage(onLogout: _logout);
    } else {
      return LoginScreen(onLoginSuccess: _loginSuccess);
    }
  }
}

// --- Login Screen ---

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true; // Controls the eye icon
  String? _errorMessage;

  // Simulated Database: username -> bcrypt_hash
  Map<String, String> _usersDb = {};

  @override
  void initState() {
    super.initState();
    // Create a default user: admin / 123456
    const defaultUser = "admin";
    const defaultPass = "123456";
    final hashedPassword = BCrypt.hashpw(defaultPass, BCrypt.gensalt());
    _usersDb = {defaultUser: hashedPassword};

    // Encryption check (debug console only):
    // a valid bcrypt hash has 60 chars and starts with $2a$10$ (or $2b$10$)
    if (kDebugMode) {
      debugPrint('Hash bcrypt: $hashedPassword');
      debugPrint('Longitud: ${hashedPassword.length} (esperado: 60)');
      debugPrint(
        'checkpw correcto: ${BCrypt.checkpw(defaultPass, hashedPassword)} (esperado: true)',
      );
      debugPrint(
        'checkpw incorrecto: ${BCrypt.checkpw("otra", hashedPassword)} (esperado: false)',
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_usersDb.containsKey(username)) {
      final storedHash = _usersDb[username]!;
      if (BCrypt.checkpw(password, storedHash)) {
        widget.onLoginSuccess();
        return;
      } else {
        _errorMessage = "Contraseña incorrecta";
      }
    } else {
      _errorMessage = "Usuario no encontrado";
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo: viviana.png
                Image.asset(
                  'assets/img/viviana.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Small, centered text boxes
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _usernameController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese su usuario'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      // Eye icon to show/hide password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese su contraseña'
                        : null,
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: 260,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: const Text('Entrar'),
                        ),
                      ),

                const SizedBox(height: 20),
                const Text(
                  'Demo: admin / 123456',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// --- Main Home Page (Original Code with Logout) ---

class MyHomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const MyHomePage({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _controller;
  bool _useCupertino = false;

  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _count++;
    });
  }

  void _showTestDialog() {
    if (_useCupertino) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Prueba'),
            content: const Text('Este es un mensaje de prueba.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Prueba'),
            content: const Text('Este es un mensaje de prueba.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToInternetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InternetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi App'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout, // Logout button
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _controller,
                    child: Image.asset(
                      'assets/img/viviana.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    'Kuru Kuru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(253, 170, 140, 96),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text('Count: $_count', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Text('+1'),
              ),
              const SizedBox(height: 30),
              _buildControlsSection(),
              const SizedBox(height: 40),
              const Text(
                'Da click aquí para obtener internet gratis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _navigateToInternetPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Internet Gratis'),
              ),
              const SizedBox(height: 20),
              const Text('BOTTOM TEXT'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Usuario',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: _showTestDialog,
          child: const Text('Botón de Prueba'),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Material: '),
            Switch(
              value: _useCupertino,
              onChanged: (bool value) {
                setState(() {
                  _useCupertino = value;
                });
              },
            ),
            const Text(' Cupertino'),
          ],
        ),
      ],
    );
  }
}

class InternetPage extends StatefulWidget {
  const InternetPage({Key? key}) : super(key: key);

  @override
  State<InternetPage> createState() => _InternetPageState();
}

class _InternetPageState extends State<InternetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Gratis'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pagar linea telefonica',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            RotationTransition(
              turns: _controller,
              child: Image.asset(
                'assets/img/viviana.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
