import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/color.dart';
import 'package:flutter/material.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({super.key});

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  // 이게 폼의 컨트롤러처럼 작동한다.
  final GlobalKey<FormState> formkey =GlobalKey();
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      onTap: (){
        // 이렇게 하면 다른 곳을 누르면 키보드 화면이 내려간다.
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height / 2 + bottomInset,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: Form(
                key: formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Time(),
                    SizedBox(
                      height: 16.0,
                    ),
                    _Content(),
                    SizedBox(
                      height: 16.0,
                    ),
                    _ColorPicker(),
                    _SaveButton(
                      onPressed: onSavePressed,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void onSavePressed(){
    //formkey는 생성을 했는데, form widget과 결합을 안했을 때에
    if(formkey.currentState == null){
      return;
    }

    // 모든 TextFormField의 validator를 실행시킨다. 모든 리턴값이 null일때에 true,
    if(formkey.currentState!.validate()){
      print('에러가 있습니다.');
    }else{
      print('에러가 없습니다.');

    }
  }
}

class _Time extends StatelessWidget {
  const _Time({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: "시작 시간",
            isTime: true,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: CustomTextField(
            label: "마감 시간",
            isTime: true,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: "내용",
        isTime: false,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    //wrap -- 줄바꿈 자동
    return Wrap(
      //양옆간격
      spacing: 8.0,
      //위아래 간격
      runSpacing: 10,
      children: [
        renderColor(Colors.red),
        renderColor(Colors.orange),
        renderColor(Colors.yellow),
        renderColor(Colors.green),
        renderColor(Colors.blue),
        renderColor(Colors.indigo),
        renderColor(Colors.purple),
      ],
    );
  }

  Widget renderColor(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed,super.key});

  @override
  Widget build(BuildContext context) {
    //button을 전체 크기로 만드는 좋은 방법
    //Row -> Expanded ->ElevatedButton으로 감싸기
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: onPressed,
          child: Text('저장'),
          style: ElevatedButton.styleFrom(
            primary: PRIMARY_COLOR,
            foregroundColor: Colors.white,
          ),
        )),
      ],
    );
  }
}
