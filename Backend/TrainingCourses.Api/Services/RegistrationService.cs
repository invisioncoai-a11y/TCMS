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
    public interface IRegistrationService
    {
        Task<List<RegistrationDto>> GetAllRegistrationsAsync();
        Task<RegistrationDto?> GetRegistrationByIdAsync(int id);
        Task<List<RegistrationDto>> GetRegistrationsByTraineeAsync(int traineeId);
        Task<List<RegistrationDto>> GetRegistrationsByEmailAsync(string email);
        Task<int> EnrollTraineeAsync(EnrollRequestDto dto);
        Task CancelRegistrationAsync(int id, string reason);
        Task UpdateStatusAsync(int id, string status);
        Task DeleteRegistrationAsync(int id);
    }

    public class RegistrationService : IRegistrationService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;
        private readonly ITraineeService _traineeService;

        public RegistrationService(IOracleDbConnectionFactory connectionFactory, ITraineeService traineeService)
        {
            _connectionFactory = connectionFactory;
            _traineeService = traineeService;
        }

        public async Task<List<RegistrationDto>> GetAllRegistrationsAsync()
        {
            return await ExecuteRegistrationQuery("REGISTRATION_PACKAGE.GetAllRegistrations", null);
        }

        public async Task<RegistrationDto?> GetRegistrationByIdAsync(int id)
        {
            var list = await ExecuteRegistrationQuery("REGISTRATION_PACKAGE.GetRegistrationById", cmd =>
            {
                cmd.Parameters.Add("p_RegistrationID", OracleDbType.Int32).Value = id;
            });
            return list.Count > 0 ? list[0] : null;
        }

        public async Task<List<RegistrationDto>> GetRegistrationsByTraineeAsync(int traineeId)
        {
            return await ExecuteRegistrationQuery("REGISTRATION_PACKAGE.GetRegistrationsByTrainee", cmd =>
            {
                cmd.Parameters.Add("p_TraineeID", OracleDbType.Int32).Value = traineeId;
            });
        }

        public async Task<List<RegistrationDto>> GetRegistrationsByEmailAsync(string email)
        {
            return await ExecuteRegistrationQuery("REGISTRATION_PACKAGE.GetRegistrationsByEmail", cmd =>
            {
                cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = email.Trim().ToLowerInvariant();
            });
        }

        public async Task<int> EnrollTraineeAsync(EnrollRequestDto dto)
        {
            // 1. Resolve or create Trainee
            var trainee = await _traineeService.GetTraineeByEmailAsync(dto.Email);
            int traineeId;
            if (trainee == null)
            {
                traineeId = await _traineeService.CreateTraineeAsync(new CreateTraineeDto
                {
                    FullName = dto.FullName,
                    Email = dto.Email,
                    PhoneNumber = dto.PhoneNumber,
                    EducationalBackground = dto.EducationalBackground
                });
            }
            else
            {
                traineeId = trainee.TraineeID;
            }

            // 2. Atomically register trainee in offering via PL/SQL package
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REGISTRATION_PACKAGE.RegisterTrainee";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_TraineeID", OracleDbType.Int32).Value = traineeId;
            cmd.Parameters.Add("p_OfferingID", OracleDbType.Int32).Value = dto.OfferingID;
            cmd.Parameters.Add("p_Status", OracleDbType.Varchar2).Value = "Confirmed";

            var outId = new OracleParameter("p_RegistrationID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task CancelRegistrationAsync(int id, string reason)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REGISTRATION_PACKAGE.CancelRegistration";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_RegistrationID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_Reason", OracleDbType.Varchar2).Value = reason;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task UpdateStatusAsync(int id, string status)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REGISTRATION_PACKAGE.UpdateRegistrationStatus";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_RegistrationID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_Status", OracleDbType.Varchar2).Value = status;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteRegistrationAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REGISTRATION_PACKAGE.DeleteRegistration";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_RegistrationID", OracleDbType.Int32).Value = id;

            await cmd.ExecuteNonQueryAsync();
        }

        private async Task<List<RegistrationDto>> ExecuteRegistrationQuery(string procName, Action<OracleCommand>? configureParams)
        {
            var list = new List<RegistrationDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = procName;
            cmd.CommandType = CommandType.StoredProcedure;

            configureParams?.Invoke(cmd);
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new RegistrationDto
                {
                    RegistrationID = reader.GetInt32(reader.GetOrdinal("RegistrationID")),
                    TraineeID = reader.GetInt32(reader.GetOrdinal("TraineeID")),
                    TraineeName = reader.GetString(reader.GetOrdinal("TraineeName")),
                    TraineeEmail = reader.GetString(reader.GetOrdinal("TraineeEmail")),
                    TraineePhone = reader.GetString(reader.GetOrdinal("TraineePhone")),
                    EducationalBackground = reader.IsDBNull(reader.GetOrdinal("EducationalBackground")) ? null : reader.GetString(reader.GetOrdinal("EducationalBackground")),
                    OfferingID = reader.GetInt32(reader.GetOrdinal("OfferingID")),
                    CourseID = reader.GetInt32(reader.GetOrdinal("CourseID")),
                    CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                    Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                    DeliveryMode = reader.GetString(reader.GetOrdinal("DeliveryMode")),
                    TrainerID = reader.GetInt32(reader.GetOrdinal("TrainerID")),
                    TrainerName = reader.GetString(reader.GetOrdinal("TrainerName")),
                    StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                    EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                    ScheduleDetails = reader.GetString(reader.GetOrdinal("ScheduleDetails")),
                    RegistrationDate = reader.GetDateTime(reader.GetOrdinal("RegistrationDate")),
                    Status = reader.GetString(reader.GetOrdinal("Status")),
                    CancellationReason = reader.IsDBNull(reader.GetOrdinal("CancellationReason")) ? null : reader.GetString(reader.GetOrdinal("CancellationReason")),
                    CancellationDate = reader.IsDBNull(reader.GetOrdinal("CancellationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("CancellationDate")),
                    IsCancellable = reader.GetInt32(reader.GetOrdinal("IsCancellable")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                });
            }
            return list;
        }
    }
}
