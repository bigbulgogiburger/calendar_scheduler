import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/color.dart';
import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:calendar_scheduler/database/drift_database.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet({
    required this.selectedDate,
    this.scheduleId,
    super.key,
  });

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  // 이게 폼의 컨트롤러처럼 작동한다.
  final GlobalKey<FormState> formkey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery
        .of(context)
        .viewInsets
        .bottom;
    return GestureDetector(
      onTap: () {
        // 이렇게 하면 다른 곳을 누르면 키보드 화면이 내려간다.
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule>(
          future: widget.scheduleId == null
              ? null
              : GetIt.I<LocalDatabase>().getSchedule(widget.scheduleId!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('스케줄을 불러올 수 없습니다.'),
              );
            }

            //FutureBuilder 처음 실행됐고,
            //로딩중일때에
            if (snapshot.connectionState != ConnectionState.none &&
                !snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // future가 실행이 되고 값이 있는데 단 한번도 startTime이 세팅되지 않았을 때에
            if (snapshot.hasData
                // 이렇게 안하면 색깔이 바뀌어도 setState를 하기 때문에 디비에 있는 값으로 다시 초기화해서 색이 안바뀜
                && startTime == null
            ) {
              startTime = snapshot.data!.startTime;
              endTime = snapshot.data!.endTime;
              content = snapshot.data!.content;
              selectedColorId = snapshot.data!.colorId;
            }
            return SafeArea(
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2 + bottomInset,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                    child: Form(
                      key: formkey,
                      // 라이브로 밸리데이션이 된다.
                      // autovalidateMode: AutovalidateMode.always,
                      // drift pakage의 칼럼도 불러와서 에러남.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Time(
                            onStartSaved: (String? val) {
                              // validator에서 값이 없으면 에러를 뱉도록 던짐.
                              startTime = int.parse(val!);
                            },
                            onEndSaved: (String? val) {
                              endTime = int.parse(val!);
                            },
                            startInitialValue: startTime?.toString() ?? '',
                            endInitialValue: endTime?.toString() ?? '',
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          _Content(
                            onSaved: (String? val) {
                              content = val!;
                            },
                            initialValue: content ?? '',
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          FutureBuilder<List<CategoryColor>>(
                              future:
                              GetIt.I<LocalDatabase>().getCategoryColors(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    selectedColorId == null &&
                                    snapshot.data!.isNotEmpty) {
                                  selectedColorId = snapshot.data![0].id;
                                  print(selectedColorId);
                                }
                                print("selectedColorId $selectedColorId");
                                return _ColorPicker(
                                  colors:
                                  snapshot.hasData ? snapshot.data! : [],
                                  selectedColorId: selectedColorId,
                                  colorIdSetter: (int id) {
                                    setState(() {
                                      selectedColorId = id;
                                    });
                                  },
                                );
                              }),
                          _SaveButton(
                            onPressed: onSavePressed,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void onSavePressed() async {
    //formkey는 생성을 했는데, form widget과 결합을 안했을 때에
    if (formkey.currentState == null) {
      return;
    }

    // 모든 TextFormField의 validator를 실행시킨다. 모든 리턴값이 null일때에 true,
    if (formkey.currentState!.validate()) {
      print('에러가 없습니다.');
      print('startTime : $startTime');
      // validate가 다 되면 save를 호출한다. currentState.save가 호출되면 onSaved가 다 호출됨

      formkey.currentState!.save();

      if (widget.scheduleId == null) {
        final key = await GetIt.I<LocalDatabase>().createScedule(
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),),
        );
      } else {
        await GetIt.I<LocalDatabase>().updateScheduleById(widget.scheduleId!,
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          )
        );
      }
      Navigator.of(context).pop();
    } else {
      print('에러가 있습니다.');
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _Time({
    required this.onStartSaved,
    required this.onEndSaved,
    required this.startInitialValue,
    required this.endInitialValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: "시작 시간",
            isTime: true,
            onSaved: onStartSaved,
            initialValue: startInitialValue,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: CustomTextField(
            label: "마감 시간",
            isTime: true,
            onSaved: onEndSaved,
            initialValue: endInitialValue,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const _Content(
      {required this.onSaved, required this.initialValue, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: "내용",
        isTime: false,
        onSaved: onSaved,
        initialValue: initialValue,
      ),
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final int? selectedColorId;
  final List<CategoryColor> colors;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker({required this.colors,
    required this.selectedColorId,
    required this.colorIdSetter,
    super.key});

  @override
  Widget build(BuildContext context) {
    //wrap -- 줄바꿈 자동
    return Wrap(
      //양옆간격
        spacing: 8.0,
        //위아래 간격
        runSpacing: 10,
        children: colors
            .map(
              (e) =>
              GestureDetector(
                onTap: () {
                  colorIdSetter(e.id);
                },
                child: renderColor(
                  e,
                  selectedColorId == e.id,
                ),
              ),
        )
            .toList());
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(int.parse('FF${color.hexCode}', radix: 16)),
          border: isSelected
              ? Border.all(
            color: Colors.black,
            width: 4.0,
          )
              : null),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed, super.key});

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
