import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/data/repeat_choice_data.dart';
import 'package:todoapp/set_up_widgets/repeat_sheet.dart';

class ScheduleSheet extends StatefulWidget {
  DateTime schedulePickedDate;
  final DateTime initTime;
  RepeatChoiceData repeatChoiceData = RepeatChoiceData();

  ScheduleSheet({this.initTime, RepeatChoiceData data}) {
    schedulePickedDate = initTime;
    repeatChoiceData = data;
  }

  @override
  _ScheduleSheetState createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<ScheduleSheet> {
  List<String> _scheduleTittle = [
    'Today',
    'Tomorrow',
    'This week',
    'Later',
    'Choose date'
  ];

  int _selectedScheduleIndex = 0;
  String _scheduleChoseDateText;
  DateTime _scheduleChoseDateTime;

  RepeatSheet _repeatSheet;

  @override
  void initState() {
    super.initState();

    _scheduleChoseDateTime = widget.schedulePickedDate == DateTime.now()
        ? DateTime.now()
        : widget.schedulePickedDate;
    _scheduleChoseDateText =
        DateFormat("EEEEEEEE dd MMMM yyyy").format(_scheduleChoseDateTime);

    _repeatSheet = RepeatSheet(
      initChoiceData: widget.repeatChoiceData,
    );

    _initPositionForScheduleChoice();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Color(0xFFECEFF1),
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Schedule",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _scheduleTittle.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.only(right: 5.0),
                  alignment: Alignment.center,
                  child: ListTile(
                    leading: _selectedScheduleIndex == index
                        ? Opacity(
                            opacity: 1.0,
                            child: Icon(Icons.check),
                          )
                        : Opacity(
                            opacity: 0.0,
                            child: Icon(Icons.check),
                          ),
                    title: Text(_scheduleTittle[index]),
                    trailing: (_selectedScheduleIndex == index && index == 0)
                        ? Text(DateFormat("EEEEEEEE dd MMMM yyyy")
                            .format(DateTime.now()))
                        : (_selectedScheduleIndex == index && index == 1)
                            ? Text(DateFormat("EEEEEEEE dd MMMM yyyy")
                                .format(DateTime.now().add(Duration(days: 1))))
                            : (_selectedScheduleIndex == index &&
                                    index == _scheduleTittle.length - 1)
                                ? Text(_scheduleChoseDateText)
                                : null,
                    onTap: () {
                      setState(() {
                        _selectedScheduleIndex = index;

                        _scheduleChoseDateText =
                            DateFormat("EEEEEEEE dd MMMM yyyy")
                                .format(_scheduleChoseDateTime);
                      });

                      // Choose date
                      if (index == _scheduleTittle.length - 1) {
                        showRoundedDatePicker(
                          theme: ThemeData.dark(),
                          context: context,
                          initialDate: _scheduleChoseDateTime,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        ).then((value) {
                          setState(() {
                            if (value != null) {
                              _scheduleChoseDateTime = value;
                              widget.schedulePickedDate =
                                  _scheduleChoseDateTime;
                            }

                            _scheduleChoseDateText =
                                DateFormat("EEEEEEEE dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime);
                            //------------------------------------------------//

                            // Xét điều kiện xem người dùng có chọn trùng với ngày của 4 choice menu trên hay không
                            //--------------Phần xét Today + Tmorrow-----------//
                            if (DateFormat("dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime) ==
                                DateFormat("dd MMMM yyyy")
                                    .format(DateTime.now())) {
                              _selectedScheduleIndex = 0;

                              return;
                            } else if (DateFormat("dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime) ==
                                DateFormat("dd MMMM yyyy").format(
                                    DateTime.now().add(Duration(days: 1)))) {
                              _selectedScheduleIndex = 1;

                              return;
                            }
                            //------------------------------------------------//

                            //----------------Phần xét This week--------------//
                            // Chuyển ngày chọn về thứ 2 của tuần đó sau đó cộng lên chủ nhật của tuần đó và xét xem chủ nhật tuần đó có trùng với ngày pick hay ko (this week)
                            var temp = DateTime.now().add(
                                Duration(days: -(DateTime.now().weekday - 1)));

                            if (DateFormat("dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime) ==
                                DateFormat("dd MMMM yyyy")
                                    .format(temp.add(Duration(days: 6)))) {
                              _selectedScheduleIndex = 2;
                              return;
                            }
                            //------------------------------------------------//

                            //------------------Phần xét Later----------------//
                            // Dời về CN tuần trc để xét
                            var temp2 = DateTime.now()
                                .add(Duration(days: -(DateTime.now().weekday)));

                            if (DateFormat("dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime) ==
                                DateFormat("dd MMMM yyyy")
                                    .format(temp2.add(Duration(days: 15)))) {
                              _selectedScheduleIndex = 3;

                              return;
                            }
                            //------------------------------------------------//
                          });
                        });
                      } else if (index == 0 || index == 1) {
                        // Today + Tomorrow
                        setState(() {
                          _scheduleChoseDateTime = index == 0
                              ? DateTime.now()
                              : DateTime.now().add(Duration(days: 1));
                          _scheduleChoseDateText =
                              DateFormat("EEEEEEEE dd MMMM yyyy")
                                  .format(_scheduleChoseDateTime);

                          widget.schedulePickedDate = _scheduleChoseDateTime;
                        });
                      } else {
                        setState(() {
                          // This week
                          if (index == 2) {
                            _scheduleChoseDateTime = DateTime.now().add(
                                Duration(days: -(DateTime.now().weekday - 1)));
                            _scheduleChoseDateTime =
                                _scheduleChoseDateTime.add(Duration(days: 6));

                            _scheduleChoseDateText =
                                DateFormat("EEEEEEEE dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime);

                            widget.schedulePickedDate = _scheduleChoseDateTime;
                          } else {
                            // Later
                            var temp = DateTime.now()
                                .add(Duration(days: -(DateTime.now().weekday)));
                            _scheduleChoseDateTime =
                                temp.add(Duration(days: 15));

                            _scheduleChoseDateText =
                                DateFormat("EEEEEEEE dd MMMM yyyy")
                                    .format(_scheduleChoseDateTime);

                            widget.schedulePickedDate = _scheduleChoseDateTime;
                          }
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Repeats",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            onTap: _onRepeatTap,
            title: Text("Open repeats set up"),
            leading: Opacity(
              opacity: 0.0,
              child: Icon(Icons.check),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  // Hàm bắt sự kiện khi ng dùng ấn chọn mở repeat sheet
  void _onRepeatTap() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => _repeatSheet).whenComplete(() {
      widget.repeatChoiceData = _repeatSheet.repeatChoiceData;
    });

    setState(() {
      isNormalFirstTime = false;
    });
  }

  // Hàm để khởi tạo vị trí theo ngày mà trc đó ng dùng chọn
  void _initPositionForScheduleChoice() {
    //----------------------Các trường hợp today, tomorrow--------------------//
    if (DateFormat("dd MMMM yyyy").format(widget.schedulePickedDate) ==
        DateFormat("dd MMMM yyyy").format(DateTime.now())) {
      _selectedScheduleIndex = 0;
      return;
    } else if (DateFormat("dd MMMM yyyy").format(widget.schedulePickedDate) ==
        DateFormat("dd MMMM yyyy")
            .format(DateTime.now().add(Duration(days: 1)))) {
      _selectedScheduleIndex = 1;
      return;
    }
    //------------------------------------------------------------------------//

    //------------------Nếu trạng thái ng dùng chọn là this week--------------//
    // Chuyển ngày chọn về thứ 2 của tuần đó sau đó cộng lên chủ nhật của tuần đó và xét xem chủ nhật tuần đó có trùng với ngày pick hay ko
    var temp =
        DateTime.now().add(Duration(days: -(DateTime.now().weekday - 1)));

    if (DateFormat("dd MMMM yyyy").format(widget.schedulePickedDate) ==
        DateFormat("dd MMMM yyyy").format(temp.add(Duration(days: 6)))) {
      _selectedScheduleIndex = 2;
      return;
    }
    //------------------------------------------------------------------------//

    //----------------Nếu trạng thái trc đó ng dùng chọn là later-------------//
    // Dời về CN tuần trc để xét ngày pick có trùng với later ko
    var temp2 = DateTime.now().add(Duration(days: -(DateTime.now().weekday)));

    if (DateFormat("dd MMMM yyyy").format(widget.schedulePickedDate) ==
        DateFormat("dd MMMM yyyy").format(temp2.add(Duration(days: 15)))) {
      _scheduleChoseDateTime = temp2.add(Duration(days: 15));
      _scheduleChoseDateText =
          DateFormat("EEEEEEEE dd MMMM yyyy").format(_scheduleChoseDateTime);

      _selectedScheduleIndex = 3;
      return;
    }
    //------------------------------------------------------------------------//

    //---------------------Trường hợp còn lại (Choose date)-------------------//
    _selectedScheduleIndex = 4;
  }
}
