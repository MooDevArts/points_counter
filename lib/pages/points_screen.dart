import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PointsScreen extends StatefulWidget {
  final DatabaseReference playersRef;
  const PointsScreen({super.key, required this.playersRef});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  // Define a list of colors for the bars
  final List<Color> barColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Points Screen')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
          child: StreamBuilder<DatabaseEvent>(
            stream: widget.playersRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return Center(child: Text('No players found.'));
              }
              final playersMap = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );
              final playerKeys = playersMap.keys.toList();

              // Prepare data for the bar chart
              final barGroups = <BarChartGroupData>[];
              final playerNames = <String>[];
              final playerPoints = <double>[];
              for (int i = 0; i < playerKeys.length; i++) {
                final key = playerKeys[i];
                final value = playersMap[key];
                if (value is Map) {
                  final player = Map<String, dynamic>.from(value);
                  final name = player['name'] ?? 'No name';
                  final points = (player['points'] ?? 0).toDouble();
                  playerNames.add(name);
                  playerPoints.add(points);
                  barGroups.add(
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: points,
                          color: barColors[i % barColors.length],
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                          // Show points value on top of each bar
                          rodStackItems: [],
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  );
                }
              }

              if (barGroups.isEmpty) {
                return Center(child: Text('No points data to display.'));
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 320,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                    ),
                                  );
                                },
                                interval: 1,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= playerNames.length)
                                        return Container();
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          '${playerNames[idx]}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            enabled: false,

                            touchTooltipData: BarTouchTooltipData(
                              tooltipMargin: 8,
                              // tooltipBgColor: Colors.black87,
                              tooltipPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${playerPoints[group.x].toInt()}',
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  PointsUpdateForm(
                    playerKeys: playerKeys,
                    playerNames: playerNames,
                    playersRef: widget.playersRef,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          // Assuming you have the gameRef path as parent of playersRef
          final gameRef = widget.playersRef.parent;
          if (gameRef != null) {
            await gameRef.remove();
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        },
        tooltip: 'Delete Game',
        child: Icon(Icons.delete, color: Colors.white),
      ),
    );
  }
}

class PointsUpdateForm extends StatefulWidget {
  final List<String> playerKeys;
  final List<String> playerNames;
  final DatabaseReference playersRef;

  const PointsUpdateForm({
    super.key,
    required this.playerKeys,
    required this.playerNames,
    required this.playersRef,
  });

  @override
  State<PointsUpdateForm> createState() => _PointsUpdateFormState();
}

class _PointsUpdateFormState extends State<PointsUpdateForm> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.playerKeys.length,
      (_) => TextEditingController(),
    );
    focusNodes = List.generate(widget.playerKeys.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    // Check all fields are filled and valid numbers
    for (final c in controllers) {
      if (c.text.trim().isEmpty || int.tryParse(c.text.trim()) == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Enter all points')));
        return;
      }
    }

    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 300));

    // Update points in Firebase
    for (int i = 0; i < widget.playerKeys.length; i++) {
      final key = widget.playerKeys[i];
      final enteredPoints = int.parse(controllers[i].text.trim());
      final playerRef = widget.playersRef.child(key).child('points');
      // Use a transaction to add the entered points to the existing value
      await playerRef.runTransaction((currentData) {
        final currentPoints = (currentData as int?) ?? 0;
        return Transaction.success(currentPoints + enteredPoints);
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Updated successfully')));

    // Optionally clear the fields
    for (final c in controllers) {
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          ...List.generate(widget.playerKeys.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextFormField(
                controller: controllers[i],
                focusNode: focusNodes[i],
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                textInputAction: i == widget.playerKeys.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                onFieldSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  if (i < controllers.length - 1) {
                    FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                  } else {
                    _submit();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Add points for ${widget.playerNames[i]}',
                  border: OutlineInputBorder(),
                ),
              ),
            );
          }),
          SizedBox(height: 12),
          ElevatedButton(onPressed: _submit, child: Text('Submit')),
        ],
      ),
    );
  }
}
