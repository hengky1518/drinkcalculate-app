import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('짠한정산'),
        backgroundColor: const Color(0xFF3BA776),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  '1차',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3BA776),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildRoundForm(),

              const SizedBox(height: 16),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print('회차 추가!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDFF3E6),
                    foregroundColor: const Color(0xFF3BA776),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  child: const Text(
                    '회차 추가',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                print('정산하기 버튼 클릭');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3BA776),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '정산하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundForm() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF3F9F5)),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.black54),
                const SizedBox(width: 6),
                const Text(
                  '참석자',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _buildChipRow(),
              secondChild: _buildChipWrap(),
            ),

            const SizedBox(height: 12),

            // 금액 입력
            Row(
              children: [
                Image.asset('assets/moneyBag.png', height: 28, width: 28),
                const SizedBox(width: 8),
                const Text('총 금액'),
              ],
            ),
            _buildAmountField('총 금액을 입력 해 주세요'),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset('assets/beer.png', height: 28, width: 28),
                const SizedBox(width: 8),
                const Text('주류 금액'),
              ],
            ),
            _buildAmountField('주류 금액을 입력 해 주세요'),
            const SizedBox(height: 14),

            // ✅ 헤더 + 데이터 행을 하나의 가로 스크롤로 묶기
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 행
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 80,
                            height: 50,
                            child: Center(
                                child: Text('이름',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                        SizedBox(
                            width: 70,
                            height: 50,
                            child: Center(
                                child: Text('주류제외',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                        SizedBox(
                            width: 70,
                            height: 50,
                            child: Center(
                                child: Text('결제자',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                        SizedBox(
                            width: 100,
                            height: 50,
                            child: Center(
                                child: Text('결제 금액',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ),

                  // 데이터 행들
                  Column(
                    children: widget.participantNames.map((name) {
                      return _buildParticipantRow(name);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 참가자 1명당 행
  Widget _buildParticipantRow(String name) {
    bool isPayer = false; // 결제자 여부
    final controller = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNameBox(name),
              const SizedBox(width: 10),

              _buildSquareToggle(),
              const SizedBox(width: 10),

              // 결제자 체크박스
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPayer = !isPayer;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isPayer
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : null,
                ),
              ),
              const SizedBox(width: 10),

              // ✅ 공간 유지하면서 표시만 전환
              Visibility(
                visible: isPayer,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: _buildFormattedInputField(controller),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameBox(String name) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🔹 참석자 칩(가로)
  Widget _buildChipRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...widget.participantNames.map((name) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildChipWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.participantNames.map((name) {
          return Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        print('새 인원 추가');
      },
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

  Widget _buildAmountField(String hint) {
    final controller = TextEditingController();

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsFormatter(),
      ],
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ✅ 정사각형 토글
  Widget _buildSquareToggle() {
    bool isChecked = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              isChecked = !isChecked;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
        );
      },
    );
  }

  // ✅ 천단위 포맷된 입력칸
  Widget _buildFormattedInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsFormatter(),
      ],
      decoration: InputDecoration(
        hintText: '금액',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ✅ 천 단위 콤마 포맷터
class _ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) return newValue;

    final newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
