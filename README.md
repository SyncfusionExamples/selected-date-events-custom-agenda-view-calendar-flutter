# How to update the custom agenda view events when selected date changes in the Flutter Calendar?

A quick-start example to help you to update the custom agenda view events when selected date changes in the Flutter Calendar.

When you change the 'selectedDate' property of the 'CalendarController' in the Flutter Event Calendar, you can update the custom agenda view using the Datasource.

In this sample, you can get the selected date appointment details using the [onTap](https://pub.dev/documentation/syncfusion_flutter_calendar/latest/calendar/SfCalendar/onTap.html) callback, and the appointment start time will be compared to data source appointments based on those details. If the appointment start time is the same, the appointment will be displayed in the custom agenda view.

![customagendaview](https://user-images.githubusercontent.com/46158936/209326816-2861f15c-30c2-47ea-9c22-556122d3ff05.png)

For more details , you can refer to our [KB](https://www.syncfusion.com/kb/11570/how-to-update-the-custom-agenda-view-events-when-selected-date-changes-in-the-flutter) documentation

## Requirements to run the demo
* [VS Code](https://code.visualstudio.com/download)
* [Flutter SDK v1.22+](https://flutter.dev/docs/development/tools/sdk/overview)
* [For more development tools](https://flutter.dev/docs/development/tools/devtools/overview)

## How to run this application
To run this application, you need to first clone or download the ‘create a flutter maps widget in 10 minutes’ repository and open it in your preferred IDE. Then, build and run your project to view the output.

## Further help
For more help, check the [Syncfusion Flutter documentation](https://help.syncfusion.com/flutter/introduction/overview),
 [Flutter documentation](https://flutter.dev/docs/get-started/install).
