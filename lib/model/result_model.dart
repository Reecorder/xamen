class Result {
  String name, exam_name, roll, batch_name;
  int id,
      exam_id,
      user_id,
      skiped_qns,
      correct_ans,
      wrong_ans,
      full_marks,
      marks_per_qns;
  Result(
    this.id,
    this.exam_id,
    this.user_id,
    this.skiped_qns,
    this.correct_ans,
    this.wrong_ans,
    this.full_marks,
    this.marks_per_qns,
    this.name,
    this.roll,
    this.exam_name,
    this.batch_name,
  );
}
