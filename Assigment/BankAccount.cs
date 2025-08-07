using System;

namespace BankSystem
{
    class BankAccount
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
            get { 
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
                if (!IsValidNationalID(value))
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
                if (!IsValidPhoneNumber(value))
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

        public BankAccount(string fullName, string nationalID, string phoneNumber, string address, decimal balance)
        {
            CreatedDate = DateTime.Now;
            FullName = fullName;
            NationalID = nationalID;
            PhoneNumber = phoneNumber;
            Address = address;
            Balance = balance;
        }


        public BankAccount(string fullName, string nationalID, string phoneNumber, string address)
            : this(fullName, nationalID, phoneNumber, address, 0) { }


        public void ShowAccountDetails()
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

        public bool IsValidNationalID(string id)
        {
            return !string.IsNullOrEmpty(id) && id.Length == 14 && long.TryParse(id, out _);
        }

        public bool IsValidPhoneNumber(string phone)
        {
            return !string.IsNullOrEmpty(phone) && phone.StartsWith("01") && phone.Length == 11 && long.TryParse(phone, out _);
        }
    }
   
}
