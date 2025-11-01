import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'models/note_item.dart';
import 'note_service.dart';
import 'note_list_page.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  await Hive.initFlutter();
  Hive.registerAdapter(NoteItemAdapter());

  const secureStorage = FlutterSecureStorage();
  String? encodedKey = await secureStorage.read(key: 'hive_key');

  if (encodedKey == null) {
    final newKey = Hive.generateSecureKey();
    encodedKey = base64UrlEncode(newKey);
    await secureStorage.write(key: 'hive_key', value: encodedKey);
  }

  final encryptionKey = base64Url.decode(encodedKey);

  await Hive.openBox<NoteItem>(NoteService.boxName, encryptionCipher: HiveAesCipher(encryptionKey));

  final noteService = NoteService();
  await noteService.init();

  runApp(MyApp(noteService: noteService, themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final NoteService noteService;
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.noteService, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: themeProvider), Provider.value(value: noteService)],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Wisdom Notes',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.themeMode == AppThemeMode.system
                    ? ThemeMode.system
                    : themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const NoteListPageWrapper(),
          );
        },
      ),
    );
  }
}

class NoteListPageWrapper extends StatelessWidget {
  const NoteListPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context, listen: false);
    return NoteListPage(noteService: noteService);
  }
}
