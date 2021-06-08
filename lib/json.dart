class Chaptermenu{
  var data;
  List chapter = [];
  List chapternames = [];
  List subchapterlist = [];
  var results = Map();

  Chaptermenu(final this.data);

  main_chapter_names(){
    this.results["chaptername"] = this.data["chapter"]["name"];
  }

  learn_module_name(){
    this.results["learnmodulename"] = this.data["exam"]["name"];
  }

  chapter_names(){
    var chaptername = data["chapter"]["chapter"];
    for(var i in chaptername){
      var _chapname = i["name"];
      this.chapternames.add(_chapname);
    }
    this.results["chapternames"] = chapternames;
  }

  subchapter_info(){
    var chaptername = data["chapter"]["chapter"];
    var rootsubchapterlist = [];
    var subchapterlist = [];
    for(var i in chaptername){
        for(var subchapter in i["chapter"]){
          var name = subchapter["name"];
          var icon = subchapter["icon"];
          subchapterlist.add([name, icon]);
          //print(rootsubchapterlist);
        }
        rootsubchapterlist.add(subchapterlist);
        subchapterlist = [];
        //print(rootsubchapterlist);
    }
    this.results["chapterinfo"] = rootsubchapterlist;

  }
  question(final int chapter,final int subchapter, final int question){
    var chaptername = this.data["chapter"]["chapter"];
    print(100 / (chaptername[chapter]["chapter"][subchapter]["question"].length));
    var result = chaptername[chapter]["chapter"][subchapter]["question"][question];
    return result;
  }
  questionprocent(final int chapter,final int subchapter, final int question){
    var chaptername = this.data["chapter"]["chapter"];
    var returnvalue = ((100 / (chaptername[chapter]["chapter"][subchapter]["question"].length)) / 100) * question;
    return returnvalue;
  }
  questioncount(final int chapter,final int subchapter, final int question){
    var chaptername = this.data["chapter"]["chapter"];
    return chaptername[chapter]["chapter"][subchapter]["question"].length;
  }
}

/*
[
  "subchapter" = [[[name,icon], [name,icon]], [[name,icon]]]
]
*/
