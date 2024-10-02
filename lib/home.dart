import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopwatchState {
  final Duration elapsedTime;
  final bool isRunning;
  final List<dynamic> laps;

  StopwatchState({
    required this.elapsedTime,
    required this.isRunning,
    required this.laps,
  });
}

class StopwatchNotifier extends StateNotifier<StopwatchState> {
  StopwatchNotifier()
      : super(StopwatchState(
            elapsedTime: Duration.zero, isRunning: false, laps: []));

  Timer? _timer;

  void start() {
    if (!state.isRunning) {
      _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
        state = StopwatchState(
          elapsedTime: state.elapsedTime + const Duration(milliseconds: 1),
          isRunning: true,
          laps: state.laps,
        );
      });
    }
  }

  void pause() {
    _timer?.cancel();
    state = StopwatchState(
      elapsedTime: state.elapsedTime,
      isRunning: false,
      laps: state.laps,
    );
  }

  void reset() {
    _timer?.cancel();
    state =
        StopwatchState(elapsedTime: Duration.zero, isRunning: false, laps: []);
  }

  void stop() {
    _timer?.cancel();
    state =
        StopwatchState(elapsedTime: Duration.zero, isRunning: false, laps: []);
  }

  void addLap(StopwatchNotifier notifier) {
    state.laps.add({
      'lap': 'LAP ${state.laps.length + 1}',
      'time': notifier.timeFormat(state.elapsedTime),
    });
    state = StopwatchState(
      elapsedTime: state.elapsedTime,
      isRunning: state.isRunning,
      laps: List.from(state.laps), // Create a new list for state immutability
    );
  }

  String timeFormat(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    String hours = twoDigits(duration.inHours.remainder(60));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = threeDigits(duration.inMilliseconds.remainder(1000));

    return '$hours:$minutes:$seconds:$milliseconds';
  }
}

final stopwatchProvider =
    StateNotifierProvider<StopwatchNotifier, StopwatchState>((ref) {
  return StopwatchNotifier();
});

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopwatch = ref.watch(stopwatchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.only(left: 25, top: 20),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 30,
            ),
          ),
          title: Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 15, right: 55, bottom: 5),
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                  color: const Color(0xFFECEFF9),
                  borderRadius: BorderRadius.circular(360)),
              child: const Center(
                child: Text(
                  'StopWatch',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 110),
            child: Center(
                child: InkWell(
              onTap: () {
                if (stopwatch.isRunning) {
                  ref
                      .read(stopwatchProvider.notifier)
                      .addLap(ref.read(stopwatchProvider.notifier));
                }
              },
              child: Container(
                  height: 270,
                  width: 270,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(360),
                      boxShadow: List.filled(
                          10,
                          BoxShadow(
                              color: const Color(0xFFE7EBF7), blurRadius: 30))),
                  child: Center(
                    child: Text(
                      ref
                          .read(stopwatchProvider.notifier)
                          .timeFormat(stopwatch.elapsedTime),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontFamily: 'Redex'),
                    ),
                  )),
            )),
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: ListView.builder(
              itemCount: stopwatch.laps.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 80),
              itemBuilder: (context, index) {
                final lapsItem = stopwatch.laps[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 30, left: 10, right: 5),
                  child: Container(
                    height: 120,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, right: 15),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 15),
                          child: Text(
                            lapsItem['lap'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Redex',
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 15),
                          child: Text(
                            lapsItem['time'],
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Ubuntu',
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        if (stopwatch.isRunning) {
                          ref.read(stopwatchProvider.notifier).pause();
                        } else {
                          ref.read(stopwatchProvider.notifier).start();
                        }
                      },
                      child: Container(
                        height: 70,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(360),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              stopwatch.isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.grey.shade300,
                              size: 35,
                            ),
                            Container(
                              width: 10,
                            ),
                            Text(
                              stopwatch.isRunning
                                  ? 'PAUSE'
                                  : stopwatch.elapsedTime > Duration.zero
                                      ? 'RESUME'
                                      : 'START',
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 19,
                                fontFamily: 'Ubuntu',
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
                const Spacer(),
                Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: InkWell(
                      onTap: () {
                        if (stopwatch.isRunning) {
                          ref.read(stopwatchProvider.notifier).stop();
                        } else {
                          ref.read(stopwatchProvider.notifier).reset();
                        }
                      },
                      child: Container(
                        height: 70,
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7EBF7),
                          borderRadius: BorderRadius.circular(360),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              stopwatch.isRunning ? Icons.stop : Icons.refresh,
                              color: Colors.black87,
                              size: 35,
                            ),
                            Container(
                              width: 10,
                            ),
                            Text(
                              stopwatch.isRunning ? 'STOP' : 'RESET',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 19,
                                fontFamily: 'Ubuntu',
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
