import 'dart:ui';
import 'package:flashy_tab_bar/flashy_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:parse_video/components/bottomSheet.dart';
import 'package:parse_video/components/taskListItem.dart';
import 'package:parse_video/plugin/download.dart';

class DownLoadPage extends StatefulWidget {
  @override
  _DownLoadPageState createState() => _DownLoadPageState();
}

class _DownLoadPageState extends State<DownLoadPage> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF3E3E3E),
          baseColor: Colors.white,
          intensity: 0.5,
          lightSource: LightSource.topLeft,
          depth: 10,
        ),
        darkTheme: neumorphicDefaultDarkTheme.copyWith(
            defaultTextColor: Colors.white70),
        child: _Page());
  }
}

class _Page extends StatefulWidget {
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  List<Widget> tasksList = [];
  int _selectedIndex = 0;
  List<DownloadTask> tasks = [];
  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.navigate_before,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 150,
              child: FlashyTabBar(
                backgroundColor: Colors.black,
                animationCurve: Curves.linear,
                selectedIndex: _selectedIndex,
                showElevation: false, // use this to remove appBar's elevation
                onItemSelected: (index) => loadTasks(index),
                items: [
                  FlashyTabBarItem(
                    activeColor: Colors.white,
                    icon: Icon(
                      Icons.cloud_download,
                      color: Colors.white,
                    ),
                    title: Text(
                      '下载中',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  FlashyTabBarItem(
                    activeColor: Colors.white,
                    icon: Icon(
                      Icons.queue_music,
                      color: Colors.white,
                    ),
                    title: Text(
                      '已下载',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    loadTasks(_selectedIndex);

    super.initState();
  }

  loadTasks(int index) async {
    String query = '';
    if (index == 0) {
      query = 'SELECT * FROM task WHERE status!=3';
    } else {
      query = 'SELECT * FROM task WHERE status=3';
    }
    tasks = await FlutterDownloader.loadTasksWithRawQuery(query: query);
    tasksList = tasks
        .map((DownloadTask movie) => TaskListTile(
              movie: movie,
              refrish: () {
                loadTasks(_selectedIndex);
              },
              onPressed: null,
            ))
        .toList();
    setState(() {
      _selectedIndex = index;
    });
  }

  showBottomOperateSheet(DownloadTask movie) async {
    if (_selectedIndex == 0) {
      await BottomSheetManage().showDownLoadBottomSheet(
        context,
        [
          SimpleListTile(
            title: '取消下载',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().cancel(movie.taskId);
            },
          ),
          SimpleListTile(
            title: '暂停下载',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().pause(movie.taskId);
            },
          ),
          SimpleListTile(
            title: '恢复下载',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance()
                  .resume(movie.taskId)
                  .then((value) => {loadTasks(_selectedIndex)});
            },
          ),
          SimpleListTile(
            title: '重试',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance()
                  .retry(movie.taskId)
                  .then((value) => {loadTasks(_selectedIndex)});
            },
          ),
          SimpleListTile(
            title: '删除',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().remove(movie.taskId);
            },
          ),
        ],
      );
    } else {
      await BottomSheetManage().showDownLoadBottomSheet(
        context,
        [
          SimpleListTile(
            title: '播放',
            onTap: () {},
          ),
          SimpleListTile(
            title: '删除',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().delete(movie.taskId);
              loadTasks(_selectedIndex);
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NeumorphicBackground(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              SizedBox(height: 10),
              Expanded(child: ListView(children: tasksList)),
            ],
          ),
        ),
      ),
    );
  }
}
