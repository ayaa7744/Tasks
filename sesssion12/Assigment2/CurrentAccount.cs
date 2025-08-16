using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment2
{

    internal class CurrentAccount:Account
    {

        //public const decimal OverdraftLimit = 500m;
        public decimal OverdraftLimit { get; set; }
        public CurrentAccount(Customer owner, decimal initialBalance,decimal overdraftLimit) : base(owner, initialBalance)
        {
            OverdraftLimit = overdraftLimit;

        }


    }
}
