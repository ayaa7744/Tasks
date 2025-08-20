namespace assigment12
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var course = new Course { Title = "Math", Description = "Basic Math", MaxDegree = 100 };

            var instructor = new Instructor { Id = 1, Name = "Ali", Specialization = "Math" };
            instructor.Courses.Add(course);


            var s1 = new Student { Id = 1, Name = "Ahmed", Email = "a@test.com" };
            var s2 = new Student { Id = 2, Name = "Sara", Email = "s@test.com" };
            s1.Courses.Add(course);
            s2.Courses.Add(course);

            var exam = new Exam { Title = "Math Final", Course = course };

            exam.AddQuestion(new MCQ
            {
                Text = "2+2=?",
                Mark = 10,
                Options = new List<string> { "3", "4", "5" },
                CorrectAnswer = "4"
            });

            exam.AddQuestion(new TrueFalse
            {
                Text = "5 is greater than 2?",
                Mark = 5,
                CorrectAnswer = true
            });

            exam.AddQuestion(new Essay
            {
                Text = "Explain Pythagoras theorem",
                Mark = 20
            });

            exam.StartExam(); 
            var se1 = new StudentExam { Student = s1, Exam = exam };
            se1.Answers[exam.Questions[0]] = "4";     
            se1.Answers[exam.Questions[1]] = "true";  
            se1.Answers[exam.Questions[2]] = "It's a formula"; 

            var se2 = new StudentExam { Student = s2, Exam = exam };
            se2.Answers[exam.Questions[0]] = "3";    
            se2.Answers[exam.Questions[1]] = "true";  
            se2.Answers[exam.Questions[2]] = "Formula"; 


           
            Report.ShowResult(se1);
            Console.WriteLine();
            Report.ShowResult(se2);
            Console.WriteLine();
            Report.Compare(se1, se2);
        }
    }
}
    
