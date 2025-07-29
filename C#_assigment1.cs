using System;

class SimpleCalculator
{
    static void Main()
    {
        Console.WriteLine("Hello! Input the first number:");
        string input1 = Console.ReadLine();

        Console.WriteLine("Input the second number:");
        string input2 = Console.ReadLine();

    
        bool isValidNum1 = int.TryParse(input1, out int num1);
        bool isValidNum2 = int.TryParse(input2, out int num2);

        if (!isValidNum1 || !isValidNum2)
        {
            Console.WriteLine("Invalid number input.");
        }
        else
        {
            Console.WriteLine("What do you want to do with those numbers? [A]dd [S]ubtract [M]ultiply");
            string operation = Console.ReadLine();

            switch (operation.ToLower())
            {
                case "a":
                    Console.WriteLine($"{num1} + {num2} = {num1 + num2}");
                    break;
                case "s":
                    Console.WriteLine($"{num1} - {num2} = {num1 - num2}");
                    break;
                case "m":
                    Console.WriteLine($"{num1} * {num2} = {num1 * num2}");
                    break;
                default:
                    Console.WriteLine("Invalid option");
                    break;
            }
        }

        Console.WriteLine("Press any key to close");
        Console.ReadKey(); 
    }
}
