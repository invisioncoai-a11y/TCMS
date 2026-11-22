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
    public interface ICategoryService
    {
        Task<List<CategoryDto>> GetAllCategoriesAsync();
        Task<CategoryDto?> GetCategoryByIdAsync(int id);
        Task<int> CreateCategoryAsync(CreateCategoryDto dto);
        Task UpdateCategoryAsync(int id, UpdateCategoryDto dto);
        Task DeleteCategoryAsync(int id);
    }

    public class CategoryService : ICategoryService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;

        public CategoryService(IOracleDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<List<CategoryDto>> GetAllCategoriesAsync()
        {
            var list = new List<CategoryDto>();
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "CATEGORY_PACKAGE.GetAllCategories";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CategoryDto
                {
                    CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                });
            }
            return list;
        }

        public async Task<CategoryDto?> GetCategoryByIdAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "CATEGORY_PACKAGE.GetCategoryById";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_CategoryID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new CategoryDto
                {
                    CategoryID = reader.GetInt32(reader.GetOrdinal("CategoryID")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                };
            }
            return null;
        }

        public async Task<int> CreateCategoryAsync(CreateCategoryDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "CATEGORY_PACKAGE.CreateCategory";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_CategoryName", OracleDbType.Varchar2).Value = dto.CategoryName;
            cmd.Parameters.Add("p_Description", OracleDbType.Varchar2).Value = (object?)dto.Description ?? DBNull.Value;
            var outId = new OracleParameter("p_CategoryID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task UpdateCategoryAsync(int id, UpdateCategoryDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "CATEGORY_PACKAGE.UpdateCategory";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_CategoryID", OracleDbType.Int32).Value = id;
            cmd.Parameters.Add("p_CategoryName", OracleDbType.Varchar2).Value = dto.CategoryName;
            cmd.Parameters.Add("p_Description", OracleDbType.Varchar2).Value = (object?)dto.Description ?? DBNull.Value;

            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteCategoryAsync(int id)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "CATEGORY_PACKAGE.DeleteCategory";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("p_CategoryID", OracleDbType.Int32).Value = id;

            await cmd.ExecuteNonQueryAsync();
        }
    }
}
