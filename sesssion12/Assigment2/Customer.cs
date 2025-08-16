using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment2
{
    internal class Customer
    {
        private static int _nextId = 100;
        private DateTime _DateOfBIrth;
        private string _fullname;
        private String _nationalid;

        public string NationalID { get { return _nationalid; } 
            set 
            {
                if (string.IsNullOrEmpty(value) || value.Length != 14)
                {
                    Console.WriteLine("invalid National Id");
                }
                else
                {
                     _nationalid = value;
                }
            }
        }
        public int Id { get; set; }
        public string FullName { get; set; }
        public DateTime DateOfBirth { get; set; }
        public List<Account> Accounts { get; set; } = new List<Account>();


        public void UpdateCustomer(string fullname, DateTime datebirth)
        {
            if (string.IsNullOrWhiteSpace(fullname))
            {
                Console.WriteLine("Full name cannot be empty.");
                return;
            }

            if (datebirth > DateTime.Now)
            {
                Console.WriteLine("Date of birth cannot be in the future.");
                return;
            }

            FullName = fullname;
            DateOfBirth = datebirth;

            Console.WriteLine("Customer information updated successfully.");
        }
        public static int GenerateId()
        {
            return _nextId++;
        }
        //public Customer(DateTime dateOfBIrth, string nationalID, int id, string fullName, DateTime dateOfBirth, List<Accounts> accounts)
        //{
        //    _DateOfBIrth = dateOfBIrth;
        //    NationalID = nationalID;
        //    Id = id;
        //    FullName = fullName;
        //    DateOfBirth = dateOfBirth;
        //    Accounts = accounts;
        //}
        public Customer(string fullName, DateTime dateOfBirth, string nationalId)
        {
            FullName = fullName;
            DateOfBirth = dateOfBirth;
            NationalID = nationalId;
            Id = GenerateId();
            Accounts = new List<Account>();
        }
       
        public decimal GetTotalBalance()
        {
            decimal totalBalance = 0;
            foreach (var c in Accounts) 
            { 
            totalBalance += c.Balance;
            }
            return totalBalance;
        }
        public void ShowAccountsReport()
        {
            foreach (var acc in Accounts)
            {
                Console.WriteLine($"account details : balance{acc.Balance} , Account Number {acc.AccountNumber}");

            }
        }


    }
}
