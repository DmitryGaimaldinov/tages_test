import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tages_test/bloc/home_bloc.dart';
import 'package:tages_test/bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _textController;
  String _text = '';

  bool get _canWithdraw => _text.isNotEmpty;

  @override
  void initState() {
    _textController = TextEditingController()
      ..addListener(() {
        setState(() {
          _text = _textController.text;
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isPortrait = constraints.maxWidth < 768;
      final isLandscape = !isPortrait;

      return Scaffold(
        appBar: AppBar(
          elevation: 8,
          shadowColor: Color(0xFF170F50).withOpacity(0.34),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                  onPressed: () {
                    _textController.text = '';
                    context.read<HomeBloc>().refresh();
                  },
                  icon: Icon(Icons.refresh, color: Colors.white)),
            )
          ],
          title: Row(
            children: [
              Image.asset('assets/logo.png'),
              SizedBox(width: 4),
              Text(
                'ATM',
                style: TextStyle(color: Colors.white, fontFamily: 'Trebuchemts'),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.topRight, colors: [Color(0xFF3827B4), Color(0xFF6C18A4)]),
            ),
          ),
        ),
        backgroundColor: isLandscape ? Colors.white : null,
        body: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
          return switch (state) {
            HomeStateInitializing() => const Center(child: CircularProgressIndicator()),
            HomeStateLoaded(:final limits, :final withdrawnBanknotes, :final errorText) => Column(
                children: [
                  _buildTopImageContainer(child: isPortrait ? _buildInputTile() : null),
                  Expanded(
                      child: CustomScrollView(
                    scrollDirection: Axis.vertical,
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Row(
                          children: [
                            if (isPortrait)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildWithdrawButton(),
                                    SizedBox(height: 10),
                                    _buildWithdrawTile(errorText, withdrawnBanknotes),
                                    SizedBox(height: 10),
                                    _buildLimitsTile(limits),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            if (isLandscape) ...[
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildInputTile(color: Theme.of(context).colorScheme.primary),
                                      SizedBox(height: 24),
                                      _buildWithdrawButton(),
                                    ],
                                  ),
                                ),
                              ),
                              VerticalDivider(),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildWithdrawTile(errorText, withdrawnBanknotes),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Divider(),
                                    ),
                                    _buildLimitsTile(limits),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  )),
                  Image.asset('assets/bottom.jpg', fit: BoxFit.fill, width: double.infinity, height: 105),
                ],
              ),
          };
        }),
      );
    });
  }

  Expanded _buildLimitsTile(Map<int, int> limits) {
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 135),
        child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 14, right: 21, left: 21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Баланс банкомата',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 15),
                _buildLimits(limits),
              ],
            )),
      ),
    );
  }

  Expanded _buildWithdrawTile(String? errorText, Map<int, int>? withdrawnBanknotes) {
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 135),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 14, right: 21, left: 21),
          child: Builder(
            builder: (_) {
              if (errorText != null) {
                return _buildErrorText(errorText);
              }

              if (withdrawnBanknotes != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Банкомат выдал следующие купюры',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 15),
                    _buildWithdrawnBanknotes(withdrawnBanknotes),
                  ],
                );
              }

              return SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Container _buildTopImageContainer({Widget? child}) {
    return Container(
      height: 175,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/top.png'))),
      child: child,
    );
  }

  Widget _buildInputTile({Color color = Colors.white}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 26),
        Text(
          'Введите сумму',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        SizedBox(height: 5),
        _buildTextField(color: color),
      ],
    );
  }

  Widget _buildWithdrawButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 24, bottom: 26),
      child: Center(
        child: FilledButton(
          onPressed: _canWithdraw
              ? () {
                  context.read<HomeBloc>().withdrawMoney(int.parse(_text));
                }
              : null,
          child: Text('Выдать сумму', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  ConstrainedBox _buildTextField({Color color = Colors.white}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 48,
      ),
      child: IntrinsicWidth(
        child: TextField(
          autofocus: true,
          controller: _textController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          cursorColor: color,
          style: TextStyle(color: color, fontSize: 30),
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: EdgeInsets.zero,
            hintText: '...',
            hintStyle: TextStyle(color: color),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
            suffixIcon: Text(' руб', style: TextStyle(color: color, fontSize: 30)),
          ),
        ),
      ),
    );
  }

  Center _buildErrorText(String errorText) {
    return Center(
      child: Text(errorText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        )),
    );
  }

  Widget _buildLimits(Map<int, int> limits) {
    return Row(
      children: [
        Expanded(
            child: Wrap(
          direction: Axis.vertical,
          spacing: 6,
          children: [
            _buildBanknoteText(banknote: 100, count: limits[100]!),
            _buildBanknoteText(banknote: 200, count: limits[200]!),
            _buildBanknoteText(banknote: 2000, count: limits[2000]!),
          ],
        )),
        Expanded(
            child: Wrap(
          direction: Axis.vertical,
          spacing: 6,
          children: [
            _buildBanknoteText(banknote: 500, count: limits[500]!),
            _buildBanknoteText(banknote: 1000, count: limits[1000]!),
            _buildBanknoteText(banknote: 5000, count: limits[5000]!),
          ],
        )),
      ],
    );
  }

  Widget _buildBanknoteText({required int banknote, required int count}) {
    return Text.rich(TextSpan(style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF3827B4)), children: [
      TextSpan(text: '$count', style: TextStyle(color: count > 0 ? Color(0xFF3827B4) : Colors.red)),
      TextSpan(text: ' X '),
      TextSpan(text: '$banknote')
    ]));
  }

  Widget _buildWithdrawnBanknotes(Map<int, int> withdrawnBanknotes) {
    final entries = withdrawnBanknotes.entries;

    return Row(
      children: [
        Expanded(
            child: Wrap(
          direction: Axis.vertical,
          spacing: 6,
          children: entries
              .take(math.min(3, entries.length))
              .map((entry) => _buildBanknoteText(banknote: entry.key, count: entry.value))
              .toList(),
        )),
        if (entries.length > 3)
          Expanded(
              child: Wrap(
            direction: Axis.vertical,
            spacing: 6,
            children: entries
                .toList()
                .sublist(0, entries.length - 3)
                .take(entries.length - 3)
                .map((e) => _buildBanknoteText(banknote: e.key, count: e.value))
                .toList(),
          )),
      ],
    );
  }
}
