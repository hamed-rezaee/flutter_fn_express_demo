import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fn_express/fn_express.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const FnExpressDemoApp());

class TerminalLine {
  final String content;
  final bool isOutput;

  TerminalLine(this.content, {this.isOutput = false});
}

class FnExpressDemoApp extends StatelessWidget {
  const FnExpressDemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fn Express Demo ver 2.1.0',
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
  final List<TerminalLine> _terminalLines = [];

  @override
  void initState() {
    super.initState();

    _repl = Repl((value, {bool newline = true}) {
      setState(() {
        if (newline) {
          _terminalLines.add(TerminalLine(value, isOutput: true));
        } else {
          if (_terminalLines.isNotEmpty && _terminalLines.last.isOutput) {
            _terminalLines[_terminalLines.length - 1] = TerminalLine(
              _terminalLines.last.content + value,
              isOutput: true,
            );
          } else {
            _terminalLines.add(TerminalLine(value, isOutput: true));
          }
        }
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _inputFocusNode.requestFocus(),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _terminalLines.length + 1,
                itemBuilder: (context, index) {
                  if (index < _terminalLines.length) {
                    final terminalLine = _terminalLines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 8.0,
                      ),
                      child: SelectableText(
                        terminalLine.isOutput
                            ? terminalLine.content
                            : '>> ${terminalLine.content}',
                        style: TextStyle(
                          fontSize: 12,
                          color: terminalLine.isOutput
                              ? const Color(0xFFFFA500)
                              : const Color(0xFF00FF00),
                          shadows: const [
                            Shadow(
                              blurRadius: 2,
                              color: Color(0xFFffcc80),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '>> ',
                            style: TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 12,
                              shadows: [
                                Shadow(
                                  blurRadius: 2,
                                  color: Color(0xFF80FF80),
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _inputFocusNode,
                              autofocus: true,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Color(0xFF00FF00),
                                fontSize: 12,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Color(0xFF80FF80),
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              cursorColor: const Color(0xFF00FF00),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFF808080)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _submitInput(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _submitInput() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _terminalLines.add(TerminalLine(input, isOutput: false));
    });

    _repl(input);
    _inputController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocusNode.requestFocus();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
