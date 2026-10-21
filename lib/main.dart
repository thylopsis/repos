import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import para widgets Cupertino

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _controller;
  bool _useCupertino = false; // Controla SOLO el estilo de la alerta

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

  // Función que muestra Material o Cupertino según el switch
  void _showTestDialog() {
    if (_useCupertino) {
      // ALERTA ESTILO CUPERTINO
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Prueba'),
            content: const Text('Este es un mensaje de prueba.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // ALERTA ESTILO MATERIAL
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Prueba'),
            content: const Text('Este es un mensaje de prueba.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
      appBar: AppBar(title: const Text('Mi App'), backgroundColor: Colors.blue),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Imagen rotando con texto "Kuru Kuru" encima (estático)
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
                  // Texto NO gira porque está fuera del RotationTransition
                  const Text(
                    'Kuru Kuru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(
                        253,
                        170,
                        140,
                        96,
                      ), // Vainilla / beige
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 2. Contador (En medio)
              Text('Count: $_count', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Text('+1'),
              ),
              const SizedBox(height: 30),

              // 3. TextField, Botón Prueba, Switch (Debajo del contador)
              _buildControlsSection(),
              const SizedBox(height: 40),

              // 4. Internet Gratis Section
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
        // TextField pequeño y centrado
        SizedBox(
          width: 220, // Ancho fijo pequeño
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

        // Botón de prueba
        ElevatedButton(
          onPressed: _showTestDialog,
          child: const Text('Botón de Prueba'),
        ),
        const SizedBox(height: 15),

        // Switch para cambiar entre Material y Cupertino
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
