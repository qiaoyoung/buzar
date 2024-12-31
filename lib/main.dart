import 'package:flutter/material.dart';
import 'package:buzar/core/constants.dart';
import 'package:buzar/core/theme.dart';
import 'package:buzar/screens/screens.dart';
import 'package:buzar/screens/character_detail_screen.dart';
import 'package:buzar/models/character.dart';
import 'package:buzar/screens/network_error_screen.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NetworkCheckScreen(),
      routes: {
        '/character_detail': (context) => CharacterDetailScreen(
              character: ModalRoute.of(context)!.settings.arguments as Character,
            ),
      },
    );
  }
}

class NetworkCheckScreen extends StatefulWidget {
  const NetworkCheckScreen({super.key});

  @override
  State<NetworkCheckScreen> createState() => _NetworkCheckScreenState();
}

class _NetworkCheckScreenState extends State<NetworkCheckScreen> {
  bool _isLoading = true;
  bool _hasNetworkError = false;
  StreamSubscription? _connectivitySubscription;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        _checkNetwork();
      } else {
        setState(() {
          _isLoading = false;
          _hasNetworkError = true;
        });
      }

      // 监听网络状态变化
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none && !_hasNavigated) {
          _checkNetwork();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasNetworkError = true;
      });
    }
  }

  Future<void> _checkNetwork() async {
    if (_hasNavigated) return;

    setState(() {
      _isLoading = true;
      _hasNetworkError = false;
    });

    try {
      final urls = [
        'https://www.apple.com',
        'https://www.google.com',
        'https://www.microsoft.com'
      ];

      bool hasConnection = false;

      for (final url in urls) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 3));

          if (response.statusCode == 200) {
            hasConnection = true;
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (!mounted) return;

      if (hasConnection) {
        _hasNavigated = true;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _hasNetworkError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _hasNetworkError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Checking network connection...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasNetworkError) {
      return NetworkErrorScreen(onRetry: _checkNetwork);
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatHistoryScreen(),
    AssistantScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.assistant_outlined),
            selectedIcon: Icon(Icons.assistant),
            label: 'AI Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 