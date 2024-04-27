import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/selectLearningPath.dart';


class Welcome extends StatefulWidget{

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  var _pageController;

  @override
  Widget build(BuildContext context) {
    if(DatabaseWidget.of(context).settings_database.containsKey("Klasse")){
      _pageController = PageController(initialPage: 1);
    } else{
      _pageController = PageController(initialPage: 0);
    }

    bool welcomePage = DatabaseWidget.of(context).settings_database.containsKey("welcomePage");
    if(welcomePage) return Learningmodule();
    return Scaffold(
      body: PageView.builder(
          itemCount: 2,
          controller: _pageController,
          itemBuilder: (content, index){
            if(index == 0){
              return SafeArea(
                bottom: true,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: SvgPicture.asset(
                          "assets/welcome/Icons.svg",
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.hardEdge,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Willkommen,", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w800),),
                                  Text(
                                      "wir freuen uns dich auf deinem Weg zur Amateurfunkzulassung begleiten zu dürfen.",
                                      style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 39, 39, 39), fontWeight: FontWeight.w600)
                                  ),

                                ]
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () {
                          _pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.linear);
                        },
                        child: Container(
                          width: 364,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Color(0xFF00A0E3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Center(
                            child: Text(
                              'Start',
                              style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }else if(index == 1){
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Womit möchtest du beginnen?", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                      ),
                      TextButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => selectClass()),
                        );
                      },
                          child: Text("Ich habe schon eine Prüfung abgelegt.", style: TextStyle(fontSize: 18),)
                      ),
                      InkWell(
                        onTap: (){
                          handleStart([1], context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff47ABE8),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Klasse N", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xff00008B),
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                "Neu",
                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                            "Baue deine eigene Funkstation auf, experimentiere mit neuester Technik und knüpfte Kontakte weltweit. Erlebe grenzenlose Kommunikation und werde Teil einer aktiven Gemeinschaft, die die Zukunft des Amateurfunks gestaltet.",
                                            style: TextStyle(fontSize: 17),
                                          )),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          handleStart([1, 2], context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffFE756C),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Klasse E", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                            "Vertiefe deine Kenntnisse in Technik und Funkbetrieb, nimm an Amateurfunk-Wettbewerben teil und engagiere dich in der Ausbildung von neuen Funkamateuren.",
                                            style: TextStyle(fontSize: 17),
                                          )),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          handleStart([1, 2, 3], context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff3BB583),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Klasse A", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                            "Errichte deine eigene Amateurfunkstation mit hoher Sendeleistung, leite Funkkurse und bilde neue Funkamateure aus. Engagiere dich in der Forschung und Entwicklung neuer Funktechnologien und gestalte die Zukunft des Amateurfunks aktiv mit.",
                                            style: TextStyle(fontSize: 17),
                                          )),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}

void handleStart(List<int> klasse, BuildContext context){
  DatabaseWidget.of(context).settings_database.put("welcomePage", true);
  DatabaseWidget.of(context).settings_database.put("Klasse", klasse);
  Navigator.pushNamedAndRemoveUntil(context, "/learn", (r) => false);
}