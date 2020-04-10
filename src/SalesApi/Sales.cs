using System.Text.Json.Serialization;

namespace SalesApi
{
    public class Sales
    {
        [JsonPropertyName("id")]
        public string ID { get; set; }

        [JsonPropertyName("name")]
        public string Name { get; set; }

        [JsonPropertyName("qty")]
        public double Qty { get; set; }
    }
}
