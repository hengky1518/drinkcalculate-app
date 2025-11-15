import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'input_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int peopleCount = 0;
  bool allFilled = false;
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];

  // ----------------------------------------------------------
  // 🔥 동명이인 자동 처리 함수
  // ----------------------------------------------------------
  List<String> makeUniqueNames(List<String> names) {
    List<String> unique = [];

    for (var name in names) {
      if (!unique.contains(name)) {
        unique.add(name);
      } else {
        int count = 2;
        while (unique.contains("$name($count)")) {
          count++;
        }
        unique.add("$name($count)");
      }
    }
    return unique;
  }

  // ----------------------------------------------------------
  // 인원 선택 모달
  // ----------------------------------------------------------
  void showCountSelector(BuildContext ctx) async {
    int tempCount = peopleCount == 0 ? 1 : peopleCount;

    final result = await showDialog<int>(
      context: ctx,
      builder: (context) {
        return Center(
          child: Container(
            width: 280,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('인원을 선택하세요', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Expanded(
                  child: CupertinoPicker(
                    scrollController:
                    FixedExtentScrollController(initialItem: tempCount - 1),
                    itemExtent: 60,
                    onSelectedItemChanged: (index) {
                      tempCount = index + 1;
                    },
                    children: List.generate(
                      99,
                          (index) => Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, tempCount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3BA776),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('선택', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        peopleCount = result;
        controllers =
            List.generate(peopleCount, (_) => TextEditingController());
        focusNodes = List.generate(peopleCount, (_) => FocusNode());
      });
    }
  }

  // ----------------------------------------------------------
  // 모든 이름이 채워졌는지 확인
  // ----------------------------------------------------------
  void checkAllFilled() {
    setState(() {
      allFilled = controllers.every((c) => c.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    for (final c in controllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '짠한정산',
          style: TextStyle(
            color: Color(0xFF3BA776),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('assets/logo.png', width: 32, height: 32),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/onboarding.png'),
            const SizedBox(height: 12),

            // 인원 선택 버튼
            Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showCountSelector(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF3BA776)),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  peopleCount == 0 ? '인원을 선택 해 주세요' : '$peopleCount명',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 이름 입력창
            Flexible(
              child: ListView.builder(
                itemCount: peopleCount,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    textInputAction: index < peopleCount - 1
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onSubmitted: (_) {
                      if (index < peopleCount - 1) {
                        FocusScope.of(context)
                            .requestFocus(focusNodes[index + 1]);
                      } else {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    onChanged: (_) => checkAllFilled(),
                    decoration: InputDecoration(
                      hintText: '이름을 입력 해 주세요',
                      filled: true,
                      fillColor: const Color(0xFFF3F9F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 시작하기 버튼
            ElevatedButton(
              onPressed: allFilled
                  ? () {
                // 원본 이름 리스트
                final rawNames =
                controllers.map((c) => c.text.trim()).toList();

                // 🔥 동명이인 자동 처리
                final uniqueNames = makeUniqueNames(rawNames);

                // InputScreen 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputScreen(
                      peopleCount: peopleCount,
                      participantNames: List<String>.from(uniqueNames),
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3BA776),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                '시작하기',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
