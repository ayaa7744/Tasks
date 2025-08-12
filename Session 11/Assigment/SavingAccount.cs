using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment
{
    internal class SavingAccount : BankAccount
    {
        private decimal _InterestRate;
        public decimal InterestRate { get; set; }

        public SavingAccount (decimal interestRate) :base()
        {

            InterestRate = interestRate;
        }
        public override decimal CalculateInterest()
        {
            return Balance * InterestRate / 100;
        }
        public override void ShowAccountDetails()
        {
            Console.WriteLine("===== Account Details =====");
            Console.WriteLine($"Bank Code: {BankCode}");
            Console.WriteLine($"Created Date: {CreatedDate}");
            Console.WriteLine($"Full Name: {FullName}");
            Console.WriteLine($"National ID: {NationalID}");
            Console.WriteLine($"Phone Number: {PhoneNumber}");
            Console.WriteLine($"Address: {Address}");
            Console.WriteLine($"Balance: {Balance}");
            Console.WriteLine($"InterestRate: {InterestRate}");
            Console.WriteLine("===========================");
        }
    }
}
