using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assigment2
{
    internal class Transaction
    {
        public DateTime DateOfTransform { get; set; }
        public string TransformType { get; set; }
        public decimal TransformAmount { get; set; }
        public int FromAccount { get; set; }
        public string ToAccount { get; set; } = string.Empty;
    }
}
