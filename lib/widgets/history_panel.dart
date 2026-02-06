import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class HistoryPanel extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;

  const HistoryPanel({
    super.key,
    required this.history,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: RetroTheme.boxDecoration(color: RetroTheme.white),
      child: Column(
        children: [
          // Tape Log Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: RetroTheme.borderColor,
                  width: RetroTheme.borderWidth,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TAPE LOG",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${history.length} ENTRIES",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: RetroTheme.accentYellow,
                        child: const Text(
                          "CLEAR",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // History Content
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      "NO HISTORY",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          history[index],
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
