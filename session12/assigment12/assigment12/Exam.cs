using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace assigment12
{
    public class Exam
    {
        public string Title { get; set; }
        public Course Course { get; set; }
        public List<Question> Questions { get; set; } = new();
        public bool Started { get; set; } = false;

        public void AddQuestion(Question q)
        {
            int totalMarks = Questions.Sum(x => x.Mark) + q.Mark;
            if (totalMarks > Course.MaxDegree)
            {
                Console.WriteLine("❌ Cannot add, exceeds course max degree!");
                return;
            }
            if (Started)
            {
                Console.WriteLine("❌ Cannot modify exam after it started!");
                return;
            }
            Questions.Add(q);
        }

        public void StartExam()
        {
            Started = true;
        }

        public Exam DuplicateTo(Course newCourse)
        {
            return new Exam
            {
                Title = this.Title + " Copy",
                Course = newCourse,
                Questions = new List<Question>(this.Questions) // shallow copy
            };
        }
    }
}
