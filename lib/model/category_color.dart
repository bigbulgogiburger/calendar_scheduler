import 'package:drift/drift.dart';


class CategoryColors extends Table{
  //primary key
  IntColumn get id => integer().autoIncrement()();

  //색상코드
  TextColumn get hexCode => text()();
}