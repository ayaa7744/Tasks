using BankSystem;

namespace Assigment
{
    internal class Program
    {
        static void Main(string[] args)
        {

            BankAccount account1 = new BankAccount();
            account1.ShowAccountDetails();

            // Object 2: Parameterized constructor
            BankAccount account2 = new BankAccount("Aya Ashraf", "12345678901234", "01012345678", "Cairo", 5000);
            account2.ShowAccountDetails();

            // Object 3: Overloaded constructor
            BankAccount account3 = new BankAccount(" Ali", "98765432109876", "01123456789", "Alexandria");
            account3.ShowAccountDetails();
        }
    }
}
