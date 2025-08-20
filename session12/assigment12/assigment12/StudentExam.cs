using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace assigment12
{
    public class StudentExam
    {
        public Student Student { get; set; }
        public Exam Exam { get; set; }
        public Dictionary<Question, string> Answers { get; set; } = new();

        public int CalculateScore()
        {
            return Answers.Sum(a => a.Key.Grade(a.Value));
        }
    }
}
