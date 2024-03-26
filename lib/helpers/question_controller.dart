import 'package:flutter/material.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';

enum PractiseTypes{
  chapter,
  neverAnswered, 
  wronglyAnswered,
  subchapter
}

enum ImageType{
  none,
  imageAnswers,
  headerImage
}

class AnswerElement<T> {
  final String element;
  final bool correct;
  final int shuffledIndex;

  AnswerElement(this.element, this.correct, this.shuffledIndex);
}

class QuestionElement<T> {
  final String number;
  final String question; 
  final ImageType imageType;
  String? headerImage;
  final List<AnswerElement> answers;

  QuestionElement({required this.number, required this.question, required this.imageType, required this.answers, this.headerImage});
}

class QuestionController extends ChangeNotifier{
  List<QuestionElement> questions = [];
  List<bool> results = [];
  String name = "";
  int currentIndex = 0;
  BuildContext? context;
  
  initialize(BuildContext context, practiseTypes, [int? chapter, int? subchapter, bool mixed = true]){
    questions = [];
    name = "";
    currentIndex = 0;

    Json json = Json(JsonWidget.of(context).json);

    if(practiseTypes == PractiseTypes.subchapter && chapter != Null && subchapter != Null){
      Map rawJson = json.getSubchapter(chapter!, subchapter!);
      this.name = rawJson["title"];
      var jsonQuestions = rawJson["questions"];
      
      for(var question in jsonQuestions){

        List<int> shuffledIndex = [0, 1, 2, 3];

        shuffledIndex.shuffle();
        if(question["answer_a"] == "" || question["answer_a"] == null){

          AnswerElement answerA = AnswerElement(question["picture_a"], true, shuffledIndex[3]);
          AnswerElement answerB = AnswerElement(question["picture_b"], false, shuffledIndex[2]);
          AnswerElement answerC = AnswerElement(question["picture_c"], false, shuffledIndex[1]);
          AnswerElement answerD = AnswerElement(question["picture_d"], false, shuffledIndex[0]);
        
          questions.add(
            QuestionElement(
              number: question["number"],
              question: question["question"],
              imageType: ImageType.imageAnswers,
              answers: [
                answerA,
                answerB,
                answerC, 
                answerD
                ]   
              )
          );
        }else{
          AnswerElement answerA = AnswerElement(question["answer_a"], true, shuffledIndex[3]);
          AnswerElement answerB = AnswerElement(question["answer_b"], false, shuffledIndex[2]);
          AnswerElement answerC = AnswerElement(question["answer_c"], false, shuffledIndex[1]);
          AnswerElement answerD = AnswerElement(question["answer_d"], false, shuffledIndex[0]);

          if(question.containsKey("picture_question")){
            questions.add(
              QuestionElement(
                number: question["number"],
                question: question["question"],
                imageType: ImageType.headerImage,
                headerImage: question["picture_question"],
                answers: [
                  answerA,
                  answerB,
                  answerC, 
                  answerD
                  ]   
                )
            );            
          }else{
            questions.add(
              QuestionElement(
                number: question["number"],
                question: question["question"],
                imageType: ImageType.none,
                answers: [
                  answerA,
                  answerB,
                  answerC, 
                  answerD
                  ]   
                )
            );
          } 
        }
      }
      results = List<bool>.filled(questions.length, false);
    }
  }

  String getChapterName() => name;

  QuestionElement getCurrentQuestion() => questions[currentIndex];
  
  bool goPreviousQuestion () {
    if((currentIndex - 1) < 0){
      return false;
    }
    currentIndex -= 1;
    return true;
  }
  void goNextQuestion(){
    if((currentIndex + 1) >= questions.length){
      throw NoMoreQuestionsException("No more questions");
    }
    currentIndex += 1;
  }

  bool saveCurrentResult(bool correct){

    results[currentIndex] = correct;
    return true;
  }

}

class NoMoreQuestionsException implements Exception{
  final String message;

  NoMoreQuestionsException(this.message) {
    print(message);
  }

}

