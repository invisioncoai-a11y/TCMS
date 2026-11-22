using System;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Oracle.ManagedDataAccess.Client;

namespace TrainingCourses.Api.Data
{
    public interface IOracleDbConnectionFactory
    {
        OracleConnection CreateConnection();
        Task<OracleConnection> CreateConnectionAsync();
    }

    public class OracleDbConnectionFactory : IOracleDbConnectionFactory
    {
        private readonly string _connectionString;

        public OracleDbConnectionFactory(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("OracleDb")
                ?? throw new InvalidOperationException("Connection string 'OracleDb' was not found in configuration.");
        }

        public OracleConnection CreateConnection()
        {
            var conn = new OracleConnection(_connectionString);
            conn.Open();
            return conn;
        }

        public async Task<OracleConnection> CreateConnectionAsync()
        {
            var conn = new OracleConnection(_connectionString);
            await conn.OpenAsync();
            return conn;
        }
    }
}
