import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fn_express/fn_express.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const FnExpressDemoApp());

class FnExpressDemoApp extends StatelessWidget {
  const FnExpressDemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fn Express Demo',
    theme: ThemeData.from(
      useMaterial3: false,
      colorScheme: ColorScheme.dark(primary: Colors.orange),
      textTheme: GoogleFonts.firaCodeTextTheme(),
    ),
    home: const FnExpressReplPage(),
  );
}

class FnExpressReplPage extends StatefulWidget {
  const FnExpressReplPage({super.key});

  @override
  State<FnExpressReplPage> createState() => _FnExpressReplPageState();
}

class _FnExpressReplPageState extends State<FnExpressReplPage> {
  late final Repl _repl;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<String> _outputLines = [];

  @override
  void initState() {
    super.initState();

    _repl = Repl((value, {bool newline = true}) {
      setState(() {
        if (newline) {
          _outputLines.add(value);
        } else {
          if (_outputLines.isEmpty) {
            _outputLines.add(value);
          } else {
            _outputLines[_outputLines.length - 1] += value;
          }
        }
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: const Text('Fn Express REPL'),
      actions: [
        IconButton(
          tooltip: 'Clear Screen',
          icon: const Icon(Icons.cancel_presentation_rounded),
          onPressed: () {
            setState(_outputLines.clear);
            _inputFocusNode.requestFocus();
          },
        ),
        IconButton(
          tooltip: 'Help',
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () {
            _repl('help');
            _inputFocusNode.requestFocus();
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _outputLines.length,
              itemBuilder: (context, index) {
                final line = _outputLines[index];
                return Text(
                  line,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFA500),
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Color(0xFFffcc80),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  style: const TextStyle(
                    color: Color(0xFFFFA500),
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Color(0xFFffcc80),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  cursorColor: Color(0xFFFFA500),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black,
                    hintText: 'Enter expression or command...',
                    hintStyle: const TextStyle(color: Color(0xFFffcc80)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFA500),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFA500),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFA500),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  onSubmitted: (_) => _submitInput(),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _submitInput,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA500),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _submitInput() {
    _outputLines.add('>> ${_inputController.text}');
    _repl(_inputController.text);
    _inputController.clear();
    _inputFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
