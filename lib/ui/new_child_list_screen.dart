import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:todoapp/animation/fade_route_builder.dart';
import 'package:todoapp/doit_database_bus/doit_database_helper.dart';
import 'package:todoapp/ui/add_task_page.dart';
import 'package:todoapp/ui/child_list_choose_color_screen.dart';
import 'package:todoapp/ui_variables/achievement_lists_screen_variables.dart';
import 'package:todoapp/ui_variables/list_screen_variables.dart';

class NewChildListScreen extends StatefulWidget {
  final IconData listIcon;
  final Color listColor;
  final String listTiltle;
  final Object tag;

  NewChildListScreen({
    this.listColor,
    this.listIcon,
    this.listTiltle,
    this.tag,
  });

  @override
  _NewChildListScreenState createState() => _NewChildListScreenState();
}

class _NewChildListScreenState extends State<NewChildListScreen> {
  // Các biến cho animation chuyển screen qua screen add task
  final Duration animationDuration = Duration(milliseconds: 200);
  final Duration delay = Duration(milliseconds: 200);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;

  String _listTitle;
  Color _listColor;
  // biến để check xem ng dùng đã edit tên list thành tên mới hay chưa
  bool _isFinished = false;

  // Các biến dùng cho phần sửa task name
  TextEditingController _editTaskTextController;
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () async {
        childListScreenOpacity = 1.0;

        Navigator.pop(context);
      },
      child: SafeArea(
        child: Hero(
          tag: '${widget.tag}',
          child: _listWidget(widget.listTiltle, widget.listColor),
        ),
      ),
    );
  }

  // Widget để tạo ra UI cho list
  Widget _listWidget(String listTitle, Color listColor) {
    _listTitle = listTitle;
    _listColor = listColor;

    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: widget.listColor,
        body: Stack(
          children: <Widget>[
            _buildTextAndAddIcon(),
            _displayListTitleWiedget(),
            _changeColorButton(),
            _closeButton(),
            _ripple(),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: listColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  // Phần dấu cộng và dòng text
  Widget _buildTextAndAddIcon() => Align(
        alignment: Alignment.center,
        child: Container(
          height: 150.0,
          child: Column(
            children: <Widget>[
              RectGetter(
                key: rectGetterKey,
                child: Container(
                  padding: EdgeInsets.only(bottom: 32.0, left: 15.0),
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      alignment: Alignment.center,
                      icon: Container(
                          child: Image.asset(
                        'images/add.png',
                        width: 40.0,
                        height: 40.0,
                        color: _listColor == Color(0xfffafafa)
                            ? Colors.black
                            : Colors.white,
                        fit: BoxFit.cover,
                      )),
                      onPressed: _onAddButtonPressed,
                    ),
                  ),
                ),
              ),
              Text(
                "Add new DOIT to this list",
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 25.0,
                    color: _listColor == Color(0xfffafafa)
                        ? Colors.black
                        : Colors.white),
              ),
            ],
          ),
        ),
      );

  // Phần hiển thị list title
  Widget _displayListTitleWiedget() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            width: 220.0,
            padding: EdgeInsets.only(
              bottom: 40.0,
            ),
            child: GestureDetector(
              onTap: () {
                _editTaskName();
              },
              child: Text(
                "$_listTitle",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 30.0,
                    color: _listColor == Color(0xfffafafa)
                        ? Colors.black
                        : Colors.white),
              ),
            )),
      );

  // Hàm để add một list mới
  void _editTaskName() {
    _editTaskTextController = TextEditingController(
        text: "${childListTitles[lastChildListChoseIndex]}");

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(top: 12.0, left: 50.0, right: 50.0),
            height: MediaQuery.of(context).viewInsets.bottom == 0
                ? 100.0
                : 100 + MediaQuery.of(context).viewInsets.bottom,
            child: TextField(
              controller: _editTaskTextController,
              maxLines: 1,
              textAlign: TextAlign.center,
              autofocus: true,
              style: TextStyle(fontSize: 30.0),
              decoration: InputDecoration(
                  hintText: "New List",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  )),
              onSubmitted: (value) {
                setState(() {
                  if (value.isEmpty == false &&
                      childListTitles[lastChildListChoseIndex] != value) {
                    childListTitles[lastChildListChoseIndex] = value;
                    _isFinished = true;

                    FocusScope.of(context).unfocus();

                    //--------------------------------------------//
                    // _databaseHelper.updateListData(ListData(
                    //     listId: lastChildListChoseIndex,
                    //     listName: listTitles[lastChildListChoseIndex],
                    //     listColor:
                    //         listColors[lastChildListChoseIndex + 1].toString()));
                    //--------------------------------------------//

                  }
                });
              },
            ),
          );
        }).whenComplete(() {
      if (_isFinished) {
        setState(() {
          _isFinished = false;
          _updateListWidgets();

          // Push về để cập nhật test mới
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
            return NewChildListScreen(
              listTiltle: listTitles[lastChildListChoseIndex],
              listColor: listColors[lastChildListChoseIndex + 1],
              listIcon: null,
              tag: lastChildListChoseIndex,
            );
          }));
        });
      }
    });
  }

  // Hàm để update widget của task screen khi người dùng đã thay đổi tên cho list xong
  void _updateListWidgets() {
    setState(() {
      childListWidgets[lastChoseMotherWidgetIndex][lastChildListChoseIndex] =
          childListWidget(
              childListTitles[lastChildListChoseIndex],
              childListColors[lastChildListChoseIndex + 1],
              childListColors[lastChildListChoseIndex + 1] == Color(0xfffafafa)
                  ? childListTitleColors[0]
                  : childListTitleColors[1],
              null);
    });
  }

  // Change color button
  Widget _changeColorButton() => Opacity(
        opacity: widget.listTiltle.isEmpty ? 0.0 : 1.0,
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.only(bottom: 32.0, left: 15.0),
          child: Container(
            width: 50.0,
            height: 50.0,
            child: IconButton(
              alignment: Alignment.center,
              icon: Container(
                  child: Image.asset(
                'images/change_color.png',
                width: 40.0,
                height: 40.0,
                color: _listColor == Color(0xfffafafa)
                    ? Colors.black
                    : Colors.white,
                fit: BoxFit.cover,
              )),
              onPressed: () {
                isChildPickColorFinished = true;

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) {
                  return ChildListChooseColorScreen(
                    childListTitle: childListTitles[childListTitles.length - 1],
                  );
                }));
              },
            ),
          ),
        ),
      );

  // Close button
  Widget _closeButton() => Opacity(
        opacity: widget.listTiltle.isEmpty ? 0.0 : 1.0,
        child: Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(bottom: 32.0, right: 15.0),
          child: Container(
            width: 50.0,
            height: 50.0,
            child: IconButton(
              alignment: Alignment.center,
              icon: Container(
                  child: Image.asset(
                'images/close.png',
                width: 40.0,
                height: 40.0,
                color: _listColor == Color(0xfffafafa)
                    ? Colors.black
                    : Colors.white,
                fit: BoxFit.cover,
              )),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );

  // Hàm sự kiện để chạy animation
  void _onAddButtonPressed() async {
    // Cập nhật list dc ng dùng chọn để add task
    // choseListIndex = lastChildListChoseIndex;

    setState(() => rect = RectGetter.getRectFromKey(
        rectGetterKey)); //<-- set rect to be size of fab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //<-- on the next frame...
      setState(() => rect = rect.inflate(1.1 *
          MediaQuery.of(context).size.longestSide)); //<-- set rect to be big
      Future.delayed(animationDuration + delay,
          _goToAddTaskScreen); //<-- after delay, go to next page
    });
  }

  // Hàm để gọi lệnh chuyển sang trang thêm task
  void _goToAddTaskScreen() {
    isChildPickColorFinished = false;
    Navigator.of(context)
        .pushReplacement(FadeRouteBuilder(
            page: AddTaskPage(
          lastFocusedScreen: mainScreenLastFocusedIndex,
          settingScreenIndex: mainScreenSettingScreenIndex,
        )))
        .then((_) => setState(() => rect = null));
  }

  // Widget tạo animation
  Widget _ripple() {
    if (rect == null) {
      return Container();
    }
    return AnimatedPositioned(
      duration: animationDuration, //<--specify the animation duration
      left: rect.left,
      right: MediaQuery.of(context).size.width - rect.right - 20.0,
      top: rect.top,
      bottom: MediaQuery.of(context).size.height - rect.bottom + 50.0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF425195),
        ),
      ),
    );
  }
}
