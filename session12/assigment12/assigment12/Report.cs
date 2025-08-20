using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace assigment12
{
    public static class Report
    {
        public static void ShowResult(StudentExam se)
        {
            int score = se.CalculateScore();
            Console.WriteLine($"Exam: {se.Exam.Title}");
            Console.WriteLine($"Student: {se.Student.Name}");
            Console.WriteLine($"Course: {se.Exam.Course.Title}");
            Console.WriteLine($"Score: {score}/{se.Exam.Course.MaxDegree}");
            Console.WriteLine(score >= (se.Exam.Course.MaxDegree / 2) ? "✅ Pass" : "❌ Fail");
        }

        public static void Compare(StudentExam s1, StudentExam s2)
        {
            int sc1 = s1.CalculateScore();
            int sc2 = s2.CalculateScore();
            Console.WriteLine($"{s1.Student.Name}: {sc1}");
            Console.WriteLine($"{s2.Student.Name}: {sc2}");
            Console.WriteLine(sc1 > sc2 ? $"{s1.Student.Name} wins" :
                              sc2 > sc1 ? $"{s2.Student.Name} wins" : "Draw");
        }
    }
}
