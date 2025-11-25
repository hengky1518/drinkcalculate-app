import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'Result_screen.dart';


String numberToKoreanSimple(int number) {
  if (number <= 0) return "";

  int eok = number ~/ 100000000;
  int man = (number % 100000000) ~/ 10000;
  int rest = number % 10000;

  List<String> parts = [];
  if (eok > 0) parts.add("${eok}억");
  if (man > 0) parts.add("${man}만");
  if (rest > 0) parts.add("$rest");

  return parts.join(" ") + "원";
}


class RoundState {
  final int roundNumber;

  final TextEditingController totalCostController;
  final TextEditingController alcoholCostController;

  String totalCostKorean;
  String alcoholCostKorean;

  final Map<String, bool> isExcluded;
  final Map<String, bool> isNonDrinker;
  final Map<String, bool> isPayer;

  final Map<String, TextEditingController> payerControllers;
  final Map<String, String> payerKoreanText;

  RoundState({
    required this.roundNumber,
    required this.totalCostController,
    required this.alcoholCostController,
    required this.totalCostKorean,
    required this.alcoholCostKorean,
    required this.isExcluded,
    required this.isNonDrinker,
    required this.isPayer,
    required this.payerControllers,
    required this.payerKoreanText,
  });
}


class _ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(",", ""));
    if (number == null) return newValue;

    final newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}


class _Account {
  String name;
  int amount;
  _Account({required this.name, required this.amount});
}

class _TransferInternal {
  final String from;
  final String to;
  final int amount;
  _TransferInternal({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class InputScreen extends StatefulWidget {
  final int peopleCount;
  final List<String> participantNames;

  const InputScreen({
    super.key,
    required this.peopleCount,
    required this.participantNames,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}


class _InputScreenState extends State<InputScreen> {
  List<int> rounds = [];
  final Map<int, RoundState> roundStates = {};
  final Map<int, bool> isExpandedMap = {};

  @override
  void initState() {
    super.initState();
    _addNewRound(1);
  }


  void _addNewRound(int roundNumber) {
    rounds.add(roundNumber);
    roundStates[roundNumber] = _createRoundState(roundNumber);
    isExpandedMap[roundNumber] = false;
  }

  RoundState _createRoundState(int roundNumber) {
    return RoundState(
      roundNumber: roundNumber,
      totalCostController: TextEditingController(),
      alcoholCostController: TextEditingController(),
      totalCostKorean: "",
      alcoholCostKorean: "",
      isExcluded: {
        for (final n in widget.participantNames) n: false,
      },
      isNonDrinker: {
        for (final n in widget.participantNames) n: false,
      },
      isPayer: {
        for (final n in widget.participantNames) n: false,
      },
      payerControllers: {
        for (final n in widget.participantNames) n: TextEditingController(),
      },
      payerKoreanText: {
        for (final n in widget.participantNames) n: "",
      },
    );
  }

  void toggleParticipantView(int r) {
    setState(() {
      isExpandedMap[r] = !(isExpandedMap[r] ?? false);
    });
  }

  int _parseAmount(String text) =>
      int.tryParse(text.replaceAll(",", "")) ?? 0;

  String _fmt(int n) =>
      n == 0 ? "" : NumberFormat('#,###').format(n);


  void _updatePayerAutoAmounts(RoundState s) {
    final total = _parseAmount(s.totalCostController.text);

    final payers =
    s.isPayer.entries.where((e) => e.value).map((e) => e.key).toList();

    if (payers.isEmpty) return;

    if (payers.length == 1) {
      final name = payers.first;
      s.payerControllers[name]!.text = _fmt(total);
      s.payerKoreanText[name] = numberToKoreanSimple(total);
      return;
    }

    final last = payers.last;
    final others = payers.sublist(0, payers.length - 1);

    int sumOthers = 0;
    for (final name in others) {
      sumOthers += _parseAmount(s.payerControllers[name]!.text);
    }

    final remain = total - sumOthers;

    if (remain <= 0) {
      s.payerControllers[last]!.text = "";
      s.payerKoreanText[last] = "";
    } else {
      s.payerControllers[last]!.text = _fmt(remain);
      s.payerKoreanText[last] = numberToKoreanSimple(remain);
    }
  }

  void _onTotalCostChanged(RoundState s) {
    setState(() {
      final total = _parseAmount(s.totalCostController.text);
      s.totalCostKorean = numberToKoreanSimple(total);
      _updatePayerAutoAmounts(s);
    });
  }

  void _onAlcoholCostChanged(RoundState s) {
    setState(() {
      final alcohol = _parseAmount(s.alcoholCostController.text);
      s.alcoholCostKorean = numberToKoreanSimple(alcohol);
    });
  }

  void _onPayerToggle(String name, RoundState s) {
    setState(() {
      final now = s.isPayer[name] ?? false;
      s.isPayer[name] = !now;

      if (!s.isPayer[name]!) {
        s.payerControllers[name]!.text = "";
        s.payerKoreanText[name] = "";
      }

      _updatePayerAutoAmounts(s);
    });
  }


  void _onPayerAmountChanged(String name, RoundState s) {
    final amount = _parseAmount(s.payerControllers[name]!.text);
    s.payerKoreanText[name] = numberToKoreanSimple(amount);

    final payers =
    s.isPayer.entries.where((e) => e.value).map((e) => e.key).toList();

    if (payers.length <= 1) {
      setState(() {});
      return;
    }

    final last = payers.last;

    if (name != last) {
      setState(() {
        _updatePayerAutoAmounts(s);
      });
    } else {
      setState(() {});
    }
  }

  void _showAddParticipantDialog() {
    final c = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("이름 추가"),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: "이름을 입력하세요"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final raw = c.text.trim();
              if (raw.isEmpty) return Navigator.pop(ctx);

              String name = raw;


              if (widget.participantNames.contains(name)) {
                int count = 2;
                while (widget.participantNames.contains("$name($count)")) {
                  count++;
                }
                name = "$name($count)";
              }

              setState(() {
                widget.participantNames.add(name);

                for (final s in roundStates.values) {
                  s.isExcluded[name] = false;
                  s.isNonDrinker[name] = false;
                  s.isPayer[name] = false;
                  s.payerControllers[name] = TextEditingController();
                  s.payerKoreanText[name] = "";
                }
              });

              Navigator.pop(ctx);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  bool _validateRound(RoundState s) {
    final total = _parseAmount(s.totalCostController.text);

    final payers =
    s.isPayer.entries.where((e) => e.value).map((e) => e.key).toList();

    if (payers.isEmpty) return false; // 결제자 한 명도 없으면 불가

    int sum = 0;
    for (final name in payers) {
      sum += _parseAmount(s.payerControllers[name]!.text);
    }

    return sum == total;
  }

  bool _validateAllRounds() {
    for (final r in rounds) {
      final s = roundStates[r]!;
      if (!_validateRound(s)) {
        return false;
      }
    }
    return true;
  }


  List<Map<String, dynamic>> _calculateTransfers() {

    final names = List<String>.from(widget.participantNames);

    final Map<String, int> net = {for (final n in names) n: 0};

    for (final r in rounds) {
      final s = roundStates[r]!;

      final total = _parseAmount(s.totalCostController.text);
      final alcohol = _parseAmount(s.alcoholCostController.text);
      final food = (total - alcohol).clamp(0, total);

      final participants =
      names.where((n) => !(s.isExcluded[n] ?? false)).toList();
      if (participants.isEmpty) continue;

      final drinkers =
      participants.where((n) => !(s.isNonDrinker[n] ?? false)).toList();

      final nPart = participants.length;
      final nDrink = drinkers.length;

      final foodPer = nPart > 0 ? food ~/ nPart : 0;
      int foodRemain = nPart > 0 ? food % nPart : 0;

      final alcoholPer = nDrink > 0 ? alcohol ~/ nDrink : 0;
      int alcoholRemain = nDrink > 0 ? alcohol % nDrink : 0;

      final Map<String, int> shouldPay = {
        for (final n in participants) n: foodPer
      };

      for (int i = 0; i < foodRemain; i++) {
        shouldPay[participants[i]] = (shouldPay[participants[i]] ?? 0) + 1;
      }

      for (final d in drinkers) {
        shouldPay[d] = (shouldPay[d] ?? 0) + alcoholPer;
      }
      for (int i = 0; i < alcoholRemain && i < drinkers.length; i++) {
        shouldPay[drinkers[i]] = (shouldPay[drinkers[i]] ?? 0) + 1;
      }

      for (final n in participants) {
        final paid =
        (s.isPayer[n] ?? false) ? _parseAmount(s.payerControllers[n]!.text) : 0;

        final want = shouldPay[n] ?? 0;
        net[n] = (net[n] ?? 0) + (paid - want);
      }
    }

    final List<_Account> receivers = [];
    final List<_Account> payers = [];

    for (final n in names) {
      final v = net[n] ?? 0;
      if (v > 0) {
        receivers.add(_Account(name: n, amount: v));
      } else if (v < 0) {
        payers.add(_Account(name: n, amount: -v));
      }
    }

    final List<_TransferInternal> transfers = [];
    int ri = 0;

    for (final payer in payers) {
      int toPay = payer.amount;

      while (toPay > 0 && ri < receivers.length) {
        final recv = receivers[ri];

        if (recv.amount <= 0) {
          ri++;
          continue;
        }

        final pay = toPay < recv.amount ? toPay : recv.amount;

        transfers.add(
          _TransferInternal(from: payer.name, to: recv.name, amount: pay),
        );

        toPay -= pay;
        recv.amount -= pay;

        if (recv.amount == 0) ri++;
      }
    }

    return transfers
        .map((t) => {
      'from': t.from,
      'to': t.to,
      'amount': t.amount,
    })
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    final isValid = _validateAllRounds();

    return Scaffold(
      appBar: AppBar(
        title: const Text('짠한정산'),
        backgroundColor: const Color(0xFF3BA776),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: isValid
                  ? () {
                final transfers = _calculateTransfers();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResultScreen(transfers: transfers),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3BA776),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "정산하기",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...rounds.map(
                  (r) => _buildRoundForm(r, roundStates[r]!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newR = rounds.last + 1;
                setState(() => _addNewRound(newR));
              },
              child: const Text("회차 추가"),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }


  Widget _buildRoundForm(int r, RoundState s) {
    final expand = isExpandedMap[r] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFF3F9F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                "$r차",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3BA776),
                ),
              ),
            ),

            Row(
              children: [
                const Icon(Icons.person, color: Colors.black54),
                const SizedBox(width: 8),
                const Text(
                  "참석자",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    expand
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () => toggleParticipantView(r),
                )
              ],
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              firstChild: _buildChipRow(s),
              secondChild: _buildChipWrap(s),
              crossFadeState: expand
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),

            const SizedBox(height: 12),

            _buildAmountSection(s),

            const SizedBox(height: 14),

            _buildPaymentTable(s),
          ],
        ),
      ),
    );
  }


  Widget _buildAmountSection(RoundState s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset("assets/moneyBag.png", width: 24, height: 24),
            const SizedBox(width: 8),
            const Text("총 금액"),
          ],
        ),
        _buildAmountInput(
          controller: s.totalCostController,
          korean: s.totalCostKorean,
          hint: "총 금액을 입력 해 주세요",
          onChanged: (_) => _onTotalCostChanged(s),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Image.asset("assets/beer.png", width: 24, height: 24),
            const SizedBox(width: 8),
            const Text("주류 금액"),
          ],
        ),
        _buildAmountInput(
          controller: s.alcoholCostController,
          korean: s.alcoholCostKorean,
          hint: "주류 금액을 입력 해 주세요",
          onChanged: (_) => _onAlcoholCostChanged(s),
        ),
      ],
    );
  }

  Widget _buildAmountInput({
    required TextEditingController controller,
    required String korean,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsFormatter(),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (korean.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              korean,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8FE1B0),
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildPaymentTable(RoundState s) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: const [
              SizedBox(
                width: 120,
                child: Center(
                    child: Text("이름",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 50,
                child: Center(
                    child: Text("주류X",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 50,
                child: Center(
                    child: Text("결제자",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 120,
                child: Center(
                    child: Text("결제 금액",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ),
            ],
          ),

          // rows
          Column(
            children: widget.participantNames
                .where((n) => !(s.isExcluded[n] ?? false))
                .map((n) => _buildParticipantRow(n, s))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(String name, RoundState s) {
    final isND = s.isNonDrinker[name] ?? false;
    final isP = s.isPayer[name] ?? false;
    final controller = s.payerControllers[name]!;
    final korean = s.payerKoreanText[name] ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: _buildNameChip(name)),
          const SizedBox(width: 10),

          SizedBox(
            width: 50,
            height: 50,
            child: _buildToggleBox(
              isND,
                  (v) => setState(() => s.isNonDrinker[name] = v),
            ),
          ),
          const SizedBox(width: 10),

          SizedBox(
            width: 50,
            height: 50,
            child: _buildToggleBox(
              isP,
                  (v) => _onPayerToggle(name, s),
            ),
          ),
          const SizedBox(width: 10),

          SizedBox(
            width: 120,
            child: Visibility(
              visible: isP,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsFormatter(),
                    ],
                    onChanged: (_) => _onPayerAmountChanged(name, s),
                    decoration: InputDecoration(
                      hintText: "금액",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (korean.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        korean,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8FE1B0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget _buildNameChip(String name) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildToggleBox(bool isChecked, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color:
          isChecked ? const Color(0xFF22C55E) : const Color(0xFFDFF3E6),
          borderRadius: BorderRadius.circular(10),
          border: isChecked ? null : Border.all(color: Colors.black12),
        ),
        child: isChecked
            ? const Center(
          child: Icon(Icons.check, color: Colors.white, size: 28),
        )
            : null,
      ),
    );
  }


  Widget _buildChipRow(RoundState s) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...widget.participantNames.map(
                (name) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildParticipantChip(name, s),
            ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildChipWrap(RoundState s) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.participantNames.map(
              (name) => _buildParticipantChip(name, s),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildParticipantChip(String name, RoundState s) {
    final excluded = s.isExcluded[name] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          s.isExcluded[name] = !excluded;

          if (s.isExcluded[name]!) {
            if (s.isPayer[name] == true) {
              s.isPayer[name] = false;
              s.payerControllers[name]!.text = "";
              s.payerKoreanText[name] = "";
              _updatePayerAutoAmounts(s);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
          excluded ? Colors.grey[300] : const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: excluded ? Colors.black54 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddParticipantDialog,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF22C55E)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, color: Color(0xFF22C55E)),
      ),
    );
  }
}
