import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Appointment>? appointmentDetails = <Appointment>[];
  final CalendarController _calendarController = CalendarController();
  _DataSource? _dataSource;

  @override
  void initState() {
    _dataSource = _DataSource(getCalendarDataSource());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          SafeArea(
            child: SfCalendar(
              view: CalendarView.month,
              controller: _calendarController,
              dataSource: _dataSource,
              onTap: calendarTapped,
              onViewChanged: viewChanged,
            ),
          ),
          Expanded(
              child: Container(
                  color: Colors.black12,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(2),
                    itemCount: appointmentDetails!.length,
                    //subjectDetails.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          padding: const EdgeInsets.all(2),
                          height: 60,
                          color: appointmentDetails![index].color,
                          child: ListTile(
                            leading: Column(
                              children: <Widget>[
                                Text(
                                  appointmentDetails![index].isAllDay
                                      ? ''
                                      : DateFormat('hh:mm a').format(appointmentDetails![index].startTime),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.5),
                                ),
                                Text(
                                  appointmentDetails![index].isAllDay
                                      ? 'All day'
                                      : '',
                                  style: const TextStyle(
                                      height: 0.5, color: Colors.white),
                                ),
                                Text(
                                  appointmentDetails![index].isAllDay
                                      ? ''
                                      : DateFormat('hh:mm a').format(appointmentDetails![index].endTime),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Container(
                                child: Icon(
                              getIcon(appointmentDetails![index].subject),
                              size: 30,
                              color: Colors.white,
                            )),
                            title: Container(
                                child: Text(
                                    appointmentDetails![index].subject,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))),
                          ));
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      height: 5,
                    ),
                  )))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        _updateAppointmentDetails();
      });
    }
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      var midDate = (viewChangedDetails
          .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]);
      if (midDate.month == DateTime.now().month) {
        _calendarController.selectedDate = DateTime.now();
      } else {
        _calendarController.selectedDate = DateTime(
          midDate.year,
          midDate.month,
          01,
          9,
          0,
          0,
        );
      }

      _updateAppointmentDetails();
    });
  }

  void _updateAppointmentDetails() {
    appointmentDetails = <Appointment>[];
    final DateTime viewStartDate = DateTime(
        _calendarController.selectedDate!.year,
        _calendarController.selectedDate!.month,
        _calendarController.selectedDate!.day,
        0,
        0,
        0);
    final DateTime viewEndDate = DateTime(
        _calendarController.selectedDate!.year,
        _calendarController.selectedDate!.month,
        _calendarController.selectedDate!.day,
        23,
        59,
        59);
    if (_dataSource!.appointments == null || _dataSource!.appointments!.isEmpty) {
      return;
    }
    for (int i = 0; i < _dataSource!.appointments!.length; i++) {
      final Appointment appointment = _dataSource!.appointments![i];
      if (appointment.recurrenceRule == null) {
        if (_isSameDate(viewStartDate, appointment.startTime) ||
            _isSameDate(viewStartDate, appointment.endTime) ||
            (appointment.startTime.isBefore(viewStartDate) &&
                appointment.endTime.isAfter(viewEndDate))) {
          appointmentDetails!.add(appointment);
        }
      } else {
        final List<DateTime> dateCollection =
            SfCalendar.getRecurrenceDateTimeCollection(
                appointment.recurrenceRule!, appointment.startTime);
        for (int j = 0; j < dateCollection.length; j++) {
          if (_isSameDate(dateCollection[j], viewStartDate)) {
            appointmentDetails!.add(appointment);
          }
        }
      }
    }
    setState(() {});
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    if (date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year) {
      return true;
    }

    return false;
  }

  List<Appointment> getCalendarDataSource() {
    List<Appointment> appointments = <Appointment>[];
    appointments.add(Appointment(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      subject: 'Meeting',
      color: Colors.green,
    ));
    appointments.add(Appointment(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      subject: 'Planning',
      color: Colors.red,
    ));
    appointments.add(Appointment(
      startTime: DateTime(2020, 5, 1, 9, 0, 0),
      endTime: DateTime(2020, 5, 1, 10, 0, 0),
      subject: 'Planning',
      color: Colors.yellow,
    ));
    appointments.add(Appointment(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        subject: 'Recurrence',
        color: const Color(0xFFfb21f66),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=2;COUNT=10'));

    return appointments;
  }

  IconData getIcon(String subject) {
    if (subject == 'Planning') {
      return Icons.subject;
    } else if (subject == 'Development Meeting   New York, U.S.A') {
      return Icons.people;
    } else if (subject == 'Support - Web Meeting   Dubai, UAE') {
      return Icons.settings;
    } else if (subject == 'Project Plan Meeting   Kuala Lumpur, Malaysia') {
      return Icons.check_circle_outline;
    } else if (subject == 'Retrospective') {
      return Icons.people_outline;
    } else if (subject == 'Project Release Meeting   Istanbul, Turkey') {
      return Icons.people_outline;
    } else if (subject == 'Customer Meeting   Tokyo, Japan') {
      return Icons.settings_phone;
    } else if (subject == 'Release Meeting') {
      return Icons.view_day;
    } else {
      return Icons.beach_access;
    }
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
