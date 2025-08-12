namespace Assigment
{
    internal class Program
    {
        static void Main(string[] args)
        {
            SavingAccount savingAcc = new SavingAccount(5m);
            savingAcc.ShowAccountDetails();

            CurrentAccount currentAcc = new CurrentAccount(77m);
            currentAcc.ShowAccountDetails();

            List<BankAccount> accounts = new List<BankAccount> { savingAcc, currentAcc };

            
            foreach (var account in accounts)
            {
                account.ShowAccountDetails();
                Console.WriteLine($"Calculated Interest: {account.CalculateInterest():C}");
                Console.WriteLine(new string('-', 40));
            }

        }
    }
}
