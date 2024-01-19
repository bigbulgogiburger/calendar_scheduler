import 'package:calendar_scheduler/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  //true 시간 , false 텍스트
  final bool isTime;

  const CustomTextField({required this.label,required this.isTime, super.key});

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
        if(isTime) renderTextField(),
        if(!isTime) Expanded(child: renderTextField(),)

      ],
    );
  }
  Widget renderTextField(){
    return TextFormField(
      //null이 리ㅓㄴ되면 에러가 없다.
      // 에러가 있으면 에러를 String 값으로 리턴해준다.
      validator: (String?  val){
        if(val == null || val.isEmpty) return '값을 입력해주세요';
      },
      cursorColor: Colors.grey,
      keyboardType: isTime?TextInputType.number : TextInputType.multiline,
      maxLines: isTime?1:null,
      expands: !isTime,
      inputFormatters: isTime? [
        FilteringTextInputFormatter.digitsOnly,
      ] : [],
      decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[300]),
    );
  }
}
