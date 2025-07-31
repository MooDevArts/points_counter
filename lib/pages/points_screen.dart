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
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];
  int roundsPlayed = 0;
  String? playerWithLeastPoints;

  @override
  void initState() {
    super.initState();
    _getRoundsPlayed();
  }

  Future<void> _getRoundsPlayed() async {
    final gameRef = widget.playersRef.parent;
    if (gameRef != null) {
      final snapshot = await gameRef.child('roundsPlayed').get();
      if (snapshot.exists) {
        setState(() {
          roundsPlayed = (snapshot.value as num).toInt();
        });
      }
    }
  }

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
                  if (roundsPlayed > 0)
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
                                      padding: const EdgeInsets.only(
                                        right: 4.0,
                                      ),
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
                                        if (idx < 0 ||
                                            idx >= playerNames.length)
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
                  SizedBox(height: 8),
                  Text(
                    'Rounds Played: $roundsPlayed',
                    style: TextStyle(fontSize: 12),
                  ),
                  if (roundsPlayed > 0)
                    Text(
                      'Last Round Winner: $playerWithLeastPoints',
                      style: TextStyle(fontSize: 12),
                    ),
                  // SizedBox(height: 8),
                  PointsUpdateForm(
                    playerKeys: playerKeys,
                    playerNames: playerNames,
                    playersRef: widget.playersRef,
                    roundsPlayed: roundsPlayed,
                    onRoundUpdated: (int newRoundsPlayed) {
                      setState(() {
                        roundsPlayed = newRoundsPlayed;
                      });
                    },
                    onLeastPointsPlayerUpdated: (String? player) {
                      setState(() {
                        playerWithLeastPoints = player;
                      });
                    },
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
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Delete Game'),
              content: Text(
                'Are you sure you want to delete this game? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final gameRef = widget.playersRef.parent;
            if (gameRef != null) {
              await gameRef.remove();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
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
  final int roundsPlayed;
  final Function(int) onRoundUpdated;
  final Function(String?) onLeastPointsPlayerUpdated;

  const PointsUpdateForm({
    Key? key,
    required this.playerKeys,
    required this.playerNames,
    required this.playersRef,
    required this.roundsPlayed,
    required this.onRoundUpdated,
    required this.onLeastPointsPlayerUpdated,
  }) : super(key: key);

  @override
  _PointsUpdateFormState createState() => _PointsUpdateFormState();
}

class _PointsUpdateFormState extends State<PointsUpdateForm> {
  late List<TextEditingController> controllers;
  late List<double> sliderValues;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.playerKeys.length,
      (_) => TextEditingController(),
    );
    sliderValues = List.generate(widget.playerKeys.length, (_) => 0.0);
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate all fields have values and are within range
    for (int i = 0; i < widget.playerKeys.length; i++) {
      if (controllers[i].text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please fill all values')));
        return;
      }
      final number = double.tryParse(controllers[i].text);
      if (number == null || number < -2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid value: ${widget.playerNames[i]}')),
        );
        return;
      }
      sliderValues[i] = number;
    }

    // Update points in Firebase
    for (int i = 0; i < widget.playerKeys.length; i++) {
      final key = widget.playerKeys[i];
      final enteredPoints = sliderValues[i].toInt(); // Use slider value
      final playerRef = widget.playersRef.child(key).child('points');
      await playerRef.runTransaction((currentData) {
        final currentPoints = (currentData as int?) ?? 0;
        return Transaction.success(currentPoints + enteredPoints);
      });
    }

    // Update roundsPlayed in Firebase
    final newRoundsPlayed = widget.roundsPlayed + 1; // Increment roundsPlayed
    final gameRef = widget.playersRef.parent;
    if (gameRef != null) {
      await gameRef.update({'roundsPlayed': newRoundsPlayed});
    }
    widget.onRoundUpdated(newRoundsPlayed); // Update the value in PointsScreen

    String? leastPointsPlayer;
    double leastPoints = double.infinity;
    for (int i = 0; i < widget.playerKeys.length; i++) {
      if (sliderValues[i] < leastPoints) {
        leastPoints = sliderValues[i];
        leastPointsPlayer = widget.playerNames[i];
      }
    }

    widget.onLeastPointsPlayerUpdated(leastPointsPlayer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear the form fields
    setState(() {
      for (int i = 0; i < widget.playerKeys.length; i++) {
        controllers[i].clear(); // Clear text field
        sliderValues[i] = 0.0; // Reset slider value
      }
    });

    // Remove focus from all fields
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(widget.playerKeys.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.playerNames[i]}:'),
                Slider(
                  min: -2,
                  max: 50,
                  divisions: 50,
                  label: sliderValues[i].round().toString(),
                  value: sliderValues[i],
                  onChanged: (value) {
                    setState(() {
                      sliderValues[i] = value;
                      controllers[i].text = value
                          .round()
                          .toString(); // Update text field
                    });
                  },
                ),
                TextFormField(
                  controller: controllers[i],
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter points',
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 12),
        ElevatedButton(onPressed: _submit, child: Text('Submit')),
        SizedBox(height: 50),
      ],
    );
  }
}
