import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transfers;

  const ResultScreen({super.key, required this.transfers});

  String _fmt(int n) => NumberFormat('#,###').format(n);


  String buildShareText() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final t in transfers) {
      final from = t['from'] as String;
      grouped.putIfAbsent(from, () => []);
      grouped[from]!.add(t);
    }

    final buffer = StringBuffer();
    buffer.writeln("💸 짠한정산 – 정산 결과\n");

    grouped.forEach((from, list) {
      buffer.writeln("■ $from →");
      for (var t in list) {
        buffer.writeln("   - ${t['to']} : ${_fmt(t['amount'])}원");
      }
      buffer.writeln("");
    });

    buffer.writeln("\n* 앱으로 자동 계산되었습니다.");

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final t in transfers) {
      final from = t['from'] as String;
      grouped.putIfAbsent(from, () => []);
      grouped[from]!.add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('정산 결과'),
        backgroundColor: const Color(0xFF3BA776),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/result.png'),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: grouped.entries.map((entry) {
                  final from = entry.key;
                  final list = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F9F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          from,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...list.map((t) {
                          final to = t['to'];
                          final amount = t['amount'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right_alt,
                                    color: Colors.black54),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "$to • ${_fmt(amount)}원",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = buildShareText();
                      await Clipboard.setData(ClipboardData(text: text));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("결과가 복사되었습니다!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("결과 복사"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8FE1B0),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = buildShareText();
                      await Share.share(text);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("공유하기"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3BA776),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
