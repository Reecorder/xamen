class MarkSheetModel {
  String name, exam_name, roll, batch_name, startdate, enddate, starttime;
  int skiped_qns,
      correct_ans,
      wrong_ans,
      full_marks,
      marks_per_qns,
      exam_duration;

  MarkSheetModel(
    this.skiped_qns,
    this.correct_ans,
    this.wrong_ans,
    this.full_marks,
    this.marks_per_qns,
    this.name,
    this.roll,
    this.exam_name,
    this.batch_name,
    this.startdate,
    this.enddate,
    this.starttime,
    this.exam_duration,
  );
}
