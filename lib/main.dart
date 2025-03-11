import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/app_state.dart';
import 'screens/main_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Definir a cor da barra de status para combinar com o tema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo cores personalizadas para o tema
    const primaryColor = Color(0xFF2E7D32); // Verde mais escuro
    const secondaryColor = Color(0xFF66BB6A); // Verde mais claro
    const backgroundColor = Color(0xFFF5F9F5); // Fundo levemente esverdeado
    const surfaceColor = Colors.white;
    const errorColor = Color(0xFFD32F2F);

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Gerenciador de Pelada',
        // Adicionar suporte para localização em português
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'), // Português do Brasil
        ],
        locale: const Locale('pt', 'BR'),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: primaryColor,
            onPrimary: Colors.white,
            secondary: secondaryColor,
            onSecondary: Colors.white,
            error: errorColor,
            onError: Colors.white,
            background: backgroundColor,
            onBackground: Colors.black87,
            surface: surfaceColor,
            onSurface: Colors.black87,
          ),
          // Estilo de texto para seguir as diretrizes da Apple
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
            displaySmall: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            titleMedium: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              letterSpacing: 0.15,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              letterSpacing: 0.25,
            ),
          ),
          // Estilo dos botões elevados
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          // Estilo dos botões de texto
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Estilo dos botões de contorno
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Estilo da AppBar
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: surfaceColor,
            foregroundColor: primaryColor,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: primaryColor),
          ),
          // Estilo dos cards
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            color: surfaceColor,
            shadowColor: Colors.black26,
          ),
          // Estilo dos inputs
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: TextStyle(color: Colors.grey.shade700),
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          // Estilo do Scaffold
          scaffoldBackgroundColor: backgroundColor,
          // Estilo dos chips
          chipTheme: ChipThemeData(
            backgroundColor: primaryColor.withOpacity(0.1),
            selectedColor: primaryColor,
            secondarySelectedColor: secondaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: const TextStyle(color: primaryColor),
            secondaryLabelStyle: const TextStyle(color: Colors.white),
            brightness: Brightness.light,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: primaryColor.withOpacity(0.2)),
            ),
          ),
          // Estilo dos diálogos
          dialogTheme: DialogTheme(
            backgroundColor: surfaceColor,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
