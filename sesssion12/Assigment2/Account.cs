using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment2
{
    internal class Account
    {
        private decimal _balance = 0;

        public static int _accountnumber = 50;
        public int AccountNumber { get; set; }
        public DateTime DateOpend { get; private set; }
        public decimal Balance { get; set; }
        public Customer Owner { get; private set; }
        public List<Transaction> Transactions { get; set; } = new List<Transaction>();

        public void Deposit(decimal amount)
        {
            Balance += amount;

            Transactions.Add(new Transaction
            {
                DateOfTransform = DateTime.Now,
                TransformType = "Deposit",
                TransformAmount = amount,
                FromAccount = AccountNumber
            });

            Console.WriteLine($"Deposit successful: {amount} added. Current Balance = {Balance}");
        }

        public void Withdraw(decimal amount)
        {
            if (amount <= Balance)
            {
                Balance -= amount;

                Transactions.Add(new Transaction
                {
                    DateOfTransform = DateTime.Now,
                    TransformAmount = amount,
                    TransformType = "Withdraw",
                    FromAccount = AccountNumber
                });

                Console.WriteLine($"Withdraw successful: {amount} withdrawn. Current Balance = {Balance}");
            }
            else
            {
                Console.WriteLine("Withdraw failed: Insufficient balance.");
            }
        }



        public void TransformMoney(Account FromAccount, Account TOAccount, decimal amount)
        {
            if (FromAccount.Balance >= amount)
            {
                FromAccount.Withdraw(amount);
                TOAccount.Deposit(amount);
                Console.WriteLine($"Transform of {amount} From Acount{FromAccount} To Account {TOAccount}succeeded");
            }
            else
            {
                Console.WriteLine("Transfer failed.");
            }
        }
        public void DisplayTransactionHistory()
        {
            Console.WriteLine($"Transaction history for Account {AccountNumber}:");
            foreach (var transaction in Transactions)
            {
                Console.WriteLine($"{transaction.DateOfTransform} - {transaction.TransformType} - {transaction.TransformAmount} - From: {transaction.FromAccount} To: {transaction.ToAccount}");
            }
        }


        public static int generateAccountNumber()
        {
            return _accountnumber++;
        }


        public Account( Customer owner ,decimal initialBalance)
        {
            DateOpend = DateTime.Now;
            AccountNumber = generateAccountNumber();
            Balance = initialBalance;
            Owner = owner;
            Transactions.Add(new Transaction
            {
                DateOfTransform = DateTime.Now,
                TransformType = "Account Created",
                TransformAmount = initialBalance,
                FromAccount = AccountNumber
            });
        }

    }

}


