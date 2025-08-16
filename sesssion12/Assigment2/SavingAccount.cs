using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment2
{
    internal class SavingAccount : Account
    {
        public decimal AnnualRate { get; set; }

        public SavingAccount(Customer owner, decimal initialBalance, decimal annualRate)
            : base(owner, initialBalance)
        {
            AnnualRate = annualRate;
        }

        public decimal CalculateMonthlyInterest()
        {
            decimal monthlyRate = AnnualRate / 12;
            return Balance * monthlyRate;
        }
    }

}
