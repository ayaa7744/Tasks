using Assigment2;

namespace Assigment2
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Bank bank = new Bank("fesail", "B432");

            Customer C1 = new Customer("Aya Ashraf", new DateTime(2003, 7, 4), "30307042234567");
            Customer C2 = new Customer("Ahmed Mohamed", new DateTime(2000, 8, 4), "20008042234561");
            Customer C3 = new Customer("Mohamed Ali", new DateTime(2000, 8, 4), "20008042234562");
            Customer C4 = new Customer("Ali Ahmed", new DateTime(2000, 8, 4), "20008042234563");
            Customer C5 = new Customer("Ahmed Osama", new DateTime(2000, 8, 4), "20008042234564");
            Customer C6 = new Customer("Mohamed Ahmed", new DateTime(2000, 8, 4), "20008042234565");
            Customer C7 = new Customer("Nour Bassam", new DateTime(2000, 8, 4), "20008042234566");
            Customer C8 = new Customer("Mahmoud Karim", new DateTime(2000, 8, 4), "20008042234567");
            Customer C9 = new Customer("Eman Salah", new DateTime(2000, 8, 4), "20008042234568");
            bank.Customers.Add(C1);
            bank.Customers.Add(C2);
            bank.Customers.Add(C3);
            bank.Customers.Add(C4);
            bank.Customers.Add(C5);
            bank.Customers.Add(C6);
            bank.Customers.Add(C7);
            bank.Customers.Add(C8);
            bank.Customers.Add(C9);

            SavingAccount accSaving1 = new SavingAccount(C1, 1000, 0.12m);
            CurrentAccount accCurrent = new CurrentAccount(C1, 1000, 500) { OverdraftLimit = 500 };
            SavingAccount accSaving = new SavingAccount(C2,6000, 0.12m);
            SavingAccount accsaving = new SavingAccount(C3, 500, 0.12m);
            C1.Accounts.Add(accSaving1);
            C1.Accounts.Add(accCurrent);
            C2.Accounts.Add(accSaving);
            C3.Accounts.Add(accsaving); 

            accSaving1.Deposit(300);
            accCurrent.Withdraw(5000);
            accCurrent.TransformMoney(accCurrent, accSaving1, 1000);
            bank.SearchCustomer("20008042234567");

            decimal Interset = accSaving1.CalculateMonthlyInterest();
            Console.WriteLine($"Monthly interest for accSaving1's saving account = {Interset}");
            Console.WriteLine("====================Bank Prport===================");
            bank.ShowCustomerREport();
            Console.WriteLine($"====================Transction History for Account {accSaving1}==================");
            accSaving1.DisplayTransactionHistory();
            Console.WriteLine($"====================Transction History for Account {accCurrent}==================");
            accCurrent.DisplayTransactionHistory();
            Console.WriteLine($"====================Transction History for Account {accSaving}==================");
            accSaving.DisplayTransactionHistory();
            Console.WriteLine($"====================Transction History for Account {accsaving}==================");
            accsaving.DisplayTransactionHistory();

           


            //// 1. إنشاء بنك
            //Bank bank = new Bank("Fesail", "B432");

            //// 2. إضافة Customers
            //Customer aya = new Customer("Aya Ashraf", new DateTime(2003, 7, 4), "12345678901234");
            //Customer ahmed = new Customer("Ahmed Mohamed", new DateTime(2000, 8, 4), "98765432109876");

            //bank.Customers.Add(aya);
            //bank.Customers.Add(ahmed);

            //// 3. إنشاء Accounts لكل Customer
            //SavingAccount ayaSaving = new SavingAccount(aya, 10000, 0.12m); // 12% سنوي
            //CurrentAccount ayaCurrent = new CurrentAccount(aya, 5000, 500) { OverdraftLimit = 500 };

            //aya.Accounts.Add(ayaSaving);
            //aya.Accounts.Add(ayaCurrent);

            //SavingAccount ahmedSaving = new SavingAccount(ahmed, 7000, 0.1m); // 10% سنوي
            //ahmed.Accounts.Add(ahmedSaving);

            //// 4. عمليات مالية (إيداع / سحب / تحويل)
            //ayaSaving.Deposit(2000);
            //ayaCurrent.Withdraw(6000); // هيقبلها لو معاه overdraft
            //ayaSaving.TransformMoney(ayaSaving, ayaCurrent, 1000);

            //// 5. حساب الفائدة الشهرية على حساب التوفير
            //decimal interest = ayaSaving.CalculateMonthlyInterest();
            //Console.WriteLine($"Monthly interest for Aya's saving account = {interest}");

            //// 6. عرض تقرير عن كل العملاء وحساباتهم
            //Console.WriteLine("\n=== Bank Report ===");
            //bank.ShowCustomerREport();

            //// 7. عرض History لكل Account
            //Console.WriteLine("\n=== Transaction History (Aya Saving) ===");
            //ayaSaving.DisplayTransactionHistory();

            //Console.WriteLine("\n=== Transaction History (Aya Current) ===");
            //ayaCurrent.DisplayTransactionHistory();

            //Console.WriteLine("\n=== Transaction History (Ahmed Saving) ===");
            //ahmedSaving.DisplayTransactionHistory();

            //Console.WriteLine("\nProgram finished successfully!");


        }
    }
}
