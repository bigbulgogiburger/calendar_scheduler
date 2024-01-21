import 'package:calendar_scheduler/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String initialValue;
  final String label;

  //true 시간 , false 텍스트
  final bool isTime;
  final FormFieldSetter<String> onSaved;

  const CustomTextField(
      {required this.label,
      required this.isTime,
      required this.onSaved,
        required this.initialValue,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime)
          Expanded(
            child: renderTextField(),
          )
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      onSaved: onSaved,
      initialValue: initialValue,
      //null이 리턴되면 에러가 없다.
      // 에러가 있으면 에러를 String 값으로 리턴해준다.
      // formkey.currentState.validate함수가 실행되면 validator가 모두 실행된다.
      validator: (String? val) {
        if (val == null || val.isEmpty) return '값을 입력해주세요';
        if (isTime) {
          int time = int.parse(val!);
          if (time < 0) {
            return '0이상의 숫자를 입력해주세요.';
          }

          if (time > 24) {
            return '24이하의 숫자를 입력해주세요';
          }
        } else {
          if (val.length > 500) {
            return '500자 이하의 글자를 입력해주세요';
          }
        }
      },
      cursorColor: Colors.grey,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      maxLines: isTime ? 1 : null,
      // maxLength: 500,
      expands: !isTime,
      inputFormatters: isTime
          ? [
              FilteringTextInputFormatter.digitsOnly,
            ]
          : [],
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null,
      ),
    );
  }
}
