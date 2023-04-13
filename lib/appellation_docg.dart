import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'search_results.dart';
import 'main.dart';
import 'navigation.dart';
import 'search_sort_buttons.dart';
import 'single_wine_tile.dart';
import 'comparisons_screen.dart';


Future<List<Map<String, dynamic>>> searchWines() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'allwines9.db');
  
  Database database = await openDatabase(path);
  List<Map<String, dynamic>> results = await database.rawQuery(
    "SELECT AppellationName, COUNT(*) as count FROM allwines WHERE AppellationLevel = 'DOCG' AND Entry = 1 GROUP BY AppellationName",
  );
  await database.close();
  return results;
}

class DocgScreen extends StatefulWidget {
  @override
  _DocgScreenState createState() => _DocgScreenState();
}

class _DocgScreenState extends State<DocgScreen> {
  List<Map<String, dynamic>> wines = [];

    @override
  void initState() {
    super.initState();
    searchWines().then((results) {
      setState(() {
        wines = results;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AGReaTWine'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: wines.length,
              itemBuilder: (context, index) {
                final wine = wines[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntriesScreen(
                          appellationName: wine['AppellationName'],
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(wine['AppellationName']),
                        Text('${wine['count']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ComparisonsScreen()
        ],
      ),
      bottomNavigationBar: AGreatBottomNavigationBar(),
    );
  }
}

class EntriesScreen extends StatefulWidget {
  final String appellationName;

  EntriesScreen({required this.appellationName});

  @override
  _EntriesScreenState createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  List<Map<String, dynamic>> entries = [];
  List<Map<String, dynamic>> groupedEntries = [];
  TextEditingController _searchController = TextEditingController();
  Map<String, bool> _sortDescendingMap = {}; // add map to track sorting of each wine type

  // Scroll Controller and List to enable Scroll to Group
  final ScrollController _scrollController = ScrollController();
  static const double _groupHeaderHeight = 32;
  final List<String> _groupTitles = [];

  @override
  void initState() {
    super.initState();
    searchEntries().then((results) {
      setState(() {
        entries = results;
        _groupEntriesByWineType();
      });
    });
  }

  void _groupEntriesByWineType() {
    groupedEntries = [];
    Map<String, List<Map<String, dynamic>>> wineTypeMap = {};
    entries.forEach((entry) {
      String wineType = entry['WineType'];
      if (!wineTypeMap.containsKey(wineType)) {
        wineTypeMap[wineType] = [];
        _sortDescendingMap[wineType] = true; // add wine type to the sort descending map
        _groupTitles.add(wineType); // add wine type to the list of group titles
      }
      wineTypeMap[wineType]!.add(entry);
    });
    wineTypeMap.forEach((wineType, entries) {
      if (entries.isNotEmpty) {
        // sort entries by RS value
        entries.sort((a, b) {
          bool sortDescending = _sortDescendingMap[wineType]!; // get sorting value from map
          if (sortDescending) {
            return b['RS'].compareTo(a['RS']);
          } else {
            return a['RS'].compareTo(b['RS']);
          }
        });
        groupedEntries.add({
          'WineType': wineType,
          'Entries': entries,
        });
      }
    });
  }

  void _resetFilter() {
    _searchController.clear(); // clear the search text field
    searchEntries().then((results) {
      setState(() {
        entries = results;
        _groupEntriesByWineType();
      });
    });
  }

  Future<List<Map<String, dynamic>>> searchEntries() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'allwines9.db');

    Database database = await openDatabase(path);
    List<Map<String, dynamic>> results = await database.rawQuery(
      "SELECT * FROM allwines WHERE AppellationName = ? AND Entry = 1 AND FullName LIKE ?",
      [widget.appellationName, '%${_searchController.text}%'], // filter by the search text field
    );
    await database.close();
    return results;
  }

  // Function to Scroll to Group
  void _scrollToGroup(String groupTitle) {
    int groupIndex = _groupTitles.indexOf(groupTitle);
    double totalHeight = _groupHeaderHeight * groupIndex +
        groupedEntries
            .sublist(0, groupIndex)
            .expand((group) => group['Entries'])
            .length *
            SingleWineTile.tileHeight;

    _scrollController.animateTo(totalHeight,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.appellationName} Appellation Wine List"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // add controller to access _scrollToGroup function
              itemCount: groupedEntries.length,
              itemBuilder: (context, index) {
                final group = groupedEntries[index];
                List<Map<String, dynamic>> entries = group['Entries']; // get wine type entries
                bool sortDescending = _sortDescendingMap[group['WineType']]!; // get sorting value from map

                // sort entries by RS value
                entries.sort((a, b) {
                  if (sortDescending) {
                    return b['RS'].compareTo(a['RS']);
                  } else {
                    return a['RS'].compareTo(b['RS']);
                  }
                });

                return entries.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            color: utils.primaryLight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                  left: 8.0, top: 0),
                                  child: Text(
                                    group['WineType'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      'RS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.arrow_downward, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          _sortDescendingMap[group['WineType']] = false; // set sorting value to false
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.arrow_upward, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          _sortDescendingMap[group['WineType']] = true; // set sorting value to true
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final isSecondLevel = false;
                              final isThirdLevel = false;
                              return SingleWineTile(result: entry, isSecondLevel: isSecondLevel, isThirdLevel: isThirdLevel);
                            },
                          ),
                        ],
                      )
                    : SizedBox.shrink();
              },
            ),
          ),
          GroupingsWidget(
            groupTitles: _groupTitles,
            scrollToGroup: _scrollToGroup,
          ),
        ],
      ),
      bottomNavigationBar: AGreatBottomNavigationBar(),
    );
  }
}

class GroupingsWidget extends StatelessWidget {
  final List<String> groupTitles;
  final Function scrollToGroup;

  GroupingsWidget({
    required this.groupTitles,
    required this.scrollToGroup,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              itemCount: groupTitles.length,
              itemBuilder: (context, index) {
                final item = groupTitles[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    Navigator.pop(context);
                    scrollToGroup(item); // call to function to scroll to group
                  },
                );
              },
            );
          },
        );
      },
      child: Container(
        height: 40,
        color: utils.primaryLight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Appellation wine types',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.menu_open, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15.0),topLeft: Radius.circular(15.0)),
                        color: utils.primaryLight,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: Offset(0, -1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: groupTitles.length,
                        itemBuilder: (context, index) {
                          final item = groupTitles[index];
                          return ListTile(
                            title: Center(child: Text(item, style: TextStyle(fontSize: 18, color: Colors.white))),
                            onTap: () {
                              Navigator.pop(context);
                              scrollToGroup(item); // call to function to scroll to group
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}