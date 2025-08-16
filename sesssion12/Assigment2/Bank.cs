using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment2
{
    internal class Bank
    {
        private string _name;
        private string _branchcode;
        public string BankName 
        { 
            get { return _name; } 
            set 
            {
                if (string.IsNullOrEmpty(value) || string.IsNullOrWhiteSpace(value)) 
                {
                    Console.WriteLine("invalid name");
                }
                else
                {
                    _name = value;
                }

            } 
        }
        public string BranchCode
        {
            get { return _branchcode; }

            set
            {
                if (string.IsNullOrEmpty(value) || string.IsNullOrWhiteSpace(value))
                {
                    Console.WriteLine("invalid name");
                }
                else
                {
                    _branchcode = value;
                }

            }
        }

       public List<Customer> Customers { get; set; }=new List<Customer>();
        public Customer AddCustomer( Customer c) 
        {
            Customers.Add(c);
            return c;
        
        }
     

        public bool RemoveCustomer(int Customerid) 
        { 
        var c= Customers.FirstOrDefault(x=>x.Id==Customerid);
            if (c!=null && c.Accounts.All(a=>a.Balance==0))
            {
                Customers.Remove(c);
                    return true;
            }
            else 
            { 
              return false;
            }
        
        }
        public Customer SearchCustomer(string nationalID)
        {
            return Customers.FirstOrDefault(c => c.NationalID == nationalID);
        }

        //public Customer AddCustomer()
        //{

        //}

        public Bank(string name, string branchCode)
        {
            BankName = name;
            BranchCode = branchCode;
        }



        public void ShowCustomerREport()
        {
            foreach (var c in Customers)
            {
                Console.WriteLine($"Customer: {c.FullName}, National ID: {c.NationalID}");
                c.ShowAccountsReport(); ;

            }
        }

    }
    }    
