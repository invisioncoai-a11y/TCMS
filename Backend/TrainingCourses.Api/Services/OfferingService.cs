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
    public interface IOfferingService
    {
        Task<List<CourseOfferingDto>> GetAllOfferingsAsync();
        Task<CourseOfferingDto?> GetOfferingByIdAsync(int id);
        Task<List<CourseOfferingDto>> GetOfferingsByCourseAsync(int courseId);
        Task<List<CourseOfferingDto>> GetUpcomingOfferingsAsync();
        Task<int> CreateOfferingAsync(CreateOfferingDto dto);
        Task UpdateOfferingAsync(int id, UpdateOfferingDto dto);
        Task DeleteOfferingAsync(int id);
    }

    public class OfferingService : IOfferingService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;

        public OfferingService(IOracleDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<List<CourseOfferingDto>> GetAllOfferingsAsync()
        {
            return await ExecuteOfferingQuery("COURSEOFFERING_PACKAGE.GetAllOfferings", null);
        }

        public async Task<CourseOfferingDto?> GetOfferingByIdAsync(int id)
        {
            var results = await ExecuteOfferingQuery("COURSEOFFERING_PACKAGE.GetOfferingById", cmd =>
            {
                cmd.Parameters.Add("p_OfferingID", OracleDbType.Int32).Value = id;
            });
            return results.Count > 0 ? results[0] : null;
        }

        public async Task<List<CourseOfferingDto>> GetOfferingsByCourseAsync(int courseId)
        {
            return await ExecuteOfferingQuery("COURSEOFFERING_PACKAGE.GetOfferingsByCourse", cmd =>
            {
                cmd.Parameters.Add("p_CourseID", OracleDbType.Int32).Value = courseId;
            });
        }

        public async Task<List<CourseOfferingDto>> GetUpcomingOfferingsAsync()
        {
            return await ExecuteOfferingQuery("COURSEOFFERING_PACKAGE.GetUpcomingOfferings", null);
        }

        public async Task<int> CreateOfferingAsync(CreateOfferingDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "COURSEOFFERING_PACKAGE.CreateOffering";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_CourseID", OracleDbType.Int32).Value = dto.CourseID;
            cmd.Parameters.Add("p_TrainerID", OracleDbType.Int32).Value = dto.TrainerID;
            cmd.Parameters.Add("p_StartDate", OracleDbType.Date).Value = dto.StartDate;
            cmd.Parameters.Add("p_EndDate", OracleDbType.Date).Value = dto.EndDate;
            cmd.Parameters.Add("p_ScheduleDetails", OracleDbType.Varchar2).Value = dto.ScheduleDetails;
            cmd.Parameters.Add("p_MaxCapacity", OracleDbType.Int32).Value = dto.MaxCapacity;

            var outId = new OracleParameter("p_OfferingID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task UpdateOfferingAsync(int id, UpdateOfferingDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "COURSEOFFERING_PACKAGE.UpdateOffering";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_OfferingID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_CourseID", OracleDbType.Int32).Value = dto.CourseID;
            cmd.Parameters.Add("p_TrainerID", OracleDbType.Int32).Value = dto.TrainerID;
            cmd.Parameters.Add("p_StartDate", OracleDbType.Date).Value = dto.StartDate;
            cmd.Parameters.Add("p_EndDate", OracleDbType.Date).Value = dto.EndDate;
            cmd.Parameters.Add("p_ScheduleDetails", OracleDbType.Varchar2).Value = dto.ScheduleDetails;
            cmd.Parameters.Add("p_MaxCapacity", OracleDbType.Int32).Value = dto.MaxCapacity;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteOfferingAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "COURSEOFFERING_PACKAGE.DeleteOffering";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_OfferingID", OracleDbType.Int32).Value = id;

            await cmd.ExecuteNonQueryAsync();
        }

        private async Task<List<CourseOfferingDto>> ExecuteOfferingQuery(string procName, Action<OracleCommand>? configureParams)
        {
            var list = new List<CourseOfferingDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = procName;
            cmd.CommandType = CommandType.StoredProcedure;

            configureParams?.Invoke(cmd);
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CourseOfferingDto
                {
                    OfferingID = reader.GetInt32(reader.GetOrdinal("OfferingID")),
                    CourseID = reader.GetInt32(reader.GetOrdinal("CourseID")),
                    CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                    Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                    Duration = reader.GetInt32(reader.GetOrdinal("Duration")),
                    DeliveryMode = reader.GetString(reader.GetOrdinal("DeliveryMode")),
                    CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    TrainerID = reader.GetInt32(reader.GetOrdinal("TrainerID")),
                    TrainerName = reader.GetString(reader.GetOrdinal("TrainerName")),
                    TrainerSpecialization = reader.IsDBNull(reader.GetOrdinal("TrainerSpecialization")) ? null : reader.GetString(reader.GetOrdinal("TrainerSpecialization")),
                    TrainerEmail = reader.IsDBNull(reader.GetOrdinal("TrainerEmail")) ? null : reader.GetString(reader.GetOrdinal("TrainerEmail")),
                    StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                    EndDate = reader.GetDateTime(reader.GetOrdinal("EndDate")),
                    ScheduleDetails = reader.GetString(reader.GetOrdinal("ScheduleDetails")),
                    MaxCapacity = reader.GetInt32(reader.GetOrdinal("MaxCapacity")),
                    AvailableSeats = reader.GetInt32(reader.GetOrdinal("AvailableSeats")),
                    EnrolledCount = reader.GetInt32(reader.GetOrdinal("EnrolledCount")),
                    SeatStatus = reader.IsDBNull(reader.GetOrdinal("SeatStatus")) ? null : reader.GetString(reader.GetOrdinal("SeatStatus")),
                    IsUpcoming = reader.GetInt32(reader.GetOrdinal("IsUpcoming")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                });
            }
            return list;
        }
    }
}
