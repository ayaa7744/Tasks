using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment
{
    internal class BankAccount
    {
        public const string BankCode = "BNK001";
        public readonly DateTime CreatedDate;
        private int _accountNumber;
        private string _fullName;
        private string _nationalID;
        private string _phoneNumber;
        private string _address;
        private decimal _balance;

        public string FullName
        {
            get
            {
                return _fullName;
            }
            set
            {
                if (string.IsNullOrWhiteSpace(value) || string.IsNullOrEmpty(value))
                {
                    Console.WriteLine("invalid title");

                }
                else
                {
                    _fullName = value;
                }

            }
        }


        public string NationalID
        {
            get { return _nationalID; }
            set
            {
                if (string.IsNullOrEmpty(value))
                {
                    Console.WriteLine("invalid NationalID");

                }
                else
                {
                    _nationalID = value;
                }
            }
        }

        public string PhoneNumber
        {
            get { return _phoneNumber; }
            set
            {
                if (string.IsNullOrEmpty(value))
                {
                    Console.WriteLine("invalid PhoneNumber");

                }
                else
                {
                    _phoneNumber = value;

                }
            }
        }

        public string Address
        {
            get { return _address; }
            set { _address = value; }
        }

        public decimal Balance
        {
            get { return _balance; }
            set
            {
                if (value < 0)
                {
                    Console.WriteLine("Balance cannot be negative.");
                }
                else
                {
                    _balance = value;
                }

            }
        }
        public BankAccount()
        {
            CreatedDate = DateTime.Now;
            FullName = "Unknown";
            NationalID = "00000000000000";
            PhoneNumber = "01000000000";
            Address = "Not specified";
            Balance = 0;
        }

        public virtual decimal CalculateInterest() => 0;


        public virtual void ShowAccountDetails()
        {
            Console.WriteLine("===== Account Details =====");
            Console.WriteLine($"Bank Code: {BankCode}");
            Console.WriteLine($"Created Date: {CreatedDate}");
            Console.WriteLine($"Full Name: {FullName}");
            Console.WriteLine($"National ID: {NationalID}");
            Console.WriteLine($"Phone Number: {PhoneNumber}");
            Console.WriteLine($"Address: {Address}");
            Console.WriteLine($"Balance: {Balance}");
            Console.WriteLine("===========================");
        }
    }
}
