using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace assigment12
{
    public abstract class Question
    {
        public string Text { get; set; }
        public int Mark { get; set; }
        public abstract int Grade(string studentAnswer);
    }

    public class MCQ : Question
    {
        public List<string> Options { get; set; }
        public string CorrectAnswer { get; set; }

        public override int Grade(string studentAnswer)
        {
            return studentAnswer == CorrectAnswer ? Mark : 0;
        }
    }

    public class TrueFalse : Question
    {
        public bool CorrectAnswer { get; set; }

        public override int Grade(string studentAnswer)
        {
            return bool.Parse(studentAnswer) == CorrectAnswer ? Mark : 0;
        }
    }

    public class Essay : Question
    {
        public override int Grade(string studentAnswer)
        {
            Console.WriteLine("Essay needs manual grading.");
            return 0;
        }
    }

}
