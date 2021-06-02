class Menu{
  var module_name;
  var main_chapter_name, sub_chapter_names;
  var data;
  chapter_names() => this.data["chapter"]["name"];
  learn_module_name() => this.data["exam"]["name"];
}