using System;
using System.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using TrainingCourses.Api.Data;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Models;

namespace TrainingCourses.Api.Services
{
    public interface IAuthService
    {
        Task<LoginResponseDto?> LoginAsync(LoginRequestDto request);
        Task<AdminDto?> GetAdminByIdAsync(int adminId);
        Task<AdminDto?> GetAdminByUsernameAsync(string username);
        Task<int> CreateAdminAsync(CreateAdminDto dto);
        Task<bool> ChangePasswordAsync(int adminId, ChangePasswordDto dto);
    }

    public class AuthService : IAuthService
    {
        private readonly IOracleDbConnectionFactory _connectionFactory;
        private readonly IConfiguration _config;

        public AuthService(IOracleDbConnectionFactory connectionFactory, IConfiguration config)
        {
            _connectionFactory = connectionFactory;
            _config = config;
        }

        public async Task<LoginResponseDto?> LoginAsync(LoginRequestDto request)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "ADMIN_PACKAGE.GetAdminByUsername";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_Username", OracleDbType.Varchar2).Value = request.Username;
            var outCursor = new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output);
            cmd.Parameters.Add(outCursor);

            Admin? admin = null;
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    admin = new Admin
                    {
                        AdminID = reader.GetInt32(reader.GetOrdinal("AdminID")),
                        Username = reader.GetString(reader.GetOrdinal("Username")),
                        PasswordHash = reader.GetString(reader.GetOrdinal("PasswordHash")),
                        PasswordSalt = reader.IsDBNull(reader.GetOrdinal("PasswordSalt")) ? null : reader.GetString(reader.GetOrdinal("PasswordSalt")),
                        Email = reader.GetString(reader.GetOrdinal("Email")),
                        FullName = reader.GetString(reader.GetOrdinal("FullName")),
                        IsActive = reader.GetInt32(reader.GetOrdinal("IsActive"))
                    };
                }
            }

            if (admin == null || admin.IsActive == 0)
            {
                return null;
            }

            if (!VerifyPassword(request.Password, admin.PasswordHash, admin.PasswordSalt))
            {
                return null;
            }

            // Update LastLogin timestamp
            using (var updateCmd = conn.CreateCommand())
            {
                updateCmd.CommandText = "UPDATE ADMINS SET LastLogin = SYSTIMESTAMP WHERE AdminID = :id";
                updateCmd.Parameters.Add("id", OracleDbType.Int32).Value = admin.AdminID;
                await updateCmd.ExecuteNonQueryAsync();
            }

            var token = GenerateJwtToken(admin, out DateTime expiresAt);

            return new LoginResponseDto
            {
                Token = token,
                AdminID = admin.AdminID,
                Username = admin.Username,
                FullName = admin.FullName,
                Email = admin.Email,
                ExpiresAt = expiresAt
            };
        }

        public async Task<AdminDto?> GetAdminByIdAsync(int adminId)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "ADMIN_PACKAGE.GetAdminById";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_AdminID", OracleDbType.Int32).Value = adminId;
            var outCursor = new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output);
            cmd.Parameters.Add(outCursor);

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new AdminDto
                {
                    AdminID = reader.GetInt32(reader.GetOrdinal("AdminID")),
                    Username = reader.GetString(reader.GetOrdinal("Username")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    FullName = reader.GetString(reader.GetOrdinal("FullName")),
                    IsActive = reader.GetInt32(reader.GetOrdinal("IsActive")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                    LastLogin = reader.IsDBNull(reader.GetOrdinal("LastLogin")) ? null : reader.GetDateTime(reader.GetOrdinal("LastLogin"))
                };
            }
            return null;
        }

        public async Task<AdminDto?> GetAdminByUsernameAsync(string username)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "ADMIN_PACKAGE.GetAdminByUsername";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_Username", OracleDbType.Varchar2).Value = username;
            var outCursor = new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output);
            cmd.Parameters.Add(outCursor);

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new AdminDto
                {
                    AdminID = reader.GetInt32(reader.GetOrdinal("AdminID")),
                    Username = reader.GetString(reader.GetOrdinal("Username")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    FullName = reader.GetString(reader.GetOrdinal("FullName")),
                    IsActive = reader.GetInt32(reader.GetOrdinal("IsActive")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                    LastLogin = reader.IsDBNull(reader.GetOrdinal("LastLogin")) ? null : reader.GetDateTime(reader.GetOrdinal("LastLogin"))
                };
            }
            return null;
        }

        public async Task<int> CreateAdminAsync(CreateAdminDto dto)
        {
            string salt = Guid.NewGuid().ToString("N");
            string hash = HashPassword(dto.Password, salt);

            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "ADMIN_PACKAGE.CreateAdmin";
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("p_Username", OracleDbType.Varchar2).Value = dto.Username;
            cmd.Parameters.Add("p_PasswordHash", OracleDbType.Varchar2).Value = hash;
            cmd.Parameters.Add("p_PasswordSalt", OracleDbType.Varchar2).Value = salt;
            cmd.Parameters.Add("p_Email", OracleDbType.Varchar2).Value = dto.Email;
            cmd.Parameters.Add("p_FullName", OracleDbType.Varchar2).Value = dto.FullName;

            var outId = new OracleParameter("p_AdminID", OracleDbType.Decimal, ParameterDirection.Output);
            cmd.Parameters.Add(outId);

            await cmd.ExecuteNonQueryAsync();
            return Convert.ToInt32(((OracleDecimal)outId.Value).Value);
        }

        public async Task<bool> ChangePasswordAsync(int adminId, ChangePasswordDto dto)
        {
            using var conn = await _connectionFactory.CreateConnectionAsync();
            using var getCmd = conn.CreateCommand();
            getCmd.CommandText = "ADMIN_PACKAGE.GetAdminById";
            getCmd.CommandType = CommandType.StoredProcedure;
            getCmd.Parameters.Add("p_AdminID", OracleDbType.Int32).Value = adminId;
            getCmd.Parameters.Add(new OracleParameter("p_Cursor", OracleDbType.RefCursor, ParameterDirection.Output));

            string? currentHash = null;
            string? currentSalt = null;

            using (var reader = await getCmd.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    currentHash = reader.GetString(reader.GetOrdinal("PasswordHash"));
                    currentSalt = reader.IsDBNull(reader.GetOrdinal("PasswordSalt")) ? null : reader.GetString(reader.GetOrdinal("PasswordSalt"));
                }
            }

            if (currentHash == null || !VerifyPassword(dto.CurrentPassword, currentHash, currentSalt))
            {
                return false;
            }

            string newSalt = Guid.NewGuid().ToString("N");
            string newHash = HashPassword(dto.NewPassword, newSalt);

            using var updateCmd = conn.CreateCommand();
            updateCmd.CommandText = "ADMIN_PACKAGE.UpdatePassword";
            updateCmd.CommandType = CommandType.StoredProcedure;
            updateCmd.Parameters.Add("p_AdminID", OracleDbType.Int32).Value = adminId;
            updateCmd.Parameters.Add("p_PasswordHash", OracleDbType.Varchar2).Value = newHash;
            updateCmd.Parameters.Add("p_PasswordSalt", OracleDbType.Varchar2).Value = newSalt;

            await updateCmd.ExecuteNonQueryAsync();
            return true;
        }

        private string GenerateJwtToken(Admin admin, out DateTime expiresAt)
        {
            var keyString = _config["Jwt:Key"] ?? "YOUR_STRONG_SECRET_KEY_MINIMUM_32_CHARACTERS_LONG!";
            var issuer = _config["Jwt:Issuer"] ?? "TrainingCoursesApi";
            var audience = _config["Jwt:Audience"] ?? "TrainingCoursesClient";
            var hours = int.TryParse(_config["Jwt:ExpiresHours"], out int h) ? h : 24;

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            expiresAt = DateTime.UtcNow.AddHours(hours);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, admin.AdminID.ToString()),
                new Claim(ClaimTypes.Name, admin.Username),
                new Claim(ClaimTypes.Email, admin.Email),
                new Claim("FullName", admin.FullName),
                new Claim(ClaimTypes.Role, "Admin")
            };

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: expiresAt,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private static string HashPassword(string password, string salt)
        {
            using var sha256 = SHA256.Create();
            var combined = Encoding.UTF8.GetBytes(password + ":" + salt);
            var hashBytes = sha256.ComputeHash(combined);
            return Convert.ToHexString(hashBytes).ToLowerInvariant();
        }

        private static bool VerifyPassword(string inputPassword, string storedHash, string? salt)
        {
// Standard cryptographic password verification

            if (string.IsNullOrEmpty(salt))
            {
                using var sha256 = SHA256.Create();
                var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(inputPassword));
                return string.Equals(storedHash, Convert.ToHexString(hashBytes), StringComparison.OrdinalIgnoreCase);
            }

            string computed = HashPassword(inputPassword, salt);
            return string.Equals(storedHash, computed, StringComparison.OrdinalIgnoreCase);
        }
    }
}
