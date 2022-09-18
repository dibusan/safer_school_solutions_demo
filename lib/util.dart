import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart';

// Question 1 : Load Data
Future<Map<String, dynamic>> getData() async {
  // ===== This would work if we had actual connection to the API =======
  // ===== Commenting out for testing. Loading test data from file ======
  // var urlStr = "https://www.myapi.com/data";
  // var uri = Uri.parse(urlStr);
  // var res = await http.get(
  //   uri,
  //   headers: {
  //     'Token-Id': 'test-token',
  //     'Content-Type': 'application/json',
  //   },
  // );
  // if(res.statusCode != 200) {
  //   var err = "[${res.statusCode}] Failed to load data.";
  //   print(err);
  //   throw Exception(err);
  // }
  //  return jsonDecode(res.body);
  return {
    "LastCompletedTime": "July 21, 2022 at 10:19:04 PM UTC-4",
    "assessmentName": "Test Single Page Drill Tracking Assignment",
    "assignmentDueDate": "2022-08-01T17:00:00.000Z",
    "assignmentType": "drill",
    "author": "danielc@saferschoolsolutions.com",
    "Completed": [
      {
        "completedBy": "phillip@saferschoolsolutions.com",
        "completedTime": 1649728991221,
        "content": {
          "0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "yes"
        }
      },
      {
        "completedBy": "phillip@saferschoolsolutions.com",
        "completedTime": 1649730338960,
        "content": {"0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "no"}
      },
      {
        "completedBy": "vincent@saferschoolsolutions.com",
        "completedTime": 1649730489829,
        "content": {"0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "no"}
      },
      {
        "completedBy": "phillip@saferschoolsolutions.com",
        "completedTime": 1649730664608,
        "content": {
          "0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "yes"
        }
      },
      {
        "completedBy": "phillip@saferschoolsolutions.com",
        "completedTime": 1649730698655,
        "content": {
          "0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "yes"
        }
      },
      {
        "completedBy": "vincent@saferschoolsolutions.com",
        "completedTime": 1649790782499,
        "content": {
          "0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "yes"
        }
      },
      {
        "completedBy": "vincent@saferschoolsolutions.com",
        "completedTime": 1649803329856,
        "content": {
          "0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "yes"
        }
      },
      {
        "completedBy": "vincent@saferschoolsolutions.com",
        "completedTime": 1649822064384,
        "content": {"0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "no"}
      },
      {
        "completedBy": "phillip@saferschoolsolutions.com",
        "completedTime": 1649878185627,
        "content": {"0c946643-5a83-523.8393016269043-baea-055b27b51e8-10": "no"}
      }
    ]
  };
}

// Question 2 : Aggregate Data
Map<String, dynamic> aggregateData(Map<String, dynamic> data) {
  List<dynamic> completedArr = data['Completed'];

  Map<String, dynamic> responsesByQuestion = {};
  Map<String, dynamic> responsesByUser = {};

  for (var survey in completedArr) {
    var content = survey['content'] as Map<String, String>;
    var user = (survey['completedBy'] as String).split("@").first;


    // In the sample data, content always has only one key, but here I assume
    // it can have multiple just to be save
    content.forEach((key, value) {
      // Aggregate response totals for each question
      if (!responsesByQuestion.containsKey(key)) {
        responsesByQuestion[key] = {};
      }
      if (!responsesByQuestion[key].containsKey(value)) {
        responsesByQuestion[key][value] = 0;
      }
      responsesByQuestion[key][value] += 1;

      // Aggregate responses per user for each question
      if (!responsesByUser.containsKey(key)) {
        responsesByUser[key] = {};
      }
      if (!responsesByUser[key].containsKey(user)) {
        responsesByUser[key][user] = {};
      }
      if (!responsesByUser[key][user].containsKey(value)) {
        responsesByUser[key][user][value] = 0;
      }
      responsesByUser[key][user][value] += 1;
      // responsesByUser[key][user]['total'] += 1;
    });
  }

  return {
    'responsesByQuestion': responsesByQuestion,
    'responsesByUser': responsesByUser,
  };
}

// Question 3 : Create Charts
Widget pieChart(Map<String, dynamic> data) {
  List<ResponseTally> qrs = [];
  data.forEach((key, value) {
    value.forEach((key2, value2) {
      qrs.add(ResponseTally('', key2, value2));
    });
    return;
  });

  Series<ResponseTally, String> series = Series<ResponseTally, String>(
    id: '',
    domainFn: (ResponseTally q, _) => q.response,
    measureFn: (ResponseTally q, _) => q.total,
    data: qrs,
    labelAccessorFn: (ResponseTally q, _) => "${q.total} : ${q.response}",
  );

  return SizedBox(
    height: 200,
    width: 800,
    child: PieChart(
      [series],
      defaultRenderer: ArcRendererConfig(
        arcRendererDecorators: [
          ArcLabelDecorator<String>(labelPosition: ArcLabelPosition.outside)
        ],
      ),
    ),
  );
}


Widget barChart(Map<String, dynamic> data) {
  List<ResponseTally> qrs = [];
  data.forEach((key, value) {
    value.forEach((key2, value2) {
      value2.forEach((key3, value3) {
        qrs.add(ResponseTally(key2, key3, value3));
      });
    });
    return;
  });

  Series<ResponseTally, String> series = Series<ResponseTally, String>(
    id: '',
    domainFn: (ResponseTally q, _) => "${q.user} - ${q.response}",
    measureFn: (ResponseTally q, _) => q.total,
    data: qrs,
    labelAccessorFn: (ResponseTally q, _) => "${q.total} : ${q.response}",
  );

  return SizedBox(
    height: 200,
    width: 600,
    child: BarChart(
      [series],
    ),
  );
}


class ResponseTally {
  String user;
  String response;
  int total;

  ResponseTally(this.user, this.response, this.total);
}
