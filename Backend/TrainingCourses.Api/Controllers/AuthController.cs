using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _authService.LoginAsync(request);
            if (result == null)
            {
                return Unauthorized(new { message = "Invalid username or password, or account is disabled." });
            }

            return Ok(result);
        }

        [HttpGet("me")]
        [Authorize]
        public async Task<IActionResult> GetCurrentUser()
        {
            var adminIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (adminIdClaim == null || !int.TryParse(adminIdClaim.Value, out int adminId))
            {
                return Unauthorized();
            }

            var admin = await _authService.GetAdminByIdAsync(adminId);
            if (admin == null)
            {
                return NotFound();
            }

            return Ok(admin);
        }

        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var adminIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (adminIdClaim == null || !int.TryParse(adminIdClaim.Value, out int adminId))
            {
                return Unauthorized();
            }

            var success = await _authService.ChangePasswordAsync(adminId, dto);
            if (!success)
            {
                return BadRequest(new { message = "Current password was incorrect." });
            }

            return Ok(new { message = "Password successfully changed." });
        }

        [HttpPost("register-admin")]
        [Authorize]
        public async Task<IActionResult> RegisterAdmin([FromBody] CreateAdminDto dto)
        {
            var existing = await _authService.GetAdminByUsernameAsync(dto.Username);
            if (existing != null)
            {
                return Conflict(new { message = "An administrator with this username already exists." });
            }

            int newId = await _authService.CreateAdminAsync(dto);
            return CreatedAtAction(nameof(GetCurrentUser), new { id = newId }, new { adminId = newId, message = "Admin created." });
        }
    }
}
