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
    public interface ICourseService
    {
        Task<List<CourseDto>> GetAllCoursesAsync();
        Task<CourseDto?> GetCourseByIdAsync(int id);
        Task<List<CourseDto>> GetFeaturedCoursesAsync();
        Task<List<CourseDto>> SearchAndFilterCoursesAsync(CourseSearchFilterDto filter);
        Task<int> CreateCourseAsync(CreateCourseDto dto);
        Task UpdateCourseAsync(int id, UpdateCourseDto dto);
        Task DeleteCourseAsync(int id);
    }

    public class CourseService : ICourseService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;

        public CourseService(IOracleDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<List<CourseDto>> GetAllCoursesAsync()
        {
            return await ExecuteCourseQuery("COURSE_PACKAGE.GetAllCourses", null);
        }

        public async Task<CourseDto?> GetCourseByIdAsync(int id)
        {
            var results = await ExecuteCourseQuery("COURSE_PACKAGE.GetCourseById", cmd =>
            {
                cmd.Parameters.Add("p_CourseID", OracleDbType.Int32).Value = id;
            });
            return results.Count > 0 ? results[0] : null;
        }

        public async Task<List<CourseDto>> GetFeaturedCoursesAsync()
        {
            return await ExecuteCourseQuery("COURSE_PACKAGE.GetFeaturedCourses", null);
        }

        public async Task<List<CourseDto>> SearchAndFilterCoursesAsync(CourseSearchFilterDto filter)
        {
            return await ExecuteCourseQuery("COURSE_PACKAGE.SearchAndFilterCourses", cmd =>
            {
                cmd.Parameters.Add("p_Search", OracleDbType.Varchar2).Value = (object?)filter.Search ?? DBNull.Value;
                cmd.Parameters.Add("p_CategoryID", OracleDbType.Int32).Value = (object?)filter.CategoryID ?? DBNull.Value;
                cmd.Parameters.Add("p_MinPrice", OracleDbType.Decimal).Value = (object?)filter.MinPrice ?? DBNull.Value;
                cmd.Parameters.Add("p_MaxPrice", OracleDbType.Decimal).Value = (object?)filter.MaxPrice ?? DBNull.Value;
                cmd.Parameters.Add("p_DeliveryMode", OracleDbType.Varchar2).Value = (object?)filter.DeliveryMode ?? DBNull.Value;
                cmd.Parameters.Add("p_SortBy", OracleDbType.Varchar2).Value = (object?)filter.SortBy ?? DBNull.Value;
            });
        }

        public async Task<int> CreateCourseAsync(CreateCourseDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "COURSE_PACKAGE.CreateCourse";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_CategoryID", OracleDbType.Int32).Value = dto.CategoryID;
            cmd.Parameters.Add("p_CourseName", OracleDbType.Varchar2).Value = dto.CourseName;
            cmd.Parameters.Add("p_Description", OracleDbType.Clob).Value = (object?)dto.Description ?? DBNull.Value;
            cmd.Parameters.Add("p_LearningObjectives", OracleDbType.Clob).Value = (object?)dto.LearningObjectives ?? DBNull.Value;
            cmd.Parameters.Add("p_Prerequisites", OracleDbType.Varchar2).Value = (object?)dto.Prerequisites ?? DBNull.Value;
            cmd.Parameters.Add("p_Price", OracleDbType.Decimal).Value = dto.Price;
            cmd.Parameters.Add("p_Duration", OracleDbType.Int32).Value = dto.Duration;
            cmd.Parameters.Add("p_DeliveryMode", OracleDbType.Varchar2).Value = dto.DeliveryMode;
            cmd.Parameters.Add("p_IsFeatured", OracleDbType.Int32).Value = dto.IsFeatured;

            var outId = new OracleParameter("p_CourseID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task UpdateCourseAsync(int id, UpdateCourseDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "COURSE_PACKAGE.UpdateCourse";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_CourseID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_CategoryID", OracleDbType.Int32).Value = dto.CategoryID;
            cmd.Parameters.Add("p_CourseName", OracleDbType.Varchar2).Value = dto.CourseName;
            cmd.Parameters.Add("p_Description", OracleDbType.Clob).Value = (object?)dto.Description ?? DBNull.Value;
            cmd.Parameters.Add("p_LearningObjectives", OracleDbType.Clob).Value = (object?)dto.LearningObjectives ?? DBNull.Value;
            cmd.Parameters.Add("p_Prerequisites", OracleDbType.Varchar2).Value = (object?)dto.Prerequisites ?? DBNull.Value;
            cmd.Parameters.Add("p_Price", OracleDbType.Decimal).Value = dto.Price;
            cmd.Parameters.Add("p_Duration", OracleDbType.Int32).Value = dto.Duration;
            cmd.Parameters.Add("p_DeliveryMode", OracleDbType.Varchar2).Value = dto.DeliveryMode;
            cmd.Parameters.Add("p_IsFeatured", OracleDbType.Int32).Value = dto.IsFeatured;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteCourseAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "COURSE_PACKAGE.DeleteCourse";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_CourseID", OracleDbType.Int32).Value = id;

            await cmd.ExecuteNonQueryAsync();
        }

        private async Task<List<CourseDto>> ExecuteCourseQuery(string procName, Action<OracleCommand>? configureParams)
        {
            var list = new List<CourseDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = procName;
            cmd.CommandType = CommandType.StoredProcedure;

            configureParams?.Invoke(cmd);
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CourseDto
                {
                    CourseID = reader.GetInt32(reader.GetOrdinal("CourseID")),
                    CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                    CategoryName = reader.IsDBNull(reader.GetOrdinal("CategoryName")) ? null : reader.GetString(reader.GetOrdinal("CategoryName")),
                    CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                    LearningObjectives = reader.IsDBNull(reader.GetOrdinal("LearningObjectives")) ? null : reader.GetString(reader.GetOrdinal("LearningObjectives")),
                    Prerequisites = reader.IsDBNull(reader.GetOrdinal("Prerequisites")) ? null : reader.GetString(reader.GetOrdinal("Prerequisites")),
                    Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                    Duration = reader.GetInt32(reader.GetOrdinal("Duration")),
                    DeliveryMode = reader.GetString(reader.GetOrdinal("DeliveryMode")),
                    IsFeatured = reader.GetInt32(reader.GetOrdinal("IsFeatured")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                    UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
                });
            }
            return list;
        }
    }
}
