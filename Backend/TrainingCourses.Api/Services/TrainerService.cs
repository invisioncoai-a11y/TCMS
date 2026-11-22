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
    public interface ITrainerService
    {
        Task<List<TrainerDto>> GetAllTrainersAsync();
        Task<TrainerDto?> GetTrainerByIdAsync(int id);
        Task<List<TrainerDto>> SearchAndFilterTrainersAsync(string? search, string? specialization);
        Task<List<TrainerAssignedCourseDto>> GetTrainerAssignedCoursesAsync(int trainerId);
        Task<int> CreateTrainerAsync(CreateTrainerDto dto);
        Task UpdateTrainerAsync(int id, UpdateTrainerDto dto);
        Task DeleteTrainerAsync(int id);
    }

    public class TrainerService : ITrainerService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;

        public TrainerService(IOracleDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<List<TrainerDto>> GetAllTrainersAsync()
        {
            var list = new List<TrainerDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.GetAllTrainers";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapTrainer(reader));
            }
            return list;
        }

        public async Task<TrainerDto?> GetTrainerByIdAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.GetTrainerById";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_TrainerID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return MapTrainer(reader);
            }
            return null;
        }

        public async Task<List<TrainerDto>> SearchAndFilterTrainersAsync(string? search, string? specialization)
        {
            var list = new List<TrainerDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.SearchAndFilterTrainers";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_Search", OracleDbType.Varchar2).Value = (object?)search ?? DBNull.Value;
            cmd.Parameters.Add("p_Specialization", OracleDbType.Varchar2).Value = (object?)specialization ?? DBNull.Value;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapTrainer(reader));
            }
            return list;
        }

        public async Task<List<TrainerAssignedCourseDto>> GetTrainerAssignedCoursesAsync(int trainerId)
        {
            var list = new List<TrainerAssignedCourseDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.GetTrainerAssignedCourses";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_TrainerID", OracleDbType.Int32).Value = trainerId;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new TrainerAssignedCourseDto
                {
                    OfferingID = reader.GetInt32(reader.GetOrdinal("OfferingID")),
                    CourseID = reader.GetInt32(reader.GetOrdinal("CourseID")),
                    CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                    Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                    StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                    EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                    ScheduleDetails = reader.IsDBNull(reader.GetOrdinal("ScheduleDetails")) ? null : reader.GetString(reader.GetOrdinal("ScheduleDetails")),
                    MaxCapacity = reader.GetInt32(reader.GetOrdinal("MaxCapacity")),
                    AvailableSeats = reader.GetInt32(reader.GetOrdinal("AvailableSeats"))
                });
            }
            return list;
        }

        public async Task<int> CreateTrainerAsync(CreateTrainerDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.CreateTrainer";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_FullName", OracleDbType.Varchar2).Value = dto.FullName;
            cmd.Parameters.Add("p_Specialization", OracleDbType.Varchar2).Value = dto.Specialization;
            cmd.Parameters.Add("p_Qualifications", OracleDbType.Varchar2).Value = (object?)dto.Qualifications ?? DBNull.Value;
            cmd.Parameters.Add("p_ProfileDetails", OracleDbType.Clob).Value = (object?)dto.ProfileDetails ?? DBNull.Value;
            cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = dto.Email;
            cmd.Parameters.Add("p_PhoneNumber", OracleDbType.Varchar2).Value = (object?)dto.PhoneNumber ?? DBNull.Value;

            var outId = new OracleParameter("p_TrainerID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task UpdateTrainerAsync(int id, UpdateTrainerDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.UpdateTrainer";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_TrainerID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_FullName", OracleDbType.Varchar2).Value = dto.FullName;
            cmd.Parameters.Add("p_Specialization", OracleDbType.Varchar2).Value = dto.Specialization;
            cmd.Parameters.Add("p_Qualifications", OracleDbType.Varchar2).Value = (object?)dto.Qualifications ?? DBNull.Value;
            cmd.Parameters.Add("p_ProfileDetails", OracleDbType.Clob).Value = (object?)dto.ProfileDetails ?? DBNull.Value;
            cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = dto.Email;
            cmd.Parameters.Add("p_PhoneNumber", OracleDbType.Varchar2).Value = (object?)dto.PhoneNumber ?? DBNull.Value;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteTrainerAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "TRAINER_PACKAGE.DeleteTrainer";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_TrainerID", OracleDbType.Int32).Value = id;

            await cmd.ExecuteNonQueryAsync();
        }

        private static TrainerDto MapTrainer(IDataRecord reader)
        {
            return new TrainerDto
            {
                TrainerID = reader.GetInt32(reader.GetOrdinal("TrainerID")),
                FullName = reader.GetString(reader.GetOrdinal("FullName")),
                Specialization = reader.GetString(reader.GetOrdinal("Specialization")),
                Qualifications = reader.IsDBNull(reader.GetOrdinal("Qualifications")) ? null : reader.GetString(reader.GetOrdinal("Qualifications")),
                ProfileDetails = reader.IsDBNull(reader.GetOrdinal("ProfileDetails")) ? null : reader.GetString(reader.GetOrdinal("ProfileDetails")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                PhoneNumber = reader.IsDBNull(reader.GetOrdinal("PhoneNumber")) ? null : reader.GetString(reader.GetOrdinal("PhoneNumber")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
