using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment
{
    internal class CurrentAccount : BankAccount
    {
        private decimal _OverdraftLimit;
        public decimal OverdraftLimit { get; set; }
       public CurrentAccount(decimal overdraftLimit ) : base()
        {
            OverdraftLimit = overdraftLimit;
        }
        public override decimal CalculateInterest()
        {
            return 0;
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
            Console.WriteLine($"OverdraftLimit: {OverdraftLimit}");
            Console.WriteLine("===========================");
        }
    }
}
