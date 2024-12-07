import 'package:flutter/material.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';
import 'package:fuenfzigohm/screens/completeLesson.dart';


enum QuestioningFormat{
  subchapter,
  chapter,
  smart,
  random,
  exam,
}
enum QuestionState{
  answering,
  evaluating,
  correcting,
  dispose
}

class Questioning{
  final String questionID;
  final String question;
  final int correct;
  final String? image;
  final List<String> answers;
  final int chapter;
  final int subchapter;

  Questioning({
    required this.questionID,
    required this.question,
    required this.correct,
    this.image,
    required this.answers,
    required this.chapter,
    required this.subchapter,
  });
}

class QuestionEvaluation{
  final Questioning question;
  final bool correct;

  QuestionEvaluation({
    required this.question,
    required this.correct,
  });
}

class QuestionManager with ChangeNotifier {
  int _currentQuestionIndex = 0;
  int _furthestQuestion = 0;

  late List<Questioning> _questions;
  late List<QuestionEvaluation> _evaluations;

  QuestionState questionState = QuestionState.answering;
  Json? json;
  late BuildContext context;

  int get currentQuestionIndex => _currentQuestionIndex;

  void initChapter(chapter) {

  }

  void initSubChapter(BuildContext context, chapter, List<dynamic> subchapter) {
    resetQuestions();
    this.context = context;
    if(json == null) {
      json = Json(JsonWidget.of(context).json);
    }
    if(json != null) {
      for(var i in subchapter){
        _aggregateQuestions(json!, chapter, i);
      }
    }
  }

  void backQuestion() {
    _currentQuestionIndex--;
    questionState = QuestionState.correcting;
    notifyListeners();
  }

  void evaluateQuestion(int answer){
    int correct = _questions[_currentQuestionIndex].correct;
    bool correctAnswer = answer == correct;
    _evaluations.add(QuestionEvaluation(
      question: _questions[_currentQuestionIndex],
      correct: correctAnswer,
    ));
    questionState = QuestionState.evaluating;
    notifyListeners();
  }

  void nextQuestion() {
    if((_currentQuestionIndex + 2) > _questions.length){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (con) => Finish(_evaluations)),
      );
      questionState = QuestionState.dispose;
      notifyListeners();
      return;
    }
    _currentQuestionIndex++;
    if(_currentQuestionIndex > _furthestQuestion){
      questionState = QuestionState.answering;
    }else{
      questionState = QuestionState.correcting;
    }
    notifyListeners();
  }

  void resetQuestions() {
    _questions = [];
    _evaluations = [];
    _currentQuestionIndex = 0;
    questionState = QuestionState.answering;
  }


  String getQuestionID(){
    return _questions[_currentQuestionIndex].questionID;
  }
  String getQuestionQuestion(){
    return _questions[_currentQuestionIndex].question;
  }
  String getQuestionAnswers(int i){
    return _questions[_currentQuestionIndex].answers[i];
  }
  String? getQuestionImage(){
    return _questions[_currentQuestionIndex].image;
  }
  bool getEvaluation(){
    return _evaluations[_currentQuestionIndex].correct;
  }
  QuestionState getQuestionState(){
    return questionState;
  }
  int getCorrectAnswer(){
    return _questions[_currentQuestionIndex].correct;
  }

  _aggregateQuestions(Json json, chapter, subchapter){
    int i = 0;
    String? questionid;
    while((questionid = json.questionId(chapter, subchapter, i)) != null){
      // scramble the answers and add the element that was at the 0th position to the correct answer
      List<String> answers = json.answerList(chapter, subchapter, i);
      String correctElement = answers[0];
      answers.shuffle();

      _questions.add(Questioning(
        questionID: questionid!,
        question: json.questionname(chapter, subchapter, i),
        correct: answers.indexOf(correctElement),
        image: json.questionimage(chapter, subchapter, i),
        answers: answers,
        chapter: chapter,
        subchapter: subchapter,
      ));
      i++;
    }

  }
}



