using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using TrainingCourses.Api.Data;
using TrainingCourses.Api.DTOs;

namespace TrainingCourses.Api.Services
{
    public interface ITraineeService
    {
        Task<List<TraineeDto>> GetAllTraineesAsync();
        Task<TraineeDto?> GetTraineeByIdAsync(int id);
        Task<TraineeDto?> GetTraineeByEmailAsync(string email);
        Task<int> CreateTraineeAsync(CreateTraineeDto dto);
        Task UpdateTraineeAsync(int id, UpdateTraineeDto dto);
        Task DeleteTraineeAsync(int id);
    }

    public class TraineeService : ITraineeService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;

        public TraineeService(IOracleDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<List<TraineeDto>> GetAllTraineesAsync()
        {
            var list = new List<TraineeDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINEE_PACKAGE.GetAllTrainees";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapTrainee(reader));
            }
            return list;
        }

        public async Task<TraineeDto?> GetTraineeByIdAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINEE_PACKAGE.GetTraineeById";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_TraineeID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return MapTrainee(reader);
            }
            return null;
        }

        public async Task<TraineeDto?> GetTraineeByEmailAsync(string email)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINEE_PACKAGE.GetTraineeByEmail";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = email.Trim();
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return MapTrainee(reader);
            }
            return null;
        }

        public async Task<int> CreateTraineeAsync(CreateTraineeDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINEE_PACKAGE.CreateTrainee";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_FullName", OracleDbType.Varchar2).Value = dto.FullName;
            cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = dto.Email.Trim().ToLowerInvariant();
            cmd.Parameters.Add("p_PhoneNumber", OracleDbType.Varchar2).Value = dto.PhoneNumber;
            cmd.Parameters.Add("p_EducationalBackground", OracleDbType.Varchar2).Value = dto.EducationalBackground;

            var outId = new OracleParameter("p_TraineeID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task UpdateTraineeAsync(int id, UpdateTraineeDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINEE_PACKAGE.UpdateTrainee";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_TraineeID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_FullName", OracleDbType.Varchar2).Value = dto.FullName;
            cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = dto.Email.Trim().ToLowerInvariant();
            cmd.Parameters.Add("p_PhoneNumber", OracleDbType.Varchar2).Value = dto.PhoneNumber;
            cmd.Parameters.Add("p_EducationalBackground", OracleDbType.Varchar2).Value = dto.EducationalBackground;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteTraineeAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINEE_PACKAGE.DeleteTrainee";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_TraineeID", OracleDbType.Int32).Value = id;

            await cmd.ExecuteNonQueryAsync();
        }

        private static TraineeDto MapTrainee(IDataRecord reader)
        {
            return new TraineeDto
            {
                TraineeID = reader.GetInt32(reader.GetOrdinal("TraineeID")),
                FullName = reader.GetString(reader.GetOrdinal("FullName")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                PhoneNumber = reader.GetString(reader.GetOrdinal("PhoneNumber")),
                EducationalBackground = reader.GetString(reader.GetOrdinal("EducationalBackground")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
