import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/resultpage.dart';
import 'package:quiz/results.dart';
import 'package:quiz/transition.dart';
import 'package:quiz/variables.dart';

class GetJson extends StatelessWidget {
  // accept the langname as a parameter

  final String test;
  String assettoload;
  Results results;
  GetJson(this.test, this.results);

  // a function
  // sets the asset to a particular JSON file
  // and opens the JSON
  setasset() {
    if (test == "Test1") {
      assettoload = "assets/model.json";
    } else {
      assettoload =
          "assets/model.json"; //For the second round change the name of the file to the one you are inserting and follow the same format used in model.json file else it won't work
    }
  }

  @override
  Widget build(BuildContext context) {
    // this function is called before the build so that
    // the string assettoload is avialable to the DefaultAssetBuilder
    setasset();
    // and now we return the FutureBuilder to load and decode JSON
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString(assettoload, cache: true),
      builder: (context, snapshot) {
        List mydata = json.decode(snapshot.data.toString());
        if (mydata == null) {
          return Scaffold(
            body: Center(
              child: Text(
                "Loading",
              ),
            ),
          );
        } else {
          return QuizPage(
            mydata: mydata,
            test: test,
            results: results,
          );
        }
      },
    );
  }
}

class QuizPage extends StatefulWidget {
  final mydata;
  final test;
  final results;
  QuizPage(
      {Key key,
      @required this.mydata,
      @required this.test,
      @required this.results})
      : super(key: key);
  @override
  _QuizPageState createState() => _QuizPageState(mydata, test, results);
}

class _QuizPageState extends State<QuizPage> {
  // These variables are important do not change them

  var mydata;
  var test;
  List<String> question, answer;
  Results results;
  Map<String, Color> btnColor;
  double rating = 0.0;

  int i = 1;

  int j = 1;
  String answ = "None";
  int count = 1;

  _QuizPageState(this.mydata, this.test, this.results) {
    question = List<String>();
    answer = List<String>();
    while (mydata[0][count.toString()] is String) {
      count++;
    }
    count--;
  }

  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void nextquestion() {
    //If no answer is selected a alert is made
    if (answ.contains("None") && rating == 0.0) {
      //If you wish to change the Style of the alert dialog .. Change here
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Answer to Continue"),
              content: Text("Answer Cannot Be Empty Or Neutral "),
            );
          });
      return;
    }

    if (answ == "None") {
      answ = rating.toString();
    }

    // Questions and answer for the respective question is added to thhe local variable

    question.add(mydata[0][count.toString()]);
    answer.add(answ);

    //Back to normal State
    answ = "None";
    rating = 0.0;

    setState(() {
      if (j < count) {
        i++;
        j++;
      } else if (test == "Test1") {
        // Questions and answer for the respective question is added to the Main variable.. So that it can be passed on
        results.q1 = question;
        results.a1 = answer;

        //A call to transition Screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Transition(
            results: results,
          ),
        ));
      } else {
        //Call to results page
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(marks: 100),
        ));
      }
      //Re-initialize the Color to normal State
      btnColor = Variable().btnColor;
    });
  }

  //The Below Function Will return the options or the Slider based on the question
  Widget choice() {
    List<Widget> widgets = new List<Widget>();

    // If your option contnains more than the options mentioned here please append them into the below array
    var array = ['a', 'b', 'c', 'd'];

    if (mydata[1][i.toString()]['b'] == '...') {
      //As the Second option read says that the question needs a slider a slider is returned

      return Slider(
        value: rating,
        onChanged: (newrating) {
          setState(() => rating = newrating);
        },
        min: -2,
        max: 2,
        divisions: 4,
        label: Variable().guide[rating.round() + 2],
      );
    } else {
      // As the question does need slider set of choices is made and added to list named as 'widgets'
      for (int j = 0; j < array.length; j++) {
        var data = mydata[1][i.toString()][array[j]];
        if (data is String) {
          widgets.add(choicebutton(array[j]));
        }
      }
    }
    // After adding choices to the list it is returned as a column widget
    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: widgets);
  }

  // Answ is set to currently pressed icon and color is changed
  void changeColor(String k) {
    //sets answer to selected option
    answ = k;
    setState(() {
      btnColor = Variable().btnColor; //set all colors to normal
      btnColor[k] = Colors.lightBlueAccent; //Color of selected option
    });
  }

  //This function creates a widget and return back . If you want to change the style of the choice ..You can make them in the below function code

  Widget choicebutton(String k) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: MaterialButton(
        onPressed: () => changeColor(
            k), // Whenver a choice is pressed the function is executed
        child: Text(
          mydata[1][i.toString()][k],
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Alike",
            fontSize: 16.0,
          ),
          maxLines: 1,
        ),
        color: btnColor[k],
        splashColor: Colors.indigo[700],
        highlightColor: Colors.indigo[700],
        minWidth: 200.0,
        height: 45.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Quiz",
                  ),
                  content: Text("You Can't Go Back At This Stage."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok',
                      ),
                    )
                  ],
                ));
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(15.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  mydata[0][i.toString()],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Quando",
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                child: choice(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blueAccent,
                alignment: Alignment.topCenter,
                child: Center(
                    child: MaterialButton(
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Alike",
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                  ),
                  onPressed: () => nextquestion(),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
