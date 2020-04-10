using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace SalesApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SalesController : ControllerBase
    {
        private static List<Sales> _sales = new List<Sales>()
        {
            new Sales() { ID = "1", Name = "Socks", Qty = 150 },
            new Sales() { ID = "2", Name = "Milk", Qty = 2650 },
            new Sales() { ID = "3", Name = "Guitar", Qty = 3 },
        };

        private readonly ILogger<SalesController> _logger;

        public SalesController(ILogger<SalesController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetSales")]
        public IEnumerable<Sales> Get()
        {
            return _sales;
        }

        [HttpGet("{id}", Name = "GetSalesById")]
        public Sales Get(string id)
        {
            return _sales.FirstOrDefault(s => s.ID == id);
        }
    }
}
