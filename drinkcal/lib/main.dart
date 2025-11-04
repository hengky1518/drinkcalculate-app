import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int peopleCount = 0; // 선택된 인원 수
  bool allFilled = false; // 모든 이름 입력창이 채워졌는지 여부
  List<TextEditingController> controllers = []; // 이름 입력 컨트롤러들
  List<FocusNode> focusNodes = []; // ✅ 각 TextField의 포커스 관리용 노드들

  // ✅ 인원 선택 모달 (정중앙 + 슬라이더)
  void showCountSelector(BuildContext ctx) async {
    int tempCount = peopleCount == 0 ? 1 : peopleCount; // 현재 선택값 기본 표시

    final result = await showDialog<int>(
      context: ctx,
      barrierDismissible: true, // 바깥 클릭 시 닫기
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
                const Text(
                  '인원을 선택하세요',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: tempCount - 1,
                    ),
                    itemExtent: 60, // 각 항목 높이
                    onSelectedItemChanged: (index) {
                      tempCount = index + 1;
                    },
                    children: List.generate(
                      99, // 최대 인원
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
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text(
                    '선택',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    // ✅ 선택 결과 반영
    if (result != null) {
      setState(() {
        peopleCount = result;
        controllers =
            List.generate(peopleCount, (_) => TextEditingController());
        focusNodes = List.generate(peopleCount, (_) => FocusNode()); // ✅ 추가
      });
    }
  }

  // ✅ 이름 입력창이 모두 채워졌는지 확인
  void checkAllFilled() {
    setState(() {
      allFilled = controllers.every((c) => c.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    // ✅ FocusNode 및 Controller 메모리 정리
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            '짠한정산',
            style: TextStyle(
              color: Color(0xFF3BA776),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset(
              'assets/logo.png',
              width: 32,
              height: 32,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset('assets/onboarding.png'),
              const SizedBox(height: 12),
              // 👇 인원 선택 버튼
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
                    peopleCount == 0
                        ? '인원을 선택 해 주세요'
                        : '$peopleCount명',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 👇 이름 입력창 리스트
              Flexible( // ✅ Expanded → Flexible로 변경
                child: ListView.builder(
                  itemCount: peopleCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index], // ✅ 포커스 연결
                        textInputAction: index < peopleCount - 1
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onSubmitted: (_) {
                          if (index < peopleCount - 1) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index + 1]); // 다음칸 이동
                          } else {
                            FocusScope.of(context).unfocus(); // 마지막이면 닫기
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
                    );
                  },
                ),
              ),
              // 👇 시작 버튼
              ElevatedButton(
                onPressed: allFilled ? () => print('시작!') : null,
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
      ),
    );
  }
}
