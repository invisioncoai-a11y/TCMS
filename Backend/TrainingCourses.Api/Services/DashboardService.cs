using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Oracle.ManagedDataAccess.Client;
using TrainingCourses.Api.Data;
using TrainingCourses.Api.DTOs;

namespace TrainingCourses.Api.Services
{
    public interface IDashboardService
    {
        Task<DashboardKpiDto> GetDashboardKpisAsync();
        Task<List<CategoryChartDto>> GetCategoryChartAsync();
        Task<List<PopularCourseDto>> GetPopularCoursesAsync(int limit = 5);
    }

    public class DashboardService : IDashboardService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;

        public DashboardService(IOracleDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<DashboardKpiDto> GetDashboardKpisAsync()
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REPORTING_PACKAGE.GetDashboardKPIs";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new DashboardKpiDto
                {
                    TotalCourses = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalCourses"))),
                    TotalOfferings = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalOfferings"))),
                    TotalTrainers = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalTrainers"))),
                    TotalTrainees = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalTrainees"))),
                    TotalRegistrations = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalRegistrations"))),
                    ActiveOfferings = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("ActiveOfferings"))),
                    TotalRevenue = Convert.ToDecimal(reader.GetValue(reader.GetOrdinal("TotalRevenue")))
                };
            }
            return new DashboardKpiDto();
        }

        public async Task<List<CategoryChartDto>> GetCategoryChartAsync()
        {
            var list = new List<CategoryChartDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REPORTING_PACKAGE.GetRegistrationsByCategoryChart";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CategoryChartDto
                {
                    CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    RegistrationCount = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("RegistrationCount"))),
                    CourseCount = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("CourseCount")))
                });
            }
            return list;
        }

        public async Task<List<PopularCourseDto>> GetPopularCoursesAsync(int limit = 5)
        {
            var list = new List<PopularCourseDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "REPORTING_PACKAGE.GetPopularCourses";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_Limit", OracleDbType.Int32).Value = limit;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new PopularCourseDto
                {
                    CourseID = reader.GetInt32(reader.GetOrdinal("CourseID")),
                    CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                    CategoryName = reader.IsDBNull(reader.GetOrdinal("CategoryName")) ? null : reader.GetString(reader.GetOrdinal("CategoryName")),
                    Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                    Duration = reader.GetInt32(reader.GetOrdinal("Duration")),
                    DeliveryMode = reader.IsDBNull(reader.GetOrdinal("DeliveryMode")) ? null : reader.GetString(reader.GetOrdinal("DeliveryMode")),
                    TotalEnrollments = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalEnrollments"))),
                    TotalOfferings = Convert.ToInt32(reader.GetValue(reader.GetOrdinal("TotalOfferings")))
                });
            }
            return list;
        }
    }
}
