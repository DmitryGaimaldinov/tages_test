import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tages_test/repository/banknote_repository.dart';
import 'package:tages_test/home_page.dart';
import 'package:provider/provider.dart';

import 'bloc/home_bloc.dart';
import 'repository/memory_banknote_repository.dart';

void main() {
  runApp(const TagesApp());
}

class TagesApp extends StatelessWidget {
  const TagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<BanknoteRepository>(
      create: (_) => MemoryBanknoteRepository(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'SFProText',
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFE61EAD), primary: Color(0xFFE61EAD)),
          scaffoldBackgroundColor: Color(0xFF3827B4).withOpacity(0.06),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 42),
            ),
          ),
          textTheme: TextTheme(
            titleSmall: TextStyle(color: Color(0xFFA3A2AC), fontSize: 13),
          )
        ),
        initialRoute: '/tages-test',
        routes: {
          '/tages-test': (BuildContext _) => BlocProvider(
            create: (context) => HomeBloc(banknoteRepository: context.read<BanknoteRepository>()),
            child: HomePage()
          ),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


